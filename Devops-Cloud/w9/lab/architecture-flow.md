# Luồng Chạy Tổng Thể: Từ Code Đến K8s (GitOps & Auto-Canary)

Để dễ nhìn hơn, sếp xem biểu đồ Tuần tự (Sequence Diagram) dưới đây nhé. Biểu đồ này thể hiện rõ ràng từng bước theo dòng thời gian, không bị rối mắt như biểu đồ khối:

```mermaid
sequenceDiagram
    autonumber
    actor Dev as Lập trình viên
    participant GitApp as Kho App (GitHub)
    participant GH as GitHub Actions (CI)
    participant Docker as Docker Hub
    participant GitOps as Kho GitOps (GitHub)
    participant Argo as ArgoCD (K8s)
    participant Rollout as Argo Rollout (K8s)
    participant Prom as Prometheus (K8s)
    participant Alert as Alertmanager (K8s)

    Note over Dev, Docker: Giai đoạn 1: Build & Đóng gói (Continuous Integration)
    Dev->>GitApp: Push code tính năng mới
    GitApp->>GH: Kích hoạt luồng chạy CI
    GH->>Docker: Build Image & Push (ví dụ: v2.0)
    GH->>GitOps: Tự động cập nhật file api.yaml (chuyển sang bản v2.0)

    Note over GitOps, Rollout: Giai đoạn 2: Triển khai tự động (Continuous Deployment)
    Argo->>GitOps: Phát hiện api.yaml có thay đổi
    Argo->>Rollout: Đồng bộ cấu hình mới vào Cụm K8s

    Note over Rollout, Prom: Giai đoạn 3: Chiến thuật Canary & Tự động Phân tích
    Rollout->>Rollout: Khởi tạo bản MỚI, chia 25% traffic vào bản MỚI, 75% ở bản CŨ
    Rollout->>Prom: Gọi AnalysisRun yêu cầu đánh giá bản MỚI
    
    loop Phân tích 6 lần (mỗi 10s)
        Prom-->>Rollout: Trả về kết quả (Tỷ lệ thành công)
    end

    alt Kịch bản TỐT: Thành công >= 90%
        Rollout->>Rollout: Analysis PASS -> Chuyển 100% traffic sang bản MỚI
        Note right of Rollout: Hoàn tất nâng cấp mượt mà!
    else Kịch bản XẤU: Lỗi 500 quá nhiều (Thành công < 90%)
        Rollout->>Rollout: Analysis FAIL -> HỦY BỎ (Abort), lùi về 100% bản CŨ
        Prom->>Alert: Báo động! Tỷ lệ lỗi > 10%
        Alert->>Dev: Gửi Email cảnh báo khẩn cấp!
        Note right of Rollout: Khách hàng an toàn, Dev nhận email về sửa code.
    end
```
