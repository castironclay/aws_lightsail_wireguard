resource "aws_lightsail_instance" "wireguard" {
  count             = local.count
  name              = "Wireguard-${count.index}"
  availability_zone = "us-east-1a"
  blueprint_id      = "ubuntu_18_04"
  bundle_id         = "micro_2_0"
  key_pair_name     = aws_lightsail_key_pair.key.name
  depends_on        = [aws_lightsail_key_pair.key]
}

resource "aws_lightsail_key_pair" "key" {
  name       = "SSH_Key"
  public_key = tls_private_key.key.public_key_openssh
  depends_on = [tls_private_key.key]
}
