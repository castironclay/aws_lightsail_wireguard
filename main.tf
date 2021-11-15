provider "random" {}
provider "template" {}
provider "null" {}
provider "tls" {}

provider "aws" {
  region = "us-west-2"
  shared_credentials_file = "~/.aws/credentials"
	profile = "terraform"
}

resource "random_integer" "wg_port" {
  min = 20000
  max = 60000
}

locals {
  name     = "lightsail-wireguard"
  AZ       = "us-west-2a"
  OS       = "ubuntu_20_04"
  Size     = "nano_2_0"
  KeyBits  = "4096"
}
