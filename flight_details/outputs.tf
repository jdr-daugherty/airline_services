locals {
  invoke_url      = aws_api_gateway_deployment.default_deployment.invoke_url
  example_details = "flight-details?flight_number=711&departure_location=ATL&departure_date=2023-02-15"
  example_inbound = "inbound-flight?tail=N1234&arrival_location=DAL&arrival_date=2023-02-15"
}

output "gateway_url" {
  value = local.invoke_url
}

output "example_urls" {
  value = [
    "${local.invoke_url}/${local.example_details}",
    "${local.invoke_url}/${local.example_inbound}"
  ]
}