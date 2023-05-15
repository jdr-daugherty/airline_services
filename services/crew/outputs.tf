output "table_name" {
  value = aws_dynamodb_table.crew_table.name
}

output "table_arn" {
  value = aws_dynamodb_table.crew_table.arn
}