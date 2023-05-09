variable "environment" {
  type    = string
  default = "dev"
}

variable "namespace" {
  type    = string
  default = "rothe"
}

locals {
  service_name = "flight"
  prefix       = "${var.namespace}-${var.environment}-${local.service_name}"

  lambda_source_path = "${path.module}/lambdas"
  lambda_zip_path    = "${path.module}/lambdas/packages"
}