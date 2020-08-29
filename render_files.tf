data "template_file" "client_config" {
  template = file("${path.module}/source_files/wg0-client.conf")

  vars = {
    WG_CLIENT_PRIVATE_KEY = var.CLIENT_PRIVATEKEY
    WG_SERVER_PUBLIC_KEY  = var.SERVER_PUBLICKEY
    SERVER_IP             = aws_lightsail_instance.wireguard.public_ip_address
    SERVER_PORT           = random_integer.wg_port.result
  }
}

data "template_file" "cloud_init" {
  template = file("${path.module}/source_files/config.sh")

  vars = {
    WG_PKEY               = var.SERVER_PRIVATEKEY
    SERVER_LINK_IPADDRESS = "10.1.2.1"
    LINK_NETMASK          = "24"
    NET_PORT              = random_integer.wg_port.result
    PEER_ALLOWED_IPS      = "10.2.1.2/32"
    PEER_KEY              = var.CLIENT_PUBLICKEY
    WG_NETWORK            = "10.1.2.0"
  }
}
