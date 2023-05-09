locals {
  zip_file_location = "${var.zip_path}/${var.lambda_name}.zip"
  source_file = "${var.source_path}/${var.lambda_name}/lambda_function.py"
  full_function_name = "${var.prefix}-${replace(var.lambda_name, "_", "-")}"
}

data "archive_file" "zip_file" {
  type        = "zip"
  source_file = local.source_file
  output_path = local.zip_file_location
}

resource "aws_lambda_function" "function" {
  function_name = local.full_function_name
  role          = var.execution_role_arn
  runtime       = "python3.10"
  handler       = "lambda_function.lambda_handler"
  filename      = local.zip_file_location

  environment {
    variables = {
      DYNAMODB_TABLE = var.table_name
    }
  }
}

resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "${local.full_function_name}-gateway-permission"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function.function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  #source_arn = "${var.rest_api_execution_arn}/*/${var.lambda_name}"
  source_arn = "${var.rest_api_execution_arn}/*/*"
}