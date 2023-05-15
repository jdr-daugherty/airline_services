resource "aws_dynamodb_table_item" "test_row_01" {
  count      = length(regexall(".*-dev-.*", local.prefix)) > 0 ? 1 : 0
  table_name = aws_dynamodb_table.crew_table.name
  hash_key   = aws_dynamodb_table.crew_table.hash_key

  item = <<ITEM
{
  "${aws_dynamodb_table.crew_table.hash_key}": {"S": "e12345"},

  "legalName": {"S": "Leslie Townes Hope"},
  "nickName": {"S": "Bob"},
  "born": {"S": "1903-05-29"},
  "department": {"S": "Pilots"},
  "position": {"S": "Captain"},
  "base": {"S": "DAL"},
  "seniority": {"S": "2345"}
}
ITEM
}

resource "aws_dynamodb_table_item" "test_row_02" {
  count      = length(regexall(".*-dev-.*", local.prefix)) > 0 ? 1 : 0
  table_name = aws_dynamodb_table.crew_table.name
  hash_key   = aws_dynamodb_table.crew_table.hash_key

  item = <<ITEM
{
  "${aws_dynamodb_table.crew_table.hash_key}": {"S": "e23456"},

  "legalName": {"S": "Ryan Rodney Reynolds"},
  "nickName": {"S": "Bob"},
  "born": {"S": "1976-10-23"},
  "department": {"S": "Flight Attendants"},
  "position": {"S": "Senior"},
  "base": {"S": "DAL"},
  "seniority": {"S": "1234"}
}
ITEM
}
