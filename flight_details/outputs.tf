locals {
  invoke_url            = aws_api_gateway_deployment.default_deployment.invoke_url
  flights_by_departure  = "flights/by-departure?flight_number=5420&departure_code=MEM&departure_date=2022-05-18"
  flights_by_arrival = "flights/by-arrival?tail=N413WN&arrival_code=DAL&arrival_date=2022-05-18"
}

output "by_departure_table_name" {
  value = module.requests.departure_table_name
}

output "by_departure_table_arn" {
  value = module.requests.departure_table_arn
}

output "by_arrival_table_name" {
  value = module.requests.arrival_table_name
}

output "by_arrival_table_arn" {
  value = module.requests.arrival_table_arn
}

output "gateway_url" {
  value = local.invoke_url
}

output "example_urls" {
  value = [
    "${local.invoke_url}/${local.flights_by_departure}",
    "${local.invoke_url}/${local.flights_by_arrival}"
  ]
}