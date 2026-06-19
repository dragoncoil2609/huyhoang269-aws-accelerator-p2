1. Resource Control trong Kubernetes (Cost Guard nội bộ)
🎯 Mục tiêu
Tránh dev “đốt tài nguyên”
Tránh 1 team làm crash cluster
🔹 Kubernetes ResourceQuota

👉 Giới hạn tổng tài nguyên theo namespace

Ví dụ:
apiVersion: v1
kind: ResourceQuota
spec:
  hard:
    requests.cpu: "4"
    requests.memory: 8Gi
    pods: "10"

👉 Nghĩa là:

Namespace này max:
4 CPU
8GB RAM
10 pods
🔹 LimitRange

👉 Giới hạn per Pod / Container

Ví dụ:
apiVersion: v1
kind: LimitRange
spec:
  limits:
  - default:
      cpu: "500m"
      memory: "512Mi"
    defaultRequest:
      cpu: "200m"
      memory: "256Mi"
⚠️ Sự khác nhau (rất hay hỏi)
	ResourceQuota	LimitRange
Scope	Namespace	Pod/Container
Mục tiêu	Tổng	Từng instance
Use case	Multi-team	Control dev
🔥 Best practice (thi hay hỏi)
LimitRange → enforce default
ResourceQuota → enforce upper bound
2. Cost Guard (Cloud Level)
🔹 AWS Cost Anomaly Detection

👉 Detect:

Chi phí tăng bất thường
Spike bất ngờ
Flow
AWS Billing
→ ML detect anomaly
→ Alert (email / SNS)
Ví dụ thực tế
Bình thường $50/ngày
Hôm nay $300 → alert 🚨
🔥 Kết hợp với Kubernetes

👉 Root cause thường là:

Pod scale quá nhiều
Memory leak
Infinite loop job
3. Chaos Engineering (Reliability)
🎯 Mục tiêu

Test hệ thống khi FAIL chứ không phải khi OK

🔹 LitmusChaos
🔹 Chaos Mesh
Các loại chaos phổ biến
Type	Ví dụ
Pod	kill pod
Node	shutdown node
Network	delay / drop
CPU	spike
Ví dụ:
Kill pod random mỗi 5 phút
→ xem system có auto recover không
🔥 Mục tiêu thật sự
Test:
HPA
Auto healing
Retry logic
Circuit breaker
4. Runbook (SRE mindset)
🔹 Google SRE Workbook

👉 Runbook = hướng dẫn xử lý sự cố

Khi nào dùng?
Alert firing
Incident xảy ra
Nội dung chuẩn
1. Symptom (triệu chứng)
2. Possible causes
3. Debug steps
4. Fix steps
5. Escalation
Ví dụ
Alert: CPU > 90%

→ Check:
- kubectl top pod
- HPA status

→ Fix:
- scale deployment
5. Platform Integration (BIG PICTURE)
🎯 Một platform chuẩn sẽ có:
Dev deploy
↓
LimitRange (auto set resource)
↓
ResourceQuota (block nếu vượt)
↓
Cluster chạy
↓
Chaos test (fail simulation)
↓
Monitoring detect issue
↓
AWS Cost detect anomaly
↓
Runbook xử lý
6. Kiến trúc tổng thể (rất hay hỏi Tech Lead)
[ Developer ]
      ↓
[ Kubernetes ]
  - LimitRange
  - ResourceQuota
      ↓
[ Cluster Runtime ]
      ↓
[ Chaos Engineering ]
      ↓
[ Monitoring + Alert ]
      ↓
[ AWS Cost Anomaly ]
      ↓
[ Runbook Response ]
7. Mapping theo mindset Platform Engineer
Layer	Tool	Mục tiêu
Resource control	LimitRange	tránh over-request
Resource control	ResourceQuota	tránh overuse
Cost	AWS Cost Anomaly	detect spike
Reliability	Chaos Mesh	test failure
Operation	Runbook	xử lý sự cố
8. Câu hỏi vấn đáp hay gặp 🔥
❓ Nếu không dùng ResourceQuota thì sao?

👉 1 team có thể:

Chiếm hết CPU
Crash cluster
❓ Chaos Engineering để làm gì?

👉 Để:

Verify hệ thống chịu lỗi
❓ Cost spike thường do đâu?

👉 90%:

Auto scaling sai
Memory leak
Loop job
9. Mindset quan trọng
System tốt không phải system không lỗi
→ mà là system chịu lỗi tốt