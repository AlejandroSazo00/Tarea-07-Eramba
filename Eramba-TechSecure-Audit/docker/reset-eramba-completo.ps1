# Reset completo de Eramba con configuraciones correctas
Write-Host "=== RESET COMPLETO DE ERAMBA ===" -ForegroundColor Red

# 1. Detener y eliminar todo
Write-Host "1. Deteniendo y eliminando contenedores..." -ForegroundColor Yellow
docker stop eramba-app eramba-cron mysql-eramba redis-eramba 2>$null
docker rm eramba-app eramba-cron mysql-eramba redis-eramba 2>$null
docker volume prune -f

# 2. Crear red
Write-Host "2. Creando red..." -ForegroundColor Yellow
docker network rm eramba-net 2>$null
docker network create eramba-net

# 3. Iniciar MySQL con configuraciones correctas
Write-Host "3. Iniciando MySQL..." -ForegroundColor Yellow
docker run -d --name mysql-eramba --network eramba-net `
  -e MYSQL_ROOT_PASSWORD=password123 `
  -e MYSQL_DATABASE=eramba `
  -e MYSQL_USER=eramba `
  -e MYSQL_PASSWORD=password123 `
  -p 3306:3306 `
  mysql:8.0 --default-authentication-plugin=mysql_native_password --disable-log-bin --sql_mode=""

# 4. Iniciar Redis
Write-Host "4. Iniciando Redis..." -ForegroundColor Yellow
docker run -d --name redis-eramba --network eramba-net -p 6379:6379 redis:alpine

# 5. Esperar MySQL
Write-Host "5. Esperando MySQL (60 segundos)..." -ForegroundColor Yellow
Start-Sleep -Seconds 60

# 6. Configurar MySQL
Write-Host "6. Configurando MySQL..." -ForegroundColor Yellow
docker exec mysql-eramba mysql -u root -ppassword123 -e "SET GLOBAL max_allowed_packet = 128000000;"
docker exec mysql-eramba mysql -u root -ppassword123 -e "SET GLOBAL innodb_lock_wait_timeout = 200;"
docker exec mysql-eramba mysql -u root -ppassword123 -e "GRANT PROCESS ON *.* TO 'eramba'@'%'; FLUSH PRIVILEGES;"

# 7. Iniciar Eramba
Write-Host "7. Iniciando Eramba..." -ForegroundColor Yellow
docker run -d --name eramba-app --network eramba-net `
  -p 8080:80 `
  -e DB_HOST=mysql-eramba `
  -e DB_DATABASE=eramba `
  -e DB_USERNAME=eramba `
  -e DB_PASSWORD=password123 `
  -e "CACHE_URL=Redis://?server=redis-eramba&port=6379" `
  -e "PUBLIC_ADDRESS=http://localhost:8080" `
  -e DOCKER_DEPLOYMENT=1 `
  ghcr.io/eramba/eramba:latest

# 8. Iniciar Cron
Write-Host "8. Iniciando Worker..." -ForegroundColor Yellow
docker run -d --name eramba-cron --network eramba-net `
  -e DB_HOST=mysql-eramba `
  -e DB_DATABASE=eramba `
  -e DB_USERNAME=eramba `
  -e DB_PASSWORD=password123 `
  -e "CACHE_URL=Redis://?server=redis-eramba&port=6379" `
  -e "PUBLIC_ADDRESS=http://localhost:8080" `
  -e DOCKER_DEPLOYMENT=1 `
  --entrypoint="/docker-cron-entrypoint.sh" `
  ghcr.io/eramba/eramba:latest cron -f

# 9. Esperar inicialización
Write-Host "9. Esperando inicializacion completa (3 minutos)..." -ForegroundColor Yellow
Start-Sleep -Seconds 180

# 10. Configurar permisos
Write-Host "10. Configurando permisos..." -ForegroundColor Yellow
docker exec eramba-app chown -R www-data:www-data /var/www/eramba
docker exec eramba-app chmod -R 777 /var/www/eramba/laravel/storage /var/www/eramba/laravel/bootstrap/cache

Write-Host ""
Write-Host "=== ERAMBA COMPLETAMENTE RESETEADO ===" -ForegroundColor Green
Write-Host "URL: http://localhost:8080" -ForegroundColor Cyan
Write-Host "Usuario: admin" -ForegroundColor White
Write-Host "Password: admin" -ForegroundColor White
Write-Host ""
Write-Host "NOTA: Espera 2-3 minutos adicionales antes de acceder" -ForegroundColor Yellow
Write-Host "para que termine la configuracion inicial." -ForegroundColor Yellow
