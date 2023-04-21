
output "gateway_url" {
  value = aws_api_gateway_deployment.default_deployment.invoke_url
}
