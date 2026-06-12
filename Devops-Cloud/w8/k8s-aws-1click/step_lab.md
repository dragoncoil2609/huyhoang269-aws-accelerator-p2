# 🚀 BÍ KÍP TRIỂN KHAI K8S TRÊN AWS (CHUẨN PRODUCTION)

> [!IMPORTANT]  
> **Mục tiêu bài Lab:** Xây dựng hệ thống tự động hóa 100% bằng Terraform để triển khai cụm Kubernetes (Minikube) chạy mô hình 3 lớp (Database - Backend - Frontend) hoàn toàn nằm trong mạng nội bộ (Private Subnet) siêu bảo mật.

---

## 🧠 QUYẾT ĐỊNH KIẾN TRÚC: REMOTE-EXEC VS USER DATA

Để tự động hóa cài đặt K8s Node nằm trong mạng Private, hệ thống đã **KHÔNG sử dụng User Data** truyền thống mà chọn giải pháp nâng cao: **`null_resource` kết hợp `remote-exec` (SSH Tunneling qua Bastion Host)**. Quyết định này giải quyết triệt để 4 điểm yếu chí mạng của User Data:

| Tiêu chí | Dùng User Data truyền thống | Dùng Remote-Exec (Lựa chọn của chúng ta) |
|---|---|---|
| **1. Tính phụ thuộc mạng (Dependency)** | EC2 boot lên là chạy script ngay. Nếu lúc đó NAT Gateway chưa kịp tạo xong ➔ Mất mạng ➔ Tải Docker thất bại. | Terraform thông minh chờ NAT Gateway khởi tạo xong hoàn toàn mới chạy script (`depends_on`). Tỷ lệ thành công 100%. |
| **2. Bắt lỗi (Troubleshooting)** | Chạy ngầm trong bóng tối. Muốn xem log cài đặt phải chui vào server đọc file `/var/log/cloud-init-output.log` rất tốn thời gian. | Terraform in log cài đặt trực tiếp (Real-time) ra màn hình máy tính cá nhân. Lỗi ở dòng nào báo chữ đỏ ở dòng đó ngay lập tức. |
| **3. Cấp quyền User (Permissions)** | Chạy bằng quyền `root` ẩn. Sinh ra lỗi `Permission Denied` khi bạn SSH vào bằng tài khoản `ubuntu` và gõ lệnh `kubectl get pods`. | Chạy trực tiếp bằng tài khoản `ubuntu` thông qua giao thức SSH (`user="ubuntu"`). Setup xong SSH vào là dùng được lệnh ngay, không rườm rà. |
| **4. Khả năng chạy lại (Re-runnable)** | Script chạy **duy nhất 1 lần** trong vòng đời máy ảo. Nếu gõ sai 1 chữ trong script, bắt buộc phải Terminate hủy máy tạo lại từ đầu. | Bị lỗi chỗ nào, sửa code chỗ đó rồi gõ lại `terraform apply`. Terraform sẽ chui vào EC2 chạy tiếp đoạn script đó mà không cần xóa máy. |

---

## 🏗️ 1. SƠ ĐỒ KIẾN TRÚC MẠNG (ARCHITECTURE FLOW)

Hệ thống được chia làm 2 phân vùng mạng rõ rệt để đảm bảo an ninh tối đa:

![Sơ đồ Kiến trúc](image/image.png)

> [!TIP]
> **Tại sao cần NAT Gateway và Bastion Host?**
> Vì K8s Node nằm trong Vùng Kín (Private Subnet) nên không có Public IP. 
> - Cần **NAT Gateway** để K8s Node có thể "đi ké" ra Internet tải Docker/Minikube.
> - Cần **Bastion Host** để Terraform có thể SSH làm bàn đạp chui vào K8s Node cài đặt.

---

## 🔄 2. LUỒNG DỮ LIỆU BÊN TRONG K8S (TRAFFIC FLOW)

Khi 1 Request từ Internet đi vào hệ thống, nó sẽ trải qua các bước sau:

| Bước | Thành phần | Mô tả |
|---|---|---|
| 1️⃣ | **Internet ➔ ALB** | User gọi vào địa chỉ miền của Load Balancer qua cổng `80` (HTTP). |
| 2️⃣ | **ALB ➔ K8s Node** | ALB nhận diện và đẩy traffic xuyên tường lửa vào `Private IP` của K8s Node qua cổng `30000`. |
| 3️⃣ | **K8s Node ➔ Frontend**| Minikube nhận lệnh ở cổng `30000` (NodePort) và đẩy vào `Frontend Pod` (Cổng `80`). |
| 4️⃣ | **Frontend ➔ Backend** | FE xử lý giao diện, gọi API của BE thông qua tên nội bộ `backend-svc:5000` (ClusterIP). |
| 5️⃣ | **Backend ➔ Database** | BE gọi xuống DB để lấy dữ liệu thông qua tên nội bộ `database-svc:3306` (ClusterIP). |

> [!NOTE]  
> Các Service dạng **ClusterIP** (Database, Backend) là hoàn toàn vô hình với bên ngoài, chỉ có các Pod trong cụm K8s mới nhìn thấy nhau.

---

## 🛠️ 3. CÁC BƯỚC THỰC HIỆN BẰNG TERRAFORM

Quá trình xây dựng hạ tầng được chia nhỏ vào các file `.tf` để dễ quản lý.

| File cấu hình | Chức năng chính | Trạng thái |
|---|---|:---:|
| `providers.tf` | 📦 Khai báo các công cụ sẽ dùng (`aws`, `tls`, `local`, `null`). | ✅ |
| `network.tf` | 🌐 Tạo lưới điện: `VPC`, `Subnets`, `IGW`, `NAT Gateway`, `Route Tables` & `Security Groups`. | ✅ |
| `main.tf` | 💻 Tạo máy chủ `Bastion`, `K8s Node`, SSH keys và **chạy kịch bản 1-Click** cài K8s + Deploy App. | ✅ |
| `alb.tf` | 🔀 Tạo Load Balancer đứng ngoài cổng, đón khách và điều phối vào trong `Target Group`. | ✅ |

---

## 🚀 4. KÍCH HOẠT HỆ THỐNG

Chỉ với 1 dòng lệnh duy nhất, Terraform sẽ tự động làm thay bạn mọi việc: dựng server, cấu hình mạng, chui vào server cài Docker, bật K8s và kéo source code của bạn về chạy.

```bash
terraform apply -auto-approve
```

> [!CAUTION]
> Quá trình triển khai sẽ mất khoảng **5 đến 7 phút** vì AWS cần thời gian cấp phát NAT Gateway, sau đó K8s Node mới có Internet để tự động cài đặt Minikube ngầm bên trong. Vui lòng kiên nhẫn!

---

## 📸 5. KẾT QUẢ VÀ MINH CHỨNG (EVIDENCE)

### Minh chứng 1: Hạ tầng được tạo thành công bởi Terraform

![Thành quả Terraform](image/terraform-success.png)

### Minh chứng 2: Website hoạt động trơn tru qua Load Balancer

![Giao diện Website](image/web-ui.png)

### Minh chứng 3: Bên trong Kubernetes Cluster

![Kubernetes Pods](image/k8s-pods.png)