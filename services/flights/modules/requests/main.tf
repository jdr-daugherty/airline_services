module "arrivals_table" {
  source     = "../../../../modules/dynamodb_simple"
  prefix     = var.prefix
  table_name = "by-arrival"
}

module "departures_table" {
  source     = "../../../../modules/dynamodb_simple"
  prefix     = var.prefix
  table_name = "by-departure"
}

module "request_handler" {
  source = "terraform-aws-modules/lambda/aws"
  version = "~> 4.0"
  publish = true

  function_name = "${var.prefix}-${local.lambda_name}"
  #  description   = "My awesome lambda function"
  handler       = "requests.lambda_handler"
  runtime       = "python3.10"

  source_path = "${var.source_path}/requests.py"

  environment_variables = {
    ARRIVAL_TABLE = module.arrivals_table.name
    DEPARTURE_TABLE = module.departures_table.name
  }

  cloudwatch_logs_retention_in_days = 3

  allowed_triggers = {
    APIGatewayAny = {
      service    = "apigateway"
      source_arn = "${var.rest_api_execution_arn}/*/*"
    }
  }

  attach_policy_statements = true
  policy_statements = {
    dynamodb = {
      effect    = "Allow",
      actions   = ["dynamodb:BatchGetItem", "dynamodb:GetItem"],
      resources = [module.arrivals_table.arn, module.departures_table.arn]
    }
  }
}

module "api_gateway_resource" {
  source = "../../../../modules/lambda_api_gateway_resource"

  rest_api_id        = var.rest_api_id
  rest_api_root_resource_id = var.rest_api_root_resource_id
  http_method        = "GET"
  invoke_arn         = module.request_handler.lambda_function_invoke_arn
  parent_path       = "flights"
  path_part          = "{request}"
}
