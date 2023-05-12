variable "source_path" {

}

variable "zip_path" {

}

variable "lambda_name" {

}

variable "prefix" {

}

variable "sqs_queue_arn" {

}

variable "execution_role_arn" {

}

locals {
  zip_file_location = "${var.zip_path}/${var.lambda_name}.zip"
  source_file = "${var.source_path}/${var.lambda_name}/lambda_function.py"
  full_function_name = "${var.prefix}-${replace(var.lambda_name, "_", "-")}"
}