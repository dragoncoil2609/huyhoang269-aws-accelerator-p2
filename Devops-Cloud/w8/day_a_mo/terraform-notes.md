# Ghi chú Terraform — W8-D1

---

## 1. Infrastructure as Code là gì?

**Infrastructure as Code**, viết tắt là **IaC**, là cách quản lý hạ tầng bằng các file cấu hình thay vì thao tác thủ công trên giao diện như AWS Console.

Với IaC, hạ tầng có thể được:
- Quản lý bằng Git
- Review trước khi thay đổi
- Tái sử dụng
- Chia sẻ cho team
- Tự động hóa
- Tạo lại nhiều lần một cách nhất quán

> **IaC giúp giảm lỗi do thao tác tay và giúp quá trình thay đổi hạ tầng an toàn hơn.**

---

## 2. Terraform là gì?

**Terraform** là một công cụ Infrastructure as Code của HashiCorp. 
Terraform cho phép kỹ sư DevOps định nghĩa hạ tầng bằng các file cấu hình dễ đọc và quản lý vòng đời của hạ tầng đó, bao gồm tạo mới, cập nhật và xóa tài nguyên.

Terraform có thể quản lý hạ tầng trên nhiều nền tảng khác nhau như:
- AWS
- Azure
- Google Cloud Platform
- Kubernetes
- GitHub
- Helm
- DataDog

---

## 3. Vì sao dùng Terraform?

Terraform có nhiều lợi ích so với việc quản lý hạ tầng thủ công:
- Có thể quản lý nhiều cloud provider khác nhau.
- Cấu hình dễ đọc, dễ viết.
- Có thể theo dõi thay đổi hạ tầng bằng `state`.
- Có thể lưu cấu hình vào Git để cộng tác.
- Giúp môi trường triển khai nhất quán hơn.
- Có thể tái sử dụng cấu hình thông qua `module`.

---

## 4. Provider là gì?

`Provider` là plugin giúp Terraform giao tiếp với các nền tảng hoặc dịch vụ bên ngoài thông qua API.

**Ví dụ:**
- AWS provider dùng để quản lý tài nguyên trên AWS
- Azure provider dùng để quản lý tài nguyên trên Azure
- Google provider dùng để quản lý tài nguyên trên GCP
- Kubernetes provider dùng để quản lý tài nguyên trong Kubernetes
- GitHub provider dùng để quản lý tài nguyên trên GitHub

> **Hiểu đơn giản:** Terraform dùng provider để “nói chuyện” với từng nền tảng.

**Ví dụ khai báo AWS provider:**
```hcl
provider "aws" {
  region = "ap-southeast-1"
}
```

---

## 5. Resource là gì?

`Resource` là một tài nguyên hạ tầng mà Terraform quản lý.

**Ví dụ resource trên AWS:**
- S3 bucket
- EC2 instance
- VPC
- Subnet
- Security Group
- RDS database

**Ví dụ:**
```hcl
resource "aws_s3_bucket" "demo" {
  bucket = "my-demo-bucket"
}
```

**Trong ví dụ trên:**
- `aws_s3_bucket` là loại resource
- `demo` là tên local trong Terraform
- `bucket` là thuộc tính của resource

---

## 6. Terraform có tính khai báo là gì?

Terraform sử dụng kiểu cấu hình **khai báo** (declarative), tức là mình mô tả trạng thái cuối cùng mong muốn của hạ tầng, thay vì viết từng bước thực hiện.

Ví dụ, thay vì ghi (imperative):
1. Mở AWS Console
2. Vào S3
3. Bấm Create Bucket
4. Nhập tên bucket
5. Bấm Save

Ta chỉ cần mô tả bằng Terraform:
```hcl
resource "aws_s3_bucket" "demo" {
  bucket = "my-demo-bucket"
}
```
Terraform sẽ tự tính toán những hành động cần làm để hạ tầng thật khớp với cấu hình mong muốn.

---

## 7. Workflow cơ bản của Terraform

Quy trình làm việc cơ bản với Terraform gồm:
1. **Scope** — Xác định hạ tầng cần tạo
2. **Author** — Viết file cấu hình Terraform
3. **Initialize** — Khởi tạo project và tải provider/plugin cần thiết
4. **Plan** — Xem trước các thay đổi Terraform sẽ thực hiện
5. **Apply** — Thực thi các thay đổi đã được lên kế hoạch

**Các lệnh Terraform thường dùng:**
```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform destroy
```

**Ý nghĩa từng lệnh:**
| Lệnh | Ý nghĩa |
| :--- | :--- |
| `terraform init` | Khởi tạo thư mục Terraform và tải provider cần thiết |
| `terraform fmt` | Format lại file cấu hình Terraform cho đúng chuẩn |
| `terraform validate` | Kiểm tra cấu hình có hợp lệ không |
| `terraform plan` | Xem trước Terraform sẽ tạo, sửa hoặc xóa gì |
| `terraform apply` | Thực hiện thay đổi thật lên hạ tầng |
| `terraform destroy` | Xóa các resource do Terraform quản lý |

---

## 8. Terraform State là gì?

Terraform sử dụng `state` để theo dõi hạ tầng thật mà nó đang quản lý. State lưu mapping giữa resource trong code Terraform và resource thật trên cloud.

**Ví dụ:**
```text
aws_s3_bucket.demo trong code Terraform
>> tương ứng với <<
một S3 bucket thật trên AWS
```

Terraform dựa vào state để biết resource nào cần tạo mới, resource nào cần cập nhật, và resource nào cần xóa.

> **Hiểu đơn giản:** `state` là bộ nhớ của Terraform về hạ tầng mà nó đang quản lý.

---

## 9. Remote State và cộng tác nhóm

Khi làm một mình, Terraform state có thể được lưu local trên máy. Nhưng khi làm việc theo nhóm, nên dùng **remote state** để nhiều người có thể chia sẻ state một cách an toàn.

**Một số cách lưu remote state:**
- HCP Terraform
- Terraform Cloud
- AWS S3 backend kết hợp state locking

**Lợi ích của Remote state:**
- Team dùng chung một state
- Tránh conflict khi nhiều người cùng thay đổi hạ tầng
- Lưu state an toàn hơn local
- Có thể tích hợp với GitHub/GitLab để review thay đổi hạ tầng

---

## 10. Cài đặt Terraform CLI

Terraform được phân phối dưới dạng một công cụ dòng lệnh, gọi là **Terraform CLI**.
Terraform CLI có thể được cài đặt trên nhiều hệ điều hành như: Windows, macOS, Linux.

**Trên Windows, có thể cài Terraform bằng Chocolatey:**
```bash
choco install terraform
```

Sau khi cài đặt, cần mở terminal mới và kiểm tra Terraform đã hoạt động hay chưa:
```bash
terraform -help
```

Có thể dùng `-help` với từng lệnh cụ thể để xem thêm chức năng và option:
```bash
terraform plan -help
```

Nếu dùng Bash hoặc Zsh, Terraform cũng hỗ trợ bật tự động hoàn thành lệnh bằng phím Tab:
```bash
terraform -install-autocomplete
```
> **Lưu ý:** Sau khi bật autocomplete, cần khởi động lại shell để tính năng có hiệu lực.

![Terraform CLI](./evidence/screenshots/Terraform%20CLI.jpg)

---

## 11. Cấu trúc cấu hình Terraform AWS cơ bản

Một project Terraform thường gồm các file `.tf`. Khi chạy Terraform trong một thư mục, Terraform sẽ đọc tất cả các file `.tf` trong thư mục đó.

**Ví dụ cấu trúc:**
```text
learn-terraform-get-started-aws/
  terraform.tf
  main.tf
```

### `terraform.tf`
File `terraform.tf` thường dùng để khai báo cấu hình Terraform, provider cần dùng và version yêu cầu.
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92"
    }
  }

  required_version = ">= 1.2"
}
```
**Ý nghĩa:**
- `required_providers`: khai báo các provider mà project cần sử dụng.
- `source`: địa chỉ provider trên Terraform Registry.
- `version`: ràng buộc version provider.
- `required_version`: version Terraform tối thiểu cần dùng.

### `main.tf`
File `main.tf` thường chứa provider, data source và resource chính.
```hcl
provider "aws" {
  region = "us-west-2"
}
```

---

## 11.1. Data source trong Terraform

`data` block dùng để đọc thông tin có sẵn từ cloud provider, không tạo resource mới.

**Ví dụ:**
```hcl
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  owners = ["099720109477"]
}
```
Ví dụ trên dùng để tìm AMI Ubuntu mới nhất. Nhờ đó không cần hard-code AMI ID trong cấu hình.

> **Điểm cần nhớ:**
> - `resource` = tạo hoặc quản lý resource thật
> - `data`     = đọc thông tin đã có

---

## 11.2. Resource EC2 instance

`resource` block dùng để định nghĩa tài nguyên hạ tầng Terraform sẽ quản lý.

**Ví dụ tạo EC2 instance:**
```hcl
resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  tags = {
    Name = "learn-terraform"
  }
}
```
**Trong đó:**
- `aws_instance` là loại resource.
- `app_server` là tên local trong Terraform.
- `ami` lấy giá trị từ data source `data.aws_ami.ubuntu.id`.
- `instance_type` là loại EC2 instance.
- `tags` dùng để gắn nhãn cho resource.
- Địa chỉ resource là: `aws_instance.app_server`

---

## 12. Input Variables

Input variables cho phép tham số hóa cấu hình Terraform. Thay vì hard-code giá trị trong `main.tf`, ta khai báo biến trong `variables.tf` và tham chiếu bằng cú pháp `var.<variable_name>`.

**Ví dụ:**
```hcl
variable "instance_name" {
  description = "Value of the EC2 instance's Name tag."
  type        = string
  default     = "learn-terraform"
}

variable "instance_type" {
  description = "The EC2 instance's type."
  type        = string
  default     = "t2.micro"
}
```

**Trong `main.tf`, có thể dùng:**
```hcl
resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  tags = {
    Name = var.instance_name
  }
}
```

**Lợi ích của variables:**
- Giảm hard-code
- Làm cấu hình linh hoạt hơn
- Dễ tái sử dụng cho nhiều môi trường
- Có thể truyền giá trị từ CLI, biến môi trường hoặc file `.tfvars`

**Ví dụ truyền biến qua CLI:** 
```bash
terraform plan -var instance_type=t2.large
```

---

## 13. Output Values

Output values cho phép hiển thị thông tin từ resource sau khi Terraform chạy.

**Ví dụ:**
```hcl
output "instance_hostname" {
  description = "Private DNS name of the EC2 instance."
  value       = aws_instance.app_server.private_dns
}
```
Sau khi apply, có thể xem output bằng lệnh: 
```bash
terraform output
```

Output hữu ích khi cần lấy thông tin hạ tầng để dùng cho công cụ khác hoặc để hiển thị lại các giá trị quan trọng như instance ID, public IP, private DNS, bucket name hoặc VPC ID.

---

## 14. Modules

Module là tập hợp cấu hình Terraform có thể tái sử dụng. Nó giúp quản lý các hạ tầng phức tạp gồm nhiều resource và data source một cách nhất quán hơn.

**Ví dụ dùng VPC module từ Terraform Registry:**
```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.19.0"

  name = "example-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24"]

  enable_dns_hostnames = true
}
```

> **Lưu ý:** Khi thêm module mới vào cấu hình, cần chạy lại: `terraform init` để tải module về workspace.

---

## 15. Dependency Graph

Terraform tự động xác định dependency giữa các resource dựa trên cách chúng tham chiếu lẫn nhau.

**Ví dụ:**
```hcl
subnet_id = module.vpc.private_subnets[0]
```
Dòng này cho Terraform biết EC2 phụ thuộc vào module VPC. Vì vậy Terraform phải tạo VPC/subnet trước rồi mới tạo EC2.

Khi tạo execution plan, Terraform xây dựng **dependency graph** để xác định thứ tự tạo, cập nhật hoặc xóa resource. Những resource không phụ thuộc nhau có thể được xử lý song song.

---

## 16. HCP Terraform và Remote State

Khi chạy Terraform trên máy cá nhân, state thường được lưu local trong file `terraform.tfstate`. Điều này có một số hạn chế:
- State nằm trên máy một người
- Khó chia sẻ state an toàn
- Dễ conflict nếu nhiều người cùng chạy Terraform
- Khó quản lý secret và credential
- Máy cá nhân trở thành một điểm lỗi duy nhất

**HCP Terraform** giúp giải quyết các vấn đề này bằng cách cung cấp:
- Remote state
- Remote runs
- Workspace management
- Secure variables
- Collaboration workflow

---

## 17. Terraform Login

Để Terraform CLI có thể giao tiếp với HCP Terraform, cần đăng nhập bằng lệnh:
```bash
terraform login
```
Lệnh này mở trình duyệt để tạo API token. Sau khi đăng nhập, Terraform CLI có thể kết nối với HCP Terraform.

---

## 18. Cloud Block

Để kết nối workspace local với HCP Terraform, thêm `cloud` block vào `terraform.tf`:
```hcl
terraform {
  cloud {
    organization = "your-organization-name"

    workspaces {
      project = "Learn Terraform"
      name    = "learn-terraform-aws-get-started"
    }
  }
}
```
**Ý nghĩa:**
- `organization`: tên organization trên HCP Terraform
- `project`: project chứa workspace
- `name`: tên workspace

Sau khi thêm cloud block, cần chạy lại:
```bash
terraform init
```

---

## 19. Remote Runs

Khi dùng HCP Terraform, người dùng vẫn có thể chạy lệnh từ máy local:
```bash
terraform apply
```
Tuy nhiên, plan/apply sẽ được **thực thi từ xa** trong HCP Terraform. Output của quá trình chạy sẽ được stream về terminal. Điều này giúp team có một môi trường chạy Terraform tập trung và an toàn hơn.

---

## 20. Quản lý AWS Credentials trong HCP Terraform

Vì HCP Terraform chạy plan/apply từ xa, workspace cần có AWS credentials để gọi AWS API.

Các biến thường cần cấu hình:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

> **Cảnh báo:** Các biến này nên được đánh dấu là Sensitive. KHÔNG NÊN hard-code access key hoặc secret key trực tiếp trong file Terraform.

---

## 21. Kiểu dữ liệu trong Terraform

Terraform hỗ trợ nhiều kiểu dữ liệu để khai báo biến và cấu hình resource rõ ràng hơn. Việc khai báo `type` cho variable giúp Terraform kiểm tra dữ liệu đầu vào đúng định dạng, giảm lỗi.

| Kiểu dữ liệu | Ý nghĩa | Ví dụ |
| :--- | :--- | :--- |
| `string` | Chuỗi | `"dev"` |
| `number` | Số | `2` |
| `bool` | Đúng/sai | `true` |
| `list(string)` | Danh sách | `["a", "b"]` |
| `map(string)` | Key-value | `{ Name = "demo" }` |
| `object({...})`| Object có cấu trúc | `{ name = "app", port = 8080 }` |

### 21.1. String
```hcl
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}
```

### 21.2. Number
```hcl
variable "instance_count" {
  description = "Number of instances"
  type        = number
  default     = 2
}
```

### 21.3. Bool
```hcl
variable "enable_monitoring" {
  description = "Enable detailed monitoring"
  type        = bool
  default     = true
}
```

### 21.4. List
```hcl
variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["ap-southeast-1a", "ap-southeast-1b"]
}
```

### 21.5. Map
```hcl
variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default = {
    Project     = "aws-accelerator-p2"
    Environment = "dev"
    Owner       = "student"
  }
}
```

### 21.6. Object
```hcl
variable "app_config" {
  description = "Application configuration"
  type = object({
    name        = string
    environment = string
    port        = number
    enabled     = bool
  })
  default = {
    name        = "demo-app"
    environment = "dev"
    port        = 8080
    enabled     = true
  }
}
```

---

## 22. Local Values

`locals` dùng để khai báo các giá trị nội bộ trong Terraform module. Local value thường được dùng khi một giá trị được sử dụng nhiều lần hoặc được tính toán từ các biến khác.

**Ví dụ:**
```hcl
locals {
  project_name = "aws-accelerator-p2"
  environment  = "dev"

  common_tags = {
    Project     = local.project_name
    Environment = local.environment
    ManagedBy   = "Terraform"
  }
}
```

**Sử dụng trong resource:**
```hcl
resource "aws_s3_bucket" "demo" {
  bucket = "ngobap-demo-bucket"
  tags   = local.common_tags
}
```

### Variable khác Local như thế nào?

| Thành phần | Ý nghĩa |
| :--- | :--- |
| `variable` | Giá trị đầu vào, có thể truyền từ bên ngoài |
| `local` | Giá trị nội bộ trong module, không truyền trực tiếp từ bên ngoài |
| `output` | Giá trị đầu ra sau khi Terraform chạy |

---

## 23. Expressions trong Terraform

Expression là cú pháp dùng để tính toán hoặc tham chiếu giá trị trong Terraform.

### 23.1. Tham chiếu
- **Variable**: `instance_type = var.instance_type`
- **Local**: `tags = local.common_tags`
- **Resource attribute**: `value = aws_instance.app_server.private_dns`

### 23.2. String interpolation
Dùng để nối nhiều giá trị thành một chuỗi:
```hcl
bucket = "${var.project_name}-${var.environment}-bucket"
```

### 23.3. Conditional expression
```hcl
condition ? true_value : false_value
```
Ví dụ:
```hcl
instance_type = var.environment == "prod" ? "t3.medium" : "t2.micro"
```

### 23.4. Function
Terraform có nhiều function hỗ trợ xử lý giá trị.
```hcl
bucket = lower("${var.project_name}-${var.environment}-bucket")
```

| Function | Ý nghĩa |
| :--- | :--- |
| `lower()` | Chuyển thành chữ thường |
| `upper()` | Chuyển thành chữ hoa |
| `length()` | Đếm số phần tử hoặc độ dài chuỗi |
| `join()` | Nối list thành chuỗi |
| `split()` | Tách chuỗi thành list |
| `toset()` | Chuyển list thành set |
| `merge()` | Gộp map/object |

### 23.5. For expression
Dùng để biến đổi list hoặc map.
```hcl
locals {
  environments = ["dev", "staging", "prod"]
  bucket_names = [
    for env in local.environments : "ngobap-${env}-bucket"
  ]
}
```

---

## 24. Meta-arguments

Meta-arguments là các argument đặc biệt do Terraform hỗ trợ, có thể dùng trong nhiều loại block như `resource`, `module`.

### 24.1. count
`count` dùng để tạo nhiều resource giống nhau theo số lượng.
```hcl
resource "aws_instance" "web" {
  count         = 2
  ami           = "ami-xxxx"
  instance_type = "t2.micro"

  tags = {
    Name = "web-${count.index}"
  }
}
```

### 24.2. for_each
`for_each` dùng để tạo nhiều resource dựa trên `map` hoặc `set`.
```hcl
resource "aws_s3_bucket" "bucket" {
  for_each = toset(["dev", "staging", "prod"])
  bucket   = "ngobap-${each.key}-bucket"
}
```

### 24.3. Sự khác nhau giữa count và for_each

| Tiêu chí | `count` | `for_each` |
| :--- | :--- | :--- |
| Dựa trên | Số lượng | Map hoặc set |
| Resource address | `[0]`, `[1]` | `["dev"]`, `["prod"]` |
| Phù hợp khi | Resource giống nhau | Resource có key riêng |
| Độ ổn định khi thay đổi list | Kém hơn | Tốt hơn |

### 24.4. depends_on
Dùng khi Terraform không tự suy luận được dependency.
```hcl
resource "aws_instance" "app" {
  ami           = "ami-xxxx"
  instance_type = "t2.micro"
  depends_on    = [aws_security_group.app_sg]
}
```

### 24.5. provider
Dùng khi một resource cần dùng một provider configuration cụ thể (ví dụ khác region).
```hcl
provider "aws" {
  alias  = "us"
  region = "us-west-2"
}

resource "aws_s3_bucket" "oregon" {
  provider = aws.us
  bucket   = "ngobap-oregon-bucket"
}
```

---

## 25. Lifecycle Block

`lifecycle` là một meta-argument đặc biệt dùng để tùy chỉnh cách Terraform tạo, cập nhật hoặc xóa resource.

### 25.1. create_before_destroy
Yêu cầu Terraform tạo resource mới trước, sau đó mới xóa resource cũ (giúp giảm downtime).
```hcl
lifecycle {
  create_before_destroy = true
}
```

### 25.2. prevent_destroy
Ngăn Terraform xóa resource quan trọng.
```hcl
lifecycle {
  prevent_destroy = true
}
```

### 25.3. ignore_changes
Yêu cầu Terraform bỏ qua thay đổi của một số attribute nếu bị sửa ngoài AWS Console.
```hcl
lifecycle {
  ignore_changes = [tags]
}
```

### 25.4. replace_triggered_by
Thay thế resource khi một resource hoặc attribute khác thay đổi.
```hcl
lifecycle {
  replace_triggered_by = [
    aws_security_group.app_sg
  ]
}
```

---

## 26. Xóa hạ tầng bằng Terraform

Terraform không chỉ dùng để tạo và cập nhật hạ tầng, mà còn dùng để xóa hạ tầng do nó quản lý.

### Cách 1: Xóa resource khỏi configuration rồi apply
Xóa hoặc comment block resource đó trong file `.tf`, sau đó chạy:
```bash
terraform apply
```
Terraform sẽ tạo execution plan để xóa resource đó. (Lưu ý xóa luôn các `outputs.tf` tham chiếu tới resource).

### Cách 2: `terraform destroy`
Khi không còn cần toàn bộ hạ tầng trong workspace:
```bash
terraform destroy
```
Terraform sẽ xóa **toàn bộ resource** đang được Terraform quản lý trong workspace (sau khi bạn xác nhận `yes`).
