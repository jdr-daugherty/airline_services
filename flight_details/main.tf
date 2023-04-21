# TODO: Add a lambda proxy API Gateway
# TODO: Add a output for each of the lambda URLs
# TODO: Convert this into a "flight details" terraform module.
# TODO: Implement each lambda.
# TODO: Convert from SQS to Kafka

# OSDS pushes an update every time a flight is created or modified.
# At peak times, several thousand updates can occur each minute.
resource "aws_sqs_queue" "flight_details_relay_queue" {
  name       = "${local.prefix}-relay.fifo"
  fifo_queue = true
}
