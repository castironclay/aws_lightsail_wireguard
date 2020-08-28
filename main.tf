provider "random" {}
provider "template" {}
provider "null" {}
provider "tls" {}

provider "aws" {
  region = "us-east-1"
}

resource "random_integer" "wg_port" {
  min = 20000
  max = 60000
}

locals {
  name    = "Wireguard"
  AZ      = "us-east-1a"
  OS      = "ubuntu_18_04"
  Size    = "micro_2_0"
  KeySize = 4096
}
