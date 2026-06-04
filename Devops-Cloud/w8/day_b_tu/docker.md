# 1. Docker giải quyết vấn đề gì?

Khi deploy app, thường gặp lỗi kiểu:
- Máy em chạy được nhưng lên server lại lỗi
- Thiếu package
- Sai version NodeJS/Python/Java
- Khác hệ điều hành
- Khác biến môi trường
- Cấu hình rối

**Docker giúp đóng gói ứng dụng thành một môi trường riêng, ổn định và dễ chạy lại.**

Ví dụ backend NestJS của bạn cần:
- NodeJS 20
- npm packages
- file build dist
- biến môi trường `.env`
- port `3000`

> Docker sẽ gom những thứ đó thành một **image**, sau đó chạy image thành **container**.

---

# 2. Các khái niệm cơ bản trong Docker

## Dockerfile

**Dockerfile** là file hướng dẫn Docker cách build ứng dụng.

Ví dụ:
```dockerfile
FROM node:20-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

RUN npm run build

EXPOSE 3000

CMD ["npm", "run", "start:prod"]
```

**Ý nghĩa:**

| Lệnh | Ý nghĩa |
| :--- | :--- |
| `FROM` | Chọn image nền |
| `WORKDIR` | Chọn thư mục làm việc trong container |
| `COPY` | Copy code vào container |
| `RUN` | Chạy lệnh khi build image |
| `EXPOSE` | Khai báo port app dùng |
| `CMD` | Lệnh chạy khi container start |

---

## Image

**Image** là bản đóng gói của ứng dụng. Có thể hiểu image giống như “bản mẫu” để tạo container.

Ví dụ:
```bash
docker build -t minie-backend .
```
Lệnh này tạo image tên: `minie-backend`

**Image chứa:**
- Code backend
- Runtime NodeJS
- Dependencies
- Cấu hình cần thiết
- Lệnh start app

---

## Container

**Container** là phiên bản đang chạy của image.

Ví dụ chạy image thành container:
```bash
docker run -d -p 3000:3000 --name backend minie-backend
```

**Ý nghĩa:**
- Từ image `minie-backend`
- Tạo container tên `backend`
- Chạy ở chế độ nền
- Map port `3000` của máy thật vào port `3000` trong container

> **Lưu ý:** Nếu image là “bản cài đặt”, thì container là “ứng dụng đang chạy”.

---

# 3. Image và Container khác nhau thế nào?

| Khái niệm | Hiểu đơn giản |
| :--- | :--- |
| **Image** | Bản đóng gói / bản mẫu |
| **Container** | Phiên bản đang chạy từ image |

**Ví dụ dễ hiểu:**
- **Image** = file cài game
- **Container** = game đang mở và đang chạy

Một image có thể tạo nhiều container.
```text
image backend
 ├── container backend-1
 ├── container backend-2
 └── container backend-3
```

---

# 4. Docker Hub / ECR là gì?

Sau khi build image, mình cần nơi lưu image. Một số nơi lưu image phổ biến:

| Registry | Ý nghĩa |
| :--- | :--- |
| **Docker Hub** | Nơi lưu image phổ biến của Docker |
| **Amazon ECR** | Nơi lưu Docker image trên AWS |
| **GitHub Container Registry** | Nơi lưu image của GitHub |

**Ví dụ push image lên Docker Hub:**
```bash
docker tag minie-backend huyhoang2609/backend-mine-datn:latest
docker push huyhoang2609/backend-mine-datn:latest
```

Sau đó server có thể pull về:
```bash
docker pull huyhoang2609/backend-mine-datn:latest
```

---

# 5. Port trong Docker

App chạy trong container có port riêng. Ví dụ backend NestJS chạy trong container ở port `3000`.

Muốn máy bên ngoài truy cập được, cần map port:
```bash
docker run -p 3000:3000 minie-backend
```

**Ý nghĩa:**
```text
Port máy thật : Port container
3000          : 3000
```

Ví dụ khác:
```bash
docker run -p 80:3000 minie-backend
```

**Ý nghĩa:**
- Người dùng gọi port `80` của server
- Docker chuyển vào port `3000` trong container

---

# 6. Volume trong Docker

Container có thể bị xóa và tạo lại. Dữ liệu bên trong container có thể mất nếu không lưu ra ngoài.
**Volume dùng để lưu dữ liệu bền vững.**

Ví dụ MySQL container:
```bash
docker run -d \
  --name mysql \
  -e MYSQL_ROOT_PASSWORD=123456 \
  -v mysql_data:/var/lib/mysql \
  mysql:8
```

**Ý nghĩa:**
- Dữ liệu MySQL được lưu vào volume `mysql_data`
- Container xóa đi thì dữ liệu vẫn còn

---

# 7. Docker Network

**Docker Network** giúp các container giao tiếp với nhau.

**Ví dụ:** backend container cần kết nối mysql container.

Tạo network:
```bash
docker network create app-network
```

Chạy MySQL:
```bash
docker run -d \
  --name mysql \
  --network app-network \
  mysql:8
```

Chạy backend:
```bash
docker run -d \
  --name backend \
  --network app-network \
  minie-backend
```

Lúc này backend có thể gọi MySQL bằng hostname: `mysql` (Không cần dùng IP container).

---

# 8. Docker Compose

**Docker Compose** dùng để chạy nhiều container cùng lúc bằng file `docker-compose.yml`.

Ví dụ app có:
- backend
- mysql
- redis

Thay vì chạy từng lệnh `docker run`, dùng Compose:
```yaml
services:
  backend:
    build: .
    ports:
      - "3000:3000"
    depends_on:
      - mysql
      - redis

  mysql:
    image: mysql:8
    environment:
      MYSQL_ROOT_PASSWORD: 123456
      MYSQL_DATABASE: minie
    volumes:
      - mysql_data:/var/lib/mysql

  redis:
    image: redis:alpine

volumes:
  mysql_data:
```

**Chạy toàn bộ:**
```bash
docker compose up -d
```

**Dừng toàn bộ:**
```bash
docker compose down
```

---

# 9. Các lệnh Docker cơ bản

| Lệnh | Ý nghĩa |
| :--- | :--- |
| `docker build -t app .` | Build image |
| `docker images` | Xem danh sách image |
| `docker run app` | Chạy container |
| `docker ps` | Xem container đang chạy |
| `docker ps -a` | Xem tất cả container |
| `docker stop <container>` | Dừng container |
| `docker rm <container>` | Xóa container |
| `docker rmi <image>` | Xóa image |
| `docker logs <container>` | Xem log container |
| `docker exec -it <container> sh` | Vào bên trong container |

**Ví dụ debug container:**
```bash
docker logs -f backend
```

**Vào container:**
```bash
docker exec -it backend sh
```

---

# 10. Docker dùng trong deploy như thế nào?

Ví dụ quy trình deploy backend:
1. Viết code backend
2. Viết Dockerfile
3. Build image
4. Push image lên Docker Hub hoặc ECR
5. Server EC2/ECS pull image
6. Chạy container
7. ALB/CloudFront trỏ traffic vào app

**Ví dụ thực tế với EC2:**
```text
Developer
  ↓
Build Docker image
  ↓
Push Docker Hub/ECR
  ↓
EC2 pull image
  ↓
docker run backend
  ↓
User truy cập app
```

---

# 11. Docker khác máy ảo như thế nào?

| Docker Container | Virtual Machine |
| :--- | :--- |
| Nhẹ hơn | Nặng hơn |
| Khởi động nhanh | Khởi động chậm hơn |
| Chia sẻ kernel với host | Có hệ điều hành riêng |
| Phù hợp deploy app | Phù hợp chạy môi trường tách biệt hoàn toàn |

**Dễ hiểu:**
- **VM** = thuê cả căn nhà riêng
- **Container** = thuê từng phòng trong cùng một tòa nhà

---

# 12. Tóm tắt cực ngắn

- **Dockerfile**  → file hướng dẫn build app
- **Image**       → bản đóng gói app
- **Container**   → app đang chạy từ image
- **Registry**    → nơi lưu image, ví dụ Docker Hub/ECR
- **Volume**      → nơi lưu dữ liệu bền vững
- **Network**     → cho container giao tiếp với nhau
- **Compose**     → chạy nhiều container cùng lúc