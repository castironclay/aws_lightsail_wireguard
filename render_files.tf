data "template_file" "client_config" {
  template = file("${path.module}/source_files/wg0-client.conf")

  vars = {
    WG_CLIENT_PRIVATE_KEY = var.CLIENT_PRIVATEKEY
    WG_SERVER_PUBLIC_KEY  = var.SERVER_PUBLICKEY
    SERVER_IP             = aws_lightsail_instance.wireguard.public_ip_address
    SERVER_PORT           = random_integer.wg_port.result
  }
}

variable "SERVER_PRIVATEKEY" {}
variable "SERVER_PUBLICKEY" {}
variable "CLIENT_PRIVATEKEY" {}
variable "CLIENT_PUBLICKEY" {}

