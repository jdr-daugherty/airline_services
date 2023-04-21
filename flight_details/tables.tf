resource "aws_dynamodb_table" "flight_details" {
  name         = local.prefix
  billing_mode = "PAY_PER_REQUEST"

  # [Departure Code]_[Flight Number]_[Planned Departure Date Herb]
  hash_key = "key"

  attribute {
    name = "key"
    type = "S"
  }

  ttl {
    # flight details should expire after a year and are populated approximately
    # a month in advance.
    # <= 1.6 million entries (~4000/day for 365 days)
    attribute_name = "expiration_time"
    enabled        = true
  }

  #  lifecycle {
  #    prevent_destroy = true
  #  }
}

resource "aws_dynamodb_table" "inbound_flight_status" {
  name         = "${local.prefix}-inbound"
  billing_mode = "PAY_PER_REQUEST"

  # [Tail Number]_[Arrival Code]_[Planned Arrival Date Herb]
  hash_key = "key"

  attribute {
    name = "key"
    type = "S"
  }

  ttl {
    # Inbound flight details should expire within a few hours of landing
    # and are populated approximately a month in advance.
    # <= 128,000 entries (~4000/day)
    attribute_name = "expiration_time"
    enabled        = true
  }

  #  lifecycle {
  #    prevent_destroy = true
  #  }
}

