variable "source_path" {
  type = string
}

variable "prefix" {
  type = string
}

variable "sqs_queue_arn" {
  type = string
}

variable "table_arn" {
  type = string
}

variable "table_name" {
  type = string
}

locals {
  lambda_name = "update"
}
