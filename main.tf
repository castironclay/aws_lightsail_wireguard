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
