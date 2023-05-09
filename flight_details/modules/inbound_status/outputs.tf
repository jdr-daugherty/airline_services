output "table_arn" {
  value = module.table.arn
}

output "table_name" {
  value = module.table.name
}

output "lambda_arn" {
  value = module.lambda_function.lambda_function_arn
}

output "lambda_name" {
  value = module.lambda_function.lambda_function_name
}