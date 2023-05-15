resource "aws_api_gateway_rest_api" "services_gateway" {
  name = "${var.namespace}-${var.environment}-gateway"
}

module "flights" {
  source                    = "./services/flights"
  service_prefix            = local.service_prefix
  rest_api_id               = aws_api_gateway_rest_api.services_gateway.id
  rest_api_root_resource_id = aws_api_gateway_rest_api.services_gateway.root_resource_id
  rest_api_execution_arn    = aws_api_gateway_rest_api.services_gateway.execution_arn
}

module "crew" {
  source                    = "./services/crew"
  service_prefix            = local.service_prefix
  rest_api_id               = aws_api_gateway_rest_api.services_gateway.id
  rest_api_root_resource_id = aws_api_gateway_rest_api.services_gateway.root_resource_id
  rest_api_execution_arn    = aws_api_gateway_rest_api.services_gateway.execution_arn
}

resource "aws_api_gateway_deployment" "default_deployment" {
  depends_on = [module.flights]

  rest_api_id = aws_api_gateway_rest_api.services_gateway.id
  stage_name  = "v1"

  lifecycle {
    create_before_destroy = true
  }

  #  triggers = {
  #    # Redeploy the API Gateway any time the set of lambda deployment packages changes.
  #    # This can be replaced with the aws_s3_objects data source when necessary.
  #    lambda_packages = sha1(join(" ", fileset(local.lambda_zip_path, "*.zip")))
  #  }
}
