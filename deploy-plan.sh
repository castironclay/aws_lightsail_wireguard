#!/bin/bash

if ! [ -x "$(command -v wg)" ]; then
	echo "ERROR: WireGuard is not installed." >&2
	exit 1
fi

# Create keys
umask 077
mkdir -v keys
wg genkey | tee keys/server_privatekey | wg pubkey > keys/server_publickey
wg genkey | tee keys/router_privatekey | wg pubkey > keys/router_publickey
wg genkey | tee keys/phone_privatekey | wg pubkey > keys/phone_publickey

# Setup vars for Terraform interpolation
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

# Deploy infrastructure
terraform init
terraform plan
#terraform apply -auto-approve
#terraform output private_key > keys/wireguard_ecdsa
#chmod u+x keys/wireguard_ecdsa
#chmod 600 keys/wireguard_ecdsa
#mkdir -v config
#terraform output router_config > config/wg0-router.conf
#terraform output phone_config > config/wg0-phone.conf

