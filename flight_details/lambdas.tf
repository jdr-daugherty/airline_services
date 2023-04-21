# TODO: Move lambdas to S3

locals {
  source_path    = "../lambdas"
  zip_path       = "../lambdas/packages"
  zip_loc_prefix = "${local.zip_path}/${local.service_name}"
}

# Flight Details and Inbound Status Updates
data "archive_file" "update_lambda_zip" {
  type        = "zip"
  source_file = "${local.source_path}/update_details/lambda_function.py"
  output_path = "${local.zip_loc_prefix}-update.zip"
}

resource "aws_lambda_function" "update_lambda" {
  function_name = "${local.prefix}-update"
  role          = aws_iam_role.update_details_execution_role.arn
  runtime       = "python3.9"
  handler       = "lambda_function.lambda_handler"
  filename      = "${local.zip_loc_prefix}-update.zip"
}

resource "aws_lambda_permission" "sqs_update_permission" {
  statement_id  = "UpdateFlightDetailsFromRelayQueue"
  principal     = "events.amazonaws.com"
  source_arn    = aws_sqs_queue.flight_details_relay_queue.arn
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_lambda.function_name
}

resource "aws_lambda_event_source_mapping" "sqs_update_trigger" {
  event_source_arn = aws_sqs_queue.flight_details_relay_queue.arn
  function_name    = aws_lambda_function.update_lambda.arn
  # For standard queues, the maximum is 10,000. For FIFO queues, the maximum is 10.
  batch_size = 10
}

# Flight Status Details
data "archive_file" "get_details_lambda_zip" {
  type        = "zip"
  source_file = "${local.source_path}/get_details/lambda_function.py"
  output_path = "${local.zip_loc_prefix}-get.zip"
}
resource "aws_lambda_function" "get_details_lambda" {
  function_name = "${local.prefix}-get"
  role          = aws_iam_role.read_execution_role.arn
  runtime       = "python3.9"
  handler       = "lambda_function.lambda_handler"
  filename      = "${local.zip_loc_prefix}-get.zip"
}

# Inbound Flight Details
data "archive_file" "get_inbound_lambda_zip" {
  type        = "zip"
  source_file = "${local.source_path}/get_inbound/lambda_function.py"
  output_path = "${local.zip_loc_prefix}-get-inbound.zip"
}

resource "aws_lambda_function" "get_inbound_lambda" {
  function_name = "${local.prefix}-get-inbound"
  role          = aws_iam_role.read_execution_role.arn
  runtime       = "python3.9"
  handler       = "lambda_function.lambda_handler"
  filename      = "${local.zip_loc_prefix}-get-inbound.zip"
}
