output "state_bucket_name" {
  description = "Tên của S3 Bucket chứa remote state file"
  value       = aws_s3_bucket.state_bucket.id
}

output "state_bucket_arn" {
  description = "ARN của S3 Bucket chứa remote state file"
  value       = aws_s3_bucket.state_bucket.arn
}

output "app_bucket_name" {
  description = "Tên của S3 Bucket ứng dụng thứ hai"
  value       = aws_s3_bucket.app_bucket.id
}

