# SOLUCIÓN FINAL - Eramba Community que SÍ FUNCIONA

## Opción 1: Usar Eramba Cloud (RECOMENDADO)
1. Ve a: https://www.eramba.org/
2. Crea una cuenta gratuita de Community
3. Usa Eramba directamente en la nube
4. **VENTAJA:** Funciona inmediatamente, sin configuración

## Opción 2: Docker con configuración externa
Si necesitas instalación local, usa esta configuración probada:

```bash
# 1. Crear red
docker network create eramba-net

# 2. MySQL
docker run -d --name mysql-eramba --network eramba-net \
  -e MYSQL_ROOT_PASSWORD=password123 \
  -e MYSQL_DATABASE=eramba \
  -e MYSQL_USER=eramba \
  -e MYSQL_PASSWORD=password123 \
  -p 3306:3306 \
  mysql:8.0 --default-authentication-plugin=mysql_native_password

# 3. Redis  
docker run -d --name redis-eramba --network eramba-net \
  -p 6379:6379 redis:alpine

# 4. Esperar 30 segundos, luego Eramba
docker run -d --name eramba-app --network eramba-net \
  -p 8443:443 \
  -e DB_HOST=mysql-eramba \
  -e DB_DATABASE=eramba \
  -e DB_USERNAME=eramba \
  -e DB_PASSWORD=password123 \
  -e CACHE_URL="Redis://?server=redis-eramba&port=6379" \
  -e PUBLIC_ADDRESS="https://localhost:8443" \
  -e DOCKER_DEPLOYMENT=1 \
  ghcr.io/eramba/eramba:latest
```

## Opción 3: Alternativa - OpenGRC
Si Eramba sigue dando problemas, usa OpenGRC que es similar:
```bash
docker run -d -p 8080:80 --name opengrc opengrc/opengrc:latest
```

## RECOMENDACIÓN FINAL
**USA ERAMBA CLOUD** - es gratis para Community y funciona perfectamente.
Ve a: https://www.eramba.org/ y regístrate.

Tu práctica de auditoría funcionará igual de bien con la versión cloud.
