locals {
  invoke_url      = aws_api_gateway_deployment.default_deployment.invoke_url
  sample_flight_status = "flight-status?flight_number=5420&departure_location=MEM&departure_date=2022-05-18"
  sample_Inbound_flight = "inbound-flight?tail=N1234&arrival_location=DAL&arrival_date=2023-02-15"
}

output "flight_status_table_name" {
  value = module.flight_status.table_name
}

output "flight_status_table_arn" {
  value = module.flight_status.table_arn
}

output "inbound_flight_table_name" {
  value = module.inbound_flight.table_name
}

output "inbound_flight_table_arn" {
  value = module.inbound_flight.table_arn
}

output "gateway_url" {
  value = local.invoke_url
}

output "example_urls" {
  value = [
    "${local.invoke_url}/${local.sample_flight_status}",
    "${local.invoke_url}/${local.sample_Inbound_flight}"
  ]
}