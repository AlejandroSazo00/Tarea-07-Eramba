# Instalación final de Eramba con botones +Add Item funcionando
Write-Host "=== INSTALACION FINAL ERAMBA CON BOTONES ===" -ForegroundColor Green

# 1. Limpiar todo
Write-Host "1. Limpiando instalacion anterior..." -ForegroundColor Yellow
docker network rm eramba-net 2>$null

# 2. Crear red
Write-Host "2. Creando red..." -ForegroundColor Yellow
docker network create eramba-net

# 3. MySQL
Write-Host "3. Iniciando MySQL..." -ForegroundColor Yellow
docker run -d --name mysql-eramba --network eramba-net `
  -e MYSQL_ROOT_PASSWORD=password123 `
  -e MYSQL_DATABASE=eramba `
  -e MYSQL_USER=eramba `
  -e MYSQL_PASSWORD=password123 `
  -p 3306:3306 `
  mysql:8.0 --default-authentication-plugin=mysql_native_password --disable-log-bin --sql_mode=""

# 4. Redis
Write-Host "4. Iniciando Redis..." -ForegroundColor Yellow
docker run -d --name redis-eramba --network eramba-net -p 6379:6379 redis:alpine

# 5. Esperar MySQL
Write-Host "5. Esperando MySQL (90 segundos)..." -ForegroundColor Yellow
Start-Sleep -Seconds 90

# 6. Configurar MySQL
Write-Host "6. Configurando MySQL..." -ForegroundColor Yellow
docker exec mysql-eramba mysql -u root -ppassword123 -e "SET GLOBAL max_allowed_packet = 128000000;"
docker exec mysql-eramba mysql -u root -ppassword123 -e "SET GLOBAL innodb_lock_wait_timeout = 200;"
docker exec mysql-eramba mysql -u root -ppassword123 -e "GRANT ALL PRIVILEGES ON *.* TO 'eramba'@'%' WITH GRANT OPTION; FLUSH PRIVILEGES;"

# 7. Eramba
Write-Host "7. Iniciando Eramba..." -ForegroundColor Yellow
docker run -d --name eramba-app --network eramba-net -p 8080:80 `
  -e APP_ENV=production `
  -e APP_DEBUG=false `
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

# 8. Worker
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

# 9. Esperar inicialización COMPLETA
Write-Host "9. Esperando inicializacion COMPLETA (4 minutos)..." -ForegroundColor Yellow
Start-Sleep -Seconds 240

# 10. Configurar datos para que aparezcan los botones
Write-Host "10. Configurando botones +Add Item..." -ForegroundColor Yellow
docker exec mysql-eramba mysql -u eramba -ppassword123 eramba -e "UPDATE users SET password = 'admin' WHERE id = 1;"
docker exec mysql-eramba mysql -u eramba -ppassword123 eramba -e "DELETE FROM users_groups WHERE user_id = 1; INSERT INTO users_groups (user_id, group_id) VALUES (1, 1);"
docker exec mysql-eramba mysql -u eramba -ppassword123 eramba -e "INSERT IGNORE INTO settings (name, value, created, modified) VALUES ('installation_complete', '1', NOW(), NOW()), ('welcome_completed', '1', NOW(), NOW());"

# 11. Permisos
Write-Host "11. Configurando permisos..." -ForegroundColor Yellow
docker exec eramba-app chown -R www-data:www-data /var/www/eramba
docker exec eramba-app chmod -R 777 /var/www/eramba/laravel/storage

# 12. Limpiar caché final
Write-Host "12. Limpiando cache final..." -ForegroundColor Yellow
docker exec eramba-app php /var/www/eramba/laravel/artisan cache:clear 2>$null
docker exec eramba-app php /var/www/eramba/laravel/artisan config:clear 2>$null

Write-Host ""
Write-Host "=== ERAMBA LISTO CON BOTONES +ADD ITEM ===" -ForegroundColor Green
Write-Host "URL: http://localhost:8080/login" -ForegroundColor Cyan
Write-Host "Usuario: admin" -ForegroundColor White
Write-Host "Password: admin" -ForegroundColor White
Write-Host ""
Write-Host "IMPORTANTE: Ve directamente a /login, NO a /welcome" -ForegroundColor Red
Write-Host "Los botones +Add Item deben aparecer ahora" -ForegroundColor Yellow
