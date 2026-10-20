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
