#!/bin/bash

plugins=(
	"github-cli"
	"packer"
	"terraform"
	"awscli"
	"elixir"
	"erlang"
	"postgres"
	"jq"
	"age"
	"sops"
)

for plugin in "${plugins[@]}"; do
	echo "Installing $plugin"
	asdf plugin-add "$plugin" || true
done
