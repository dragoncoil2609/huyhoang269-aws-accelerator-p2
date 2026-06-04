# 1. Tạo Application Load Balancer (ALB) nằm ở Vùng Mở
resource "aws_lb" "main" {
  name               = "k8s-aws-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  
  # ALB bắt buộc phải nằm trên ít nhất 2 Public Subnet
  subnets = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}

# 2. Tạo Target Group (Nhóm mục tiêu) - Trỏ thẳng vào cổng 30000 của K8s Node
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

# 3. Gắn máy K8s Node vào Target Group
resource "aws_lb_target_group_attachment" "k8s_node" {
  target_group_arn = aws_lb_target_group.app.arn
  target_id        = aws_instance.k8s_node.id # Trỏ vào K8s Node ở Private Subnet
  port             = 30000
}

# 4. Mở cổng đón khách (Listener)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# 5. In ra đường link URL trang web
output "alb_dns_name" {
  value       = aws_lb.main.dns_name
  description = "DIA CHI URL CUA TRANG WEB (COPY & PASTE VAO TRINH DUYET)"
}
