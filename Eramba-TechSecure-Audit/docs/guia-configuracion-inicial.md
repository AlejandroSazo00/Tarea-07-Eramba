# Guía de Configuración Inicial - Eramba Community

## Fase 1: Configuración Inicial en Eramba (2 horas)

### 1. Acceso Inicial al Sistema

1. **Abrir navegador** y acceder a: `http://localhost`
2. **Credenciales iniciales:**
   - Usuario: `admin`
   - Contraseña: `admin`
3. **¡CRÍTICO!** Cambiar contraseña inmediatamente

### 2. Configuración de la Organización TechSecure Solutions

#### 2.1 Información Básica de la Empresa
- **Nombre:** TechSecure Solutions
- **Tipo:** Empresa de desarrollo de software y almacenamiento en la nube
- **Tamaño:** Mediana empresa
- **Sector:** Tecnología de la información

#### 2.2 Estructura Organizacional a Crear
```
TechSecure Solutions
├── Dirección General
├── Departamento de TI
│   ├── Desarrollo de Software
│   ├── Infraestructura y Redes
│   └── Seguridad de la Información
├── Departamento de Operaciones
│   ├── Gestión de Servicios
│   └── Continuidad del Negocio
└── Departamento de Cumplimiento
    ├── Auditoría Interna
    └── Gestión de Riesgos
```

### 3. Configuración de Marcos de Referencia

#### 3.1 ISO 27001:2022
**Controles a implementar:**
- A.5 - Políticas de seguridad de la información
- A.6 - Organización de la seguridad de la información
- A.8 - Gestión de activos
- A.9 - Control de acceso
- A.12 - Seguridad de las operaciones
- A.17 - Aspectos de seguridad de la información en la gestión de la continuidad del negocio
- A.18 - Cumplimiento

#### 3.2 COBIT 2023
**Dominios a alinear:**
- **EDM (Evaluar, Dirigir y Monitorear)**
  - EDM03 - Asegurar la optimización del riesgo
- **APO (Alinear, Planificar y Organizar)**
  - APO12 - Gestionar el riesgo
  - APO13 - Gestionar la seguridad
- **BAI (Construir, Adquirir e Implementar)**
  - BAI06 - Gestionar los cambios
- **DSS (Entregar, Dar Servicio y Soporte)**
  - DSS05 - Gestionar los servicios de seguridad
  - DSS06 - Gestionar los controles de procesos de negocio

### 4. Definición de Roles y Responsabilidades

#### 4.1 Roles en Eramba
1. **Administrador del Sistema**
   - Configuración general
   - Gestión de usuarios
   - Mantenimiento del sistema

2. **Auditor Principal**
   - Planificación de auditorías
   - Ejecución de evaluaciones
   - Generación de informes

3. **Responsable de Seguridad**
   - Gestión de controles
   - Seguimiento de incidentes
   - Implementación de mejoras

4. **Propietario de Proceso**
   - Validación de controles
   - Implementación de acciones correctivas
   - Reporte de estado

#### 4.2 Matriz de Responsabilidades RACI
| Actividad | Admin | Auditor | Seg. | Propietario |
|-----------|-------|---------|------|-------------|
| Configurar sistema | R | C | I | I |
| Planificar auditoría | C | R | A | I |
| Ejecutar evaluación | I | R | C | A |
| Implementar controles | I | C | A | R |
| Generar informes | I | R | C | C |

### 5. Configuración de Controles por Área

#### 5.1 Controles de Acceso Lógico
- **Control ID:** AC-001 a AC-010
- **Marco:** ISO 27001:2022 - A.9
- **Frecuencia de evaluación:** Trimestral
- **Responsable:** Departamento de TI - Seguridad

#### 5.2 Gestión de Respaldos
- **Control ID:** BK-001 a BK-005
- **Marco:** ISO 27001:2022 - A.12.3
- **Frecuencia de evaluación:** Mensual
- **Responsable:** Departamento de TI - Infraestructura

#### 5.3 Seguridad en Desarrollo
- **Control ID:** SD-001 a SD-008
- **Marco:** ISO 27001:2022 - A.14
- **Frecuencia de evaluación:** Por proyecto
- **Responsable:** Departamento de TI - Desarrollo

#### 5.4 Gestión de Incidentes
- **Control ID:** IR-001 a IR-006
- **Marco:** ISO 27001:2022 - A.16
- **Frecuencia de evaluación:** Mensual
- **Responsable:** Departamento de TI - Seguridad

#### 5.5 Continuidad del Negocio
- **Control ID:** BC-001 a BC-007
- **Marco:** ISO 27001:2022 - A.17
- **Frecuencia de evaluación:** Semestral
- **Responsable:** Departamento de Operaciones

### 6. Checklist de Configuración Inicial

- [ ] Cambiar credenciales por defecto
- [ ] Configurar información de la empresa
- [ ] Crear estructura organizacional
- [ ] Definir usuarios y roles
- [ ] Importar marcos de referencia (ISO 27001:2022, COBIT 2023)
- [ ] Configurar controles por área
- [ ] Establecer frecuencias de evaluación
- [ ] Configurar notificaciones
- [ ] Realizar backup inicial de configuración
- [ ] Documentar configuración realizada

### 7. Próximos Pasos

Una vez completada la configuración inicial:
1. **Fase 2:** Mapeo de Activos y Procesos
2. **Fase 3:** Evaluación de Controles
3. **Fase 4:** Análisis de Brechas
4. **Fase 5:** Plan de Remediación
5. **Fase 6:** Generación de Informes
