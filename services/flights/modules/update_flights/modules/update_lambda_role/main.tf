resource "aws_iam_policy" "relay_read_policy" {
  name = "${var.prefix}-${var.lambda_name}-relay-read-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
        Effect   = "Allow"
        Resource = var.sqs_queue_arn
      },
    ]
  })
}

resource "aws_iam_policy" "write_policy" {
  name = "${var.prefix}-${var.lambda_name}-read-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:BatchWriteItem", "dynamodb:DeleteItem",
          "dynamodb:UpdateItem", "dynamodb:PutItem",
        ]
        Effect = "Allow"
        Resource = var.table_arn_list
      },
    ]
  })
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "execution_role" {
  name        = "${var.prefix}-${var.lambda_name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "write_attachment" {
  role       = aws_iam_role.execution_role.name
  policy_arn = aws_iam_policy.write_policy.arn
}

resource "aws_iam_role_policy_attachment" "relay_read_attachment" {
  role       = aws_iam_role.execution_role.name
  policy_arn = aws_iam_policy.relay_read_policy.arn
}