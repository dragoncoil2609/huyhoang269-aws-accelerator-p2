terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # --- CONFIG REMOTE BACKEND S3 ---
  # Bước 1: Để comment phần này ở lần chạy đầu tiên (chạy local state trước).
  # Bước 2: Sau khi chạy apply tạo xong bucket S3 chứa state, bỏ comment phần này và chạy `terraform init -migrate-state`.
  # backend "s3" {
  #   bucket       = "huyhoang269-aws-accelerator-p2-tfstate"
  #   key          = "state/terraform.tfstate"
  #   region       = "us-east-1"
  #   encrypt      = true
  #   use_lockfile = true # Thay vì xài dynamo thì xài này
  # }
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
