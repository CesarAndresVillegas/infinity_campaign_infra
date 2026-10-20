data "aws_caller_identity" "current" {}

locals {
  post_confirmation_function_name = "infinity-campaign-post-confirmation"
  post_confirmation_arn           = "arn:aws:lambda:${var.aws_region}:${data.aws_caller_identity.current.account_id}:function:${local.post_confirmation_function_name}"
}

module "cognito" {
  source                        = "./modules/cognito"
  name                          = "infinity-campaign"
  post_confirmation_lambda_arn = local.post_confirmation_arn
}

module "lambda" {
  source = "./modules/lambda"

  name                             = "infinity-campaign"
  package_path                     = var.backend_package_path
  database_url                     = var.database_url
  cognito_user_pool_id             = module.cognito.user_pool_id
  cognito_client_id                = module.cognito.user_pool_client_id
  cognito_user_pool_arn            = module.cognito.user_pool_arn
  post_confirmation_function_name = local.post_confirmation_function_name
  frontend_origin                  = var.frontend_origin
  cloudflare_account_id            = var.cloudflare_account_id
  r2_access_key_id                 = var.r2_access_key_id
  r2_secret_access_key             = var.r2_secret_access_key
  r2_bucket_name                   = var.r2_bucket_name
  r2_public_url                    = var.r2_public_url
}

output "cognito_user_pool_id" {
  value = module.cognito.user_pool_id
}

output "cognito_user_pool_client_id" {
  value = module.cognito.user_pool_client_id
}

output "api_invoke_url" {
  value = module.lambda.api_invoke_url
}
