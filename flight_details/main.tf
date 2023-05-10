resource "aws_api_gateway_rest_api" "services_gateway" {
  name = "${var.namespace}-${var.environment}-gateway"
}

module "by_departure" {
  source                 = "./modules/by_departure"
  api_execution_arn      = aws_api_gateway_rest_api.services_gateway.execution_arn
  api_id                 = aws_api_gateway_rest_api.services_gateway.id
  api_parent_resource_id = aws_api_gateway_rest_api.services_gateway.root_resource_id
  prefix                 = local.prefix
  source_path            = local.lambda_source_path
  zip_path               = local.lambda_zip_path
}

module "by_arrival" {
  source                 = "./modules/by_arrival"
  api_execution_arn      = aws_api_gateway_rest_api.services_gateway.execution_arn
  api_id                 = aws_api_gateway_rest_api.services_gateway.id
  api_parent_resource_id = aws_api_gateway_rest_api.services_gateway.root_resource_id
  prefix                 = local.prefix
  source_path            = local.lambda_source_path
  zip_path               = local.lambda_zip_path
}

resource "aws_api_gateway_deployment" "default_deployment" {
  depends_on = [module.by_departure, module.by_arrival]

  rest_api_id = aws_api_gateway_rest_api.services_gateway.id
  stage_name  = "v1"

  lifecycle {
    create_before_destroy = true
  }

  triggers = {
    # Redeploy the API Gateway any time the set of lambda deployment packages changes.
    # This can be replaced with the aws_s3_objects data source when necessary.
    lambda_packages = sha1(join(" ", fileset(local.lambda_zip_path, "*.zip")))
  }
}

## The system pushes an update every time a flight is created or modified.
## At peak times, several thousand updates can occur each minute.
#resource "aws_sqs_queue" "flight_details_relay_queue" {
#  name       = "${local.prefix}-relay.fifo"
#  fifo_queue = true
#}
#
#module "update_flights" {
#  source         = "./modules/update_flights"
#  sqs_queue_arn  = aws_sqs_queue.flight_details_relay_queue.arn
#  table_arn_list = [module.by_departure.table_arn, module.by_arrival.table_arn]
#  prefix         = local.prefix
#  source_path    = local.lambda_source_path
#  zip_path       = local.lambda_zip_path
#}
