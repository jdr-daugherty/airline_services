output "lambda_arn" {
  value = module.request_handler.lambda_function_arn
}

output "lambda_name" {
  value = module.request_handler.lambda_function_name
}