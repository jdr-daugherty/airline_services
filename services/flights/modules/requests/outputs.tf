output "arrival_table_arn" {
  value = module.arrivals_table.arn
}

output "arrival_table_name" {
  value = module.arrivals_table.name
}

output "departure_table_arn" {
  value = module.departures_table.arn
}

output "departure_table_name" {
  value = module.departures_table.name
}

output "lambda_arn" {
  value = module.request_handler.lambda_function_arn
}

output "lambda_name" {
  value = module.request_handler.lambda_function_name
}