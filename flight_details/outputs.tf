locals {
  invoke_url      = aws_api_gateway_deployment.default_deployment.invoke_url
  sample_flight_status = "by-departure?flight_number=5420&departure_code=MEM&departure_date=2022-05-18"
  sample_inbound_flight = "by-arrival?tail=N413WN&arrival_code=DAL&arrival_date=2022-05-18"
}

output "by_departure_table_name" {
  value = module.by_departure.table_name
}

output "by_departure_table_arn" {
  value = module.by_departure.table_arn
}

output "by_arrival_table_name" {
  value = module.by_arrival.table_name
}

output "by_arrival_table_arn" {
  value = module.by_arrival.table_arn
}

output "gateway_url" {
  value = local.invoke_url
}

output "example_urls" {
  value = [
    "${local.invoke_url}/${local.sample_flight_status}",
    "${local.invoke_url}/${local.sample_inbound_flight}"
  ]
}