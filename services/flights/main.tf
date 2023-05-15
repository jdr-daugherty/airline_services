module "arrivals_table" {
  source     = "../../modules/dynamodb_simple"
  prefix     = local.prefix
  table_name = "by-arrival"
}

module "departures_table" {
  source     = "../../modules/dynamodb_simple"
  prefix     = local.prefix
  table_name = "by-departure"
}

module "requests" {
  source                    = "./modules/requests"
  rest_api_execution_arn    = var.rest_api_execution_arn
  rest_api_id               = var.rest_api_id
  rest_api_root_resource_id = var.rest_api_root_resource_id
  prefix                    = local.prefix
  source_path               = local.lambda_source_path

  arrivals_table_name   = module.arrivals_table.name
  departures_table_name = module.departures_table.name
  table_arn_list        = [module.departures_table.arn, module.arrivals_table.arn]
}

module "updates" {
  source                = "./modules/updates"
  prefix                = local.prefix
  source_path           = local.lambda_source_path
  sqs_queue_arn         = aws_sqs_queue.flight_details_relay_queue.arn
  arrivals_table_name   = module.arrivals_table.name
  departures_table_name = module.departures_table.name
  table_arn_list        = [module.departures_table.arn, module.arrivals_table.arn]
}

# The system pushes an update every time a flight is created or modified.
# At peak times, several thousand updates can occur each minute.
resource "aws_sqs_queue" "flight_details_relay_queue" {
  name       = "${local.prefix}-relay.fifo"
  fifo_queue = true
}
