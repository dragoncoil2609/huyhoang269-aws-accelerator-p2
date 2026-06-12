# Kế Hoạch Thực Hành: AWS Monitoring (CloudWatch & SNS)

Tài liệu này trình bày các bước thực hiện cấu hình hệ thống giám sát và cảnh báo trên AWS sử dụng Amazon CloudWatch và Amazon SNS.

## Bài 1: CPU Alarm → Email Alert via SNS
**Mục tiêu:** Gửi email cảnh báo khi mức độ sử dụng CPU của EC2 vượt ngưỡng 80% liên tục trong 5 phút.

### Bước 1: Tạo SNS Topic & Subscription
1. Truy cập giao diện AWS Console và điều hướng đến dịch vụ **SNS (Simple Notification Service)**.
2. Chọn **Create Topic**.
   - Type: **Standard**
   - Name: Đặt tên cho topic (Ví dụ: `EC2-CPU-Alerts`).
3. Sau khi tạo xong, chuyển sang tab **Subscriptions** và chọn **Create subscription**.
   - Protocol: **Email**
   - Endpoint: Nhập địa chỉ email người nhận cảnh báo.
4. Kiểm tra hộp thư đến, tìm email xác nhận từ AWS và tiến hành **Confirm subscription**.
![Xác nhận SNS](./image/sns-confirm.png)

### Bước 2: Tạo CloudWatch Alarm
1. Truy cập dịch vụ **CloudWatch** -> **Alarms** -> **All alarms** -> **Create alarm**.
2. Chọn **Select metric**.
   - Chọn mục **EC2** -> **Per-Instance Metrics**.
   - Lọc theo Instance ID của EC2 cần giám sát và chọn metric **CPUUtilization**.

### Bước 3: Cấu hình Điều kiện Báo động (Conditions)
Thiết lập các thông số cảnh báo theo yêu cầu:
- **Metric Name:** CPUUtilization
- **Period:** 5 minutes
- **Conditions:**
  - Threshold type: Static
  - Whenever CPUUtilization is: **Greater/Equal (>=)** hoặc **Greater (>)**
  - than: **80**
- **Datapoints to alarm:** 1 out of 1.
![Cấu hình CloudWatch Alarm](./image/cloudwatch-alarm.png)

### Bước 4: Cấu hình Hành động Gửi Email (Actions)
- Tại bước Configure actions:
  - Alarm state trigger: **In alarm**
  - Send notification to the following SNS topic: Lựa chọn SNS Topic `EC2-CPU-Alerts` đã tạo ở Bước 1.
- Tiến hành đặt tên cho Alarm (Ví dụ: `High-CPU-Alarm`) và lưu cấu hình.
- Có thể sử dụng công cụ `stress` trên EC2 hoặc CLI để giả lập cảnh báo và kiểm tra khả năng gửi email.
![Email Cảnh Báo](./image/email-received.png)

---

## Bài 2: Installing the CloudWatch Agent on EC2
**Mục tiêu:** Cài đặt CloudWatch Agent để thu thập các số liệu chuyên sâu từ hệ điều hành của EC2 (như Memory, Disk usage) và gửi lên hệ thống CloudWatch.

### Điều kiện tiên quyết: Gắn IAM Role cho EC2
Đảm bảo EC2 đang được phân quyền IAM Role chứa Policy: **`CloudWatchAgentServerPolicy`**. 

### Bước 1: Cài đặt gói phần mềm Agent
Thực hiện kết nối SSH vào EC2 và chạy lệnh cài đặt:

- **Đối với hệ điều hành Amazon Linux:**
  ```bash
  sudo yum install amazon-cloudwatch-agent -y
  ```
- **Đối với hệ điều hành Ubuntu:**
  ```bash
  sudo apt-get update
  sudo apt-get install collectd -y
  wget https://amazoncloudwatch-agent.s3.amazonaws.com/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
  sudo dpkg -i -E ./amazon-cloudwatch-agent.deb
  ```
![Cài đặt Agent](./image/install-agent.png)

### Bước 2: Khởi tạo tệp cấu hình bằng Wizard
Chạy lệnh sau để kích hoạt trình hướng dẫn (wizard) cấu hình:
```bash
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard
```
Có thể lựa chọn các thiết lập mặc định bằng cách nhấn Enter. Hệ thống sẽ sinh ra tệp cấu hình JSON tại thư mục cài đặt.

### Bước 3: Kích hoạt Agent với cấu hình vừa tạo
Thực thi lệnh sau để nạp cấu hình (fetch-config) và khởi động CloudWatch Agent:
```bash
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json
```

### Bước 4: Kiểm tra trạng thái hoạt động của Agent
Xác minh Agent đang chạy bình thường bằng câu lệnh:
```bash
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m ec2 -a status
```
Khi cài đặt thành công, trạng thái sẽ hiển thị `"status": "running"`.
![Trạng thái Agent](./image/agent-status.png)
