resource "aws_dynamodb_table" "crew_table" {
  name         = "${local.prefix}-crew"
  billing_mode = "PAY_PER_REQUEST"

  # Employee ID Number in the form e12345
  hash_key = "eid"

  attribute {
    name = "eid"
    type = "S"
  }

  #  lifecycle {
  #    prevent_destroy = true
  #  }
}


module "requests" {
  source                    = "./modules/requests"
  rest_api_execution_arn    = var.rest_api_execution_arn
  rest_api_id               = var.rest_api_id
  rest_api_root_resource_id = var.rest_api_root_resource_id
  prefix                    = local.prefix
  source_path               = local.lambda_source_path

  table_name = aws_dynamodb_table.crew_table.name
  table_arn  = aws_dynamodb_table.crew_table.arn
}

module "updates" {
  source        = "./modules/updates"
  prefix        = local.prefix
  source_path   = local.lambda_source_path
  sqs_queue_arn = aws_sqs_queue.crew_relay_queue.arn
  table_name    = aws_dynamodb_table.crew_table.name
  table_arn     = aws_dynamodb_table.crew_table.arn
}

# The system pushes an update every time a crew member is created or modified.
resource "aws_sqs_queue" "crew_relay_queue" {
  name       = "${local.prefix}-relay.fifo"
  fifo_queue = true
}
