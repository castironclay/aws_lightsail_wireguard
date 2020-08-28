#!/bin/bash
terraform destroy -auto-approve
rm -rf server_privatekey client_privatekey server_publickey client_publickey id_rsa
