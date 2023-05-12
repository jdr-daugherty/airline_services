variable "rest_api_id" {
  type = string
}

variable "rest_api_root_resource_id" {
  type = string
}

variable "rest_api_execution_arn" {
  type = string
}

variable "service_prefix" {
  type = string
}

locals {
  prefix = "${var.service_prefix}-flights"

  lambda_source_path = "${path.module}/lambdas"
  lambda_zip_path    = "${path.module}/lambdas/packages"

  update_queue_enabled = false
}