module "update_details_role" {
  source = "./modules/update_lambda_role"

  lambda_name    = local.lambda_name
  prefix         = var.prefix
  table_arn_list = var.table_arn_list
  sqs_queue_arn  = var.sqs_queue_arn
}

module "update_details" {
  source = "./modules/update_lambda"

  execution_role_arn = module.update_details_role.arn
  lambda_name        = local.lambda_name
  prefix             = var.prefix
  sqs_queue_arn      = var.sqs_queue_arn
  source_path        = var.source_path
  zip_path           = var.zip_path
}