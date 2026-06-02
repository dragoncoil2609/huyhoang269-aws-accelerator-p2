variable "aws_region" {
  type        = string
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

variable "project_name" {
  type        = string
  description = "Project name prefix for resources"
  default     = "aws-acc-p2"
}
variable "environment" {
  type        = string
  description = "Deployment environment (Must be passed via .tfvars)"
}

# --- BẢO MẬT CREDENTIALS (SECRETS) ---
variable "aws_access_key" {
  type        = string
  description = "AWS Access Key ID"
  sensitive   = true
}

variable "aws_secret_key" {
  type        = string
  description = "AWS Secret Access Key"
  sensitive   = true
}
