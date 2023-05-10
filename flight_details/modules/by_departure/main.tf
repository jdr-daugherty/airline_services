module "table" {
  source     = "../../../modules/dynamodb_simple"
  prefix     = var.prefix
  table_name = local.lambda_name
}

module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"
  version = "~> 4.0"
  publish = true

  function_name = "${var.prefix}-${local.lambda_name}"
  #  description   = "My awesome lambda function"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.10"

  source_path = "${var.source_path}/${local.lambda_name}/lambda_function.py"

  environment_variables = {
    DYNAMODB_TABLE = module.table.name
  }

  cloudwatch_logs_retention_in_days = 3

  allowed_triggers = {
    APIGatewayAny = {
      service    = "apigateway"
      source_arn = "${var.api_execution_arn}/*/*"
    }
  }

  attach_policy_statements = true
  policy_statements = {
    dynamodb = {
      effect    = "Allow",
      actions   = ["dynamodb:BatchGetItem", "dynamodb:GetItem"],
      resources = [module.table.arn]
    }
  }
}

module "api_gateway_resource" {
  source = "../../../modules/lambda_api_gateway_resource"

  rest_api_id        = var.api_id
  parent_resource_id = var.api_parent_resource_id
  http_method        = "GET"
  invoke_arn         = module.lambda_function.lambda_function_invoke_arn
  path_part          = local.lambda_name
}

resource "aws_dynamodb_table_item" "flight_status_test_row" {
  count = length(regexall(".*-dev-.*", var.prefix)) > 0 ? 1 : 0
  table_name = module.table.name
  hash_key   = module.table.hash_key

  item = <<ITEM
{
  "key": {"S": "MEM_5420_2022-05-18"},

  "createdBy": {"S": ""},
  "createdTime": {"S": "2022-04-18T18:54:21.762Z"},

  "number": {"S": "5420"},
  "tailNumber": {"S": "N413WN"},

  "departureDate": {"S": "2022-05-03"},

  "departureStationCode": {"S": "MEM"},
  "departureStationTimeZone": {"S": "America/Chicago"},
  "originalArrivalTime": {"S": "2022-05-18T20:29:40.131Z"},
  "currentDepartureTime": {"S": "2022-05-03T18:54:21.762Z"},
  "outboundStatus": {"S": "On Time"},
  "departureGate": {"S": "B3"},

  "arrivalStationCode": {"S": "DAL"},
  "arrivalStationTimeZone": {"S": "America/Los_Angeles"},
  "originalArrivalTime": {"S": "2022-05-18T20:29:40.131Z"},
  "currentArrivalTime": {"S": "2022-05-18T20:43:29.487Z"},
  "inboundStatus": {"S": "Delayed"},
  "arrivalGate": {"S": "C17"},

  "lastModifiedBy": {"S": ""},
  "lastModifiedTime": {"S": "2022-04-22T15:24:29.882Z"},


  "expiration_time": {"S": "1650412800"}
}
ITEM
}
