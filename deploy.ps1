# RuoYi 一键部署脚本（本地执行）
mvn clean package -DskipTests
docker compose build
docker save ruoyi-vue-master-ruoyi-admin:latest ruoyi-vue-master-ruoyi-ui:latest -o update.tar
scp update.tar docker-compose-server.yml root@8.163.121.116:/root/
ssh root@8.163.121.116 "docker load -i /root/update.tar && docker compose -f /root/docker-compose-server.yml up -d"
