#!/bin/bash
# Clean up and set vars for destroy

unset TF_VAR_SERVER_PRIVATEKEY
unset TF_VAR_SERVER_PUBLICKEY
unset TF_VAR_ROUTER_PRIVATEKEY
unset TF_VAR_ROUTER_PUBLICKEY
unset TF_VAR_PHONE_PRIVATEKEY
unset TF_VAR_PHONE_PUBLICKEY
export TF_VAR_SERVER_PRIVATEKEY=$(cat keys/server_privatekey)
export TF_VAR_SERVER_PUBLICKEY=$(cat keys/server_publickey)
export TF_VAR_ROUTER_PRIVATEKEY=$(cat keys/router_privatekey)
export TF_VAR_ROUTER_PUBLICKEY=$(cat keys/router_publickey)
export TF_VAR_PHONE_PRIVATEKEY=$(cat keys/phone_privatekey)
export TF_VAR_PHONE_PUBLICKEY=$(cat keys/phone_publickey)

# Destroy Infrastructure
terraform destroy -auto-approve
rm -rf keys config keys/wireguard_ecds
