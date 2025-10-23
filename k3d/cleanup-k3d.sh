#!/bin/bash

# Script para limpiar el cluster K3D y todos los recursos
# Uso: ./cleanup-k3d.sh

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

CLUSTER_NAME="todo-cluster"
NAMESPACE="todo-app"

echo "=========================================="
echo "  🧹 LIMPIEZA DE K3D - TODO APP"
echo "=========================================="
echo ""

echo -e "${YELLOW}⚠ ADVERTENCIA:${NC} Esta operación eliminará:"
echo "  • El cluster K3D '$CLUSTER_NAME'"
echo "  • Todos los pods y servicios"
echo "  • Datos persistentes (MongoDB, Redis)"
echo "  • Registry local de imágenes"
echo ""

read -p "¿Estás seguro de continuar? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}ℹ${NC} Operación cancelada"
    exit 0
fi

# Eliminar namespace (esto elimina todos los recursos dentro)
echo -e "${BLUE}➜${NC} Eliminando namespace '$NAMESPACE'..."
kubectl delete namespace $NAMESPACE --ignore-not-found=true --timeout=60s || true
echo -e "${GREEN}✓${NC} Namespace eliminado"

# Eliminar cluster K3D
echo -e "${BLUE}➜${NC} Eliminando cluster K3D '$CLUSTER_NAME'..."
k3d cluster delete $CLUSTER_NAME || true
echo -e "${GREEN}✓${NC} Cluster eliminado"

# Limpiar datos persistentes
echo -e "${BLUE}➜${NC} Limpiando datos persistentes..."
rm -rf ./k3d-data
echo -e "${GREEN}✓${NC} Datos eliminados"

# Limpiar imágenes del registry (opcional)
echo ""
read -p "¿Eliminar también las imágenes Docker locales? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}➜${NC} Eliminando imágenes Docker..."
    docker rmi k3d-todo-registry.localhost:5555/todo-backend:1.0.0 2>/dev/null || true
    docker rmi k3d-todo-registry.localhost:5555/todo-frontend:1.0.0 2>/dev/null || true
    docker rmi k3d-todo-registry.localhost:5555/todo-worker:1.0.0 2>/dev/null || true
    docker rmi k3d-todo-registry.localhost:5555/todo-nginx:1.0.0 2>/dev/null || true
    echo -e "${GREEN}✓${NC} Imágenes eliminadas"
fi

echo ""
echo "=========================================="
echo "  ✓ LIMPIEZA COMPLETADA"
echo "=========================================="
echo ""
echo -e "${GREEN}Todos los recursos han sido eliminados${NC}"
echo ""
echo "Para volver a desplegar, ejecuta:"
echo "  ./k3d/deploy-k3d.sh"
echo ""
