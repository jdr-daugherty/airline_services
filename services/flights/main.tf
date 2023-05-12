module "requests" {
  source                    = "./modules/requests"
  rest_api_execution_arn    = var.rest_api_execution_arn
  rest_api_id               = var.rest_api_id
  rest_api_root_resource_id = var.rest_api_root_resource_id
  prefix                    = local.prefix
  source_path               = local.lambda_source_path
  zip_path                  = local.lambda_zip_path
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
