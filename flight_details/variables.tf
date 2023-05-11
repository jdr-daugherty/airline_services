variable "environment" {
  description = "The name name of the environment (e.g. prod, qa1, dev-blue)."
  type    = string
  default = "dev-blue"
}

variable "namespace" {
  description = "The global namespace name used as the prefix for all infrastructure names."
  type    = string
  default = "airline"
}

locals {
  prefix       = "${var.namespace}-${var.environment}-flights"

  lambda_source_path = "${path.module}/lambdas"
  lambda_zip_path    = "${path.module}/lambdas/packages"

  update_queue_enabled = false
}