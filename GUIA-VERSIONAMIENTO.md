# 🏷️ Guía de Versionamiento de Imágenes Docker# 🏷️ Guía de Versionamiento y DockerHub



**Proyecto:** ToDo App - UCB  ## 📋 Índice

**Fecha:** 24 de Octubre, 20251. [Comandos Básicos](#comandos-básicos)

2. [Workflow Completo](#workflow-completo)

---3. [Rollback en Kubernetes](#rollback-en-kubernetes)

4. [Buenas Prácticas](#buenas-prácticas)

## 📋 Índice

---

1. [Estrategia de Versionamiento](#estrategia-de-versionamiento)

2. [Comandos Manuales](#comandos-manuales)## 🚀 Comandos Básicos

3. [Script Automatizado](#script-automatizado)

4. [Subir a Docker Hub](#subir-a-docker-hub)### 1. Configuración Inicial (HACER UNA SOLA VEZ)

5. [Rollback en Kubernetes](#rollback-en-kubernetes)

6. [Buenas Prácticas](#buenas-prácticas)```bash

# Crear cuenta en DockerHub (si no tienes)

---# https://hub.docker.com/signup



## 🎯 Estrategia de Versionamiento# Login en DockerHub

docker login

### Semantic Versioning (MAJOR.MINOR.PATCH)# Ingresar: username y password

```

- **MAJOR (1.x.x)**: Cambios incompatibles con versiones anteriores

- **MINOR (x.1.x)**: Nueva funcionalidad compatible### 2. Construir Imagen con Múltiples Tags

- **PATCH (x.x.1)**: Corrección de bugs

```bash

### Tags Recomendados# Opción A: Backend - Versión específica + latest

docker build -t tu-usuario/todo-backend:0.0.1 \

Para cada versión, crear **3 tags**:             -t tu-usuario/todo-backend:latest \

             -f backend/Dockerfile backend/

1. **Versión específica**: `1.0.1`, `1.0.2`, `1.0.3`

2. **Versión minor**: `1.0` (siempre apunta a la última patch)# Opción B: Frontend - Versión específica + latest

3. **Latest**: `latest` (siempre apunta a la última versión estable)docker build -t tu-usuario/todo-frontend:0.0.1 \

             -t tu-usuario/todo-frontend:latest \

---             -f frontend/Dockerfile frontend/



## 🔧 Comandos Manuales# Opción C: Worker

docker build -t tu-usuario/todo-worker:0.0.1 \

### Paso 1: Construir la Imagen con Versión             -t tu-usuario/todo-worker:latest \

             -f worker/Dockerfile worker/

```bash

# Versión 1.0.1# Opción D: Nginx

docker build -t wvarg/todo-backend:1.0.1 ./backenddocker build -t tu-usuario/todo-nginx:0.0.1 \

docker tag wvarg/todo-backend:1.0.1 wvarg/todo-backend:1.0             -t tu-usuario/todo-nginx:latest \

docker tag wvarg/todo-backend:1.0.1 wvarg/todo-backend:latest             -f nginx/Dockerfile nginx/

```

# Versión 1.0.2

docker build -t wvarg/todo-backend:1.0.2 ./backend### 3. Verificar Imágenes Locales

docker tag wvarg/todo-backend:1.0.2 wvarg/todo-backend:1.0

docker tag wvarg/todo-backend:1.0.2 wvarg/todo-backend:latest```bash

# Ver todas las imágenes

# Versión 1.0.3docker images | grep todo

docker build -t wvarg/todo-backend:1.0.3 ./backend

docker tag wvarg/todo-backend:1.0.3 wvarg/todo-backend:1.0# Ver solo backend

docker tag wvarg/todo-backend:1.0.3 wvarg/todo-backend:latestdocker images tu-usuario/todo-backend

```

# Ver tamaño de las imágenes

### Paso 2: Subir a Docker Hubdocker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

```

```bash

# Login (ya lo hiciste)### 4. Subir Imágenes a DockerHub

docker login

```bash

# Push versión específica# Subir versión específica

docker push wvarg/todo-backend:1.0.1docker push tu-usuario/todo-backend:0.0.1



# Push versión minor# Subir tag latest

docker push wvarg/todo-backend:1.0docker push tu-usuario/todo-backend:latest



# Push latest# Subir todas las versiones de un servicio

docker push wvarg/todo-backend:latestdocker push tu-usuario/todo-backend --all-tags

``````



### Paso 3: Ver Imágenes Locales---



```bash## 🔄 Workflow Completo: De 0.0.1 a 0.0.3

# Ver todas las imágenes

docker images | grep todo-backend### **VERSIÓN 0.0.1** (Primera versión)



# Ver tags```bash

docker image ls wvarg/todo-backend# 1. Construir imagen

```docker build -t tu-usuario/todo-backend:0.0.1 \

             -t tu-usuario/todo-backend:latest \

---             -f backend/Dockerfile backend/



## 🚀 Script Automatizado# 2. Probar localmente

docker run -p 5000:5000 tu-usuario/todo-backend:0.0.1

He creado el script `build-and-push.sh` que hace todo automáticamente.

# 3. Subir a DockerHub

### Uso del Scriptdocker push tu-usuario/todo-backend:0.0.1

docker push tu-usuario/todo-backend:latest

```bash

# Dar permisos# 4. Desplegar en K3D

chmod +x build-and-push.shkubectl set image deployment/backend \

    backend=tu-usuario/todo-backend:0.0.1 -n todo-app

# Construir y subir versión 1.0.1

./build-and-push.sh 1.0.1# 5. Verificar despliegue

kubectl rollout status deployment/backend -n todo-app

# Construir y subir versión 1.0.2kubectl get pods -n todo-app -l app=backend

./build-and-push.sh 1.0.2```



# Construir y subir versión 1.0.3### **VERSIÓN 0.0.2** (Con tus cambios actuales)

./build-and-push.sh 1.0.3

``````bash

# 1. Hacer cambios en backend/server.js

### Lo que hace el script:# Ya cambiaste version: '0.0.2' en el health check ✓



1. ✅ Valida que Docker Hub esté autenticado# 2. Construir nueva imagen

2. ✅ Construye la imagen con la versión especificadadocker build -t tu-usuario/todo-backend:0.0.2 \

3. ✅ Crea tags automáticamente (versión, minor, latest)             -t tu-usuario/todo-backend:latest \

4. ✅ Sube todas las versiones a Docker Hub             -f backend/Dockerfile backend/

5. ✅ Muestra resumen final

6. ✅ Genera logs de versionamiento# 3. Subir a DockerHub

docker push tu-usuario/todo-backend:0.0.2

---docker push tu-usuario/todo-backend:latest



## 📦 Subir a Docker Hub# 4. Actualizar en K3D

kubectl set image deployment/backend \

### Configuración Inicial    backend=tu-usuario/todo-backend:0.0.2 -n todo-app



```bash# 5. Monitorear el despliegue

# Login en Docker Hubkubectl rollout status deployment/backend -n todo-app

docker loginkubectl get pods -n todo-app -l app=backend -w

# Usuario: wvarg

# Password: [tu password]# 6. Verificar la nueva versión

```curl http://localhost:9500/health

# Debe mostrar: "version": "0.0.2"

### Subir Primera Versión (1.0.1)```



```bash### **VERSIÓN 0.0.3** (Próxima versión)

# Opción 1: Usar script (RECOMENDADO)

./build-and-push.sh 1.0.1```bash

# 1. Hacer nuevos cambios en backend/server.js

# Opción 2: Manual# Cambiar version: '0.0.3'

docker build -t wvarg/todo-backend:1.0.1 ./backend

docker tag wvarg/todo-backend:1.0.1 wvarg/todo-backend:1.0# 2. Construir imagen

docker tag wvarg/todo-backend:1.0.1 wvarg/todo-backend:latestdocker build -t tu-usuario/todo-backend:0.0.3 \

docker push wvarg/todo-backend:1.0.1             -t tu-usuario/todo-backend:latest \

docker push wvarg/todo-backend:1.0             -f backend/Dockerfile backend/

docker push wvarg/todo-backend:latest

```# 3. Subir a DockerHub

docker push tu-usuario/todo-backend:0.0.3

### Subir Segunda Versión (1.0.2)docker push tu-usuario/todo-backend:latest



```bash# 4. Desplegar

# Hacer cambios en el códigokubectl set image deployment/backend \

# Por ejemplo, modificar server.js    backend=tu-usuario/todo-backend:0.0.3 -n todo-app

```

# Usar script

./build-and-push.sh 1.0.2---

```

## 🔙 Rollback en Kubernetes

### Subir Tercera Versión (1.0.3)

### Método 1: Rollback Automático (a la versión anterior)

```bash

# Hacer más cambios en el código```bash

# Ver historial de despliegues

# Usar scriptkubectl rollout history deployment/backend -n todo-app

./build-and-push.sh 1.0.3

```# Hacer rollback a la versión anterior

kubectl rollout undo deployment/backend -n todo-app

### Verificar en Docker Hub

# Verificar el rollback

```bashkubectl rollout status deployment/backend -n todo-app

# Ver imágenes en Docker Hubkubectl get pods -n todo-app -l app=backend

# https://hub.docker.com/r/wvarg/todo-backend/tags```



# O usar CLI### Método 2: Rollback a una Versión Específica

docker search wvarg/todo-backend

``````bash

# Ver historial con detalles

---kubectl rollout history deployment/backend -n todo-app



## ↩️ Rollback en Kubernetes# Rollback a revisión específica (ej: revisión 2)

kubectl rollout undo deployment/backend --to-revision=2 -n todo-app

### Ver Historial de Deployments

# Verificar

```bashkubectl get pods -n todo-app -l app=backend

# Ver historial del backend```

kubectl rollout history deployment backend -n todo-app

### Método 3: Especificar Versión Directamente

# Ver detalles de una revisión específica

kubectl rollout history deployment backend -n todo-app --revision=2```bash

```# Volver a versión 0.0.1

kubectl set image deployment/backend \

### Método 1: Rollback a Versión Anterior    backend=tu-usuario/todo-backend:0.0.1 -n todo-app



```bash# Volver a versión 0.0.2

# Volver a la versión inmediatamente anteriorkubectl set image deployment/backend \

kubectl rollout undo deployment backend -n todo-app    backend=tu-usuario/todo-backend:0.0.2 -n todo-app

```

# Volver a una revisión específica

kubectl rollout undo deployment backend -n todo-app --to-revision=2---

```

## 📝 Ejemplo Práctico Completo

### Método 2: Actualizar a Versión Específica

### Escenario: Desplegar versión 0.0.2 y hacer rollback

```bash

# Actualizar a versión 1.0.1```bash

kubectl set image deployment/backend backend=wvarg/todo-backend:1.0.1 -n todo-app# ========================================

# PASO 1: Preparación

# Actualizar a versión 1.0.2# ========================================

kubectl set image deployment/backend backend=wvarg/todo-backend:1.0.2 -n todo-app

# Configurar tu usuario de DockerHub

# Actualizar a versión 1.0.3export DOCKER_USER="tu-usuario-dockerhub"

kubectl set image deployment/backend backend=wvarg/todo-backend:1.0.3 -n todo-app

```# Login

docker login

### Método 3: Editar el Deployment Directamente

# ========================================

```bash# PASO 2: Construir versión 0.0.2

# Editar el deployment# ========================================

kubectl edit deployment backend -n todo-app

# Construir imagen

# Buscar la sección:docker build -t ${DOCKER_USER}/todo-backend:0.0.2 \

# spec:             -t ${DOCKER_USER}/todo-backend:latest \

#   containers:             -f backend/Dockerfile backend/

#   - image: wvarg/todo-backend:1.0.3

#     name: backend# Verificar

docker images ${DOCKER_USER}/todo-backend

# Cambiar a la versión deseada y guardar

```# ========================================

# PASO 3: Subir a DockerHub

### Método 4: Actualizar el Manifiesto YAML# ========================================



```bash# Push versión específica

# Editar k3d/05-backend.yamldocker push ${DOCKER_USER}/todo-backend:0.0.2

# Cambiar la línea:

# image: wvarg/todo-backend:1.0.3# Push latest

docker push ${DOCKER_USER}/todo-backend:latest

# Aplicar cambios

kubectl apply -f k3d/05-backend.yaml# Verificar en DockerHub

```# https://hub.docker.com/r/${DOCKER_USER}/todo-backend/tags



### Verificar el Rollback# ========================================

# PASO 4: Desplegar en K3D

```bash# ========================================

# Ver estado del rollout

kubectl rollout status deployment backend -n todo-app# Ver versión actual

kubectl get deployment backend -n todo-app -o jsonpath='{.spec.template.spec.containers[0].image}'

# Ver pods actualizados

kubectl get pods -n todo-app -l app=backend# Actualizar a versión 0.0.2

kubectl set image deployment/backend \

# Ver qué imagen está usando    backend=${DOCKER_USER}/todo-backend:0.0.2 -n todo-app

kubectl describe deployment backend -n todo-app | grep Image

# Monitorear el despliegue

# Ver logs del podkubectl rollout status deployment/backend -n todo-app

kubectl logs -f <pod-name> -n todo-app

```# Ver logs de nuevo pod

kubectl logs -n todo-app -l app=backend --tail=50

---

# ========================================

## 🔄 Flujo de Trabajo Completo# PASO 5: Verificar nueva versión

# ========================================

### Ejemplo Práctico: De 1.0.0 a 1.0.3

# Health check

#### Paso 1: Versión Inicial (1.0.0)curl http://localhost:9500/health | jq .version

# Debe mostrar: "0.0.2"

```bash

# Construir y subir# Ver pods

./build-and-push.sh 1.0.0kubectl get pods -n todo-app -l app=backend



# Desplegar en K3D# ========================================

kubectl set image deployment/backend backend=wvarg/todo-backend:1.0.0 -n todo-app# PASO 6: Simular problema y hacer rollback

```# ========================================



#### Paso 2: Primera Actualización (1.0.1)# Si la versión 0.0.2 falla...



```bash# Opción A: Rollback automático

# Hacer cambio en backend/server.jskubectl rollout undo deployment/backend -n todo-app

echo "// Cambio 1.0.1" >> backend/server.js

# Opción B: Volver a versión específica

# Construir y subirkubectl set image deployment/backend \

./build-and-push.sh 1.0.1    backend=${DOCKER_USER}/todo-backend:0.0.1 -n todo-app



# Actualizar en K3D# Verificar rollback

kubectl set image deployment/backend backend=wvarg/todo-backend:1.0.1 -n todo-appkubectl rollout status deployment/backend -n todo-app

curl http://localhost:9500/health | jq .version

# Verificar```

kubectl rollout status deployment backend -n todo-app

```---



#### Paso 3: Segunda Actualización (1.0.2)## 🛠️ Usando el Script Automatizado



```bash### Instalación

# Hacer cambio en backend/server.js

echo "// Cambio 1.0.2" >> backend/server.js```bash

# Dar permisos de ejecución

# Construir y subirchmod +x build-and-push.sh

./build-and-push.sh 1.0.2

# Editar el script y cambiar el usuario

# Actualizar en K3Dnano build-and-push.sh

kubectl set image deployment/backend backend=wvarg/todo-backend:1.0.2 -n todo-app# Cambiar: DOCKERHUB_USERNAME="tu-usuario-dockerhub"

``````



#### Paso 4: Tercera Actualización (1.0.3)### Uso del Script



```bash```bash

# Hacer cambio en backend/server.js# Construir y subir backend v0.0.1

echo "// Cambio 1.0.3" >> backend/server.js./build-and-push.sh 0.0.1 backend



# Construir y subir# Construir y subir backend v0.0.2

./build-and-push.sh 1.0.3./build-and-push.sh 0.0.2 backend



# Actualizar en K3D# Construir y subir backend v0.0.3

kubectl set image deployment/backend backend=wvarg/todo-backend:1.0.3 -n todo-app./build-and-push.sh 0.0.3 backend

```

# Construir y subir todas las imágenes v0.0.2

#### Paso 5: Rollback (si 1.0.3 falla)./build-and-push.sh 0.0.2 all



```bash# Solo frontend v0.0.2

# Opción A: Volver a la anterior (1.0.2)./build-and-push.sh 0.0.2 frontend

kubectl rollout undo deployment backend -n todo-app```



# Opción B: Volver a una específica (1.0.1)---

kubectl set image deployment/backend backend=wvarg/todo-backend:1.0.1 -n todo-app

```## 📊 Verificación y Monitoreo



---### Ver Historial de Despliegues



## 📝 Buenas Prácticas```bash

# Ver todas las revisiones

### 1. Siempre Usar Semantic Versioningkubectl rollout history deployment/backend -n todo-app



```bash# Ver detalles de una revisión

# ✅ BIENkubectl rollout history deployment/backend --revision=2 -n todo-app

1.0.1, 1.0.2, 1.1.0, 2.0.0

# Ver cambios entre revisiones

# ❌ MALkubectl rollout history deployment/backend -n todo-app --output=yaml

v1, version2, latest-fix```

```

### Monitorear Despliegue en Vivo

### 2. Mantener Tags Múltiples

```bash

```bash# Ver status del rollout

# Para versión 1.0.3, crear:kubectl rollout status deployment/backend -n todo-app

wvarg/todo-backend:1.0.3  # Versión específica

wvarg/todo-backend:1.0    # Minor version# Ver pods en tiempo real

wvarg/todo-backend:latest # Latest establekubectl get pods -n todo-app -l app=backend -w

```

# Ver eventos

### 3. Documentar Cambioskubectl get events -n todo-app --sort-by='.lastTimestamp' | grep backend



```bash# Ver logs de todos los pods de backend

# Crear archivo CHANGELOG.mdkubectl logs -n todo-app -l app=backend --all-containers=true --tail=100

cat >> CHANGELOG.md << EOF```

## [1.0.1] - 2025-10-24

- Cambio en health check### Verificar Versión Desplegada



## [1.0.2] - 2025-10-24```bash

- Mejora en logging# Ver imagen actual en el deployment

kubectl get deployment backend -n todo-app -o jsonpath='{.spec.template.spec.containers[0].image}'

## [1.0.3] - 2025-10-24

- Fix en conexión Redis# Ver versión desde la API

EOFcurl http://localhost:9500/health | jq .

```

# Ver desde dentro del cluster

### 4. Usar Git Tagskubectl run test-curl --image=curlimages/curl --rm -it --restart=Never -- \

    curl backend.todo-app.svc.cluster.local:5000/health

```bash```

# Crear tag en Git para cada versión

git tag -a v1.0.1 -m "Release version 1.0.1"---

git push origin v1.0.1

## 🎯 Buenas Prácticas

git tag -a v1.0.2 -m "Release version 1.0.2"

git push origin v1.0.2### 1. Semantic Versioning



git tag -a v1.0.3 -m "Release version 1.0.3"```

git push origin v1.0.3MAJOR.MINOR.PATCH

```

Ejemplos:

### 5. Nunca Usar :latest en Producción- 0.0.1  → Primera versión

- 0.0.2  → Bug fix

```yaml- 0.1.0  → Nueva funcionalidad (minor)

# ❌ MAL (en producción)- 1.0.0  → Release de producción (major)

image: wvarg/todo-backend:latest- 1.0.1  → Hotfix

```

# ✅ BIEN (en producción)

image: wvarg/todo-backend:1.0.3### 2. Tags Recomendados

```

```bash

### 6. Probar Antes de Subir# Siempre usar versión específica + latest

docker build -t ${DOCKER_USER}/todo-backend:0.0.2 \

```bash             -t ${DOCKER_USER}/todo-backend:latest \

# Construir localmente             -t ${DOCKER_USER}/todo-backend:0.0 \

docker build -t wvarg/todo-backend:1.0.1 ./backend             -f backend/Dockerfile backend/



# Probar localmente# Tags útiles:

docker run -p 5000:5000 wvarg/todo-backend:1.0.1# - 0.0.2     → Versión específica (SIEMPRE USAR EN PRODUCCIÓN)

# - 0.0       → Última versión del minor

# Verificar# - latest    → Última versión en general (NO usar en producción)

curl http://localhost:5000/health# - stable    → Versión estable

# - dev       → Versión de desarrollo

# Si funciona, entonces subir```

docker push wvarg/todo-backend:1.0.1

```### 3. Workflow de Desarrollo



---```

Desarrollo Local

## 🔍 Comandos de Verificación    ↓

docker build (tag: dev)

### Ver Versiones Locales    ↓

Pruebas locales

```bash    ↓

# Listar todas las imágenesdocker build (tag: 0.0.x)

docker images wvarg/todo-backend    ↓

docker push

# Ver tags    ↓

docker image ls wvarg/todo-backend --format "{{.Tag}}"Deploy a K3D

```    ↓

Pruebas en cluster

### Ver Versiones en Docker Hub    ↓

Si funciona → Mantener

```bashSi falla → Rollback

# Usar Docker Hub CLI (instalar primero)```

# O visitar: https://hub.docker.com/r/wvarg/todo-backend/tags

### 4. Comandos de Emergencia

# Ver con curl

curl -s "https://hub.docker.com/v2/repositories/wvarg/todo-backend/tags/" | jq -r '.results[].name'```bash

```# ROLLBACK RÁPIDO (volver a la anterior)

kubectl rollout undo deployment/backend -n todo-app

### Ver Versión en Kubernetes

# PAUSAR despliegue (si está fallando)

```bashkubectl rollout pause deployment/backend -n todo-app

# Ver imagen actual

kubectl get deployment backend -n todo-app -o jsonpath='{.spec.template.spec.containers[0].image}'# REANUDAR despliegue

kubectl rollout resume deployment/backend -n todo-app

# Ver historial

kubectl rollout history deployment backend -n todo-app# REINICIAR pods sin cambiar imagen

```kubectl rollout restart deployment/backend -n todo-app



---# VER STATUS

kubectl rollout status deployment/backend -n todo-app

## 📊 Matriz de Versiones```



| Versión | Cambio | Fecha | Docker Hub | K8s Status |---

|---------|--------|-------|------------|------------|

| 1.0.0 | Initial release | 2025-10-23 | ✅ | Deployed |## 📝 Checklist de Versionamiento

| 1.0.1 | Comentario en server.js | 2025-10-24 | ⏳ | Pending |

| 1.0.2 | [Tu próximo cambio] | 2025-10-24 | ⏳ | Pending |Antes de subir una nueva versión:

| 1.0.3 | [Tu siguiente cambio] | 2025-10-24 | ⏳ | Pending |

- [ ] Cambios en código realizados

---- [ ] Versión actualizada en `server.js` (health check)

- [ ] Imagen construida localmente

## 🎯 Resumen de Comandos Rápidos- [ ] Imagen probada localmente

- [ ] Login en DockerHub

### Crear Nueva Versión- [ ] Imagen pusheada con versión específica

- [ ] Tag latest actualizado

```bash- [ ] Deployment actualizado en K3D

# Paso 1: Hacer cambios en el código- [ ] Pods nuevos verificados

vim backend/server.js- [ ] Health check confirmado con nueva versión

- [ ] Logs revisados sin errores

# Paso 2: Construir y subir- [ ] Funcionalidad probada

./build-and-push.sh 1.0.X- [ ] Documentación actualizada



# Paso 3: Actualizar en K8s---

kubectl set image deployment/backend backend=wvarg/todo-backend:1.0.X -n todo-app

## 🔗 Enlaces Útiles

# Paso 4: Verificar

kubectl rollout status deployment backend -n todo-app- **DockerHub**: https://hub.docker.com/

```- **Semantic Versioning**: https://semver.org/

- **Kubernetes Rollout**: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#updating-a-deployment

### Hacer Rollback- **Docker Build**: https://docs.docker.com/engine/reference/commandline/build/



```bash---

# Método rápido: volver a la anterior

kubectl rollout undo deployment backend -n todo-app**Desarrollado por:** [TU NOMBRE]  

**Universidad Católica Boliviana (UCB)**  

# Método específico: volver a versión exacta**Fecha:** 24 de Octubre, 2025

kubectl set image deployment/backend backend=wvarg/todo-backend:1.0.1 -n todo-app
```

---

## 📚 Referencias

- [Semantic Versioning](https://semver.org/)
- [Docker Tag Best Practices](https://docs.docker.com/engine/reference/commandline/tag/)
- [Kubernetes Rollout](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#rolling-back-a-deployment)

---

**Creado por:** [Tu Nombre]  
**Universidad Católica Boliviana (UCB)**  
**Fecha:** 24 de Octubre, 2025
