# Ghi chú Terraform — W8-D1

## 1. Infrastructure as Code là gì?

Infrastructure as Code, viết tắt là IaC, là cách quản lý hạ tầng bằng các file cấu hình thay vì thao tác thủ công trên giao diện như AWS Console.

Với IaC, hạ tầng có thể được:

* Quản lý bằng Git
* Review trước khi thay đổi
* Tái sử dụng
* Chia sẻ cho team
* Tự động hóa
* Tạo lại nhiều lần một cách nhất quán

-> IaC giúp giảm lỗi do thao tác tay và giúp quá trình thay đổi hạ tầng an toàn hơn.

## 2. Terraform là gì?

Terraform là một công cụ Infrastructure as Code của HashiCorp.

Terraform cho phép kỹ sư DevOps định nghĩa hạ tầng bằng các file cấu hình dễ đọc và quản lý vòng đời của hạ tầng đó, bao gồm tạo mới, cập nhật và xóa tài nguyên.

Terraform có thể quản lý hạ tầng trên nhiều nền tảng khác nhau như:

* AWS
* Azure
* Google Cloud Platform
* Kubernetes
* GitHub
* Helm
* DataDog

## 3. Vì sao dùng Terraform?

Terraform có nhiều lợi ích so với việc quản lý hạ tầng thủ công:

* Có thể quản lý nhiều cloud provider khác nhau
* Cấu hình dễ đọc, dễ viết
* Có thể theo dõi thay đổi hạ tầng bằng `state`
* Có thể lưu cấu hình vào Git để cộng tác
* Giúp môi trường triển khai nhất quán hơn
* Có thể tái sử dụng cấu hình thông qua `module`

## 4. Provider là gì?

`Provider` là plugin giúp Terraform giao tiếp với các nền tảng hoặc dịch vụ bên ngoài thông qua API.

Ví dụ:

* AWS provider dùng để quản lý tài nguyên trên AWS
* Azure provider dùng để quản lý tài nguyên trên Azure
* Google provider dùng để quản lý tài nguyên trên GCP
* Kubernetes provider dùng để quản lý tài nguyên trong Kubernetes
* GitHub provider dùng để quản lý tài nguyên trên GitHub

Hiểu đơn giản: Terraform dùng provider để “nói chuyện” với từng nền tảng.

Ví dụ khai báo AWS provider:

```hcl
provider "aws" {
  region = "ap-southeast-1"
}
```

## 5. Resource là gì?

`Resource` là một tài nguyên hạ tầng mà Terraform quản lý.

Ví dụ resource trên AWS:

* S3 bucket
* EC2 instance
* VPC
* Subnet
* Security Group
* RDS database

Ví dụ:

```hcl
resource "aws_s3_bucket" "demo" {
  bucket = "my-demo-bucket"
}
```

Trong ví dụ trên:

* `aws_s3_bucket` là loại resource
* `demo` là tên local trong Terraform
* `bucket` là thuộc tính của resource

## 6. Terraform có tính khai báo là gì?

Terraform sử dụng kiểu cấu hình khai báo, tức là mình mô tả trạng thái cuối cùng mong muốn của hạ tầng, thay vì viết từng bước thực hiện.

Ví dụ, thay vì ghi:

* Mở AWS Console
* Vào S3
* Bấm Create Bucket
* Nhập tên bucket
* Bấm Save

Ta chỉ cần mô tả bằng Terraform:

```hcl
resource "aws_s3_bucket" "demo" {
  bucket = "my-demo-bucket"
}
```

Terraform sẽ tự tính toán những hành động cần làm để hạ tầng thật khớp với cấu hình mong muốn.

## 7. Workflow cơ bản của Terraform

Quy trình làm việc cơ bản với Terraform gồm:

1. Scope — Xác định hạ tầng cần tạo
2. Author — Viết file cấu hình Terraform
3. Initialize — Khởi tạo project và tải provider/plugin cần thiết
4. Plan — Xem trước các thay đổi Terraform sẽ thực hiện
5. Apply — Thực thi các thay đổi đã được lên kế hoạch

Các lệnh Terraform thường dùng:

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform destroy
```

Ý nghĩa từng lệnh:

* `terraform init`: khởi tạo thư mục Terraform và tải provider cần thiết
* `terraform fmt`: format lại file cấu hình Terraform cho đúng chuẩn
* `terraform validate`: kiểm tra cấu hình có hợp lệ không
* `terraform plan`: xem trước Terraform sẽ tạo, sửa hoặc xóa gì
* `terraform apply`: thực hiện thay đổi thật lên hạ tầng
* `terraform destroy`: xóa các resource do Terraform quản lý

## 8. Terraform State là gì?

Terraform sử dụng `state` để theo dõi hạ tầng thật mà nó đang quản lý.

State lưu mapping giữa resource trong code Terraform và resource thật trên cloud.

Ví dụ:

```txt
aws_s3_bucket.demo trong code Terraform
tương ứng với
một S3 bucket thật trên AWS
```

Terraform dựa vào state để biết resource nào cần tạo mới, resource nào cần cập nhật, và resource nào cần xóa.

Hiểu đơn giản: `state` là bộ nhớ của Terraform về hạ tầng mà nó đang quản lý.

## 9. Remote State và cộng tác nhóm

Khi làm một mình, Terraform state có thể được lưu local trên máy.

Khi làm việc theo nhóm, nên dùng remote state để nhiều người có thể chia sẻ state một cách an toàn.

Một số cách lưu remote state:

* HCP Terraform
* Terraform Cloud
* AWS S3 backend kết hợp state locking

Remote state giúp:

* Team dùng chung một state
* Tránh conflict khi nhiều người cùng thay đổi hạ tầng
* Lưu state an toàn hơn local
* Có thể tích hợp với GitHub/GitLab để review thay đổi hạ tầng
## 10. Cài đặt Terraform CLI

Terraform được phân phối dưới dạng một công cụ dòng lệnh, gọi là Terraform CLI.

Terraform CLI có thể được cài đặt trên nhiều hệ điều hành như:

* Windows
* macOS
* Linux

Trên Windows, có thể cài Terraform bằng Chocolatey:

```bash
choco install terraform
```

Ngoài cách dùng package manager, cũng có thể cài Terraform thủ công bằng cách tải binary từ HashiCorp.

Sau khi cài đặt, cần mở terminal mới và kiểm tra Terraform đã hoạt động hay chưa:

```bash
terraform -help
```

Lệnh này hiển thị danh sách các lệnh con của Terraform, ví dụ:

* `init`
* `plan`
* `apply`
* `destroy`
* `fmt`
* `validate`

Có thể dùng `-help` với từng lệnh cụ thể để xem thêm chức năng và option:

```bash
terraform plan -help
```

Ví dụ, lệnh trên dùng để xem hướng dẫn chi tiết cho `terraform plan`.

Nếu dùng Bash hoặc Zsh, Terraform cũng hỗ trợ bật tự động hoàn thành lệnh bằng phím Tab:

```bash
terraform -install-autocomplete
```

Sau khi bật autocomplete, cần khởi động lại shell để tính năng có hiệu lực.

Tóm lại, trước khi làm việc với Terraform project, cần đảm bảo Terraform CLI đã được cài đặt và terminal nhận được lệnh `terraform`.
![Terraform CLI](./evidence/screenshots/Terraform%20CLI.jpg)

## 11. Cấu trúc cấu hình Terraform AWS cơ bản

Một project Terraform thường gồm các file `.tf`. Khi chạy Terraform trong một thư mục, Terraform sẽ đọc tất cả các file `.tf` trong thư mục đó.

Ví dụ cấu trúc:

```txt
learn-terraform-get-started-aws/
  terraform.tf
  main.tf
```
**terraform.tf**
- File terraform.tf thường dùng để khai báo cấu hình Terraform, provider cần dùng và version yêu cầu.
- Ví dụ: 
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
*Ý nghĩa:*
- required_providers: khai báo các provider mà project cần sử dụng.
- source: địa chỉ provider trên Terraform Registry.
- version: ràng buộc version provider.
- required_version: version Terraform tối thiểu cần dùng.

**main.tf**

File main.tf thường chứa provider, data source và resource chính.

Ví dụ:
```
provider "aws" {
  region = "us-west-2"
}
```

Provider block cấu hình AWS provider và region dùng để tạo resource.

## Data source trong Terraform

data block dùng để đọc thông tin có sẵn từ cloud provider, không tạo resource mới.

Ví dụ:
```
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

Điểm cần nhớ:
- resource = tạo hoặc quản lý resource thật
- data     = đọc thông tin đã có

## Resource EC2 instance

resource block dùng để định nghĩa tài nguyên hạ tầng Terraform sẽ quản lý.

Ví dụ tạo EC2 instance:
```
resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  tags = {
    Name = "learn-terraform"
  }
}
```
Trong đó:
- aws_instance là loại resource.
- app_server là tên local trong Terraform.
- ami lấy giá trị từ data source data.aws_ami.ubuntu.id.
- instance_type là loại EC2 instance.
- tags dùng để gắn nhãn cho resource.
- Địa chỉ resource là: aws_instance.app_server

## 12. Input Variables
Input variables cho phép tham số hóa cấu hình Terraform. Thay vì hard-code giá trị trong `main.tf`, ta khai báo biến trong `variables.tf` và tham chiếu bằng cú pháp `var.<variable_name>`.

Ví dụ:

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
Trong main.tf, có thể dùng:
```
resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  tags = {
    Name = var.instance_name
  }
}
```

Lợi ích của variables:
- Giảm hard-code
- Làm cấu hình linh hoạt hơn
- Dễ tái sử dụng cho nhiều môi trường
- Có thể truyền giá trị từ CLI, biến môi trường hoặc file .tfvars

Ví dụ truyền biến qua CLI: terraform plan -var instance_type=t2.large
## 13. Output Values
Output values cho phép hiển thị thông tin từ resource sau khi Terraform chạy.

Ví dụ:
```
output "instance_hostname" {
  description = "Private DNS name of the EC2 instance."
  value       = aws_instance.app_server.private_dns
}
```
Sau khi apply, có thể xem output bằng: terraform output

Output hữu ích khi cần lấy thông tin hạ tầng để dùng cho công cụ khác hoặc để hiển thị lại các giá trị quan trọng như instance ID, public IP, private DNS, bucket name hoặc VPC ID.
## 14. Modules

Module là tập hợp cấu hình Terraform có thể tái sử dụng.

Module giúp quản lý các hạ tầng phức tạp gồm nhiều resource và data source một cách nhất quán hơn.

Ví dụ dùng VPC module từ Terraform Registry:
```
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
Khi thêm module mới vào cấu hình, cần chạy lại: terraform init

Lý do là Terraform cần tải module về workspace.

## 15. Dependency Graph

Terraform tự động xác định dependency giữa các resource dựa trên cách chúng tham chiếu lẫn nhau.

Ví dụ:

subnet_id = module.vpc.private_subnets[0]

Dòng này cho Terraform biết EC2 phụ thuộc vào module VPC. Vì vậy Terraform phải tạo VPC/subnet trước rồi mới tạo EC2.

Khi tạo execution plan, Terraform xây dựng dependency graph để xác định thứ tự tạo, cập nhật hoặc xóa resource. Những resource không phụ thuộc nhau có thể được xử lý song song.
## 22. Xóa hạ tầng bằng Terraform

Terraform không chỉ dùng để tạo và cập nhật hạ tầng, mà còn dùng để xóa hạ tầng do nó quản lý.

Có 2 cách xóa resource phổ biến:

### Cách 1: Xóa resource khỏi configuration rồi apply

Nếu một resource đang được Terraform quản lý trong state, nhưng bị xóa hoặc comment khỏi file cấu hình `.tf`, Terraform sẽ hiểu rằng resource đó không còn nằm trong desired state.

Khi chạy:

```bash
terraform apply
```
-> Terraform sẽ tạo execution plan để xóa resource đó.

Ví dụ plan: Plan: 0 to add, 0 to change, 1 to destroy.

Cách này phù hợp khi chỉ muốn xóa một vài resource riêng lẻ.

Lưu ý: nếu outputs.tf vẫn tham chiếu đến resource đã bị xóa khỏi configuration, cần xóa hoặc comment output đó, nếu không cấu hình sẽ không hợp lệ.
## Cách 2: terraform destroy

Khi không còn cần toàn bộ hạ tầng trong workspace, có thể chạy:

terraform destroy

Lệnh này sẽ xóa toàn bộ resource đang được Terraform quản lý trong workspace.

Terraform sẽ hiển thị plan destroy và yêu cầu xác nhận:

Only 'yes' will be accepted to confirm.

Chỉ khi nhập yes, Terraform mới thực hiện xóa resource thật.

## 16. HCP Terraform và Remote State

Khi chạy Terraform trên máy cá nhân, state thường được lưu local trong file `terraform.tfstate`.

Cách này có một số hạn chế khi làm việc nhóm:

- State nằm trên máy một người
- Khó chia sẻ state an toàn
- Dễ conflict nếu nhiều người cùng chạy Terraform
- Khó quản lý secret và credential
- Máy cá nhân trở thành một điểm lỗi duy nhất

HCP Terraform giúp giải quyết các vấn đề này bằng cách cung cấp:

- Remote state
- Remote runs
- Workspace management
- Secure variables
- Collaboration workflow

## 17. Terraform Login

Để Terraform CLI có thể giao tiếp với HCP Terraform, cần đăng nhập bằng lệnh:

```bash
terraform login
```
Lệnh này mở trình duyệt để tạo API token. Sau khi đăng nhập, Terraform CLI có thể kết nối với HCP Terraform.
## 18. Cloud Block

Để kết nối workspace local với HCP Terraform, thêm cloud block vào terraform.tf:
```
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
- organization: tên organization trên HCP Terraform
- project: project chứa workspace
- name: tên workspace

Sau khi thêm cloud block, cần chạy lại:

terraform init

Terraform có thể hỏi có muốn migrate state local lên HCP Terraform hay không.

## 19. Remote Runs

Khi dùng HCP Terraform, người dùng vẫn có thể chạy lệnh từ máy local:

terraform apply

Tuy nhiên, plan/apply sẽ được thực thi từ xa trong HCP Terraform. Output của quá trình chạy sẽ được stream về terminal.

Điều này giúp team có một môi trường chạy Terraform tập trung và an toàn hơn.

## 20. Quản lý AWS Credentials trong HCP Terraform

Vì HCP Terraform chạy plan/apply từ xa, workspace cần có AWS credentials để gọi AWS API.

Các biến thường cần cấu hình:

AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY

Các biến này nên được đánh dấu là Sensitive.

Không nên hard-code access key hoặc secret key trực tiếp trong file Terraform.

# 21. Kiểu dữ liệu trong Terraform

Terraform hỗ trợ nhiều kiểu dữ liệu để khai báo biến và cấu hình resource rõ ràng hơn.

Việc khai báo `type` cho variable giúp Terraform kiểm tra dữ liệu đầu vào đúng định dạng, giảm lỗi khi chạy `plan` hoặc `apply`.

## 1.1. String

`string` là kiểu chuỗi văn bản.

Ví dụ:

```hcl
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}
```

Sử dụng:

```hcl
tags = {
  Environment = var.environment
}
```

## 1.2. Number

`number` là kiểu số.

Ví dụ:

```hcl
variable "instance_count" {
  description = "Number of instances"
  type        = number
  default     = 2
}
```

## 1.3. Bool

`bool` là kiểu đúng/sai, gồm `true` hoặc `false`.

Ví dụ:

```hcl
variable "enable_monitoring" {
  description = "Enable detailed monitoring"
  type        = bool
  default     = true
}
```

## 1.4. List

`list` là danh sách các giá trị cùng kiểu.

Ví dụ:

```hcl
variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["ap-southeast-1a", "ap-southeast-1b"]
}
```

Sử dụng phần tử đầu tiên:

```hcl
availability_zone = var.availability_zones[0]
```

## 1.5. Map

`map` là tập hợp key-value, thường dùng cho tags hoặc cấu hình theo môi trường.

Ví dụ:

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

Sử dụng:

```hcl
tags = var.common_tags
```

## 1.6. Object

`object` dùng để gom nhiều thuộc tính khác nhau vào một biến có cấu trúc rõ ràng.

Ví dụ:

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

Sử dụng:

```hcl
tags = {
  App         = var.app_config.name
  Environment = var.app_config.environment
}
```

## 1.7. Tóm tắt kiểu dữ liệu

| Kiểu dữ liệu    | Ý nghĩa            | Ví dụ                           |
| --------------- | ------------------ | ------------------------------- |
| `string`        | Chuỗi              | `"dev"`                         |
| `number`        | Số                 | `2`                             |
| `bool`          | Đúng/sai           | `true`                          |
| `list(string)`  | Danh sách          | `["a", "b"]`                    |
| `map(string)`   | Key-value          | `{ Name = "demo" }`             |
| `object({...})` | Object có cấu trúc | `{ name = "app", port = 8080 }` |

# 22. Local Values

`locals` dùng để khai báo các giá trị nội bộ trong Terraform module.

Local value thường được dùng khi một giá trị được sử dụng nhiều lần hoặc được tính toán từ các biến khác.

## 2.1. Ví dụ locals

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

Sử dụng trong resource:

```hcl
resource "aws_s3_bucket" "demo" {
  bucket = "ngobap-demo-bucket"

  tags = local.common_tags
}
```

## 2.2. Variable khác Local như thế nào?

| Thành phần | Ý nghĩa                                                          |
| ---------- | ---------------------------------------------------------------- |
| `variable` | Giá trị đầu vào, có thể truyền từ bên ngoài                      |
| `local`    | Giá trị nội bộ trong module, không truyền trực tiếp từ bên ngoài |
| `output`   | Giá trị đầu ra sau khi Terraform chạy                            |

## 2.3. Khi nào dùng locals?

Dùng `locals` khi:

* Muốn tránh lặp lại cùng một giá trị nhiều lần
* Muốn gom tags chung
* Muốn tạo naming convention
* Muốn tính toán giá trị trung gian từ variables

Ví dụ naming convention:

```hcl
locals {
  name_prefix = "${var.project_name}-${var.environment}"
}
```

Sử dụng:

```hcl
bucket = "${local.name_prefix}-bucket"
```

# 23. Expressions trong Terraform

Expression là cú pháp dùng để tính toán hoặc tham chiếu giá trị trong Terraform.

Trong Terraform, nhiều chỗ có thể dùng expression, ví dụ:

* Gán giá trị cho argument
* Tham chiếu variable
* Tham chiếu local
* Tham chiếu resource attribute
* Dùng điều kiện
* Gọi function
* Dùng for expression

## 3.1. Tham chiếu variable

```hcl
instance_type = var.instance_type
```

Ý nghĩa: lấy giá trị từ biến `instance_type`.

## 3.2. Tham chiếu local

```hcl
tags = local.common_tags
```

Ý nghĩa: lấy giá trị từ local `common_tags`.

## 3.3. Tham chiếu resource attribute

```hcl
value = aws_instance.app_server.private_dns
```

Ý nghĩa: lấy thuộc tính `private_dns` từ resource `aws_instance.app_server`.

## 3.4. String interpolation

```hcl
bucket = "${var.project_name}-${var.environment}-bucket"
```

Ý nghĩa: nối nhiều giá trị thành một chuỗi.

Ví dụ nếu:

```hcl
project_name = "p2"
environment  = "dev"
```

thì kết quả là:

```txt
p2-dev-bucket
```

## 3.5. Conditional expression

Cú pháp:

```hcl
condition ? true_value : false_value
```

Ví dụ:

```hcl
instance_type = var.environment == "prod" ? "t3.medium" : "t2.micro"
```

Ý nghĩa:

* Nếu `environment` là `prod` thì dùng `t3.medium`
* Ngược lại dùng `t2.micro`

## 3.6. Function

Terraform có nhiều function hỗ trợ xử lý giá trị.

Ví dụ:

```hcl
bucket = lower("${var.project_name}-${var.environment}-bucket")
```

`lower()` dùng để chuyển chuỗi thành chữ thường.

Một số function thường gặp:

| Function   | Ý nghĩa                          |
| ---------- | -------------------------------- |
| `lower()`  | Chuyển thành chữ thường          |
| `upper()`  | Chuyển thành chữ hoa             |
| `length()` | Đếm số phần tử hoặc độ dài chuỗi |
| `join()`   | Nối list thành chuỗi             |
| `split()`  | Tách chuỗi thành list            |
| `toset()`  | Chuyển list thành set            |
| `merge()`  | Gộp map/object                   |

## 3.7. For expression

Dùng để biến đổi list hoặc map.

Ví dụ:

```hcl
locals {
  environments = ["dev", "staging", "prod"]

  bucket_names = [
    for env in local.environments : "ngobap-${env}-bucket"
  ]
}
```

Kết quả:

```txt
[
  "ngobap-dev-bucket",
  "ngobap-staging-bucket",
  "ngobap-prod-bucket"
]
```


# 24. Meta-arguments

Meta-arguments là các argument đặc biệt do Terraform hỗ trợ, có thể dùng trong nhiều loại block như `resource`, `module`.

Các meta-arguments quan trọng:

* `count`
* `for_each`
* `depends_on`
* `provider`
* `lifecycle`

---

## 4.1. count

`count` dùng để tạo nhiều resource giống nhau theo số lượng.

Ví dụ:

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

Kết quả Terraform tạo:

```txt
aws_instance.web[0]
aws_instance.web[1]
```

`count.index` là chỉ số của từng resource, bắt đầu từ 0.

## Khi nào dùng count?

Dùng `count` khi:

* Muốn tạo nhiều resource giống nhau
* Số lượng resource được quyết định bằng một con số
* Các resource không cần key riêng có ý nghĩa

Ví dụ:

```hcl
count = var.instance_count
```

---

## 4.2. for_each

`for_each` dùng để tạo nhiều resource dựa trên `map` hoặc `set`.

Ví dụ:

```hcl
resource "aws_s3_bucket" "bucket" {
  for_each = toset(["dev", "staging", "prod"])

  bucket = "ngobap-${each.key}-bucket"
}
```

Kết quả Terraform tạo:

```txt
aws_s3_bucket.bucket["dev"]
aws_s3_bucket.bucket["staging"]
aws_s3_bucket.bucket["prod"]
```

## Khi nào dùng for_each?

Dùng `for_each` khi:

* Mỗi resource có key riêng
* Muốn quản lý resource theo tên rõ ràng
* Dữ liệu đầu vào là map hoặc set

Ví dụ với map:

```hcl
variable "buckets" {
  type = map(string)

  default = {
    dev     = "ngobap-dev-bucket"
    staging = "ngobap-staging-bucket"
    prod    = "ngobap-prod-bucket"
  }
}

resource "aws_s3_bucket" "bucket" {
  for_each = var.buckets

  bucket = each.value
}
```

---

## 4.3. count khác for_each như thế nào?

| Tiêu chí                     | count               | for_each              |
| ---------------------------- | ------------------- | --------------------- |
| Dựa trên                     | Số lượng            | Map hoặc set          |
| Resource address             | `[0]`, `[1]`        | `["dev"]`, `["prod"]` |
| Phù hợp khi                  | Resource giống nhau | Resource có key riêng |
| Độ ổn định khi thay đổi list | Kém hơn             | Tốt hơn               |

Ví dụ:

```txt
count    = tạo 3 EC2 giống nhau
for_each = tạo bucket theo từng môi trường dev/staging/prod
```

---

## 4.4. depends_on

Terraform thường tự động xác định dependency thông qua việc tham chiếu giữa các resource.

Ví dụ:

```hcl
subnet_id = module.vpc.private_subnets[0]
```

Dòng này làm Terraform hiểu rằng EC2 phụ thuộc vào VPC module.

Tuy nhiên, trong một số trường hợp dependency không thể hiện rõ bằng tham chiếu, ta có thể dùng `depends_on`.

Ví dụ:

```hcl
resource "aws_instance" "app" {
  ami           = "ami-xxxx"
  instance_type = "t2.micro"

  depends_on = [aws_security_group.app_sg]
}
```

## Khi nào dùng depends_on?

Dùng `depends_on` khi:

* Terraform không tự suy luận được dependency
* Có dependency logic nhưng không có tham chiếu attribute trực tiếp
* Cần đảm bảo resource A được tạo trước resource B

Không nên lạm dụng `depends_on`. Nếu có thể tham chiếu trực tiếp resource attribute, nên để Terraform tự xây dependency graph.

---

## 4.5. provider meta-argument

`provider` meta-argument dùng khi một resource cần dùng một provider configuration cụ thể.

Ví dụ có nhiều region AWS:

```hcl
provider "aws" {
  region = "ap-southeast-1"
}

provider "aws" {
  alias  = "us"
  region = "us-west-2"
}
```

Resource dùng provider mặc định:

```hcl
resource "aws_s3_bucket" "singapore" {
  bucket = "ngobap-singapore-bucket"
}
```

Resource dùng provider alias:

```hcl
resource "aws_s3_bucket" "oregon" {
  provider = aws.us

  bucket = "ngobap-oregon-bucket"
}
```

Ý nghĩa:

```txt
aws_s3_bucket.oregon sẽ được tạo ở region us-west-2
```

---

# 25. Lifecycle Block

`lifecycle` là một meta-argument đặc biệt dùng để tùy chỉnh cách Terraform tạo, cập nhật hoặc xóa resource.

Các option quan trọng:

* `create_before_destroy`
* `prevent_destroy`
* `ignore_changes`
* `replace_triggered_by`

---

## 5.1. create_before_destroy

Mặc định, nếu một thay đổi buộc Terraform phải thay thế resource, Terraform có thể xóa resource cũ rồi tạo resource mới.

`create_before_destroy` yêu cầu Terraform tạo resource mới trước, sau đó mới xóa resource cũ.

Ví dụ:

```hcl
resource "aws_instance" "app" {
  ami           = "ami-xxxx"
  instance_type = "t2.micro"

  lifecycle {
    create_before_destroy = true
  }
}
```

## Khi nào dùng create_before_destroy?

Dùng khi muốn giảm downtime.

Ví dụ:

```txt
Tạo instance mới trước
Sau đó mới xóa instance cũ
```

Lưu ý: không phải resource nào cũng hỗ trợ tốt cách này, vì có thể bị trùng tên hoặc giới hạn tài nguyên.

---

## 5.2. prevent_destroy

`prevent_destroy` dùng để ngăn Terraform xóa resource quan trọng.

Ví dụ:

```hcl
resource "aws_s3_bucket" "important" {
  bucket = "important-data-bucket"

  lifecycle {
    prevent_destroy = true
  }
}
```

Nếu chạy:

```bash
terraform destroy
```

Terraform sẽ báo lỗi và không xóa resource này.

## Khi nào dùng prevent_destroy?

Dùng cho resource quan trọng như:

* Database production
* S3 bucket chứa dữ liệu quan trọng
* VPC production
* Resource khó khôi phục

Lưu ý: `prevent_destroy` không bảo vệ resource nếu người dùng xóa trực tiếp trên AWS Console. Nó chỉ ngăn Terraform destroy resource.

---

## 5.3. ignore_changes

`ignore_changes` dùng để yêu cầu Terraform bỏ qua thay đổi của một số attribute.

Ví dụ:

```hcl
resource "aws_instance" "app" {
  ami           = "ami-xxxx"
  instance_type = "t2.micro"

  lifecycle {
    ignore_changes = [tags]
  }
}
```

Ý nghĩa:

```txt
Nếu tags bị thay đổi bên ngoài Terraform, Terraform sẽ không cố sửa lại tags trong lần plan/apply sau.
```

## Khi nào dùng ignore_changes?

Dùng khi:

* Một số attribute được hệ thống khác quản lý
* Có tag được AWS hoặc tool khác tự động thêm
* Không muốn Terraform liên tục báo drift cho attribute đó

Không nên lạm dụng `ignore_changes`, vì có thể làm Terraform bỏ qua thay đổi quan trọng.

---

## 5.4. replace_triggered_by

`replace_triggered_by` dùng để yêu cầu Terraform thay thế resource khi một resource hoặc attribute khác thay đổi.

Ví dụ:

```hcl
resource "aws_instance" "app" {
  ami           = "ami-xxxx"
  instance_type = "t2.micro"

  lifecycle {
    replace_triggered_by = [
      aws_security_group.app_sg
    ]
  }
}
```

Ý nghĩa:

```txt
Nếu aws_security_group.app_sg thay đổi, Terraform sẽ replace aws_instance.app.
```










