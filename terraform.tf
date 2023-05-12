terraform {
  #  backend "s3" {
  #    dynamodb_table = ""
  #  }

  required_providers {
    archive = {
      version = "~> 2.0"
      source  = "hashicorp/archive"
    }

    aws = {
      version = "~> 4.0"
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-east-2"

  default_tags {
    tags = {
      project_owner = "john.rothe@daugherty.com"
      deployer      = "Terraform"
    }
  }
}