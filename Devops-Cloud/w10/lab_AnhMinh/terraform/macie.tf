# Kích hoạt dịch vụ Macie
resource "aws_macie2_account" "macie_account" {
  status = "ENABLED"
}

# Tạo Job quét tìm dữ liệu nhạy cảm trên S3 bucket
resource "aws_macie2_classification_job" "sensitive_data_job" {
  # Phải đợi Macie được bật lên xong mới chạy Job
  depends_on = [aws_macie2_account.macie_account]

  job_type = "ONE_TIME"
  name     = "Scan-Sensitive-Data-Terraform"
  
  s3_job_definition {
    bucket_definitions {
      account_id = data.aws_caller_identity.current.account_id
      buckets    = [aws_s3_bucket.macie_bucket.bucket]
    }
  }
}

# Lấy ID của account AWS hiện tại để cho vào biến account_id ở trên
data "aws_caller_identity" "current" {}
