# Práctica: Evaluación de Controles de Seguridad con Eramba Community

## Objetivo General
Realizar una auditoría de sistemas enfocada en controles de seguridad de la información utilizando Eramba Community, aplicando los conceptos de COBIT 2023 e ISO 27001:2022.

## Caso de Estudio: TechSecure Solutions
Empresa mediana que proporciona servicios de desarrollo de software y almacenamiento en la nube.

### Alcance de la Auditoría
- Evaluación de controles de acceso lógico
- Gestión de respaldos
- Seguridad en el desarrollo de software
- Gestión de incidentes
- Continuidad del negocio

## Estructura del Proyecto
```
Eramba-TechSecure-Audit/
├── docker/                           # Configuración Docker
│   ├── install-eramba-final-con-botones.ps1  # Script de instalación completa
│   ├── restaurar-eramba.ps1          # Script para restaurar después de reinicio
│   └── reset-eramba-con-botones.ps1  # Script de reset completo
├── docs/                             # Documentación de la auditoría
├── data/                             # Datos de respaldo de Eramba
├── SOLUCION-DEFINITIVA.md            # Guía de soluciones alternativas
└── README.md                         # Este archivo
```

## 🚀 Instalación de Eramba Community con Docker

### Prerrequisitos
- **Docker Desktop** instalado en Windows 11
- **PowerShell** con permisos de administrador
- Al menos **8GB de RAM** disponible
- Puertos **8080, 3306, 6379** disponibles

### 📋 Instalación Paso a Paso

#### Opción 1: Instalación Automática (Recomendada)
```powershell
# Navegar al directorio del proyecto
cd C:\Users\usuario\CascadeProjects\Eramba-TechSecure-Audit\docker

# Ejecutar script de instalación completa
.\install-eramba-final-con-botones.ps1
```

#### Opción 2: Instalación Manual
```powershell
# 1. Crear red Docker
docker network create eramba-net

# 2. Iniciar MySQL
docker run -d --name mysql-eramba --network eramba-net \
  -e MYSQL_ROOT_PASSWORD=password123 \
  -e MYSQL_DATABASE=eramba \
  -e MYSQL_USER=eramba \
  -e MYSQL_PASSWORD=password123 \
  -p 3306:3306 \
  mysql:8.0 --default-authentication-plugin=mysql_native_password --disable-log-bin --sql_mode=""

# 3. Iniciar Redis
docker run -d --name redis-eramba --network eramba-net -p 6379:6379 redis:alpine

# 4. Esperar 90 segundos para MySQL
Start-Sleep -Seconds 90

# 5. Configurar MySQL
docker exec mysql-eramba mysql -u root -ppassword123 -e "SET GLOBAL max_allowed_packet = 128000000;"
docker exec mysql-eramba mysql -u root -ppassword123 -e "SET GLOBAL innodb_lock_wait_timeout = 200;"
docker exec mysql-eramba mysql -u root -ppassword123 -e "GRANT ALL PRIVILEGES ON *.* TO 'eramba'@'%' WITH GRANT OPTION; FLUSH PRIVILEGES;"

# 6. Iniciar Eramba
docker run -d --name eramba-app --network eramba-net -p 8080:80 \
  -e APP_ENV=production \
  -e DB_CONNECTION=mysql \
  -e DB_HOST=mysql-eramba \
  -e DB_PORT=3306 \
  -e DB_DATABASE=eramba \
  -e DB_USERNAME=eramba \
  -e DB_PASSWORD=password123 \
  -e CACHE_DRIVER=redis \
  -e REDIS_HOST=redis-eramba \
  -e REDIS_PORT=6379 \
  -e "CACHE_URL=Redis://?server=redis-eramba&port=6379" \
  -e "PUBLIC_ADDRESS=http://localhost:8080" \
  -e DOCKER_DEPLOYMENT=1 \
  ghcr.io/eramba/eramba:latest

# 7. Iniciar Worker/Cron
docker run -d --name eramba-cron --network eramba-net \
  -e DB_HOST=mysql-eramba \
  -e DB_DATABASE=eramba \
  -e DB_USERNAME=eramba \
  -e DB_PASSWORD=password123 \
  -e "CACHE_URL=Redis://?server=redis-eramba&port=6379" \
  -e "PUBLIC_ADDRESS=http://localhost:8080" \
  -e DOCKER_DEPLOYMENT=1 \
  --entrypoint="/docker-cron-entrypoint.sh" \
  ghcr.io/eramba/eramba:latest cron -f

# 8. Esperar inicialización completa (4 minutos)
Start-Sleep -Seconds 240
```

### 🔧 Configuración Post-Instalación
```powershell
# Configurar usuario admin
docker exec mysql-eramba mysql -u eramba -ppassword123 eramba -e "UPDATE users SET password = 'admin' WHERE id = 1;"
docker exec mysql-eramba mysql -u eramba -ppassword123 eramba -e "DELETE FROM users_groups WHERE user_id = 1; INSERT INTO users_groups (user_id, group_id) VALUES (1, 1);"

# Configurar permisos de archivos
docker exec eramba-app chown -R www-data:www-data /var/www/eramba
docker exec eramba-app chmod -R 777 /var/www/eramba/laravel/storage

# Limpiar caché
docker exec eramba-app php /var/www/eramba/laravel/artisan cache:clear
docker exec eramba-app php /var/www/eramba/laravel/artisan config:clear
```

## 🌐 Acceso a la Aplicación

### URL de Acceso
- **Aplicación Principal:** http://localhost:8080
- **Login Directo:** http://localhost:8080/login

### Credenciales por Defecto
- **Usuario:** `admin`
- **Contraseña:** `admin`

### ⚠️ Notas Importantes
- **NO** acceder a `/welcome` - ir directamente a `/login`
- Esperar al menos **4 minutos** después de la instalación antes del primer acceso
- Los botones "+Add Item" deberían aparecer después de la configuración completa

## 🔄 Gestión de Contenedores

### Verificar Estado
```powershell
docker ps
```

### Reiniciar Después de Corte de Luz
```powershell
.\restaurar-eramba.ps1
```

### Logs de Depuración
```powershell
# Ver logs de Eramba
docker logs eramba-app --tail=20

# Ver logs de MySQL
docker logs mysql-eramba --tail=10
```

### Detener Servicios
```powershell
docker stop eramba-app eramba-cron mysql-eramba redis-eramba
```

### Eliminar Instalación Completa
```powershell
docker stop eramba-app eramba-cron mysql-eramba redis-eramba
docker rm eramba-app eramba-cron mysql-eramba redis-eramba
docker volume prune -f
docker network rm eramba-net
```

## 🛠️ Solución de Problemas

### Problema: Errores 500 en APIs
**Solución:** Verificar configuración de base de datos
```powershell
docker exec eramba-app php /var/www/eramba/laravel/artisan config:clear
docker restart eramba-app
```

### Problema: No aparecen botones "+Add Item"
**Solución:** Configurar permisos de usuario
```powershell
docker exec mysql-eramba mysql -u eramba -ppassword123 eramba -e "DELETE FROM users_groups WHERE user_id = 1; INSERT INTO users_groups (user_id, group_id) VALUES (1, 1);"
docker restart eramba-app
```

### Problema: Bloqueo de cuenta
**Solución:** Limpiar intentos de login
```powershell
docker exec mysql-eramba mysql -u eramba -ppassword123 eramba -e "TRUNCATE TABLE login_bans; TRUNCATE TABLE login_attempts;"
```

### Problema: Página de bienvenida infinita
**Solución:** Forzar bypass de configuración inicial
```powershell
docker exec mysql-eramba mysql -u eramba -ppassword123 eramba -e "INSERT IGNORE INTO settings (name, value, created, modified) VALUES ('installation_complete', '1', NOW(), NOW()), ('welcome_completed', '1', NOW(), NOW());"
```

## 📊 Configuración de TechSecure Solutions

### Información de la Organización
- **Nombre:** TechSecure Solutions
- **Tipo:** Empresa de desarrollo de software
- **Tamaño:** Mediana empresa
- **Servicios:** Desarrollo de software y almacenamiento en la nube

### Unidades de Negocio Sugeridas
1. **Dirección General**
2. **Tecnologías de la Información**
3. **Operaciones**
4. **Cumplimiento y Auditoría**

## 📚 Marcos de Referencia

### ISO 27001:2022
- Controles de seguridad de la información
- Gestión de riesgos
- Auditorías internas

### COBIT 2023
- Gobierno de TI
- Gestión de procesos
- Evaluación de controles

## 🎯 Entregables de la Práctica

1. **Configuración de Eramba** ✅
2. **Definición de TechSecure Solutions** 
3. **Implementación de controles ISO 27001:2022**
4. **Evaluación con COBIT 2023**
5. **Informe de auditoría**

## 📝 Versión y Compatibilidad

- **Eramba Community:** v3.27.1
- **MySQL:** 8.0
- **Redis:** Alpine
- **Docker:** Compatible con Windows 11
- **Navegadores:** Chrome, Firefox, Edge

## 🆘 Soporte y Alternativas

Si la instalación local presenta problemas persistentes, consultar:
- `SOLUCION-DEFINITIVA.md` - Alternativas como Eramba Cloud
- Scripts de restauración en la carpeta `docker/`
- Documentación oficial de Eramba Community

---

**Desarrollado para la práctica académica de Auditoría de Sistemas**  
**Fecha:** Octubre 2025
