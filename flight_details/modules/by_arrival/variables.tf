variable "source_path" {
  type = string
}

variable "zip_path" {
  type = string
}

variable "prefix" {
  type = string
}

variable "api_id" {
  type = string
}

variable "api_parent_resource_id" {
  type = string
}

variable "api_execution_arn" {
  type = string
}

locals {
  lambda_name = "by-arrival"
}
