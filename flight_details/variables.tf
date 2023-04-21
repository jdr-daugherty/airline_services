variable "environment" {
  type    = string
  default = "dev"
}

variable "namespace" {
  type    = string
  default = "rothe-mob"
}

locals {
  service_name = "flight-details"
  prefix       = "${var.namespace}-${var.environment}-${local.service_name}"
}