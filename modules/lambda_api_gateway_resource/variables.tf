variable "rest_api_id" {
  description = "ID of the REST API"
  type        = string
}

variable "rest_api_root_resource_id" {
  description = "Resource ID of the REST API's root"
  type        = string
}

variable "invoke_arn" {
  description = "ARN to be used for invoking Lambda Function from API Gateway - to be used in aws_api_gateway_integration's uri."
  type        = string
}

variable "http_method" {
  description = "HTTP Method (GET, POST, PUT, DELETE, HEAD, OPTIONS, ANY)"
  type        = string
}

variable "parent_path" {
  description = "The name of the resource that will be created as a parent for the lambda. For example: /stage_name/parent_path/path_part"
  type        = string
}

variable "path_part" {
  description = "The name of the resource that will be created for the lambda. For example: /stage_name/parent_path/path_part"
  type        = string
}