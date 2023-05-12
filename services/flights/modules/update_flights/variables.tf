variable "source_path" {
  type = string
}

variable "zip_path" {
  type = string
}

variable "prefix" {
  type = string
}

variable "sqs_queue_arn" {
  type = string
}

variable "table_arn_list" {
  type = list(string)
}

locals {
  lambda_name = "update-flights"
}
