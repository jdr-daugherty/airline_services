module "update_lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 4.0"
  publish = true

  function_name = "${var.prefix}-${local.lambda_name}"
  #  description   = "My awesome lambda function"
  handler = "crew_updates.lambda_handler"
  runtime = "python3.10"

  source_path = "${var.source_path}/crew_updates.py"

  environment_variables = {
    ARRIVAL_TABLE   = var.table_name
    DEPARTURE_TABLE = var.table_name
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
      resources = [var.table_arn]
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
  function_name    = module.update_lambda.lambda_function_name
  # For standard queues, the maximum is 10,000. For FIFO queues, the maximum is 10.
  batch_size = 10
}