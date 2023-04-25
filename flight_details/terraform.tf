provider "aws" {
  region = "us-east-2"

  default_tags {
    tags = {
      creator   = "john.rothe@daugherty.com"
      Terraform = true
    }
  }
}