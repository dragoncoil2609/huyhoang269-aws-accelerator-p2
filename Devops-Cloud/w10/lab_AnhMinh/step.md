# Lab: Detect Sensitive Data in Amazon S3 Buckets using Amazon Macie

## Tổng quan Kiến trúc (Architecture)
Bài lab này triển khai luồng phát hiện dữ liệu nhạy cảm tự động trên AWS với các thành phần sau:
1. Tạo một S3 Bucket và tải lên file chứa dữ liệu nhạy cảm (Sample files).
2. Kích hoạt Amazon Macie và tạo Job để quét S3 Bucket đó.
3. Khi Macie phát hiện dữ liệu nhạy cảm, hệ thống sẽ tạo ra các Cảnh báo (Findings).
4. Sử dụng Amazon EventBridge để bắt các sự kiện (Findings) này và tự động kích hoạt một Rule.
5. EventBridge chuyển tiếp cảnh báo tới Amazon SNS.
6. Amazon SNS gửi Email cảnh báo (Alerts on Email) trực tiếp về địa chỉ email được cấu hình.

---

## Các Bước Triển Khai Bằng Terraform (Infrastructure as Code)

Để tối ưu hóa quá trình triển khai thay vì thao tác thủ công trên giao diện AWS Console, **Terraform** được sử dụng để tự động hóa toàn bộ việc khởi tạo hạ tầng. Mã nguồn Terraform được lưu trữ trong thư mục `terraform/`.

### Bước 1: Khởi tạo S3 Bucket và Dữ liệu nhạy cảm (`s3.tf`)
- Khởi tạo S3 bucket `macie-lab-bucket-huyhoang269-tf`.
- Tự động tạo một object (file) `sensitive-data.txt` chứa dữ liệu thẻ tín dụng giả và upload trực tiếp lên S3 Bucket vừa tạo.

### Bước 2: Cấu hình Amazon SNS để nhận Email (`sns.tf`)
- Khởi tạo SNS Topic mang tên `Macie-Alert-Topic`.
- Tạo một Subscription với giao thức Email và đăng ký địa chỉ email nhận cảnh báo (`nguyenvanhuyhoang2609@gmail.com`).
- Thiết lập SNS Topic Policy cho phép EventBridge có quyền `sns:Publish` tin nhắn vào Topic này.
- **Xác nhận Email:** Truy cập hộp thư email và nhấn "Confirm subscription" từ thư của AWS để xác nhận việc nhận cảnh báo.

### Bước 3: Cấu hình Amazon EventBridge (`eventbridge.tf`)
- Tạo một Rule mang tên `Macie-Finding-To-SNS` để theo dõi các sự kiện trên hệ thống.
- Rule này được thiết lập để lọc và bắt chính xác các sự kiện có `detail-type` là `Macie Finding`.
- Cấu hình Target của Rule trỏ thẳng về SNS Topic đã tạo ở Bước 2.

### Bước 4: Kích hoạt Amazon Macie và Tạo Job quét (`macie.tf`)
- Kích hoạt dịch vụ Amazon Macie trên tài khoản AWS (`aws_macie2_account`).
- Tạo một Classification Job (loại `ONE_TIME`) trỏ trực tiếp vào S3 bucket ở Bước 1 để thực hiện rà quét dữ liệu nhạy cảm.

### Bước 5: Thực thi và Chờ kết quả
- Thực thi lệnh `terraform init` và `terraform apply -auto-approve` để hệ thống tự động triển khai toàn bộ hạ tầng.
- Sau khi Terraform hoàn tất, tiến hành theo dõi trạng thái Job trên giao diện Macie và chờ đợi quá trình phân tích file kết thúc.

---

## Kết Quả Nghiệm Thu (Evidence)

Sau khi Job quét hoàn tất, hệ thống đã ghi nhận lỗi và tự động kích hoạt luồng sự kiện gửi cảnh báo về email thành công. Dưới đây là bằng chứng thực hiện:

### 1. Bằng chứng phát hiện dữ liệu nhạy cảm trên giao diện Macie
- Tại giao diện Amazon Macie, mục **Findings**, hệ thống đã phát hiện thành công và hiển thị cảnh báo `SensitiveData:S3Object...` báo cáo file bị lộ dữ liệu.

![Macie Detect Finding](macie-finding.png)

### 2. Bằng chứng nhận được Email Cảnh Báo
- Hệ thống EventBridge và SNS đã phối hợp gửi thành công đoạn mã JSON chứa thông tin chi tiết về báo cáo của Macie trực tiếp vào hộp thư email.

![Macie Email Alert](macie-email-alert.png)
