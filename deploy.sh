#!/bin/bash
umask 077
wg genkey | tee server_privatekey | wg pubkey > server_publickey
wg genkey | tee client_privatekey | wg pubkey > client_publickey
terraform apply -auto-approve
terraform output private_key > id_rsa
chmod u+x id_rsa
chmod 600 id_rsa
