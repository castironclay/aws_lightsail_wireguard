output "public_ip" {
  value = aws_lightsail_instance.wireguard.*.public_ip_address
}

output "private_key" {
  value     = tls_private_key.key.private_key_pem
  sensitive = true
}

output "username" {
  value = aws_lightsail_instance.wireguard.*.username
}

output "port" {
  value = random_integer.wg_port.result
}
