output "arn" {
  value = aws_lambda_function.function.arn
}

output "name" {
  value = aws_lambda_function.function.function_name
}

output "invoke_arn" {
  value = aws_lambda_function.function.invoke_arn
}