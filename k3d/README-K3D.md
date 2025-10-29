# 🚀 Despliegue en K3D (K3s in Docker)

## 📋 Tabla de Contenidos

- [¿Qué es K3D?](#qué-es-k3d)
- [Arquitectura del Cluster](#arquitectura-del-cluster)
- [Prerequisitos](#prerequisitos)
- [Instalación Rápida](#instalación-rápida)
- [Configuración del Cluster](#configuración-del-cluster)
- [Despliegue](#despliegue)
- [Pruebas y Validación](#pruebas-y-validación)
- [Acceso a la Aplicación](#acceso-a-la-aplicación)
- [Comandos Útiles](#comandos-útiles)
- [Troubleshooting](#troubleshooting)
- [Limpieza](#limpieza)

---

## ¿Qué es K3D?

**K3D** es una herramienta que ejecuta **K3s** (Kubernetes ligero de Rancher) en contenedores Docker. Es ideal para:

- **Desarrollo local** de aplicaciones Kubernetes
- **Testing** de configuraciones antes de producción
- **CI/CD** pipelines
- **Aprendizaje** de Kubernetes sin infraestructura compleja

### Ventajas sobre otros entornos:

| Característica | K3D | Minikube | Kind |
|----------------|-----|----------|------|
| Velocidad de inicio | ⚡ Muy rápido | 🐌 Lento | ⚡ Rápido |
| Uso de recursos | 💚 Bajo | 💛 Medio | 💚 Bajo |
| Multi-nodo | Sí | Sí | Sí |
| Registry local | Built-in | ❌ Manual | ❌ Manual |
| LoadBalancer | Automático | ⚠️ Requiere tunnel | ❌ Manual |

---

## 🏗️ Arquitectura del Cluster

```
┌─────────────────────────────────────────────────────────────┐
│                     K3D TODO CLUSTER                         │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐                                           │
│  │   Master     │  Control Plane (1 nodo)                   │
│  │   Node       │  - API Server                             │
│  └──────────────┘  - Scheduler                              │
│                    - Controller Manager                      │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Worker 1   │  │   Worker 2   │  │   Worker 3   │      │
│  │              │  │              │  │              │      │
│  │  MongoDB     │  │  Redis       │  │  Backend     │      │
│  │              │  │  Worker      │  │  Frontend    │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│                                                              │
│  ┌──────────────────────────────────────────────────┐       │
│  │           LoadBalancer (Nginx)                   │       │
│  │  Port 8080 → http://localhost:8080               │       │
│  └──────────────────────────────────────────────────┘       │
│                                                              │
│  ┌──────────────────────────────────────────────────┐       │
│  │           Registry Local (puerto 5555)           │       │
│  │  k3d-todo-registry.localhost:5555                │       │
│  └──────────────────────────────────────────────────┘       │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Componentes Desplegados:

| Componente | Replicas | Recursos | Puertos |
|------------|----------|----------|---------|
| MongoDB (StatefulSet) | 1 | 256Mi-512Mi / 250m-500m CPU | 27017 |
| Redis (Deployment) | 1 | 128Mi-256Mi / 100m-200m CPU | 6379 |
| Backend API (Deployment) | 3 | 256Mi-512Mi / 200m-500m CPU | 5000 |
| Frontend (Deployment) | 2 | 128Mi-256Mi / 100m-200m CPU | 80 |
| Worker (Deployment) | 2 | 256Mi-512Mi / 150m-300m CPU | - |
| Nginx LB (Deployment) | 2 | 128Mi-256Mi / 100m-200m CPU | 80 |

---

## 📦 Prerequisitos

### Software Requerido:

```bash
# Docker
docker --version  # >= 20.10

# kubectl (se instala automáticamente con K3D)
kubectl version --client

# curl (para pruebas)
curl --version
```

### Recursos del Sistema:

- **RAM**: Mínimo 4GB disponible (8GB recomendado)
- **CPU**: Mínimo 2 cores (4 cores recomendado)
- **Disco**: 10GB libres

---

## 🚀 Instalación Rápida

### Opción 1: Usando el script automático

```bash
cd /home/dev/Documents/developer_folder/ucb/final
chmod +x k3d/deploy-k3d.sh
./k3d/deploy-k3d.sh
```

### Opción 2: Instalación manual

```bash
# 1. Instalar K3D
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# 2. Verificar instalación
k3d version

# 3. Crear cluster
k3d cluster create --config ./k3d/cluster-config.yaml

# 4. Aplicar manifiestos
kubectl apply -f ./k3d/00-namespace.yaml
kubectl apply -f ./k3d/01-config-secrets.yaml
kubectl apply -f ./k3d/02-persistent-volumes.yaml
kubectl apply -f ./k3d/03-mongodb.yaml
kubectl apply -f ./k3d/04-redis.yaml
kubectl apply -f ./k3d/05-backend.yaml
kubectl apply -f ./k3d/06-frontend.yaml
kubectl apply -f ./k3d/07-worker.yaml
kubectl apply -f ./k3d/08-nginx-ingress.yaml
```

---

## ⚙️ Configuración del Cluster

El archivo `cluster-config.yaml` define:

```yaml
# Nodos
servers: 1    # 1 master node
agents: 3     # 3 worker nodes

# Puertos mapeados al host
ports:
  - 8080:80      # HTTP LoadBalancer
  - 5000:30500   # Backend NodePort
  - 3000:30300   # Frontend NodePort

# Registry local para imágenes
registries:
  create:
    name: todo-registry
    hostPort: 5555

# Volúmenes persistentes
volumes:
  - ./k3d-data/mongodb:/data/mongodb
  - ./k3d-data/redis:/data/redis
```

---

## Despliegue

### 1. Preparar imágenes Docker

```bash
# Las imágenes deben estar construidas previamente
docker images | grep todo

# Expected output:
# todo-backend    1.0.0
# todo-frontend   1.0.0
# todo-worker     1.0.0
# todo-nginx      1.0.0
```

### 2. Ejecutar despliegue

```bash
cd k3d
chmod +x deploy-k3d.sh
./deploy-k3d.sh
```

El script automáticamente:
- Instala K3D si no está presente
- Crea el cluster con 1 master + 3 workers
- Configura registry local
- Tagea y sube imágenes al registry
- Aplica todos los manifiestos Kubernetes
- Espera a que todos los pods estén listos
- Muestra información de acceso

### 3. Verificar despliegue

```bash
# Ver todos los pods
kubectl get pods -n todo-app

# Ver servicios
kubectl get svc -n todo-app

# Ver logs del backend
kubectl logs -f deployment/backend -n todo-app
```

---

## 🧪 Pruebas y Validación

### Script de pruebas automatizado:

```bash
chmod +x k3d/test-k3d.sh
./k3d/test-k3d.sh
```

### Pruebas manuales:

```bash
# 1. Health check del backend
kubectl port-forward svc/backend-service 5000:5000 -n todo-app &
curl http://localhost:5000/health

# Expected output:
# {
#   "status": "OK",
#   "mongodb": "connected",
#   "redis": "connected",
#   "version": "1.0.0"
# }

# 2. Crear una tarea
curl -X POST http://localhost:5000/api/todos \
  -H "Content-Type: application/json" \
  -d '{"title":"Probar K3D","description":"Verificar funcionamiento"}'

# 3. Listar tareas
curl http://localhost:5000/api/todos

# 4. Ver frontend
# Abrir en navegador: http://localhost:3000
```

---

## 🌐 Acceso a la Aplicación

### URLs disponibles:

| Servicio | URL | Tipo |
|----------|-----|------|
| **Frontend** | http://localhost:3000 | NodePort |
| **Backend API** | http://localhost:5000 | NodePort |
| **Nginx LoadBalancer** | http://localhost:8080 | LoadBalancer |
| **Registry** | localhost:5555 | Registry |

### Port Forwarding para acceso directo:

```bash
# Backend (API)
kubectl port-forward svc/backend-service 5000:5000 -n todo-app

# Frontend
kubectl port-forward svc/frontend-service 3000:80 -n todo-app

# MongoDB (para debugging)
kubectl port-forward svc/mongodb-service 27017:27017 -n todo-app

# Redis (para debugging)
kubectl port-forward svc/redis-service 6379:6379 -n todo-app
```

---

## 🛠️ Comandos Útiles

### Gestión del Cluster:

```bash
# Listar clusters
k3d cluster list

# Ver información del cluster
k3d cluster get todo-cluster

# Detener cluster (conserva datos)
k3d cluster stop todo-cluster

# Iniciar cluster
k3d cluster start todo-cluster

# Eliminar cluster
k3d cluster delete todo-cluster
```

### Kubectl:

```bash
# Cambiar context
kubectl config use-context k3d-todo-cluster

# Ver todos los recursos
kubectl get all -n todo-app

# Describir un pod
kubectl describe pod <pod-name> -n todo-app

# Ver logs en tiempo real
kubectl logs -f <pod-name> -n todo-app

# Ejecutar comando en pod
kubectl exec -it <pod-name> -n todo-app -- sh

# Ver eventos
kubectl get events -n todo-app --sort-by='.lastTimestamp'
```

### Debugging:

```bash
# Ver pods que no están running
kubectl get pods -n todo-app --field-selector=status.phase!=Running

# Ver uso de recursos
kubectl top nodes
kubectl top pods -n todo-app

# Ver configuración de un deployment
kubectl get deployment backend -n todo-app -o yaml

# Ver logs de todos los containers de un deployment
kubectl logs -f deployment/backend -n todo-app --all-containers=true
```

### Registry:

```bash
# Ver imágenes en el registry
curl http://localhost:5555/v2/_catalog

# Ver tags de una imagen
curl http://localhost:5555/v2/todo-backend/tags/list
```

---

## 🔧 Troubleshooting

### Problema: Pods en estado Pending

```bash
# Ver por qué está pending
kubectl describe pod <pod-name> -n todo-app

# Solución común: recursos insuficientes
kubectl get nodes
kubectl describe node <node-name>
```

### Problema: Imagen no se encuentra

```bash
# Verificar que la imagen está en el registry
docker images | grep todo

# Re-tag y push al registry
docker tag todo-backend:1.0.0 k3d-todo-registry.localhost:5555/todo-backend:1.0.0
docker push k3d-todo-registry.localhost:5555/todo-backend:1.0.0

# Reiniciar deployment
kubectl rollout restart deployment backend -n todo-app
```

### Problema: PVC no se vincula

```bash
# Ver estado de PVCs
kubectl get pvc -n todo-app

# Describir PVC
kubectl describe pvc mongodb-pvc -n todo-app

# Solución: verificar StorageClass
kubectl get storageclass
```

### Problema: Service no responde

```bash
# Verificar endpoints
kubectl get endpoints -n todo-app

# Verificar que los pods tienen las labels correctas
kubectl get pods -n todo-app --show-labels

# Probar conectividad desde otro pod
kubectl run test-pod --image=busybox -n todo-app -it --rm -- sh
# Dentro del pod:
wget -O- http://backend-service:5000/health
```

### Problema: Cluster muy lento

```bash
# Ver uso de recursos
docker stats

# Reducir réplicas
kubectl scale deployment backend --replicas=1 -n todo-app
kubectl scale deployment frontend --replicas=1 -n todo-app
kubectl scale deployment worker --replicas=1 -n todo-app
```

---

## 🧹 Limpieza

### Opción 1: Script automático

```bash
chmod +x k3d/cleanup-k3d.sh
./k3d/cleanup-k3d.sh
```

### Opción 2: Limpieza manual

```bash
# Eliminar namespace (elimina todos los recursos)
kubectl delete namespace todo-app

# Eliminar cluster
k3d cluster delete todo-cluster

# Limpiar datos persistentes
rm -rf ./k3d-data

# Eliminar imágenes del registry (opcional)
docker rmi k3d-todo-registry.localhost:5555/todo-backend:1.0.0
docker rmi k3d-todo-registry.localhost:5555/todo-frontend:1.0.0
docker rmi k3d-todo-registry.localhost:5555/todo-worker:1.0.0
docker rmi k3d-todo-registry.localhost:5555/todo-nginx:1.0.0
```

---

## 📚 Recursos Adicionales

- **Documentación oficial K3D**: https://k3d.io/
- **K3s Documentation**: https://docs.k3s.io/
- **Kubernetes Docs**: https://kubernetes.io/docs/

---

## 🎓 Conclusión

K3D proporciona un entorno Kubernetes completo y ligero ideal para:

- Desarrollo y testing local
- Aprendizaje de Kubernetes
- CI/CD pipelines
- Demos y presentaciones

**Ventajas de esta configuración:**
- 🚀 Despliegue rápido (< 5 minutos)
- 📦 Registry local incluido
- 🔄 Multi-nodo para simular producción
- 💾 Persistencia de datos
- 🔍 Health checks y auto-healing
- 📊 Monitoreo con kubectl

---

**¿Problemas o preguntas?** Revisa la sección de [Troubleshooting](#troubleshooting) o consulta los logs:

```bash
kubectl logs -f <pod-name> -n todo-app
```
