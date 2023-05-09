data "aws_caller_identity" "current_aws" {}

locals {
  account_id = data.aws_caller_identity.current_aws.account_id
}

resource "aws_iam_policy" "read_policy" {
  name = "${var.prefix}-${var.lambda_name}-read-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["dynamodb:BatchGetItem", "dynamodb:GetItem"]
        Effect = "Allow"
        Resource = var.table_arn
      },
    ]
  })
}

resource "aws_iam_policy" "log_policy" {
  name = "${var.prefix}-${var.lambda_name}-log-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Effect = "Allow"
        Resource = ["arn:aws:logs:*:${local.account_id}:log-group:/aws/lambda/${var.prefix}-${var.lambda_name}:*"]
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
  name = "${var.prefix}-${var.lambda_name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "read_attachment" {
  role       = aws_iam_role.execution_role.name
  policy_arn = aws_iam_policy.read_policy.arn
}

resource "aws_iam_role_policy_attachment" "log_attachment" {
  role       = aws_iam_role.execution_role.name
  policy_arn = aws_iam_policy.log_policy.arn
}