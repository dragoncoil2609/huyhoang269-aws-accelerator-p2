# 1. Tạo Application Load Balancer
resource "aws_lb" "main" {
  name               = "k8s-aws-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]

  # ALB bắt buộc phải nằm trên ít nhất 2 Public Subnet
  subnets = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}

# 2. Tạo Target Group (Nhóm mục tiêu) - Trỏ thẳng vào cổng 30000 của EC2
resource "aws_lb_target_group" "app" {
  name     = "k8s-aws-tg"
  port     = 30000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  # Cấu hình Health Check để ALB biết K8s có đang sống không
  health_check {
    path                = "/"
    port                = "30000"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 10
  }
}

# 3. Gắn K8s Node vào Target Group
resource "aws_lb_target_group_attachment" "app" {
  target_group_arn = aws_lb_target_group.app.arn
  target_id        = aws_instance.k8s_node.id
  port             = 30000
}

# 4. Tạo Listener (Kẻ lắng nghe) - Đứng ở cổng 80 và vứt traffic vào Target Group
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# 5. In ra đường link URL để nộp bài
output "alb_dns_name" {
  description = "Copy link nay dan vao trinh duyet de xem web"
  value       = aws_lb.main.dns_name
}
