module "table" {
  source     = "../../../modules/dynamodb_simple"
  prefix     = var.prefix
  table_name = local.lambda_name
}

module "lambda_getter" {
  source                 = "../../../modules/lambda_getter"
  execution_role_arn     = module.lambda_getter_role.arn
  lambda_name            = local.lambda_name
  prefix                 = var.prefix
  rest_api_execution_arn = var.api_execution_arn
  table_name             = module.table.name
  source_path            = var.source_path
  zip_path               = var.zip_path
}

module "lambda_getter_role" {
  source      = "../../../modules/lambda_getter_role"
  lambda_name = local.lambda_name
  prefix      = var.prefix
  table_arn   = module.table.arn
}

module "api_gateway_resource" {
  source = "../../../modules/lambda_api_gateway_resource"

  rest_api_id        = var.api_id
  parent_resource_id = var.api_parent_resource_id
  http_method        = "GET"
  invoke_arn         = module.lambda_getter.invoke_arn
  path_part          = local.lambda_name
}


resource "aws_dynamodb_table_item" "example" {
  table_name = module.table.name
  hash_key   = module.table.hash_key

  item = <<ITEM
{
  "key": {"S": "MEM_5420_2022-05-03"},
  "number": {"N": "5420"},
  "departureDate": {"S": "2022-05-03"},
  "departureStationCode": {"S": "MEM"},
  "originalDepartureTime": {"S": "2022-05-03T18:54:21.762Z"},
  "four": {"N": "44444"}
}
ITEM
}

