#!/bin/bash

# Script para desplegar la aplicación ToDo en K3D
# Uso: ./deploy-k3d.sh

set -e

echo "=========================================="
echo "  📦 DESPLIEGUE EN K3D - TODO APP"
echo "=========================================="
echo ""

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables
CLUSTER_NAME="todo-cluster"
REGISTRY_NAME="k3d-todo-registry.localhost"
REGISTRY_PORT="5555"
NAMESPACE="todo-app"

# Función para imprimir mensajes
print_step() {
    echo -e "${BLUE}➜${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Paso 1: Verificar que K3D está instalado
print_step "Verificando instalación de K3D..."
if ! command -v k3d &> /dev/null; then
    print_error "K3D no está instalado. Instalando..."
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
    print_success "K3D instalado correctamente"
else
    K3D_VERSION=$(k3d version | head -n1)
    print_success "K3D instalado: $K3D_VERSION"
fi

# Paso 2: Crear el cluster K3D (si no existe)
print_step "Verificando cluster K3D..."
if k3d cluster list | grep -q "$CLUSTER_NAME"; then
    print_warning "El cluster '$CLUSTER_NAME' ya existe"
    read -p "¿Deseas eliminarlo y recrearlo? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_step "Eliminando cluster existente..."
        k3d cluster delete $CLUSTER_NAME
        print_success "Cluster eliminado"
    else
        print_warning "Usando cluster existente"
    fi
fi

if ! k3d cluster list | grep -q "$CLUSTER_NAME"; then
    print_step "Creando cluster K3D con configuración personalizada..."
    k3d cluster create --config ./k3d/cluster-config.yaml
    print_success "Cluster '$CLUSTER_NAME' creado exitosamente"
    
    # Esperar a que el cluster esté listo
    print_step "Esperando a que el cluster esté listo..."
    sleep 10
fi

# Paso 3: Verificar kubectl context
print_step "Configurando kubectl context..."
kubectl config use-context k3d-$CLUSTER_NAME
print_success "Context configurado: k3d-$CLUSTER_NAME"

# Paso 4: Crear directorio para datos persistentes
print_step "Creando directorios para volúmenes persistentes..."
mkdir -p ./k3d-data/mongodb
mkdir -p ./k3d-data/redis
print_success "Directorios creados"

# Paso 5: Tag y push de imágenes al registry local de K3D
print_step "Preparando imágenes Docker para K3D registry..."

# Verificar que las imágenes existen
IMAGES=("todo-backend:1.0.0" "todo-frontend:1.0.0" "todo-worker:1.0.0" "todo-nginx:1.0.0")
for img in "${IMAGES[@]}"; do
    if ! docker images | grep -q "$img"; then
        print_error "Imagen $img no encontrada. Construyendo..."
        if [[ "$img" == "todo-backend:1.0.0" ]]; then
            docker build -t $img ./backend
        elif [[ "$img" == "todo-frontend:1.0.0" ]]; then
            docker build -t $img ./frontend
        elif [[ "$img" == "todo-worker:1.0.0" ]]; then
            docker build -t $img ./worker
        elif [[ "$img" == "todo-nginx:1.0.0" ]]; then
            docker build -t $img ./nginx
        fi
    fi
    
    # Tag para registry local
    docker tag $img $REGISTRY_NAME:$REGISTRY_PORT/$img
    print_success "Tagged: $img → $REGISTRY_NAME:$REGISTRY_PORT/$img"
done

# Push imágenes al registry
print_step "Subiendo imágenes al registry K3D..."
for img in "${IMAGES[@]}"; do
    docker push $REGISTRY_NAME:$REGISTRY_PORT/$img
    print_success "Pushed: $img"
done

# Paso 6: Aplicar manifiestos de Kubernetes
print_step "Desplegando aplicación en K3D..."

echo ""
echo "Aplicando manifiestos en orden..."

kubectl apply -f ./k3d/00-namespace.yaml
print_success "Namespace creado"
sleep 2

kubectl apply -f ./k3d/01-config-secrets.yaml
print_success "ConfigMaps y Secrets aplicados"
sleep 2

kubectl apply -f ./k3d/02-persistent-volumes.yaml
print_success "PersistentVolumeClaims creados"
sleep 5

kubectl apply -f ./k3d/03-mongodb.yaml
print_success "MongoDB desplegado"
sleep 10

kubectl apply -f ./k3d/04-redis.yaml
print_success "Redis desplegado"
sleep 10

kubectl apply -f ./k3d/05-backend.yaml
print_success "Backend API desplegado"
sleep 10

kubectl apply -f ./k3d/06-frontend.yaml
print_success "Frontend desplegado"
sleep 5

kubectl apply -f ./k3d/07-worker.yaml
print_success "Worker desplegado"
sleep 5

kubectl apply -f ./k3d/08-nginx-ingress.yaml
print_success "Nginx Ingress desplegado"

# Paso 7: Esperar a que todos los pods estén listos
print_step "Esperando a que todos los pods estén listos..."
kubectl wait --for=condition=ready pod --all -n $NAMESPACE --timeout=300s || true

# Paso 8: Mostrar estado del despliegue
echo ""
echo "=========================================="
echo "  📊 ESTADO DEL DESPLIEGUE"
echo "=========================================="
echo ""

print_step "Pods en el namespace '$NAMESPACE':"
kubectl get pods -n $NAMESPACE -o wide

echo ""
print_step "Servicios en el namespace '$NAMESPACE':"
kubectl get svc -n $NAMESPACE

echo ""
print_step "PersistentVolumeClaims:"
kubectl get pvc -n $NAMESPACE

echo ""
echo "=========================================="
echo "  🎉 DESPLIEGUE COMPLETADO"
echo "=========================================="
echo ""

# Obtener información de acceso
BACKEND_PORT=$(kubectl get svc backend-nodeport -n $NAMESPACE -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || echo "30500")
FRONTEND_PORT=$(kubectl get svc frontend-nodeport -n $NAMESPACE -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || echo "30300")

echo -e "${GREEN}✓ Aplicación desplegada exitosamente en K3D${NC}"
echo ""
echo "📍 URLs de acceso:"
echo "   • Frontend:  http://localhost:3000"
echo "   • Backend:   http://localhost:5000"
echo "   • Nginx LB:  http://localhost:8080"
echo ""
echo "🔍 Comandos útiles:"
echo "   • Ver pods:        kubectl get pods -n $NAMESPACE"
echo "   • Ver logs:        kubectl logs -f <pod-name> -n $NAMESPACE"
echo "   • Ejecutar shell:  kubectl exec -it <pod-name> -n $NAMESPACE -- sh"
echo "   • Ver servicios:   kubectl get svc -n $NAMESPACE"
echo "   • Port forward:    kubectl port-forward svc/backend-service 5000:5000 -n $NAMESPACE"
echo ""
echo "🧪 Probar la API:"
echo "   curl http://localhost:5000/health"
echo "   curl http://localhost:5000/api/todos"
echo ""
echo "🛑 Para eliminar todo:"
echo "   ./cleanup-k3d.sh"
echo ""
