# Tạo bộ lọc sự kiện (Rule) để bắt các cảnh báo từ Macie
resource "aws_cloudwatch_event_rule" "macie_finding_rule" {
  name        = "Macie-Finding-To-SNS"
  description = "Tự động bắt Macie findings và gửi sang SNS"

  event_pattern = jsonencode({
    source = ["aws.macie"]
    "detail-type" = ["Macie Finding"]
  })
}

# Đặt đích đến (Target) cho sự kiện là cái SNS Topic đã tạo
resource "aws_cloudwatch_event_target" "sns_target" {
  rule      = aws_cloudwatch_event_rule.macie_finding_rule.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.macie_alerts.arn
}
