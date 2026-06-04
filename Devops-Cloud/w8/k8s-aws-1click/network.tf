# ==========================================
# PHẦN 1: TỰ QUY HOẠCH HẠ TẦNG MẠNG (CUSTOM VPC)
# ==========================================

# 1. Tạo VPC (Mảnh đất chính)
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "k8s-aws-vpc" }
}

# 2. VÙNG MỞ (PUBLIC SUBNETS)
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = { Name = "k8s-aws-public-1" }
}
resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = { Name = "k8s-aws-public-2" }
}

# 3. VÙNG KÍN (PRIVATE SUBNET) - Nơi giấu K8s
resource "aws_subnet" "private_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false # Tắt IP Public, tuyệt đối cách ly
  tags = { Name = "k8s-aws-private-1" }
}

# 4. TẠO CỬA NGÕ (INTERNET GATEWAY & NAT GATEWAY)
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "k8s-aws-igw" }
}

# Thuê 1 IP tĩnh (Elastic IP) cho NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"
}

# Đặt NAT Gateway ở Vùng Mở (Public Subnet) để đi chợ giùm Vùng Kín
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_1.id
  tags = { Name = "k8s-aws-nat" }
  depends_on = [aws_internet_gateway.gw]
}

# 5. ĐỊNH TUYẾN ĐƯỜNG ĐI (ROUTE TABLES)
# Bảng chỉ đường cho Vùng Mở (đi thẳng ra Internet Gateway)
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}
resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public_rt.id
}
resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public_rt.id
}

# Bảng chỉ đường cho Vùng Kín (nhờ vả qua NAT Gateway)
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}
resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private_rt.id
}

# ==========================================
# PHẦN 2: SECURITY GROUPS (Lớp khiên bảo vệ)
# ==========================================

# SG cho Bastion Host (Chỉ mở SSH ra thế giới)
resource "aws_security_group" "bastion" {
  name        = "k8s-aws-bastion-sg"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# SG cho ALB (Mở HTTP ra thế giới)
resource "aws_security_group" "alb" {
  name        = "k8s-aws-alb-sg"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# SG cho K8s Node (Tuyệt đối an toàn)
resource "aws_security_group" "ec2" {
  name        = "k8s-aws-ec2-sg"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    description     = "Chi nhan SSH tu Bastion Host"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id] # Khóa cứng
  }
  ingress {
    description     = "Chi nhan Traffic NodePort tu ALB"
    from_port       = 30000
    to_port         = 30000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id] # Khóa cứng
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
