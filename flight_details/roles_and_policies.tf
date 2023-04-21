resource "aws_iam_policy" "flight_details_relay_read_policy" {
  name = "${local.prefix}-relay-read-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
        Effect   = "Allow"
        Resource = [aws_sqs_queue.flight_details_relay_queue.arn]
      },
    ]
  })
}

resource "aws_iam_policy" "flight_details_write_policy" {
  name = "${local.prefix}-table-write-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:BatchWriteItem", "dynamodb:DeleteItem",
          "dynamodb:UpdateItem", "dynamodb:PutItem",
        ]
        Effect = "Allow"
        Resource = [
          aws_dynamodb_table.flight_details.arn,
          aws_dynamodb_table.inbound_flight_status.arn
        ]
      },
    ]
  })
}

resource "aws_iam_policy" "flight_details_read_policy" {
  name = "${local.prefix}-table-read-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["dynamodb:BatchGetItem", "dynamodb:GetItem"]
        Effect = "Allow"
        Resource = [
          aws_dynamodb_table.flight_details.arn,
          aws_dynamodb_table.inbound_flight_status.arn
        ]
      },
    ]
  })
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "read_execution_role" {
  name               = "${local.prefix}-read-execution-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "read_attachment" {
  role       = aws_iam_role.read_execution_role.name
  policy_arn = aws_iam_policy.flight_details_read_policy.arn
}

# Flight Details Update Lambda Execution Role
resource "aws_iam_role" "update_details_execution_role" {
  name               = "${local.prefix}-write-execution-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "write_attachment" {
  role       = aws_iam_role.update_details_execution_role.name
  policy_arn = aws_iam_policy.flight_details_write_policy.arn
}

resource "aws_iam_role_policy_attachment" "relay_read_attachment" {
  role       = aws_iam_role.update_details_execution_role.name
  policy_arn = aws_iam_policy.flight_details_relay_read_policy.arn
}