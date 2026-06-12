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

### 📖 GIẢI NGHĨA CHI TIẾT TỪNG BƯỚC:

**Giai đoạn 1: Lập trình viên code (Bước 1 - 5)**
- Sếp code xong tính năng mới, đẩy code lên Github (Kho App).
- Máy móc trên Github (GitHub Actions) lập tức lấy code đi gói lại thành Docker Image, ném lên kho chứa Docker Hub.
- Sau đó, hệ thống CI sẽ tự động chui sang kho `minikube-gitops`, sửa file `api.yaml` để cập nhật tên phiên bản Image mới nhất. (Nhiệm vụ kiểm tra lỗi chính tả Kubeconform cũng tự động chạy ở bước này để đảm bảo file YAML không bị sai).

**Giai đoạn 2: Bác bảo vệ ArgoCD làm việc (Bước 6 - 7)**
- ArgoCD (được cài trong K8s) luôn luôn theo dõi kho Git `minikube-gitops`. Khi phát hiện ra kho này vừa có sự thay đổi cấu hình.
- Nó lập tức lôi cấu hình mới về K8s và ra lệnh cập nhật bằng cách giao việc cho **Argo Rollout**.

**Giai đoạn 3: Chiến thuật thả mìn Canary (Bước 8 - 11)**
- Thay vì xóa hết ứng dụng cũ để cài ứng dụng mới, Argo Rollout chỉ cấp phát **25%** lượng truy cập (khách hàng) vào phiên bản MỚI, **75%** khách hàng còn lại vẫn dùng phiên bản CŨ cho an toàn.
- Lúc này, bài test **AnalysisRun** được kích hoạt. Nó sẽ liên tục hỏi hệ thống Camera giám sát (**Prometheus**) xem: *"Trong 1 phút vừa qua, 25% khách hàng dùng phiên bản mới này tỷ lệ thành công là bao nhiêu?"*.

**Giai đoạn 4: Phán xét và Xử lý sự cố (Bước 12 - 14)**
Sẽ có 2 kịch bản xảy ra ở điểm nghẽn sinh tử này:
- **Kịch bản Tốt (12A):** Prometheus báo cáo tỷ lệ thành công là 100%. Analysis thông qua. Rollout tự tin mở khóa đưa 100% khách hàng sang phiên bản mới. Quy trình hoàn tất mượt mà!
- **Kịch bản Xấu (12B - Lỗi 500 do code hỏng):** Prometheus báo cáo tỷ lệ thành công bị tụt xuống dưới mức quy định (dưới 90%). 
  - Analysis lập tức ra quyết định **ĐÁNH TRƯỢT (Fail)**.
  - Rollout nhận lệnh Fail, lập tức **khóa họng** bản MỚI lại, chuyển 100% lượng truy cập quay lại bản CŨ một cách chớp nhoáng (Auto-Rollback). Khách hàng không hề nhận ra hệ thống vừa gặp sự cố nghiêm trọng.
  - Cùng lúc đó, Prometheus báo cáo thẳng cho **Alertmanager** về việc tỷ lệ lỗi tăng cao bất thường. Alertmanager tự động soạn 1 email khẩn cấp gửi vào hộp thư của nhóm DevOps báo động: *"Hệ thống vừa có lỗi và đã tự động khóa bản cập nhật lại!"*.
