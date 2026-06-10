# RuoYi 一键部署（本地编译 + 上传）
$IP = "8.163.121.116"

Write-Host "1/4 后端编译..." -ForegroundColor Yellow
mvn clean package -DskipTests -q

Write-Host "2/4 前端编译..." -ForegroundColor Yellow
cd RuoYi-Vue3-typescript
npm run build:prod 2>$null
cd ..

Write-Host "3/4 构建镜像..." -ForegroundColor Yellow
docker compose build

Write-Host "4/4 上传 & 部署..." -ForegroundColor Yellow
docker save ruoyi-vue-master-ruoyi-admin:latest ruoyi-vue-master-ruoyi-ui:latest -o update.tar
scp update.tar root@${IP}:/root/
ssh root@${IP} "docker load -i /root/update.tar && cd /opt/ruoyi && git pull && docker compose up -d --no-build"

Write-Host "✅ 完成 $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Green
