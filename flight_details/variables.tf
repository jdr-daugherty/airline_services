variable "environment" {
  type    = string
  default = "dev-blue"
}

variable "namespace" {
  type    = string
  default = "airline"
}

locals {
  service_name = "flights"
  prefix       = "${var.namespace}-${var.environment}-${local.service_name}"

  lambda_source_path = "${path.module}/lambdas"
  lambda_zip_path    = "${path.module}/lambdas/packages"

  update_queue_enabled = false
}