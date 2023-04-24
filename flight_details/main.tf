# The system pushes an update every time a flight is created or modified.
# At peak times, several thousand updates can occur each minute.
resource "aws_sqs_queue" "flight_details_relay_queue" {
  name       = "${local.prefix}-relay.fifo"
  fifo_queue = true
}

resource "aws_api_gateway_rest_api" "services_gateway" {
  name = "${var.namespace}-${var.environment}-gateway"
}

module "flight_status" {
  source                 = "./modules/flight_status"
  api_execution_arn      = aws_api_gateway_rest_api.services_gateway.execution_arn
  api_id                 = aws_api_gateway_rest_api.services_gateway.id
  api_parent_resource_id = aws_api_gateway_rest_api.services_gateway.root_resource_id
  prefix                 = local.prefix
  source_path            = local.lambda_source_path
  zip_path               = local.lambda_zip_path
}

module "inbound_flight" {
  source                 = "./modules/inbound_flight"
  api_execution_arn      = aws_api_gateway_rest_api.services_gateway.execution_arn
  api_id                 = aws_api_gateway_rest_api.services_gateway.id
  api_parent_resource_id = aws_api_gateway_rest_api.services_gateway.root_resource_id
  prefix                 = local.prefix
  source_path            = local.lambda_source_path
  zip_path               = local.lambda_zip_path
}

module "update_flights" {
  source         = "./modules/update_flights"
  sqs_queue_arn  = aws_sqs_queue.flight_details_relay_queue.arn
  table_arn_list = [module.flight_status.table_arn, module.inbound_flight.table_arn]
  prefix         = local.prefix
  source_path    = local.lambda_source_path
  zip_path       = local.lambda_zip_path
}

resource "aws_api_gateway_deployment" "default_deployment" {
  depends_on = [
    module.flight_status,
    module.inbound_flight
  ]

  rest_api_id = aws_api_gateway_rest_api.services_gateway.id
  stage_name  = "v1"
}
