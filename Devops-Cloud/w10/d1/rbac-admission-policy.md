1. RBAC trong Kubernetes là gì?

RBAC (Role-Based Access Control) là cơ chế phân quyền trong Kubernetes.

👉 Nó quyết định:

“AI được phép làm gì với resource nào?”

Thành phần chính
🔹 Role / ClusterRole
Role: áp dụng trong 1 namespace
ClusterRole: áp dụng toàn cluster

Ví dụ:

rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "create"]
🔹 RoleBinding / ClusterRoleBinding
Gán Role cho:
User
Group
ServiceAccount
Cách RBAC hoạt động
User gửi request (vd: kubectl apply)
API Server kiểm tra:
User có Role không?
Role có quyền đó không?
Nếu hợp lệ → cho phép
⚠️ Lưu ý

RBAC chỉ kiểm soát:

WHO + WHAT

👉 Không kiểm soát:

Nội dung resource (ví dụ image có phải nginx không?)

➡️ Đây là lý do cần Admission Policy

2. Admission Controller / Admission Policy
Là gì?

Admission Controller là bước kiểm tra bổ sung sau RBAC

👉 Nó trả lời:

“Resource này có hợp lệ không?”

Flow đầy đủ trong Kubernetes
Request → Authentication → Authorization (RBAC)
        → Admission Controller → Persist etcd
2 loại Admission Controller
🔹 Mutating Admission
Có thể chỉnh sửa resource
Ví dụ:
Tự thêm label
Inject sidecar
🔹 Validating Admission
Chỉ cho phép / từ chối
Ví dụ:
Không cho dùng image latest
Không cho chạy container root
3. OPA (Open Policy Agent)

Open Policy Agent là một policy engine chung, dùng để viết rule bằng ngôn ngữ Rego

Ví dụ Rego đơn giản
deny[msg] {
  input.request.kind.kind == "Pod"
  input.request.object.spec.containers[_].image == "nginx:latest"
  msg = "Không được dùng latest tag"
}

👉 OPA không gắn trực tiếp vào Kubernetes → cần tool trung gian

4. Gatekeeper (OPA for Kubernetes)

OPA Gatekeeper là implementation của OPA cho Kubernetes

2 khái niệm quan trọng
🔹 ConstraintTemplate
Định nghĩa rule (Rego)
🔹 Constraint
Áp dụng rule vào cluster
Flow Gatekeeper
User apply YAML
→ API Server
→ Gatekeeper (OPA)
→ Check policy
→ Allow / Deny
Ví dụ use case
Bắt buộc:
Có label owner
Không dùng latest
CPU limit phải set
5. ValidatingAdmissionPolicy (Native K8s 1.30+)

ValidatingAdmissionPolicy là cách native (không cần OPA)

👉 Dùng CEL (Common Expression Language)

Ví dụ
spec:
  validations:
  - expression: "object.spec.containers.all(c, c.image != 'nginx:latest')"
Ưu điểm
Không cần cài thêm tool
Nhẹ, native
Nhược điểm
Không mạnh như Rego
Ít flexible hơn OPA
6. Kyverno (Alternative)

Kyverno là tool khác thay thế OPA

👉 Điểm mạnh:

Viết policy bằng YAML (không cần học Rego)
Dễ dùng hơn
Ví dụ Kyverno
validate:
  message: "Không dùng latest"
  pattern:
    spec:
      containers:
      - image: "!*:latest"
7. So sánh nhanh
Tool	Ngôn ngữ	Dễ dùng	Mạnh
RBAC	YAML	✅	❌
OPA	Rego	❌	✅
Gatekeeper	Rego	❌	✅
Kyverno	YAML	✅	⚠️
ValidatingAdmissionPolicy	CEL	⚠️	⚠️
8. Tổng kết (Quan trọng)

👉 Khi design security trong Kubernetes:

🔹 RBAC
Kiểm soát ai được làm gì
🔹 Admission Policy
Kiểm soát làm như thế nào có hợp lệ không
🎯 Ví dụ thực tế
RBAC:
Dev chỉ được deploy Pod
Admission:
Pod:
Không được dùng latest
Phải có resource limit
Không chạy root
9. Mindset quan trọng (đi thi hay hỏi)

👉 Chuẩn DevOps:

RBAC = WHO can do WHAT
Admission = WHAT is allowed