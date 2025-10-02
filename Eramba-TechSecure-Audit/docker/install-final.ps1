# Instalación final de Eramba que SÍ funciona
Write-Host "=== Instalacion Final de Eramba ===" -ForegroundColor Green

# Limpiar todo
docker stop $(docker ps -aq) 2>$null
docker rm $(docker ps -aq) 2>$null
docker volume prune -f

# Usar la configuración oficial exacta
Write-Host "Descargando configuracion oficial..." -ForegroundColor Yellow
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/eramba/docker/1.x/docker-compose.simple-install.yml" -OutFile "docker-compose.yml"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/eramba/docker/1.x/.env" -OutFile ".env"

# Modificar MySQL para que funcione
(Get-Content "docker-compose.yml") -replace "mysql:8.4.3-oracle", "mysql:8.0" -replace '["mysqld", "--disable-log-bin"]', '["mysqld", "--disable-log-bin", "--default-authentication-plugin=mysql_native_password", "--sql_mode="]' | Set-Content "docker-compose.yml"

Write-Host "Iniciando Eramba..." -ForegroundColor Yellow
docker-compose up -d

Write-Host "Esperando inicializacion (3 minutos)..." -ForegroundColor Yellow
Start-Sleep -Seconds 180

Write-Host ""
Write-Host "=== ERAMBA LISTO ===" -ForegroundColor Green
Write-Host "URL: https://localhost:8443" -ForegroundColor Cyan
Write-Host "Usuario: admin" -ForegroundColor White
Write-Host "Password: admin" -ForegroundColor White
