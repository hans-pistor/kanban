
locals {
  init_script = file("${path.module}/scripts/initialize.sh")
  manager_tag = "docker-swarm-manager"
  join_script = templatefile("${path.module}/scripts/join.sh", {
    manager_tag = local.manager_tag,
    region      = var.region
  })
}

data "aws_vpc" "main" {
  filter {
    name   = "isDefault"
    values = ["true"]
  }
}

data "aws_subnets" "main_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
}

data "aws_ami" "amazon_linux_docker" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amazon-linux-docker*"]
  }

  owners = ["647664114478"]
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "local_sensitive_file" "private_key" {
  filename        = var.private_key_path
  content         = tls_private_key.rsa.private_key_openssh
  file_permission = "0400"
}

resource "aws_key_pair" "deployer_key" {
  key_name   = "swarm-key"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "aws_instance" "my_swarm" {
  depends_on           = [aws_ssm_parameter.swarm_token]
  ami                  = data.aws_ami.amazon_linux_docker.id
  count                = var.number_of_nodes
  iam_instance_profile = aws_iam_instance_profile.main_profile.name
  instance_type        = "t2.micro"
  key_name             = aws_key_pair.deployer_key.key_name
  subnet_id = data.aws_subnets.main_subnets.ids[
    # Hacky way to work  around us-west-2d not having any t2.micro
    # instances. Will break for count > 3
    (count.index + 2) % length(data.aws_subnets.main_subnets.ids)
  ]
  vpc_security_group_ids = [
    aws_security_group.swarm_sg.id
  ]
  user_data = count.index == 0 ? local.init_script : local.join_script
  tags = {
    Name = local.manager_tag
  }
  lifecycle {
    ignore_changes = [tags]
  }
}



resource "aws_security_group" "swarm_sg" {
  description = "Swarm SG"
  vpc_id      = data.aws_vpc.main.id

  egress {
    description = "Egress"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Phoenix application"
    from_port   = 4000
    to_port     = 4000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Docker swarm management"
    from_port   = 2377
    to_port     = 2377
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.main.cidr_block]
  }
  ingress {
    description = "Docker container network discovery (tcp)"
    from_port   = 7946
    to_port     = 7946
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.main.cidr_block]
  }

  ingress {
    description = "Docker container network discovery (udp)"
    from_port   = 7946
    to_port     = 7946
    protocol    = "udp"
    cidr_blocks = [data.aws_vpc.main.cidr_block]
  }
  ingress {
    description = "Docker overlay network"
    from_port   = 4789
    to_port     = 4789
    protocol    = "udp"
    cidr_blocks = [data.aws_vpc.main.cidr_block]
  }

  name                   = "swarm-pool-ports"
  revoke_rules_on_delete = false
}

resource "aws_ssm_parameter" "swarm_token" {
  name        = "/docker/swarm_manager_token"
  description = "The swarm manager join token"
  type        = "SecureString"
  value       = "NONE"
  lifecycle {
    ignore_changes = [value]
  }
}

resource "null_resource" "wait_for_swarm_ready_tag" {
  depends_on = [aws_instance.my_swarm]
  provisioner "local-exec" {
    environment = {
      AWS_REGION           = var.region
      INSTANCE_MANAGER_TAG = local.manager_tag
    }
    command = "bash ../../scripts/wait_for_swarm_ready_tag.sh"
  }
}

resource "null_resource" "swarm_provisioner" {
  depends_on = [null_resource.wait_for_swarm_ready_tag]
  provisioner "local-exec" {
    environment = {
      GITHUB_USER           = var.gh_owner
      GITHUB_TOKEN          = var.gh_pat
      AWS_SECRET_ACCESS_KEY = var.aws_secret_access_key
      AWS_ACCESS_KEY_ID     = var.aws_access_key_id
      PRIVATE_KEY_PATH      = var.private_key_path
      SOPS_AGE_KEY_FILE     = var.age_key_path
      COMPOSE_FILE_PATH     = var.compose_file
      WEB_REPLICAS          = length(aws_instance.my_swarm)
    }
    command = "bash ../../scripts/deploy.sh ${var.image_to_deploy}"
  }

}
