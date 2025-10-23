# 📝 ToDo App - Proyecto Final de Containerización y Orquestación

## 📋 Descripción del Proyecto

Sistema de gestión de tareas (ToDo List) completamente containerizado y orquestado, desarrollado como proyecto final para el curso de **Containerización y Orquestación de Contenedores** de la Universidad Católica Boliviana (UCB).

El proyecto implementa una arquitectura de microservicios con 6 servicios diferenciados, desplegables en entornos locales (Docker Compose), Docker Swarm y Kubernetes.

### 🎯 Características Principales

- ✅ Aplicación web multi-servicio completamente funcional
- 🐳 Containerización completa con Docker
- 🔄 Orquestación con Docker Swarm
- ☸️ Despliegue en Kubernetes
- 📊 Balanceo de carga con Nginx
- 💾 Persistencia de datos con MongoDB
- ⚡ Cache con Redis
- 🔧 Procesamiento en background con Worker
- 📈 Escalabilidad horizontal
- 🔒 Buenas prácticas de seguridad

---

## 🏗️ Arquitectura del Sistema

```
┌─────────────────────────────────────────────────────────────┐
│                        USUARIO                               │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
        ┌─────────────────────────────┐
        │      NGINX (Port 80)        │
        │   Reverse Proxy & LB        │
        └──────────┬──────────────────┘
                   │
         ┌─────────┴─────────┐
         ▼                   ▼
┌──────────────────┐  ┌──────────────────┐
│    FRONTEND      │  │    BACKEND API   │
│   React:3000     │  │   Node.js:5000   │
└──────────────────┘  └─────────┬────────┘
                                │
                    ┌───────────┼───────────┐
                    ▼           ▼           ▼
              ┌─────────┐ ┌─────────┐ ┌─────────┐
              │ MongoDB │ │  Redis  │ │ Worker  │
              │  :27017 │ │  :6379  │ │ Process │
              └─────────┘ └─────────┘ └─────────┘
```

### 📦 Servicios

| Servicio | Tecnología | Puerto | Descripción |
|----------|-----------|--------|-------------|
| **Frontend** | React 18 | 3000 | Interfaz de usuario web |
| **Backend** | Node.js + Express | 5000 | API REST para gestión de tareas |
| **MongoDB** | MongoDB 7 | 27017 | Base de datos NoSQL |
| **Redis** | Redis 7 Alpine | 6379 | Cache y almacenamiento temporal |
| **Nginx** | Nginx Alpine | 80 | Reverse proxy y load balancer |
| **Worker** | Node.js | N/A | Procesamiento en background |

---

## 📁 Estructura del Proyecto

```
ucb-final/
├── frontend/                 # Aplicación React
│   ├── public/
│   ├── src/
│   │   ├── App.js
│   │   ├── App.css
│   │   ├── index.js
│   │   └── index.css
│   ├── package.json
│   ├── Dockerfile
│   └── .dockerignore
├── backend/                  # API Node.js
│   ├── server.js
│   ├── package.json
│   ├── Dockerfile
│   ├── .dockerignore
│   └── .env.example
├── worker/                   # Servicio Worker
│   ├── worker.js
│   ├── package.json
│   ├── Dockerfile
│   └── .dockerignore
├── nginx/                    # Configuración Nginx
│   ├── nginx.conf
│   └── Dockerfile
├── mongodb-init/             # Scripts de inicialización
│   └── init-mongo.js
├── kubernetes/               # Manifiestos K8s
│   ├── 00-namespace.yaml
│   ├── 01-secrets-configmap.yaml
│   ├── 02-persistent-volumes.yaml
│   ├── 03-mongodb-deployment.yaml
│   ├── 04-redis-deployment.yaml
│   ├── 05-backend-deployment.yaml
│   ├── 06-worker-deployment.yaml
│   ├── 07-frontend-deployment.yaml
│   ├── 08-nginx-loadbalancer.yaml
│   └── 09-version-2-deployments.yaml
├── swarm/                    # Configuración Swarm
│   └── stack-deploy.yml
├── docker-compose.yml        # Despliegue local
└── README.md                 # Esta documentación
```

---

## 🚀 Guía de Despliegue

### Prerrequisitos

- Docker Engine 20.10+
- Docker Compose 2.0+
- Docker Swarm (para despliegue en clúster)
- Kubernetes 1.25+ / Minikube / Kind (para despliegue K8s)
- 4GB RAM mínimo
- 10GB espacio en disco

### 🔧 1. Despliegue Local con Docker Compose

#### 1.1. Construcción de Imágenes

```bash
# Posicionarse en el directorio del proyecto
cd /home/dev/Documents/developer_folder/ucb/final

# Construir todas las imágenes
docker-compose build

# Verificar imágenes creadas
docker images | grep todo
```

#### 1.2. Iniciar los Servicios

```bash
# Levantar todos los servicios en background
docker-compose up -d

# Ver logs en tiempo real
docker-compose logs -f

# Ver estado de los servicios
docker-compose ps
```

#### 1.3. Verificar el Despliegue

```bash
# Verificar salud de los servicios
docker-compose ps

# Verificar logs específicos
docker-compose logs backend
docker-compose logs frontend

# Acceder a la aplicación
# Abrir navegador en: http://localhost
# O directamente al frontend: http://localhost:3000
# API disponible en: http://localhost:5000/api/tasks
```

#### 1.4. Probar la Aplicación

```bash
# Health check del backend
curl http://localhost:5000/health

# Obtener todas las tareas
curl http://localhost:5000/api/tasks

# Crear una nueva tarea
curl -X POST http://localhost:5000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "Mi primera tarea", "description": "Probar la aplicación", "priority": "high"}'

# Ver estadísticas
curl http://localhost:5000/api/stats
```

#### 1.5. Detener los Servicios

```bash
# Detener servicios
docker-compose stop

# Detener y eliminar contenedores
docker-compose down

# Detener y eliminar contenedores + volúmenes
docker-compose down -v
```

---

### 🐝 2. Despliegue en Docker Swarm

#### 2.1. Inicializar Swarm

```bash
# Inicializar nodo manager
docker swarm init

# Ver información del swarm
docker node ls

# Crear secreto para MongoDB (requerido)
echo "password123" | docker secret create mongodb_password -
```

#### 2.2. Construir y Etiquetar Imágenes

```bash
# Las imágenes ya construidas con docker-compose están listas
# Verificar
docker images | grep todo
```

#### 2.3. Desplegar el Stack

```bash
# Desplegar stack
docker stack deploy -c swarm/stack-deploy.yml todoapp

# Ver servicios del stack
docker stack services todoapp

# Ver tareas/contenedores
docker service ps todoapp_backend
docker service ps todoapp_frontend

# Ver logs de un servicio
docker service logs todoapp_backend
```

#### 2.4. Escalar Servicios

```bash
# Escalar backend a 5 réplicas
docker service scale todoapp_backend=5

# Escalar frontend a 4 réplicas
docker service scale todoapp_frontend=4

# Ver estado actualizado
docker stack services todoapp
```

#### 2.5. Actualizar Servicios (Rolling Update)

```bash
# Actualizar imagen del backend a versión 2.0
docker service update \
  --image todo-backend:2.0.0 \
  todoapp_backend

# Verificar actualización
docker service ps todoapp_backend
```

#### 2.6. Verificar Despliegue

```bash
# Acceder a la aplicación
# http://localhost (Nginx balancea automáticamente)

# Ver réplicas en ejecución
docker service ls

# Inspeccionar un servicio
docker service inspect todoapp_backend
```

#### 2.7. Remover el Stack

```bash
# Eliminar stack completo
docker stack rm todoapp

# Verificar eliminación
docker stack ls

# Salir de swarm (opcional)
docker swarm leave --force
```

---

### ☸️ 3. Despliegue en Kubernetes

#### 3.1. Preparar el Entorno (Minikube)

```bash
# Iniciar Minikube
minikube start --cpus=4 --memory=4096

# Verificar cluster
kubectl cluster-info
kubectl get nodes

# Habilitar dashboard (opcional)
minikube dashboard
```

#### 3.2. Cargar Imágenes en Minikube

```bash
# Cambiar al contexto de Docker de Minikube
eval $(minikube docker-env)

# Reconstruir imágenes en el contexto de Minikube
docker-compose build

# Verificar imágenes disponibles
minikube ssh -- docker images | grep todo

# Volver al contexto de Docker local (opcional)
eval $(minikube docker-env -u)
```

#### 3.3. Desplegar la Aplicación

```bash
# Aplicar manifiestos en orden
kubectl apply -f kubernetes/00-namespace.yaml
kubectl apply -f kubernetes/01-secrets-configmap.yaml
kubectl apply -f kubernetes/02-persistent-volumes.yaml
kubectl apply -f kubernetes/03-mongodb-deployment.yaml
kubectl apply -f kubernetes/04-redis-deployment.yaml

# Esperar que MongoDB y Redis estén listos
kubectl wait --for=condition=ready pod -l app=mongodb -n todoapp --timeout=120s
kubectl wait --for=condition=ready pod -l app=redis -n todoapp --timeout=60s

# Desplegar backend, worker, frontend y nginx
kubectl apply -f kubernetes/05-backend-deployment.yaml
kubectl apply -f kubernetes/06-worker-deployment.yaml
kubectl apply -f kubernetes/07-frontend-deployment.yaml
kubectl apply -f kubernetes/08-nginx-loadbalancer.yaml
```

#### 3.4. Verificar el Despliegue

```bash
# Ver todos los recursos
kubectl get all -n todoapp

# Ver pods
kubectl get pods -n todoapp

# Ver servicios
kubectl get services -n todoapp

# Ver deployments
kubectl get deployments -n todoapp

# Ver logs de un pod
kubectl logs -f <pod-name> -n todoapp

# Describir un pod
kubectl describe pod <pod-name> -n todoapp
```

#### 3.5. Acceder a la Aplicación

```bash
# Obtener URL del servicio (Minikube)
minikube service nginx-service -n todoapp --url

# Alternativamente, usar port-forward
kubectl port-forward -n todoapp service/nginx-service 8080:80

# Acceder en navegador
# http://localhost:8080 (si usas port-forward)
# O la URL que devuelve minikube service
```

#### 3.6. Desplegar Versión 2.0 (Versionamiento)

```bash
# Aplicar deployments versión 2
kubectl apply -f kubernetes/09-version-2-deployments.yaml

# Ver el rolling update en acción
kubectl rollout status deployment/backend-deployment-v2 -n todoapp
kubectl rollout status deployment/frontend-deployment-v2 -n todoapp

# Ver historial de rollouts
kubectl rollout history deployment/backend-deployment-v1 -n todoapp
kubectl rollout history deployment/backend-deployment-v2 -n todoapp
```

#### 3.7. Escalar Deployments

```bash
# Escalar backend v1
kubectl scale deployment backend-deployment-v1 --replicas=5 -n todoapp

# Escalar frontend v2
kubectl scale deployment frontend-deployment-v2 --replicas=3 -n todoapp

# Ver réplicas
kubectl get deployments -n todoapp
```

#### 3.8. Rollback (si es necesario)

```bash
# Hacer rollback del backend
kubectl rollout undo deployment/backend-deployment-v2 -n todoapp

# Rollback a una revisión específica
kubectl rollout undo deployment/backend-deployment-v2 --to-revision=1 -n todoapp
```

#### 3.9. Limpiar el Despliegue

```bash
# Eliminar todos los recursos del namespace
kubectl delete namespace todoapp

# Verificar eliminación
kubectl get all -n todoapp
```

---

## 🔍 Verificación y Pruebas

### Health Checks

```bash
# Docker Compose
curl http://localhost:5000/health

# Docker Swarm
curl http://localhost/health

# Kubernetes
kubectl exec -it <backend-pod> -n todoapp -- wget -O- http://localhost:5000/health
```

### Probar la API

```bash
# Listar tareas
curl http://localhost/api/tasks

# Crear tarea
curl -X POST http://localhost/api/tasks \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Tarea de prueba",
    "description": "Verificando el funcionamiento",
    "priority": "high"
  }'

# Actualizar tarea (reemplazar ID)
curl -X PUT http://localhost/api/tasks/<task-id> \
  -H "Content-Type: application/json" \
  -d '{"completed": true}'

# Eliminar tarea
curl -X DELETE http://localhost/api/tasks/<task-id>

# Ver estadísticas
curl http://localhost/api/stats
```

---

## 📊 Monitoreo y Logs

### Docker Compose

```bash
# Ver logs de todos los servicios
docker-compose logs

# Ver logs de un servicio específico
docker-compose logs -f backend

# Ver logs con timestamp
docker-compose logs -t frontend

# Últimas 50 líneas
docker-compose logs --tail=50 worker
```

### Docker Swarm

```bash
# Logs de servicio
docker service logs todoapp_backend

# Logs en tiempo real
docker service logs -f todoapp_frontend

# Últimas 100 líneas
docker service logs --tail=100 todoapp_worker
```

### Kubernetes

```bash
# Logs de un pod
kubectl logs <pod-name> -n todoapp

# Logs en tiempo real
kubectl logs -f <pod-name> -n todoapp

# Logs de todos los pods de un deployment
kubectl logs -l app=backend -n todoapp --all-containers=true

# Logs anteriores (si el pod se reinició)
kubectl logs <pod-name> -n todoapp --previous
```

---

## 🔒 Seguridad y Buenas Prácticas

### Implementadas en el Proyecto

✅ **Imágenes base ligeras**: Alpine Linux
✅ **Usuario no-root**: Backend y Worker usan usuario `nodejs`
✅ **.dockerignore**: Excluye archivos innecesarios
✅ **Multi-stage builds**: Frontend optimizado
✅ **Health checks**: Todos los servicios incluyen health checks
✅ **Secrets**: Uso de secrets en Kubernetes
✅ **ConfigMaps**: Configuración externalizada
✅ **Resource limits**: CPU y memoria limitados
✅ **Network isolation**: Redes separadas frontend/backend
✅ **Persistent volumes**: Datos persistentes
✅ **Graceful shutdown**: Manejo de señales SIGTERM

---

## 📈 Escalabilidad

### Servicios Escalables

| Servicio | Docker Compose | Swarm | Kubernetes |
|----------|---------------|-------|------------|
| Frontend | 1 réplica | 2 réplicas | 2 réplicas |
| Backend | 1 réplica | 3 réplicas | 3 réplicas |
| Worker | 1 réplica | 2 réplicas | 2 réplicas |
| Nginx | 1 réplica | 2 réplicas | 2 réplicas |
| MongoDB | 1 réplica | 1 réplica | 1 réplica |
| Redis | 1 réplica | 1 réplica | 1 réplica |

### Escalar Manualmente

```bash
# Docker Swarm
docker service scale todoapp_backend=10

# Kubernetes
kubectl scale deployment backend-deployment-v1 --replicas=10 -n todoapp
```

---

## 🐛 Troubleshooting

### Problemas Comunes

#### 1. Servicios no inician

```bash
# Ver logs detallados
docker-compose logs <servicio>
kubectl logs <pod-name> -n todoapp

# Verificar salud
docker-compose ps
kubectl get pods -n todoapp
```

#### 2. No se puede conectar a MongoDB

```bash
# Verificar que MongoDB esté corriendo
docker-compose ps mongodb
kubectl get pods -l app=mongodb -n todoapp

# Probar conexión
docker exec -it todo-mongodb mongosh --eval "db.adminCommand('ping')"
```

#### 3. Frontend no se conecta al Backend

```bash
# Verificar variable de entorno
docker-compose exec frontend env | grep REACT_APP_API_URL

# Verificar que nginx esté funcionando
curl http://localhost/health
```

#### 4. Imágenes no encontradas en Kubernetes

```bash
# Reconstruir en contexto de Minikube
eval $(minikube docker-env)
docker-compose build
```

---

## 📝 Variables de Entorno

### Backend
- `NODE_ENV`: Entorno de ejecución (production)
- `PORT`: Puerto del servidor (5000)
- `MONGODB_URI`: URI de conexión a MongoDB
- `REDIS_URL`: URL de conexión a Redis

### Frontend
- `REACT_APP_API_URL`: URL de la API backend

### Worker
- `NODE_ENV`: Entorno de ejecución (production)
- `MONGODB_URI`: URI de conexión a MongoDB
- `REDIS_URL`: URL de conexión a Redis

---

## 📚 Tecnologías Utilizadas

### Frontend
- React 18
- Axios
- CSS3

### Backend
- Node.js 18
- Express.js
- Mongoose
- Redis Client

### Base de Datos
- MongoDB 7
- Redis 7

### Infraestructura
- Docker
- Docker Compose
- Docker Swarm
- Kubernetes
- Nginx

---

## 👨‍💻 Autor

**Estudiante UCB**
- Curso: Containerización y Orquestación de Contenedores
- Proyecto: Examen Final
- Fecha: Octubre 2025

---

## 📄 Licencia

Este proyecto es parte de un examen académico de la Universidad Católica Boliviana (UCB).

---

## 🎓 Evaluación del Proyecto

### Cumplimiento de Requisitos

| Criterio | Ponderación | Implementado |
|----------|-------------|--------------|
| **Arquitectura y diseño** | 10% | ✅ 6 servicios modulares |
| **Containerización** | 25% | ✅ Dockerfiles optimizados, tags, Alpine |
| **Docker Compose/Swarm** | 20% | ✅ Compose funcional, Stack con réplicas |
| **Kubernetes** | 20% | ✅ Manifiestos completos, 2 versiones |
| **Documentación** | 25% | ✅ README detallado con diagramas |

### Características Adicionales

- ✅ Health checks en todos los servicios
- ✅ Logging centralizado
- ✅ Resource limits y requests
- ✅ Secrets y ConfigMaps
- ✅ Persistent volumes
- ✅ Rolling updates
- ✅ Multi-stage builds
- ✅ Security best practices

---

## 🔗 Enlaces Útiles

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- [Docker Swarm](https://docs.docker.com/engine/swarm/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Minikube](https://minikube.sigs.k8s.io/docs/)

---

**¡Proyecto completamente funcional y listo para evaluación! 🎉**
