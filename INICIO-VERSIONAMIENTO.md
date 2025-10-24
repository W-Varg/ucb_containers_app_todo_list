# 🚀 Inicio Rápido - Versionamiento

## 📝 Resumen

Ya hiciste un cambio en `backend/server.js` (línea 41), ahora vamos a crear versiones de la imagen Docker y subirlas a Docker Hub.

## ✅ Lo que ya tienes listo:

- ✅ Docker login (ya autenticado)
- ✅ Script `build-and-push.sh` configurado con usuario `wvarg`
- ✅ Cambio en el código del backend
- ✅ Cluster K3D corriendo

## 🎯 Paso a Paso

### 1️⃣ Crear Versión 1.0.1

```bash
./build-and-push.sh 1.0.1
```

Cuando pregunte si deseas subir a Docker Hub, responde: **s**

**Resultado:**
- Se crea imagen: `wvarg/todo-backend:1.0.1`
- Se crea tag: `wvarg/todo-backend:1.0`
- Se crea tag: `wvarg/todo-backend:latest`
- Se sube a Docker Hub

### 2️⃣ Actualizar en Kubernetes

```bash
kubectl set image deployment/backend backend=wvarg/todo-backend:1.0.1 -n todo-app
kubectl rollout status deployment backend -n todo-app
```

### 3️⃣ Verificar que funciona

```bash
# Ver pods actualizados
kubectl get pods -n todo-app -l app=backend

# Ver qué versión está corriendo
kubectl describe deployment backend -n todo-app | grep Image

# Probar la API
curl http://localhost:9500/health
```

---

## 🔄 Crear Siguientes Versiones

### Para 1.0.2:

```bash
# 1. Hacer cambio en el código
vim backend/server.js
# Agregar: // docs: cambio para versión 1.0.2

# 2. Construir y subir
./build-and-push.sh 1.0.2

# 3. Actualizar en K8s
kubectl set image deployment/backend backend=wvarg/todo-backend:1.0.2 -n todo-app
```

### Para 1.0.3:

```bash
# 1. Hacer cambio en el código
vim backend/server.js
# Agregar: // docs: cambio para versión 1.0.3

# 2. Construir y subir
./build-and-push.sh 1.0.3

# 3. Actualizar en K8s
kubectl set image deployment/backend backend=wvarg/todo-backend:1.0.3 -n todo-app
```

---

## ↩️ Hacer Rollback

Si una versión falla, puedes volver atrás:

### Opción A: Volver a la versión anterior

```bash
kubectl rollout undo deployment backend -n todo-app
```

### Opción B: Volver a una versión específica

```bash
# Volver a 1.0.1
kubectl set image deployment/backend backend=wvarg/todo-backend:1.0.1 -n todo-app

# Volver a 1.0.2
kubectl set image deployment/backend backend=wvarg/todo-backend:1.0.2 -n todo-app
```

### Verificar el Rollback

```bash
kubectl rollout status deployment backend -n todo-app
kubectl get pods -n todo-app -l app=backend
```

---

## 📊 Ver Historial

### Ver versiones en Docker Hub

```bash
docker images wvarg/todo-backend
```

### Ver historial de deployments

```bash
kubectl rollout history deployment backend -n todo-app
```

### Ver detalles de una revisión

```bash
kubectl rollout history deployment backend -n todo-app --revision=2
```

### Ver log de versiones

```bash
cat version-history.log
```

---

## 🎓 Ejemplo Completo

```bash
# ========================================
# VERSIÓN 1.0.1
# ========================================
./build-and-push.sh 1.0.1
# Responder: s (para subir)

kubectl set image deployment/backend backend=wvarg/todo-backend:1.0.1 -n todo-app
kubectl rollout status deployment backend -n todo-app

# ========================================
# VERSIÓN 1.0.2
# ========================================
echo "// docs: versión 1.0.2" >> backend/server.js
./build-and-push.sh 1.0.2
# Responder: s

kubectl set image deployment/backend backend=wvarg/todo-backend:1.0.2 -n todo-app

# ========================================
# VERSIÓN 1.0.3
# ========================================
echo "// docs: versión 1.0.3" >> backend/server.js
./build-and-push.sh 1.0.3
# Responder: s

kubectl set image deployment/backend backend=wvarg/todo-backend:1.0.3 -n todo-app

# ========================================
# ROLLBACK (si 1.0.3 falla)
# ========================================
kubectl rollout undo deployment backend -n todo-app
# O específico:
kubectl set image deployment/backend backend=wvarg/todo-backend:1.0.2 -n todo-app
```

---

## 🔗 Enlaces Útiles

- **Docker Hub:** https://hub.docker.com/r/wvarg/todo-backend/tags
- **Guía Completa:** [GUIA-VERSIONAMIENTO.md](GUIA-VERSIONAMIENTO.md)
- **Changelog:** [CHANGELOG.md](CHANGELOG.md)

---

## 💡 Tips

1. **Siempre prueba localmente antes de subir:**
   ```bash
   docker build -t wvarg/todo-backend:1.0.1 ./backend
   docker run -p 5000:5000 wvarg/todo-backend:1.0.1
   curl http://localhost:5000/health
   ```

2. **Usa Git tags para versiones:**
   ```bash
   git tag -a v1.0.1 -m "Release 1.0.1"
   git push origin v1.0.1
   ```

3. **Actualiza el CHANGELOG.md** después de cada versión

4. **Nunca uses `:latest` en producción**, siempre versión específica

---

## 🆘 Problemas Comunes

### "No puedo subir a Docker Hub"
```bash
# Verifica que estás autenticado
docker login
```

### "La imagen es muy grande"
```bash
# Ver tamaño
docker images wvarg/todo-backend

# El backend debe ser ~150MB (Alpine)
```

### "El rollback no funciona"
```bash
# Asegúrate que la imagen existe en Docker Hub
docker pull wvarg/todo-backend:1.0.1

# Verifica el historial
kubectl rollout history deployment backend -n todo-app
```

---

**¡Listo para empezar! Ejecuta:** `./build-and-push.sh 1.0.1` 🚀
