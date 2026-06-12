# Luồng Chạy Tổng Thể: Từ Code Đến K8s (GitOps & Auto-Canary)

```mermaid
graph TD
    %% Định nghĩa các khối
    Dev(("Lập trình viên"))
    GitApp["GitHub: Source Code App"]
    GitOps["GitHub: minikube-gitops"]
    
    subgraph CI_Pipeline ["CI: Tích hợp liên tục"]
        GH_App["GitHub Actions: Build Image"]
        DockerHub[("Docker Hub")]
        GH_Ops["GitHub Actions: Kubeconform"]
    end
    
    subgraph CD_Pipeline ["CD: Triển khai liên tục"]
        ArgoCD{"ArgoCD"}
    end
    
    subgraph K8s_Cluster ["Cụm K8s Minikube"]
        Rollout["Argo Rollout"]
        Canary["Bản MỚI: 25% Traffic"]
        Stable["Bản CŨ: 75% Traffic"]
        Analysis["AnalysisRun"]
    end
    
    subgraph Observability ["Giám sát & Cảnh báo"]
        Prometheus(("Prometheus"))
        AlertManager["Alertmanager"]
        Email["Email Cảnh Báo"]
    end

    %% Luồng chạy thực tế
    Dev -- "1. Push Code/Đổi Version" --> GitApp
    GitApp -- "2. Trigger" --> GH_App
    GH_App -- "3. Build & Push" --> DockerHub
    GH_App -- "4. Tự động sửa file YAML" --> GitOps
    
    Dev -- "Hoặc tự sửa file YAML" --> GitOps
    GitOps -- "5. Kiểm tra lỗi chính tả" --> GH_Ops
    
    GitOps -- "6. Phát hiện thay đổi" --> ArgoCD
    ArgoCD -- "7. Đồng bộ vào K8s" --> Rollout
    
    Rollout -- "8. Nhả 25% khách hàng" --> Canary
    Rollout -- "Giữ 75% khách hàng an toàn" --> Stable
    
    Rollout -- "9. Kích hoạt bài Test" --> Analysis
    Analysis -- "10. Xin điểm số (Query)" --> Prometheus
    Prometheus -- "11. Trả kết quả Tỷ lệ thành công" --> Analysis
    
    Analysis -- "12A. Nếu Pass (Thành công >= 90%)" --> Rollout
    Rollout -. "Nâng cấp 100% bản MỚI" .-> Canary
    
    Analysis -- "12B. Nếu Fail (Lỗi 500 quá nhiều)" --> Rollout
    Rollout -. "Khóa bản Mới, lùi về 100% bản CŨ" .-> Stable
    
    Prometheus -- "13. Gửi tín hiệu Lỗi 500 > 10%" --> AlertManager
    AlertManager -- "14. Bắn thông báo khẩn cấp" --> Email
    
    classDef git fill:#f34f29,color:white,stroke:#333
    classDef k8s fill:#326ce5,color:white,stroke:#333
    classDef monitor fill:#e6522c,color:white,stroke:#333
    class GitApp,GitOps git
    class Rollout,Canary,Stable k8s
    class Prometheus,AlertManager monitor
```

---

