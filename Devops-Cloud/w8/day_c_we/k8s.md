# 1. Vì sao cần Kubernetes?

Docker giúp mình đóng gói app thành container và chạy ổn định ở nhiều môi trường. Nhưng khi lên production, chỉ Docker thôi chưa đủ.

**Vấn đề xuất hiện khi có nhiều container:**
- Container chết thì ai khởi động lại?
- Traffic tăng thì ai scale thêm container?
- Deploy version mới thì rollback thế nào?
- Nhiều container trên nhiều máy thì ai phân bổ?
- Container A gọi container B bằng địa chỉ nào khi IP thay đổi?

**Kubernetes** giải quyết các vấn đề đó bằng cách làm nhiệm vụ **orchestration**, tức là điều phối, quản lý và tự động hóa vòng đời của container.

> **Nói đơn giản:**
> - **Docker** = đóng gói và chạy container
> - **Kubernetes** = quản lý nhiều container chạy ổn định, tự phục hồi, scale, deploy, networking

---

# 2. Tư tưởng cốt lõi: Desired State

Kubernetes hoạt động theo kiểu **declarative** (khai báo), tức là mình khai báo trạng thái mong muốn, còn Kubernetes tự lo cách đạt được trạng thái đó.

**Ví dụ:** Tôi muốn backend luôn chạy 3 bản.
Kubernetes sẽ liên tục kiểm tra:
- Đang có 3 Pod chưa?
- Nếu chỉ còn 2 Pod -> tạo thêm 1 Pod
- Nếu có 4 Pod -> xóa bớt 1 Pod

**Chu trình của Kubernetes:**
`Declare -> Observe -> Diff -> Reconcile`

**Giải thích:**
- **Declare:** mình khai báo bằng YAML
- **Observe:** Kubernetes quan sát trạng thái thực tế
- **Diff:** so sánh thực tế với mong muốn
- **Reconcile:** tự điều chỉnh để khớp lại

> Đây là lý do Kubernetes có khả năng **self-healing** (tự phục hồi).

---

# 3. Kiến trúc Kubernetes Cluster

Một cụm Kubernetes gồm 2 phần chính:
- **Control Plane** = bộ脑
- **Worker Node** = nơi chạy ứng dụng

## 3.1. Control Plane
Control Plane là nơi ra quyết định cho toàn bộ cluster.

| Thành phần | Vai trò |
| :--- | :--- |
| **kube-apiserver** | Cổng giao tiếp trung tâm của cluster |
| **etcd** | Database lưu toàn bộ trạng thái cluster |
| **scheduler** | Chọn node phù hợp để chạy Pod |
| **controller-manager** | Chạy các vòng lặp kiểm soát, giữ desired state |

**Ví dụ khi bạn chạy:**
```bash
kubectl apply -f deploy.yaml
```
Lệnh này sẽ gửi yêu cầu đến `kube-apiserver`, sau đó trạng thái được lưu vào `etcd`, rồi các controller sẽ tạo Pod/ReplicaSet tương ứng.

## 3.2. Worker Node
Worker Node là nơi container thật sự chạy.

| Thành phần | Vai trò |
| :--- | :--- |
| **kubelet** | Agent trên node, nhận lệnh từ control plane |
| **container runtime** | Thực sự chạy container, ví dụ containerd |
| **kube-proxy** | Xử lý network routing cho Service |

> **Lưu ý:** Trong Minikube, thường cả control plane và worker node được gom trong một node local để học và lab.

---

# 4. Pod là gì?

**Pod** là đơn vị nhỏ nhất mà Kubernetes quản lý. Pod không hoàn toàn giống container. Có thể hiểu:
**Pod = lớp bọc quanh 1 hoặc nhiều container**

Thường gặp nhất: `1 Pod = 1 container app`

**Ví dụ:**
```text
Pod backend
 └── container backend
```

**Đặc điểm quan trọng của Pod:**
- Pod có IP riêng
- Pod có thể chết và được tạo lại
- IP của Pod không ổn định
- Không nên gọi trực tiếp IP Pod

> Vì Pod có thể bị xóa và tạo mới, nên trong thực tế thường không tạo Pod trực tiếp, mà tạo thông qua **Deployment**.

---

# 5. Deployment là gì?

**Deployment** là object dùng rất nhiều trong Kubernetes. Nó quản lý Pod, ReplicaSet, scaling, rolling update và rollback.

**Ví dụ mình khai báo:**
```yaml
replicas: 3
```
Nghĩa là: *Tôi muốn luôn có 3 Pod chạy app này.*

Deployment sẽ tạo ra ReplicaSet, sau đó ReplicaSet tạo Pod.
> **Quan hệ:** `Deployment -> ReplicaSet -> Pod`

**Deployment giúp:**
- Tự tạo lại Pod nếu Pod chết
- Scale số lượng Pod
- Update image mới
- Rollback version cũ
- Quản lý app theo desired state

**Ví dụ scale backend:**
```bash
kubectl scale deployment backend --replicas=3
```

---

# 6. ReplicaSet là gì?

**ReplicaSet** có nhiệm vụ giữ đúng số lượng Pod mong muốn.

Ví dụ: `replicas = 3`
Nếu có 1 Pod chết:
- ReplicaSet thấy còn 2 Pod
- -> Tạo thêm 1 Pod mới

> Thông thường mình **không** làm việc trực tiếp với ReplicaSet, vì Deployment sẽ tự quản lý nó.

---

# 7. Namespace là gì?

**Namespace** là vùng phân chia logic trong Kubernetes cluster. Giúp tách tài nguyên giữa các môi trường hoặc team.

**Ví dụ:**
- `dev`
- `staging`
- `production`
- `kube-system`
- `default`

**Ví dụ xem Pod trong namespace:**
```bash
kubectl get pods -n default
kubectl get pods -n kube-system
```
> Nếu không chỉ định namespace, Kubernetes thường dùng namespace `default`.

---

# 8. Labels và Selectors

- **Labels** là cặp key-value gắn vào object.
- **Selector** dùng để tìm object dựa trên label.

**Ví dụ:**
```yaml
labels:
  app: web
```

**Ví dụ tìm kiếm:**
- Service tìm các Pod có label `app=web`
- Deployment quản lý các Pod có label `app=web`

Đây là điểm rất quan trọng trong Kubernetes:
- Kubernetes **không** liên kết object bằng IP cố định.
- Kubernetes liên kết bằng **label** và **selector**.

> **Ví dụ:** Pod cũ chết -> Pod mới sinh ra -> IP đổi. Nhưng nếu label vẫn là `app=web`, Service vẫn tìm được Pod mới.

---

# 9. ConfigMap là gì?

**ConfigMap** dùng để lưu cấu hình không nhạy cảm.

**Ví dụ:**
```env
APP_ENV=production
API_URL=http://api:8080
REDIS_HOST=redis-service
```
Mục đích là tách config ra khỏi Docker image. Thay vì build image riêng cho dev, staging, production, mình dùng cùng một image và thay config bên ngoài.

---

# 10. Secret là gì?

**Secret** dùng để lưu thông tin nhạy cảm. Giống ConfigMap nhưng dùng cho dữ liệu cần bảo mật hơn.

**Ví dụ:**
- `DB_PASSWORD`
- `JWT_SECRET`
- `API_KEY`
- `ACCESS_TOKEN`

> **Lưu ý quan trọng:** Dữ liệu trong Secret thường được encode base64, nhưng base64 không phải mã hóa thật. Muốn bảo mật tốt hơn cần cấu hình encryption-at-rest cho etcd hoặc dùng giải pháp secret chuyên biệt.

---

# 11. kubectl là gì?

**kubectl** là công cụ dòng lệnh để giao tiếp với Kubernetes cluster.

**Một số lệnh quan trọng:**
```bash
kubectl get pods
kubectl get pods -A
kubectl get deploy,rs,pods
kubectl describe pod <pod-name>
kubectl logs -f <pod-name>
kubectl apply -f app.yaml
kubectl delete -f app.yaml
kubectl exec -it <pod-name> -- sh
```

**Cách debug thường dùng:**
`get -> describe -> logs`

**Ví dụ Pod lỗi:**
```bash
kubectl get pods
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

**Ba lỗi hay gặp:**
1. **ImagePullBackOff**: không kéo được image
2. **CrashLoopBackOff**: container chạy lên rồi crash liên tục
3. **Pending**: Pod chưa được schedule lên node

---

# 12. Minikube / kind dùng để làm gì?

Cả hai đều giúp bạn có một Kubernetes cluster trên máy cá nhân để học/lab.

**Với Minikube:**
```bash
minikube start
kubectl get nodes
kubectl cluster-info
```
> Khi node ở trạng thái `Ready`, nghĩa là cluster đã chạy được.

---

# 13. Bài học từ Lab

### Lab 1: Dựng cluster
- **Mục tiêu:** Khởi động Minikube/kind, kiểm tra node Ready, kiểm tra cluster-info.
- **Lệnh:**
```bash
minikube start
kubectl get nodes
kubectl cluster-info
```

### Lab 2: Tạo Pod trần
- **Lệnh:**
```bash
kubectl run hello --image=nginx:1.27 --port=80
kubectl get pods -o wide
kubectl describe pod hello
kubectl exec -it hello -- sh
kubectl delete pod hello
```
- **Bài học:** Pod trần bị xóa là mất luôn. Không có gì tự tạo lại nó.

### Lab 3: Tạo Deployment bằng YAML
- Khai báo 3 replicas.
- **Bài học:** Deployment tạo ReplicaSet, ReplicaSet tạo Pod. K8s giữ đúng số Pod mong muốn. (`Deployment -> ReplicaSet -> Pod`)

### Lab 4: Labels và Self-healing
- Lọc Pod bằng label:
```bash
kubectl get pods --show-labels
kubectl get pods -l app=web
kubectl logs -l app=web
```
- **Xóa một Pod thuộc Deployment:**
```bash
kubectl delete pod <pod-name>
```
- **Kết quả:** Pod bị xóa -> ReplicaSet phát hiện thiếu Pod -> K8s tạo Pod mới (Self-healing).

### Lab 5: ConfigMap và Secret
- **Tạo ConfigMap & Secret:**
```bash
kubectl create configmap app-cfg --from-literal=APP_ENV=production
kubectl create secret generic app-sec --from-literal=DB_PASSWORD=s3cr3t
```
- **Inject vào Deployment:**
```bash
kubectl set env deploy/web --from=configmap/app-cfg
kubectl set env deploy/web --from=secret/app-sec
```
- **Bài học:** Config tách khỏi image. Không cần build lại image khi đổi config. Pod được rollout lại để nhận env mới.

---

# 14. Tóm tắt cực ngắn để nhớ

Bạn có thể học theo chuỗi này:
1. **Docker** tạo image
2. **Kubernetes** chạy image bằng Pod
3. **Deployment** quản lý nhiều Pod
4. **ReplicaSet** giữ đúng số lượng Pod
5. **Labels** giúp object tìm nhau
6. **ConfigMap/Secret** inject config vào Pod
7. **kubectl** dùng để thao tác và debug cluster
