resource "aws_dynamodb_table" "table" {
  name         = "${var.prefix}-${var.table_name}"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "key"

  attribute {
    name = "key"
    type = "S"
  }

  ttl {
    attribute_name = "expiration_time"
    enabled        = true
  }

  #  lifecycle {
  #    prevent_destroy = true
  #  }
}