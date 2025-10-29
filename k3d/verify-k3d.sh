#!/bin/bash

# Script de verificación para el despliegue en K3D
# Examen Final - Containerización y Orquestación UCB

echo "========================================="
echo "  VERIFICACIÓN DEL DESPLIEGUE EN K3D"
echo "========================================="
echo ""

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}📋 1. Información del Cluster K3D:${NC}"
echo "-----------------------------------"
k3d cluster list
echo ""

echo -e "${BLUE}🖥️  2. Nodos del Cluster:${NC}"
echo "-----------------------------------"
kubectl get nodes -o wide
echo ""

echo -e "${BLUE}📦 3. Namespaces:${NC}"
echo "-----------------------------------"
kubectl get namespaces
echo ""

echo -e "${BLUE}🚀 4. Pods en todo-app:${NC}"
echo "-----------------------------------"
kubectl get pods -n todo-app -o wide
echo ""

echo -e "${BLUE}🌐 5. Servicios en todo-app:${NC}"
echo "-----------------------------------"
kubectl get svc -n todo-app
echo ""

echo -e "${BLUE}📊 6. Deployments:${NC}"
echo "-----------------------------------"
kubectl get deployments -n todo-app
echo ""

echo -e "${BLUE}💾 7. StatefulSets:${NC}"
echo "-----------------------------------"
kubectl get statefulsets -n todo-app
echo ""

echo -e "${BLUE}🔄 8. ReplicaSets:${NC}"
echo "-----------------------------------"
kubectl get replicasets -n todo-app
echo ""

echo -e "${BLUE}📂 9. PersistentVolumeClaims:${NC}"
echo "-----------------------------------"
kubectl get pvc -n todo-app
echo ""

echo -e "${BLUE}⚙️  10. ConfigMaps y Secrets:${NC}"
echo "-----------------------------------"
kubectl get configmaps -n todo-app
kubectl get secrets -n todo-app
echo ""

echo -e "${BLUE}📈 11. Estado de Recursos:${NC}"
echo "-----------------------------------"
kubectl top nodes 2>/dev/null || echo "Metrics server no disponible (normal en K3D)"
echo ""

echo -e "${BLUE}🔍 12. Eventos Recientes:${NC}"
echo "-----------------------------------"
kubectl get events -n todo-app --sort-by='.lastTimestamp' | tail -10
echo ""

echo -e "${BLUE}13. Endpoints:${NC}"
echo "-----------------------------------"
kubectl get endpoints -n todo-app
echo ""

echo -e "${BLUE}📝 14. Detalles del Backend:${NC}"
echo "-----------------------------------"
kubectl get pods -n todo-app -l app=backend
echo ""

echo -e "${BLUE}🖼️  15. Detalles del Frontend:${NC}"
echo "-----------------------------------"
kubectl get pods -n todo-app -l app=frontend
echo ""

echo -e "${BLUE}🔌 16. Acceso a la Aplicación:${NC}"
echo "-----------------------------------"
echo "Aplicación disponible en:"
echo "  - LoadBalancer: http://localhost:9080"
echo "  - Backend NodePort: http://localhost:9500"
echo "  - Frontend NodePort: http://localhost:9300"
echo ""

echo -e "${BLUE}📊 17. Resumen de Recursos:${NC}"
echo "-----------------------------------"
echo "Pods:"
kubectl get pods -n todo-app | grep -c "Running" | xargs echo "  Running:"
kubectl get pods -n todo-app | grep -c "Error\|CrashLoop" | xargs echo "  Con problemas:"
echo ""
echo "Servicios:"
kubectl get svc -n todo-app | grep -c "ClusterIP\|NodePort\|LoadBalancer" | xargs echo "  Total:"
echo ""
echo "Deployments:"
kubectl get deployments -n todo-app | tail -n +2 | wc -l | xargs echo "  Total:"
echo ""

echo -e "${BLUE}🧪 18. Prueba de Conectividad:${NC}"
echo "-----------------------------------"
echo "Probando acceso al LoadBalancer..."
curl -s -o /dev/null -w "Status: %{http_code}\n" http://localhost:9080/ || echo "LoadBalancer no responde (puede estar iniciando)"
echo ""

echo "========================================="
echo "  VERIFICACIÓN COMPLETADA"
echo "========================================="
echo ""
echo "Para ver logs de un pod específico:"
echo "  kubectl logs -n todo-app <nombre-del-pod>"
echo ""
echo "Para describir un recurso:"
echo "  kubectl describe pod -n todo-app <nombre-del-pod>"
echo ""
echo "Para escalar un deployment:"
echo "  kubectl scale deployment <nombre> --replicas=N -n todo-app"
echo ""
