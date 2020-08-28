#!/bin/bash
# Clean up and set vars for destroy
unset TF_VAR_SERVER_PRIVATEKEY
unset TF_VAR_SERVER_PUBLICKEY
unset TF_VAR_CLIENT_PRIVATEKEY
unset TF_VAR_CLIENT_PUBLICKEY
export TF_VAR_SERVER_PRIVATEKEY=$(cat server_privatekey)
export TF_VAR_SERVER_PUBLICKEY=$(cat server_publickey)
export TF_VAR_CLIENT_PRIVATEKEY=$(cat client_privatekey)
export TF_VAR_CLIENT_PUBLICKEY=$(cat client_publickey)

# Destroy Infrastructure
terraform destroy -auto-approve
rm -rf server_privatekey client_privatekey server_publickey client_publickey id_rsa
