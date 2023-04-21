# The system pushes an update every time a flight is created or modified.
# At peak times, several thousand updates can occur each minute.
resource "aws_sqs_queue" "flight_details_relay_queue" {
  name       = "${local.prefix}-relay.fifo"
  fifo_queue = true
}

resource "aws_api_gateway_rest_api" "services_gateway" {
  name = "${var.namespace}-${var.environment}-gateway"
}

resource "aws_api_gateway_resource" "flight_details_get_details" {
  rest_api_id = aws_api_gateway_rest_api.services_gateway.id
  parent_id   = aws_api_gateway_rest_api.services_gateway.root_resource_id
  path_part   = "flight-details"
}

resource "aws_api_gateway_method" "flight_details_get_details" {
  rest_api_id   = aws_api_gateway_rest_api.services_gateway.id
  resource_id   = aws_api_gateway_resource.flight_details_get_details.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_details_lambda" {
  rest_api_id = aws_api_gateway_rest_api.services_gateway.id
  resource_id = aws_api_gateway_method.flight_details_get_details.resource_id
  http_method = aws_api_gateway_method.flight_details_get_details.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_details_lambda.invoke_arn
}


resource "aws_api_gateway_resource" "flight_details_get_inbound" {
  rest_api_id = aws_api_gateway_rest_api.services_gateway.id
  parent_id   = aws_api_gateway_rest_api.services_gateway.root_resource_id
  path_part   = "inbound-flight"
}

resource "aws_api_gateway_method" "flight_details_get_inbound" {
  rest_api_id   = aws_api_gateway_rest_api.services_gateway.id
  resource_id   = aws_api_gateway_resource.flight_details_get_inbound.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_inbound_lambda" {
  rest_api_id = aws_api_gateway_rest_api.services_gateway.id
  resource_id = aws_api_gateway_method.flight_details_get_inbound.resource_id
  http_method = aws_api_gateway_method.flight_details_get_inbound.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_inbound_lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "default_deployment" {
  depends_on = [
    aws_api_gateway_integration.get_details_lambda,
    aws_api_gateway_integration.get_inbound_lambda,
  ]

  rest_api_id = aws_api_gateway_rest_api.services_gateway.id
  stage_name  = "v1"
}
resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = aws_api_gateway_rest_api.services_gateway.id
  resource_id   = aws_api_gateway_rest_api.services_gateway.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = aws_api_gateway_rest_api.services_gateway.id
  resource_id = aws_api_gateway_method.proxy_root.resource_id
  http_method = aws_api_gateway_method.proxy_root.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_details_lambda.invoke_arn
}