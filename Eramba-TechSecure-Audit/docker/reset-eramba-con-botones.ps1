# Reset completo de Eramba con botones funcionando
Write-Host "=== RESET ERAMBA CON BOTONES ADD ===" -ForegroundColor Green

# 1. Crear red
Write-Host "1. Creando red..." -ForegroundColor Yellow
docker network rm eramba-net 2>$null
docker network create eramba-net

# 2. MySQL con configuración específica
Write-Host "2. Iniciando MySQL..." -ForegroundColor Yellow
docker run -d --name mysql-eramba --network eramba-net `
  -e MYSQL_ROOT_PASSWORD=password123 `
  -e MYSQL_DATABASE=eramba `
  -e MYSQL_USER=eramba `
  -e MYSQL_PASSWORD=password123 `
  -p 3306:3306 `
  mysql:8.0 --default-authentication-plugin=mysql_native_password --disable-log-bin --sql_mode=""

# 3. Redis
Write-Host "3. Iniciando Redis..." -ForegroundColor Yellow
docker run -d --name redis-eramba --network eramba-net -p 6379:6379 redis:alpine

# 4. Esperar MySQL
Write-Host "4. Esperando MySQL (60 segundos)..." -ForegroundColor Yellow
Start-Sleep -Seconds 60

# 5. Configurar MySQL para Eramba
Write-Host "5. Configurando MySQL..." -ForegroundColor Yellow
docker exec mysql-eramba mysql -u root -ppassword123 -e "SET GLOBAL max_allowed_packet = 128000000;"
docker exec mysql-eramba mysql -u root -ppassword123 -e "SET GLOBAL innodb_lock_wait_timeout = 200;"
docker exec mysql-eramba mysql -u root -ppassword123 -e "GRANT ALL PRIVILEGES ON *.* TO 'eramba'@'%' WITH GRANT OPTION; FLUSH PRIVILEGES;"

# 6. Eramba con todas las variables necesarias
Write-Host "6. Iniciando Eramba..." -ForegroundColor Yellow
docker run -d --name eramba-app --network eramba-net -p 8080:80 `
  -e APP_ENV=production `
  -e APP_DEBUG=true `
  -e DB_CONNECTION=mysql `
  -e DB_HOST=mysql-eramba `
  -e DB_PORT=3306 `
  -e DB_DATABASE=eramba `
  -e DB_USERNAME=eramba `
  -e DB_PASSWORD=password123 `
  -e CACHE_DRIVER=redis `
  -e REDIS_HOST=redis-eramba `
  -e REDIS_PORT=6379 `
  -e "CACHE_URL=Redis://?server=redis-eramba&port=6379" `
  -e "PUBLIC_ADDRESS=http://localhost:8080" `
  -e DOCKER_DEPLOYMENT=1 `
  ghcr.io/eramba/eramba:latest

# 7. Worker
Write-Host "7. Iniciando Worker..." -ForegroundColor Yellow
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

# 8. Esperar inicialización completa
Write-Host "8. Esperando inicializacion (3 minutos)..." -ForegroundColor Yellow
Start-Sleep -Seconds 180

# 9. Configurar usuario admin con permisos completos
Write-Host "9. Configurando usuario admin..." -ForegroundColor Yellow
docker exec mysql-eramba mysql -u eramba -ppassword123 eramba -e "DELETE FROM users_groups WHERE user_id = 1;"
docker exec mysql-eramba mysql -u eramba -ppassword123 eramba -e "INSERT INTO users_groups (user_id, group_id) VALUES (1, 1);"
docker exec mysql-eramba mysql -u eramba -ppassword123 eramba -e "UPDATE users SET password = 'admin' WHERE id = 1;"

# 10. Configurar permisos de visualización
Write-Host "10. Configurando permisos..." -ForegroundColor Yellow
docker exec eramba-app chown -R www-data:www-data /var/www/eramba
docker exec eramba-app chmod -R 777 /var/www/eramba/laravel/storage

# 11. Limpiar caché
Write-Host "11. Limpiando cache..." -ForegroundColor Yellow
docker exec eramba-app php /var/www/eramba/laravel/artisan cache:clear
docker exec eramba-app php /var/www/eramba/laravel/artisan config:clear

Write-Host ""
Write-Host "=== ERAMBA LISTO CON BOTONES ADD ===" -ForegroundColor Green
Write-Host "URL: http://localhost:8080" -ForegroundColor Cyan
Write-Host "Usuario: admin" -ForegroundColor White
Write-Host "Password: admin" -ForegroundColor White
Write-Host ""
Write-Host "NOTA: Los botones morados ADD deberan aparecer ahora" -ForegroundColor Yellow
