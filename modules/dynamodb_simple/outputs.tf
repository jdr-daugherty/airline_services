output "arn" {
  value = aws_dynamodb_table.table.arn
}

output "name" {
  value = aws_dynamodb_table.table.name
}

output "hash_key" {
  value = aws_dynamodb_table.table.hash_key
}