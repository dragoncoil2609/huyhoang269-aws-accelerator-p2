locals {
  # Naming convention prefix
  name_prefix = "${var.project_name}-${var.environment}"

  # Common tags for all resources
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}


resource "aws_s3_bucket" "state_bucket" {
  # Đã sửa lại để sử dụng đúng biến local như mục đích ban đầu
  bucket        = "huyhoang269-${local.name_prefix}-tfstate"
  force_destroy = true # Cho phép xóa bucket khi còn dữ liệu (chỉ dùng cho môi bài này)

  tags = merge(
    local.common_tags,
    {
      Name = "Terraform State Storage"
    }
  )
}

resource "aws_s3_bucket_versioning" "state_versioning" {
  bucket = aws_s3_bucket.state_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "app_bucket" {
  # PHỤ THUỘC NGẦM ĐỊNH (Implicit Dependency) qua việc tham chiếu ID của state_bucket
  bucket = "huyhoang269-${aws_s3_bucket.state_bucket.id}-app-data"

  # PHỤ THUỘC TƯỜNG MINH (Explicit Dependency)
  # Yêu cầu tính năng Versioning phải được bật trên state_bucket trước khi tạo bucket ứng dụng này
  depends_on = [
    aws_s3_bucket_versioning.state_versioning
  ]

  tags = merge(
    local.common_tags,
    {
      Name = "Application Data Storage"
    }
  )
}
