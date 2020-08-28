resource "aws_lightsail_instance" "wireguard" {
  name              = "Wireguard"
  availability_zone = "us-east-1a"
  blueprint_id      = "ubuntu_18_04"
  bundle_id         = "micro_2_0"
  key_pair_name     = aws_lightsail_key_pair.key.name
  depends_on        = [aws_lightsail_key_pair.key]
  provisioner "local-exec" {
    command = "aws lightsail put-instance-public-ports --instance-name ${aws_lightsail_instance.wireguard.name} --port-infos fromPort=${random_integer.wg_port.result},toPort=${random_integer.wg_port.result},protocol=udp fromPort=22,toPort=22,protocol=tcp"
  }
}


