# The system pushes an update every time a flight is created or modified.
# At peak times, several thousand updates can occur each minute.
resource "aws_sqs_queue" "flight_details_relay_queue" {
  name       = "${local.prefix}-relay.fifo"
  fifo_queue = true
}

resource "aws_api_gateway_rest_api" "services_gateway" {
  name = "${var.namespace}-${var.environment}-gateway"
}

module "flight_details_resource" {
  source = "../modules/apigw_lambda_resource"

  rest_api_id        = aws_api_gateway_rest_api.services_gateway.id
  parent_resource_id = aws_api_gateway_rest_api.services_gateway.root_resource_id
  http_method        = "GET"
  invoke_arn         = aws_lambda_function.get_details_lambda.invoke_arn
  path_part          = "flight-details"
}

module "inbound_flight_resource" {
  source = "../modules/apigw_lambda_resource"

  rest_api_id        = aws_api_gateway_rest_api.services_gateway.id
  parent_resource_id = aws_api_gateway_rest_api.services_gateway.root_resource_id
  http_method        = "GET"
  invoke_arn         = aws_lambda_function.get_inbound_lambda.invoke_arn
  path_part          = "inbound-flight"
}

resource "aws_api_gateway_deployment" "default_deployment" {
  depends_on = [
    module.flight_details_resource,
    module.inbound_flight_resource
  ]

  rest_api_id = aws_api_gateway_rest_api.services_gateway.id
  stage_name  = "v1"
}