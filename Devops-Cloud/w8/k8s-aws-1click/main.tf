# ======================================================================
# PHẦN 1: CÁC THÔNG TIN CƠ BẢN (DATA & SSH KEY)
# ======================================================================

# 1. Tìm bản Linux Ubuntu 24.04 LTS mới nhất do Canonical phát hành
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

# 2. Tự động sinh ra 1 chìa khóa SSH (dùng thuật toán mã hóa RSA 4096 bit)
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# 3. Gửi phần Công khai (Public Key) của chìa khóa lên AWS
resource "aws_key_pair" "generated_key" {
  key_name   = "k8s-aws-key"
  public_key = tls_private_key.ssh.public_key_openssh
}

# 4. Lưu phần Bí mật (Private Key) xuống máy tính thành file private_key.pem để sau này dùng
resource "local_file" "private_key" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "${path.module}/private_key.pem"
  file_permission = "0400" # Cấp quyền 0400 (Chỉ cho phép đọc) để bảo mật
}

# ======================================================================
# PHẦN 2: TẠO MÁY CHỦ BASTION HOST (BÀN ĐẠP) Ở VÙNG MỞ (PUBLIC SUBNET)
# ======================================================================
# Nhiệm vụ: Đứng ở ngoài Internet để nhận lệnh SSH từ bạn (Terraform), 
# sau đó mới "nhảy" vào trong Vùng Kín để cài K8s.
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro" # Bị AWS khóa t2, chuyển sang t3.micro (Free Tier)
  key_name                    = aws_key_pair.generated_key.key_name
  subnet_id                   = aws_subnet.public_1.id # Đặt ở mạng Public
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  associate_public_ip_address = true # Có IP Public để Internet gọi vào được
  tags                        = { Name = "k8s-aws-bastion" }
}

# ======================================================================
# PHẦN 3: TẠO MÁY CHỦ K8S NODE GIẤU Ở VÙNG KÍN (PRIVATE SUBNET)
# ======================================================================
# Nhiệm vụ: Chứa Docker, Minikube và chạy App của bạn. Cực kỳ bảo mật.
resource "aws_instance" "k8s_node" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro" # Giữ nguyên t3.micro để hoàn toàn MIỄN PHÍ (Free Tier)
  key_name                    = aws_key_pair.generated_key.key_name
  subnet_id                   = aws_subnet.private_1.id # Giấu trong mạng Private
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  associate_public_ip_address = false # TUYỆT ĐỐI KHÔNG CÓ IP PUBLIC!

  # Cấp ổ cứng 20GB để đủ chỗ chứa K8s, Docker và các Image tải về
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }
  tags = { Name = "K8s-Minikube-Node-Private" }
}

# ======================================================================
# PHẦN 4: TUYỆT KỸ 1-CLICK XUYÊN TƯỜNG LỬA & DEPLOY 3 LỚP (DB-BE-FE)
# ======================================================================
resource "null_resource" "setup_k8s" {

  # BẮT BUỘC ĐỢI: Node K8s và NAT Gateway phải được tạo xong thì lệnh này mới chạy. 
  # Lý do: Node K8s cần NAT Gateway để đi ra ngoài Internet tải cài đặt.
  depends_on = [aws_instance.k8s_node, aws_nat_gateway.nat, aws_route_table_association.private_1]

  # CẤU HÌNH ĐƯỜNG HẦM SSH (SSH TUNNELING)
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.ssh.private_key_pem
    host        = aws_instance.k8s_node.private_ip # Nhắm thẳng vào Private IP

    # Đoạn này là "cầu nối": Đi qua Bastion Host trước
    bastion_host        = aws_instance.bastion.public_ip
    bastion_user        = "ubuntu"
    bastion_private_key = tls_private_key.ssh.private_key_pem
    timeout             = "5m"
  }

  # CÁC LỆNH SẼ ĐƯỢC CHẠY BÊN TRONG MÁY K8S NODE
  provisioner "remote-exec" {
    inline = [
      "set -ex",
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do sleep 2; done",

      # 0. TẠO RAM ẢO (SWAP): Lấy 2GB ổ cứng làm RAM để cứu cánh cho t3.micro
      "sudo fallocate -l 2G /swapfile",
      "sudo chmod 600 /swapfile",
      "sudo mkswap /swapfile",
      "sudo swapon /swapfile",
      "echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab",
      "sudo sysctl vm.swappiness=10",
    
      # 1. Cài đặt Docker bằng Script chuẩn gốc (Docker CE)
      "sudo apt-get update -y",
      "sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg --yes",
      "echo \"deb [signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt-get update -y",
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo curl -L \"https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose",
      "sudo chmod +x /usr/local/bin/docker-compose",
      "sudo usermod -aG docker ubuntu",
    
      # 2. Tải và cài đặt Minikube (Chạy K8s) & Kubectl (Điều khiển K8s)
      "curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64",
      "sudo install minikube-linux-amd64 /usr/local/bin/minikube",
      "curl -LO \"https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl\"",
      "sudo install kubectl /usr/local/bin/kubectl",

      # 3. Kích hoạt K8s Cluster (Ép chạy trên 1 CPU vì bị giới hạn Free Tier)
      "sudo chmod a+rw /var/run/docker.sock",
      "minikube start --force --driver=docker --ports=30000:30000 --extra-config=kubeadm.ignore-preflight-errors=NumCPU,Mem",

      # 4. VIẾT FILE CẤU HÌNH K8S (BAO GỒM DATABASE, BACKEND, FRONTEND)
      "cat << 'EOF' > ~/app.yaml",

      # -------------- KHỐI 1: DATABASE (MYSQL) --------------
      # ĐÃ CHUYỂN SANG DÙNG AWS RDS NÊN ĐOẠN NÀY ĐƯỢC ẨN ĐI
      # "apiVersion: apps/v1",
      # "kind: Deployment",
      # "metadata:",
      # "  name: my-database",
      # "spec:",
      # "  replicas: 1",
      # "  selector:",
      # "    matchLabels:",
      # "      app: database",
      # "  template:",
      # "    metadata:",
      # "      labels:",
      # "        app: database",
      # "    spec:",
      # "      containers:",
      # "      - name: db",
      # "        image: mysql:8.0", 
      # "        env:",
      # "        - name: MYSQL_ROOT_PASSWORD",
      # "          value: \"root123\"", 
      # "        - name: MYSQL_DATABASE",
      # "          value: \"mylabdb\"", 
      # "        ports:",
      # "        - containerPort: 3306",
      # "---",
      # "apiVersion: v1",
      # "kind: Service",
      # "metadata:",
      # "  name: database-svc",
      # "spec:",
      # "  type: ClusterIP",
      # "  selector:",
      # "    app: database",
      # "  ports:",
      # "    - protocol: TCP",
      # "      port: 3306",
      # "      targetPort: 3306",
      # "---",


      # -------------- KHỐI 2: BACKEND --------------
      "apiVersion: apps/v1",
      "kind: Deployment",
      "metadata:",
      "  name: my-backend",
      "spec:",
      "  replicas: 3",
      "  selector:",
      "    matchLabels:",
      "      app: backend",
      "  template:",
      "    metadata:",
      "      labels:",
      "        app: backend",
      "    spec:",
      "      containers:",
      "      - name: backend",
      "        image: huyhoang2609/lab_be:latest", # Image Backend của bạn
      "        env:",
      "        - name: DB_HOST",
      "          value: \"${aws_db_instance.mysql.address}\"", # Sử dụng AWS RDS
      "        - name: DB_USER",
      "          value: \"admin\"",
      "        - name: DB_PASSWORD",
      "          value: \"root12345\"",
      "        - name: DB_NAME",
      "          value: \"mylabdb\"",
      "        ports:",
      "        - containerPort: 5000", # Hãy đổi số 5000 này nếu API của bạn chạy port khác
      "---",
      # Service ClusterIP để ẩn Backend khỏi Internet, chỉ cho phép Frontend gọi vào
      "apiVersion: v1",
      "kind: Service",
      "metadata:",
      "  name: backend-svc",
      "spec:",
      "  type: ClusterIP",
      "  selector:",
      "    app: backend",
      "  ports:",
      "    - protocol: TCP",
      "      port: 5000", # Đổi port cho khớp với port bên trên
      "      targetPort: 5000",
      "---",

      # -------------- KHỐI 3: FRONTEND --------------
      "apiVersion: apps/v1",
      "kind: Deployment",
      "metadata:",
      "  name: my-frontend",
      "spec:",
      "  replicas: 3",
      "  selector:",
      "    matchLabels:",
      "      app: frontend",
      "  template:",
      "    metadata:",
      "      labels:",
      "        app: frontend",
      "    spec:",
      "      containers:",
      "      - name: frontend",
      "        image: huyhoang2609/lab_fe:latest", # Image Frontend của bạn
      "        ports:",
      "        - containerPort: 80", # Nginx thường chạy port 80
      "---",
      # Service NodePort để hứng traffic từ ALB bên ngoài AWS truyền vào
      "apiVersion: v1",
      "kind: Service",
      "metadata:",
      "  name: frontend-svc",
      "spec:",
      "  type: NodePort", # Khác biệt lớn nhất: NodePort!
      "  selector:",
      "    app: frontend",
      "  ports:",
      "    - protocol: TCP",
      "      port: 80",
      "      targetPort: 80",
      "      nodePort: 30000", # Nối cố định cổng 30000 để ăn khớp với cài đặt của Load Balancer
      "EOF",

      # 5. Phóng tàu vũ trụ: Đưa toàn bộ cấu hình 3 lớp trên lên chạy
      "kubectl apply -f ~/app.yaml",
    ]
  }
}
