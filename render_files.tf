data "template_file" "router_config" {
  template = file("${path.module}/source_files/wg0-router.conf")

  vars = {
    WG_CLIENT_PRIVATE_KEY = var.ROUTER_PRIVATEKEY
    WG_SERVER_PUBLIC_KEY  = var.SERVER_PUBLICKEY
    SERVER_IP             = aws_lightsail_instance.wireguard.public_ip_address
    SERVER_PORT           = random_integer.wg_port.result
  }
}

data "template_file" "phone_config" {
  template = file("${path.module}/source_files/wg0-phone.conf")

  vars = {
    WG_CLIENT_PRIVATE_KEY = var.PHONE_PRIVATEKEY
    WG_SERVER_PUBLIC_KEY  = var.SERVER_PUBLICKEY
    SERVER_IP             = aws_lightsail_instance.wireguard.public_ip_address
    SERVER_PORT           = random_integer.wg_port.result
  }
}

data "template_file" "cloud_init" {
  template = file("${path.module}/source_files/config.sh")

  vars = {
    WG_PKEY               = var.SERVER_PRIVATEKEY
    SERVER_LINK_IPADDRESS = "10.200.200.1"
    LINK_NETMASK          = "24"
    NET_PORT              = random_integer.wg_port.result
    ROUTER_ALLOWED_IPS    = "10.200.200.2/32"
    PHONE_ALLOWED_IPS     = "10.200.200.4/32"
    ROUTER_KEY            = var.ROUTER_PUBLICKEY
    PHONE_KEY             = var.PHONE_PUBLICKEY
    WG_NETWORK            = "10.200.200.0"
  }
}
