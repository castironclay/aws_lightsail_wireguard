resource "tls_private_key" "key" {
  algorithm   = "RSA"
	rsa_bits    = local.KeyBits
}

resource "aws_lightsail_key_pair" "key" {
  name       = "${local.name}-key"
  public_key = tls_private_key.key.public_key_openssh
  depends_on = [tls_private_key.key]
}
