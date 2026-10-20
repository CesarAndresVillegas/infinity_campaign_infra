variable "name" {
  type = string
}

variable "package_path" {
  type = string
}

variable "database_url" {
  type      = string
  sensitive = true
}

variable "cognito_user_pool_id" {
  type = string
}

variable "cognito_client_id" {
  type = string
}

variable "cognito_user_pool_arn" {
  type = string
}

variable "post_confirmation_function_name" {
  type = string
}

variable "frontend_origin" {
  type = string
}

variable "cloudflare_account_id" {
  type = string
}

variable "r2_access_key_id" {
  type      = string
  sensitive = true
}

variable "r2_secret_access_key" {
  type      = string
  sensitive = true
}

variable "r2_bucket_name" {
  type = string
}

variable "r2_public_url" {
  type = string
}
