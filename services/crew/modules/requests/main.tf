
module "request_handler" {
  source        = "terraform-aws-modules/lambda/aws"
  version       = "~> 4.0"
  function_name = "${var.prefix}-${local.lambda_name}"
  source_path   = "${var.source_path}/crew_requests.py"
  handler       = "crew_requests.lambda_handler"
  runtime       = "python3.10"
  publish       = true

  #  description   = "My awesome lambda function"
  environment_variables = {
    TABLE_NAME = var.table_name
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
      effect = "Allow",
      actions = [
        "dynamodb:BatchGetItem",
        "dynamodb:GetItem",
        "dynamodb:Query",
        "dynamodb:Scan"
      ],
      resources = [var.table_arn]
    }
  }
}

module "api_gateway_resource" {
  source = "../../../../modules/lambda_api_gateway_resource"

  rest_api_id               = var.rest_api_id
  rest_api_root_resource_id = var.rest_api_root_resource_id
  http_method               = "GET"
  invoke_arn                = module.request_handler.lambda_function_invoke_arn
  parent_path               = "crew"
  path_part                 = "{request}"
}
