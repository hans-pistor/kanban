#!/bin/bash
CURRENT_SCRIPT_DIRECTRORY=$(dirname "$0")
SECRETS_DIRECTORY=$CURRENT_SCRIPT_DIRECTRORY/../secrets

decrypted_content=$(sops --decrypt $SECRETS_DIRECTORY/secrets.enc.yaml)

echo "${decrypted_content}" | while IFS=: read -r filename value; do
    # trim any leading space from value
    content=$(echo "$value" | xargs)
    # write the content to the corresponding file in the secrets folder
    echo "${content}" > "$SECRETS_DIRECTORY/${filename}"
done