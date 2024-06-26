# Declare Provider
provider "aws" {
  region = "us-east-1"
  }

resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}