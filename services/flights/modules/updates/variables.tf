variable "source_path" {
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

variable "departures_table_name" {
  type = string
}

variable "arrivals_table_name" {
  type = string
}

locals {
  lambda_name = "update"
}
