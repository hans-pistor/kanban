
output "ssh_commands" {
  value = {
    for idx, instance in aws_instance.my_swarm :
    format("node_%d", idx + 1) => format("ssh -i %s ec2-user@%s", var.private_key_path, instance.public_ip)
  }
  description = "The SSH command to connect to the instances"
}

output "private_key" {
  value       = local_sensitive_file.private_key.content
  sensitive   = true
  description = "The SSH private key to connect to the instance"
}
