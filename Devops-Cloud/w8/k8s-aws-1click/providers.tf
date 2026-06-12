terraform {
  required_version = ">= 1.5.0"
  required_providers {
    # Dùng để giao tiếp với AWS API (tạo EC2, VPC, ALB, Security Group...)
    aws   = { source = "hashicorp/aws", version = "~> 5.0" }

    # Dùng để tự động sinh ra khóa mã hóa SSH (thuật toán RSA 4096 bit) trên RAM
    tls   = { source = "hashicorp/tls", version = "~> 4.0" }

    # Dùng để ghi nội dung Private Key xuống ổ cứng máy tính thành file .pem
    local = { source = "hashicorp/local", version = "~> 2.4" }

    # Dùng để tạo ra môi trường ảo rỗng, cho phép chạy kịch bản cài đặt remote-exec qua SSH
    null  = { source = "hashicorp/null", version = "~> 3.2" }
  }
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Project   = "K8s-AWS-1Click"
      ManagedBy = "Terraform"
    }
  }
}
