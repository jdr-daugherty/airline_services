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
}

resource "aws_lambda_permission" "sqs_update_permission" {
  statement_id  = "${local.full_function_name}-relay-queue-permission"
  principal     = "events.amazonaws.com"
  source_arn    = var.sqs_queue_arn
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function.function_name
}

resource "aws_lambda_event_source_mapping" "sqs_update_trigger" {
  event_source_arn = var.sqs_queue_arn
  function_name    = aws_lambda_function.function.arn
  # For standard queues, the maximum is 10,000. For FIFO queues, the maximum is 10.
  batch_size = 10
}