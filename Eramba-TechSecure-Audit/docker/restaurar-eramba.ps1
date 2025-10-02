# Script para restaurar Eramba después de reinicio
Write-Host "=== Restaurando Eramba ===" -ForegroundColor Green

# Iniciar contenedores
Write-Host "Iniciando contenedores..." -ForegroundColor Yellow
docker start mysql-eramba redis-eramba eramba-app eramba-cron

# Esperar a que MySQL esté listo
Write-Host "Esperando MySQL..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Aplicar configuraciones MySQL
Write-Host "Configurando MySQL..." -ForegroundColor Yellow
docker exec mysql-eramba mysql -u root -ppassword123 -e "SET GLOBAL max_allowed_packet = 128000000;"
docker exec mysql-eramba mysql -u root -ppassword123 -e "SET GLOBAL innodb_lock_wait_timeout = 200;"
docker exec mysql-eramba mysql -u root -ppassword123 -e "GRANT PROCESS ON *.* TO 'eramba'@'%'; FLUSH PRIVILEGES;"

# Reiniciar Eramba
Write-Host "Reiniciando Eramba..." -ForegroundColor Yellow
docker restart eramba-app

Write-Host ""
Write-Host "=== ERAMBA RESTAURADO ===" -ForegroundColor Green
Write-Host "URL: http://localhost:8080" -ForegroundColor Cyan
Write-Host "Usuario: admin" -ForegroundColor White
Write-Host "Password: admin" -ForegroundColor White
