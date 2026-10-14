variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "cloudflare_api_token" {
  type      = string
  sensitive = true
}

variable "cloudflare_account_id" {
  type = string
}
