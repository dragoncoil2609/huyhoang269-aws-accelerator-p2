variable "aws_region" {
  description = "AWS Region to deploy resources"
  type        = string
  default     = "ap-southeast-1"
}

variable "email_address" {
  description = "Địa chỉ email để nhận cảnh báo từ Macie"
  type        = string
}

variable "bucket_name" {
  description = "Tên S3 bucket chứa dữ liệu nhạy cảm"
  type        = string
  default     = "macie-lab-bucket-huyhoang269-tf"
}
