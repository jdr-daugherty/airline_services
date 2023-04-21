provider "aws" {
  region = "us-east-2"

  default_tags {
    tags = {
      creator    = "john.rothe@daugherty.com"
      created_at = formatdate("YYYY-MM-DD", timestamp())
      Terraform  = true
    }
  }
}