# Khởi tạo SNS Topic
resource "aws_sns_topic" "macie_alerts" {
  name = "Macie-Alert-Topic"
}

# Đăng ký nhận email từ Topic
resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.macie_alerts.arn
  protocol  = "email"
  endpoint  = var.email_address
}

# Tạo Policy cho phép EventBridge có quyền gửi (Publish) message vào SNS Topic này
resource "aws_sns_topic_policy" "default" {
  arn = aws_sns_topic.macie_alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowEventBridgeToPublish"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action   = "sns:Publish"
        Resource = aws_sns_topic.macie_alerts.arn
      }
    ]
  })
}
