variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "cloudflare_api_token" {
  type      = string
  sensitive = true
  default   = ""
}

variable "cloudflare_account_id" {
  type    = string
  default = ""
}

variable "database_url" {
  type      = string
  sensitive = true
}

variable "frontend_origin" {
  type    = string
  default = "https://infinity-campaign-frontend.infinitycampaign.workers.dev"
}

variable "backend_package_path" {
  type    = string
  default = "../../infinity_campaign_backend/build/lambda.zip"
}
