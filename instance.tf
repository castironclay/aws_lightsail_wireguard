resource "aws_lightsail_instance" "wireguard" {
  name              = local.name
  availability_zone = local.AZ
  blueprint_id      = local.OS
  bundle_id         = local.Size
  key_pair_name     = aws_lightsail_key_pair.key.name
  depends_on        = [aws_lightsail_key_pair.key]
  user_data         = data.template_file.cloud_init.rendered

  provisioner "local-exec" {
    command = "aws lightsail put-instance-public-ports --instance-name ${aws_lightsail_instance.wireguard.name} --port-infos fromPort=${random_integer.wg_port.result},toPort=${random_integer.wg_port.result},protocol=udp fromPort=22,toPort=22,protocol=tcp"
  }
}


