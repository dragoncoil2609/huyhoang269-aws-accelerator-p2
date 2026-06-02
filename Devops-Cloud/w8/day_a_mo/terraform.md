## Bước 1: Khai báo "Nguyên liệu" (Variables)
Giống như nấu ăn, bạn phải chuẩn bị nguyên liệu (tham số cấu hình) trước để không phải ghi chết (hardcode) dữ liệu vào logic.

1. **Tạo file `variables.tf`:** Khai báo các biến cần thiết.
   - `aws_region`: Khu vực deploy.
   - `project_name`, `environment`: Dùng để nối chuỗi tạo tên tài nguyên.
   - `aws_access_key`, `aws_secret_key`: Thông tin xác thực AWS. (Lưu ý: Thêm thuộc tính `sensitive = true` để bảo mật).
   > [!TIP]
   > Không nên đặt giá trị `default` cho các biến này. Hãy biến file này thành một "khuôn đúc" (Template) thuần túy.

2. **Tạo file `terraform.tfvars`:** Truyền giá trị thật vào các biến trên.
   - Điền Access Key và Secret Key thật của bạn vào đây.
   > [!WARNING]
   > File `.tfvars` chứa thông tin nhạy cảm. Tuyệt đối không được commit file này lên Git (phải thêm vào `.gitignore`)

---

## Bước 2: Gọi  Providers
Terraform cần biết bạn muốn làm việc với nền tảng nào (AWS, Azure, GCP...) và lưu sổ sách (state) ở đâu.

1. **Tạo file `providers.tf`:**
   - **Khối `terraform`:** Khai báo `required_version` và `required_providers` (chỉ định dùng provider `aws`).
   - **Khối `provider "aws"`:** Truyền các biến xác thực (`var.aws_region`, `var.aws_access_key`, `var.aws_secret_key`) từ Bước 1 vào.
   - **Khối `backend "s3"`:** Định nghĩa nơi lưu file `terraform.tfstate`. 
   > [!IMPORTANT]
   > Ở lần chạy đầu tiên, S3 Bucket dùng để lưu state chưa tồn tại. Bạn phải `# comment` toàn bộ khối `backend "s3"` lại để chạy Local State trước.

---

## Bước 3: Resources
Đây là bản vẽ kiến trúc chính, định nghĩa các tài nguyên sẽ được tạo ra trên AWS.

1. **Tạo file `main.tf`:**
   - **Khối `locals`:** Gom nhóm các giá trị lặp đi lặp lại. Ví dụ: Tính toán `name_prefix = "${var.project_name}-${var.environment}"` và gộp các `common_tags`.
   - **Resource số 1 (State Bucket):** Khai báo `aws_s3_bucket` để tạo cái rổ chứa State. Bật tính năng Versioning cho nó (`aws_s3_bucket_versioning`) để có thể khôi phục file state nếu bị hỏng.
   - **Resource số 2 (App Bucket):** Khai báo một `aws_s3_bucket` khác để chứa dữ liệu ứng dụng.

2. **Thiết lập phụ thuộc (Dependencies):**
   - **Implicit Dependency (Ngầm định):** Trong tên của App Bucket, gọi đến ID của State Bucket (`${aws_s3_bucket.state_bucket.id}`). Terraform sẽ tự hiểu phải tạo State Bucket xong mới lấy được ID.
   - **Explicit Dependency (Tường minh):** Thêm khối `depends_on = [aws_s3_bucket_versioning.state_versioning]` vào App Bucket để ép Terraform phải bật Versioning xong xuôi thì mới được tạo App Bucket.

---

## Bước 4: Nghiệm thu công trình (Outputs)
Thay vì phải đăng nhập vào giao diện AWS Console lặn lội đi tìm xem cái Bucket ID hay ARN nó là gì, hãy bảo Terraform in ra màn hình cho bạn.

1. **Tạo file `outputs.tf`:** 
   - Khai báo các khối `output` để in ra giá trị mong muốn.
   - Ví dụ: `value = aws_s3_bucket.app_bucket.id`.
   - Cứ mỗi lần chạy `terraform apply` xong, kết quả sẽ hiện ngay trên Terminal.

---

## Bước 5: Thi công thực tế (Vấn đề con gà quả trứng)
Sau khi viết xong 4 file trên, hãy mở Terminal và chạy theo thứ tự:

1. Đảm bảo khối `backend "s3"` trong `providers.tf` đang bị **comment**.
2. Chạy `terraform init` (Khởi tạo local).
3. Chạy `terraform apply` (Tạo 2 S3 bucket trên AWS).
4. Chạy `terraform init -migrate-state` (Di chuyển file state từ máy tính lên S3).

🎉 Hoàn tất! Hạ tầng của bạn đã chạy thành công trên AWS và State đã được quản lý an toàn trên Cloud.