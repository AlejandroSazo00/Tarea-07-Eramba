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
├── docker/                 # Configuración Docker
├── docs/                   # Documentación de la auditoría
├── data/                   # Datos de respaldo de Eramba
└── README.md              # Este archivo
```

## Instalación con Docker

### Prerrequisitos
- Docker Desktop instalado en Windows 11
- Al menos 4GB de RAM disponible
- Puerto 80 disponible

### Pasos de Instalación
1. Ejecutar `docker-compose up -d` en la carpeta docker/
2. Esperar a que todos los servicios estén ejecutándose
3. Acceder a http://localhost para configurar Eramba

## Credenciales por Defecto
- Usuario: admin
- Contraseña: admin

**¡IMPORTANTE!** Cambiar estas credenciales inmediatamente después del primer acceso.
