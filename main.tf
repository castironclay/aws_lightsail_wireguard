provider "random" {}
provider "template" {}
provider "null" {}
provider "aws" {
  region = "us-east-1"
}

provider "tls" {}

locals {
  # How many instances would you like?
  count = 2
}
