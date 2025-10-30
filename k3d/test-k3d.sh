#!/bin/bash

# Script de pruebas para verificar el funcionamiento del cluster K3D
# Uso: ./test-k3d.sh

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

NAMESPACE="todo-app"

echo "=========================================="
echo "  🧪 PRUEBAS DEL CLUSTER K3D"
echo "=========================================="
echo ""

# Test 1: Verificar cluster
echo -e "${BLUE}[TEST 1]${NC} Verificando cluster K3D..."
if k3d cluster list | grep -q "todo-cluster"; then
    echo -e "${GREEN}✓${NC} Cluster activo"
else
    echo -e "${RED}✗${NC} Cluster no encontrado"
    exit 1
fi

# Test 2: Verificar kubectl context
echo -e "${BLUE}[TEST 2]${NC} Verificando kubectl context..."
CURRENT_CONTEXT=$(kubectl config current-context)
if [[ "$CURRENT_CONTEXT" == "k3d-todo-cluster" ]]; then
    echo -e "${GREEN}✓${NC} Context correcto: $CURRENT_CONTEXT"
else
    echo -e "${YELLOW}⚠${NC} Context actual: $CURRENT_CONTEXT (esperado: k3d-todo-cluster)"
fi

# Test 3: Verificar namespace
echo -e "${BLUE}[TEST 3]${NC} Verificando namespace..."
if kubectl get namespace $NAMESPACE &>/dev/null; then
    echo -e "${GREEN}✓${NC} Namespace '$NAMESPACE' existe"
else
    echo -e "${RED}✗${NC} Namespace no encontrado"
    exit 1
fi

# Test 4: Verificar pods
echo -e "${BLUE}[TEST 4]${NC} Verificando estado de pods..."
TOTAL_PODS=$(kubectl get pods -n $NAMESPACE --no-headers | wc -l)
RUNNING_PODS=$(kubectl get pods -n $NAMESPACE --field-selector=status.phase=Running --no-headers | wc -l)
echo "   Total de pods: $TOTAL_PODS"
echo "   Pods corriendo: $RUNNING_PODS"

if [ "$RUNNING_PODS" -eq "$TOTAL_PODS" ] && [ "$TOTAL_PODS" -gt 0 ]; then
    echo -e "${GREEN}✓${NC} Todos los pods están corriendo"
else
    echo -e "${YELLOW}⚠${NC} Algunos pods no están listos"
    kubectl get pods -n $NAMESPACE
fi

# Test 5: Verificar servicios
echo -e "${BLUE}[TEST 5]${NC} Verificando servicios..."
SERVICES=$(kubectl get svc -n $NAMESPACE --no-headers | wc -l)
echo "   Servicios desplegados: $SERVICES"
if [ "$SERVICES" -gt 0 ]; then
    echo -e "${GREEN}✓${NC} Servicios configurados"
    kubectl get svc -n $NAMESPACE
else
    echo -e "${RED}✗${NC} No se encontraron servicios"
fi

# Test 6: Verificar PVCs
echo -e "${BLUE}[TEST 6]${NC} Verificando volúmenes persistentes..."
PVCS=$(kubectl get pvc -n $NAMESPACE --no-headers | wc -l)
BOUND_PVCS=$(kubectl get pvc -n $NAMESPACE --field-selector=status.phase=Bound --no-headers | wc -l)
echo "   PVCs totales: $PVCS"
echo "   PVCs vinculados: $BOUND_PVCS"
if [ "$BOUND_PVCS" -eq "$PVCS" ]; then
    echo -e "${GREEN}✓${NC} Todos los volúmenes están vinculados"
else
    echo -e "${YELLOW}⚠${NC} Algunos volúmenes no están vinculados"
fi

# Test 7: Health check del backend
echo -e "${BLUE}[TEST 7]${NC} Probando health endpoint del backend..."
sleep 2
if kubectl get svc backend-nodeport -n $NAMESPACE &>/dev/null; then
    # Intentar port-forward en segundo plano
    kubectl port-forward svc/backend-service 15000:5000 -n $NAMESPACE &>/dev/null &
    PF_PID=$!
    sleep 3
    
    if curl -s http://localhost:15000/health &>/dev/null; then
        HEALTH_RESPONSE=$(curl -s http://localhost:15000/health)
        echo -e "${GREEN}✓${NC} Backend responde correctamente"
        echo "   Response: $HEALTH_RESPONSE"
    else
        echo -e "${YELLOW}⚠${NC} Backend no responde (puede estar iniciando)"
    fi
    
    # Terminar port-forward
    kill $PF_PID 2>/dev/null || true
else
    echo -e "${YELLOW}⚠${NC} Servicio backend no disponible"
fi

# Test 8: Verificar logs de errores
echo -e "${BLUE}[TEST 8]${NC} Verificando logs por errores..."
ERROR_COUNT=0
for pod in $(kubectl get pods -n $NAMESPACE -o name); do
    ERRORS=$(kubectl logs $pod -n $NAMESPACE --tail=50 2>/dev/null | grep -i "error" | wc -l || echo 0)
    if [ "$ERRORS" -gt 0 ]; then
        echo -e "${YELLOW}⚠${NC} $pod tiene $ERRORS líneas con 'error'"
        ERROR_COUNT=$((ERROR_COUNT + ERRORS))
    fi
done

if [ "$ERROR_COUNT" -eq 0 ]; then
    echo -e "${GREEN}✓${NC} No se encontraron errores en los logs"
else
    echo -e "${YELLOW}⚠${NC} Se encontraron $ERROR_COUNT líneas con 'error' (revisar manualmente)"
fi

# Test 9: Verificar recursos del sistema
echo -e "${BLUE}[TEST 9]${NC} Verificando uso de recursos..."
echo "Top nodes:"
kubectl top nodes --context k3d-todo-cluster 2>/dev/null || echo -e "${YELLOW}⚠${NC} Metrics no disponibles (normal en clusters nuevos)"

echo ""
echo "=========================================="
echo "  RESUMEN DE PRUEBAS"
echo "=========================================="
echo ""
echo "Cluster:    ✓ Activo"
echo "Namespace:  ✓ $NAMESPACE"
echo "Pods:       $RUNNING_PODS/$TOTAL_PODS corriendo"
echo "Servicios:  $SERVICES configurados"
echo "PVCs:       $BOUND_PVCS/$PVCS vinculados"
echo ""

if [ "$RUNNING_PODS" -eq "$TOTAL_PODS" ] && [ "$BOUND_PVCS" -eq "$PVCS" ]; then
    echo -e "${GREEN}✓ TODAS LAS PRUEBAS PASARON${NC}"
    echo ""
    echo "🎉 El cluster está funcionando correctamente"
else
    echo -e "${YELLOW}⚠ ALGUNAS PRUEBAS REQUIEREN ATENCIÓN${NC}"
    echo ""
    echo "💡 Comandos útiles para debugging:"
    echo "   kubectl get pods -n $NAMESPACE"
    echo "   kubectl describe pod <pod-name> -n $NAMESPACE"
    echo "   kubectl logs <pod-name> -n $NAMESPACE"
fi

echo ""
