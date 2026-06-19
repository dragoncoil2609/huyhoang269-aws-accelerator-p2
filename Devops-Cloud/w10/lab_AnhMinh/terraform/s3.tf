# Tạo S3 Bucket
resource "aws_s3_bucket" "macie_bucket" {
  bucket        = var.bucket_name
  force_destroy = true # Cho phép xóa bucket ngay cả khi có dữ liệu bên trong

  tags = {
    Name = "Macie Lab Target Bucket"
  }
}

# Tạo ra một file text ảo chứa "số thẻ tín dụng fake" để Macie quét
resource "aws_s3_object" "sensitive_data_file" {
  bucket       = aws_s3_bucket.macie_bucket.id
  key          = "sensitive-data.txt"
  content      = "This file contains sensitive data. Credit Card Number: 4532 1234 5678 9012. Name: John Doe."
  content_type = "text/plain"
}
