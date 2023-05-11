variable "source_path" {
  type = string
}

variable "zip_path" {
  type = string
}

variable "prefix" {
  type = string
}

variable "rest_api_id" {
  type = string
}

variable "rest_api_root_resource_id" {
  type = string
}

variable "rest_api_execution_arn" {
  type = string
}

locals {
  lambda_name = "requests"
}
