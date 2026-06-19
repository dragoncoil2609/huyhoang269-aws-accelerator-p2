1. Secrets Rotation là gì?

👉 Secrets = password, API key, DB credential…

❗ Problem
Hardcode trong code / YAML
Lưu lâu không đổi
Leak → bị hack toàn hệ thống
✅ Secrets Rotation

Tự động thay đổi secrets định kỳ

Ví dụ:
DB password rotate mỗi 30 ngày
Token expire sau 1h
🔧 Tool phổ biến
1. AWS Secrets Manager
Lưu secrets an toàn
Auto rotation (Lambda)
Versioning

👉 Flow:

App → AWS Secrets Manager → lấy secret
                ↑
          Auto rotate
2. External Secrets Operator (ESO)

👉 Bridge giữa Kubernetes và secret store (AWS, GCP…)

Cách hoạt động:
AWS Secrets Manager
        ↓
External Secrets Operator
        ↓
Kubernetes Secret
        ↓
Pod dùng
Ví dụ ESO
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: aws-secrets
  target:
    name: db-secret

👉 refreshInterval = auto sync secret mới

3. Sealed Secrets

👉 Giải bài toán:

Muốn commit secret lên Git (GitOps)
Cách làm:
Secret → encrypt → SealedSecret → commit Git

👉 Chỉ cluster mới decrypt được

⚠️ So sánh nhanh
Tool	Use case
AWS Secrets Manager	Lưu + rotate
ESO	Sync vào K8s
Sealed Secrets	GitOps
2. Supply Chain Security là gì?

👉 Bảo vệ toàn bộ pipeline:

Code → Build → Image → Deploy
❗ Problem
Image chứa malware
Dependency bị hack
CI/CD bị inject code
Image bị giả mạo
3. Image Scanning (CI)
🔍 Trivy

👉 Scan:

CVE
Secret leak
Misconfig
Ví dụ:
trivy image myapp:latest

👉 Dùng trong CI:

Fail build nếu có vuln
4. Image Signing (Integrity)
🔐 Cosign (Sigstore)

👉 Đảm bảo:

Image này là authentic

2 cách ký
🔹 Key-based
Dùng private key
🔹 Keyless (OIDC) ⭐ (modern)
Login bằng GitHub / Google
Không cần quản lý key
Flow
Build image
→ cosign sign
→ push registry
5. Verify Image (Admission)

👉 Đây là phần cực quan trọng

🔥 Kyverno Verify Images

👉 Kubernetes chỉ cho deploy nếu:

Image đã được ký
Signature hợp lệ
Ví dụ policy
verifyImages:
- image: "*"
  key: cosign.pub
Flow đầy đủ
Dev push image
→ Signed bằng Cosign
→ CI scan bằng Trivy
→ Deploy
→ Kyverno verify signature
→ OK thì chạy
6. SLSA Framework
🏆 SLSA

👉 Chuẩn bảo mật supply chain

4 level
Level	Ý nghĩa
1	Basic CI
2	Build service
3	Trusted build
4	Hermetic + reproducible
Mục tiêu:
Không ai inject code được
Build phải traceable
Artifact phải verify được
7. Tổng hợp toàn bộ kiến trúc 🔥
🎯 Secure Pipeline chuẩn
1. Code
   ↓
2. CI (GitHub Actions)
   - Scan (Trivy)
   ↓
3. Build Image
   ↓
4. Sign Image (Cosign)
   ↓
5. Push Registry
   ↓
6. CD (ArgoCD / Flux)
   ↓
7. Admission (Kyverno)
   - Verify signature
   ↓
8. Runtime
   - Secret từ AWS Secrets Manager (ESO)
8. Mapping theo DevOps mindset
🔐 Secrets
AWS Secrets Manager → store
ESO → inject
Rotation → auto update
🔐 Supply Chain
Step	Tool
Scan	Trivy
Sign	Cosign
Verify	Kyverno
Standard	SLSA
9. Câu hỏi vấn đáp hay gặp 🔥
❓ RBAC vs Secrets vs Supply Chain khác gì?
Layer	Mục tiêu
RBAC	Ai được làm gì
Secrets	Bảo vệ credential
Supply Chain	Bảo vệ pipeline
❓ Tại sao cần verify image?

👉 Vì:

Hacker có thể push image giả vào registry
❓ Tại sao cần rotation?

👉 Vì:

Secret leak là inevitible
10. Mindset quan trọng (rất hay hỏi)
Security không phải 1 layer
→ mà là nhiều layer:
RBAC + Admission + Secrets + Supply Chain