resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_lightsail_key_pair" "key" {
  name       = "SSH_Key"
  public_key = tls_private_key.key.public_key_openssh
  depends_on = [tls_private_key.key]
}
