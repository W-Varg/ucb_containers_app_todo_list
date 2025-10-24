# 📝 Changelog - ToDo App Backend

Todos los cambios notables del backend serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/lang/es/).

---

## [1.0.1] - 2025-10-24

### Agregado
- Comentario de documentación para rastrear cambios de versión en `server.js` línea 41
- Sistema de versionamiento de imágenes Docker

### Cambios
- Preparación para sistema de rollback en Kubernetes

### Notas
- Primera versión versionada para Docker Hub
- Imagen lista para despliegue en K8s con capacidad de rollback

---

## [1.0.0] - 2025-10-23

### Agregado
- Release inicial del backend
- Conexión a MongoDB
- Conexión a Redis con caché
- API REST completa para gestión de tareas
- Health check endpoint
- Endpoint de estadísticas
- Manejo de errores robusto
- Cierre graceful del servidor

### Características
- CRUD completo de tareas
- Sistema de prioridades (low, medium, high)
- Caché con Redis (TTL 60 segundos)
- Persistencia con MongoDB
- Logs informativos con emojis
- Validación de datos
- Soporte para CORS

---

## Próximas Versiones

### [1.0.2] - Planificado
- [ ] Mejoras en el sistema de logging
- [ ] Optimización de queries a MongoDB
- [ ] Mejora en el manejo de cache

### [1.0.3] - Planificado
- [ ] Endpoint de búsqueda de tareas
- [ ] Filtros avanzados
- [ ] Paginación de resultados

### [1.1.0] - Futuro
- [ ] Autenticación con JWT
- [ ] Sistema de usuarios
- [ ] Tareas compartidas

---

## Formato de Versionamiento

- **MAJOR.MINOR.PATCH** (ej: 1.0.1)
  - **MAJOR**: Cambios incompatibles con versiones anteriores
  - **MINOR**: Nueva funcionalidad compatible con versiones anteriores
  - **PATCH**: Corrección de bugs

---

## Cómo Actualizar

```bash
# 1. Hacer cambios en el código
vim backend/server.js

# 2. Actualizar este CHANGELOG.md

# 3. Construir y subir nueva versión
./build-and-push.sh 1.0.X

# 4. Actualizar en Kubernetes
kubectl set image deployment/backend backend=wvarg/todo-backend:1.0.X -n todo-app
```

---

## Historial de Despliegues

| Versión | Fecha | Docker Hub | K8s | Notas |
|---------|-------|------------|-----|-------|
| 1.0.0 | 2025-10-23 | ✅ | ✅ | Release inicial |
| 1.0.1 | 2025-10-24 | ⏳ | ⏳ | Sistema de versionamiento |
| 1.0.2 | - | ⏳ | ⏳ | Pendiente |
| 1.0.3 | - | ⏳ | ⏳ | Pendiente |

---

**Última actualización:** 24 de Octubre, 2025
