module "flight_updater" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 4.0"
  publish = true

  function_name = "${var.prefix}-${local.lambda_name}"
  #  description   = "My awesome lambda function"
  handler = "flight_requests.lambda_handler"
  runtime = "python3.10"

  source_path = "${var.source_path}/flight_updates.py"

  environment_variables = {
    ARRIVAL_TABLE   = var.arrivals_table_name
    DEPARTURE_TABLE = var.departures_table_name
  }

  cloudwatch_logs_retention_in_days = 3

  allowed_triggers = {
    EventBridgeInvoke = {
      service    = "events"
      source_arn = var.sqs_queue_arn
    }
  }

  attach_policy_statements = true
  policy_statements = {
    dynamodb = {
      effect    = "Allow",
      actions   = ["dynamodb:BatchPutItem", "dynamodb:PutItem", "dynamodb:UpdateItem"],
      resources = var.table_arn_list
    },
    sqs = {
      effect    = "Allow",
      actions   = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"],
      resources = [var.sqs_queue_arn]
    }
  }
}

resource "aws_lambda_event_source_mapping" "sqs_update_trigger" {
  event_source_arn = var.sqs_queue_arn
  function_name    = module.flight_updater.lambda_function_name
  # For standard queues, the maximum is 10,000. For FIFO queues, the maximum is 10.
  batch_size = 10
}