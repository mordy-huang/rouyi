# RuoYi-Vue Docker 部署说明

---

## 前提条件

- 安装 Docker（推荐 Docker Desktop 或 Docker Engine 24+）
- 安装 Docker Compose v2
- 宿主机预留端口：`80`（前端）、`8080`（后端）、`3307`（MySQL）、`6380`（Redis）

---

## 快速启动

在项目根目录执行：

```bash
# 一键启动所有服务（后台运行）
docker compose up -d

# 查看启动日志
docker compose logs -f

# 等所有服务启动完毕（首次约 3-5 分钟）
# 访问 http://localhost → 若依登录页
# 默认账号：admin / admin123
```

启动过程中 Docker 会依次做：

```
1. 拉取 MySQL 9.0 → 创建数据库 → 执行初始化 SQL
2. 拉取 Redis 7 → 启动
3. 构建后端镜像 → Maven 编译打包 → 启动 Spring Boot
4. 构建前端镜像 → npm 打包 → 启动 Nginx
```

---

## 服务说明

| 服务 | 容器名 | 宿主机端口 | 内部端口 | 说明 |
|------|--------|-----------|---------|------|
| MySQL | ry-mysql | 3307 | 3306 | 数据库，数据持久化到 volume |
| Redis | ry-redis | 6380 | 6379 | 缓存，开启 AOF 持久化 |
| 后端 | ry-admin | 8080 | 8080 | Spring Boot API |
| 前端 | ry-ui | 80 | 80 | Nginx + Vue 静态文件 |

> 注意：宿主机端口 3307 和 6380 映射到 MySQL/Redis 内部端口，避免与本机已有 MySQL/Redis 冲突。
> 如需使用标准端口，修改 `docker-compose.yml` 中 ports 映射即可。

---

## 连接关系

```
浏览器 http://localhost
     ↓
Nginx (ruoyi-ui:80)
     ├── / → 静态页面（Vue SPA）
     └── /prod-api/* → 代理到后端 ruoyi-admin:8080
                           ↓
                    Spring Boot (ruoyi-admin:8080)
                           ├── 连接 MySQL (mysql:3306)
                           └── 连接 Redis (redis:6379)
```

---

## 常用命令

```bash
# 启动所有服务
docker compose up -d

# 查看日志（实时跟踪）
docker compose logs -f

# 查看单个服务日志
docker compose logs -f ruoyi-admin

# 重启某个服务
docker compose restart ruoyi-admin

# 重新构建镜像（代码有改动后）
docker compose build --no-cache

# 构建后重启
docker compose up -d --build

# 停止所有服务
docker compose stop

# 停止并删除容器
docker compose down

# 彻底清理（包括数据卷，会丢失数据库和 Redis 数据）
docker compose down -v
```

---

## 代码修改后重新部署

### 修改后端代码后

```bash
docker compose build ruoyi-admin    # 重新构建后端镜像
docker compose up -d ruoyi-admin    # 重启后端容器
```

### 修改前端代码后

```bash
docker compose build ruoyi-ui       # 重新构建前端镜像
docker compose up -d ruoyi-ui       # 重启前端容器
```

### 快捷方式（后端 + 前端一起重建）

```bash
docker compose up -d --build
```

---

## 访问地址

| 服务 | 地址 |
|------|------|
| 前端页面 | http://localhost |
| Swagger 文档 | http://localhost:8080/swagger-ui.html |
| Druid 监控 | http://localhost:8080/druid |
| MySQL 外部连接 | localhost:3307 (root / root123) |
| Redis 外部连接 | localhost:6380 |

---

## 常见问题

### Q: 启动后访问 80 端口没反应

```bash
# 查看所有容器状态
docker compose ps

# 确认所有服务都是 "Up" 状态
# 如果 ruoyi-admin 在重启，说明数据库还没准备好，等一会再试
docker compose logs ruoyi-admin
```

### Q: 后端报数据库连接拒绝

```
# 查看 MySQL 日志
docker compose logs mysql

# 确认 MySQL 启动成功后再等 10 秒，后端会自动重连
# 如果仍然报错：检查 docker-compose.yml 中的数据库密码是否一致
```

### Q: 如何修改数据库密码

编辑 `docker-compose.yml`，修改两处：
1. `mysql` 服务的 `MYSQL_ROOT_PASSWORD`
2. `ruoyi-admin` 服务的 `SPRING_DATASOURCE_DRUID_MASTER_PASSWORD`

然后重建：`docker compose up -d --build`

### Q: 端口冲突

如果宿主机 80 端口已被占用，修改 `docker-compose.yml` 中 `ruoyi-ui` 的 ports 映射，例如改为 `"8081:80"`，然后访问 `http://localhost:8081`。
