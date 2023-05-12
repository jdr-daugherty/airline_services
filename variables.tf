variable "environment" {
  description = "The name name of the environment (e.g. prod, qa1, dev-blue)."
  type        = string
  default     = "dev-blue"
}

variable "namespace" {
  description = "The global namespace name used as the prefix for all infrastructure names."
  type        = string
  default     = "airline"
}

locals {
  service_prefix = "${var.namespace}-${var.environment}"
}