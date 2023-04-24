output "table_arn" {
  value = module.table.arn
}

output "table_name" {
  value = module.table.name
}

output "lambda_arn" {
  value = module.lambda_getter.arn
}

output "lambda_name" {
  value = module.lambda_getter.name
}