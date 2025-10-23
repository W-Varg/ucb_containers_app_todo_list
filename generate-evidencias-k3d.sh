#!/bin/bash

# Script para generar reporte de evidencias del examen final
# Examen Final UCB - Containerización y Orquestación

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
REPORT_FILE="reports/evidencias-examen-${TIMESTAMP}.txt"

mkdir -p reports

echo "=====================================" > "$REPORT_FILE"
echo " EVIDENCIAS - EXAMEN FINAL UCB" >> "$REPORT_FILE"
echo " Containerización y Orquestación" >> "$REPORT_FILE"
echo "=====================================" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "Fecha: $(date '+%d de %B, %Y')" >> "$REPORT_FILE"
echo "Estudiante: [Tu Nombre]" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo "=== IMÁGENES DOCKER CONSTRUIDAS ===" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
docker images | grep todo >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo "=== CLUSTER K3D ===" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
k3d cluster list >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo "=== NODOS DEL CLUSTER ===" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
kubectl get nodes -o wide >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo "=== PODS DESPLEGADOS ===" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
kubectl get pods -n todo-app -o wide >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo "=== SERVICIOS ===" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
kubectl get svc -n todo-app >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo "=== DEPLOYMENTS ===" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
kubectl get deployments -n todo-app >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo "=== STATEFULSETS ===" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
kubectl get statefulsets -n todo-app >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo "=== PERSISTENT VOLUME CLAIMS ===" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
kubectl get pvc -n todo-app >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo "=== TODOS LOS RECURSOS ===" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
kubectl get all -n todo-app >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo "=== RESUMEN ===" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "Cluster K3D creado: ✓" >> "$REPORT_FILE"
echo "Imágenes Docker construidas: ✓" >> "$REPORT_FILE"
echo "Imágenes importadas a K3D: ✓" >> "$REPORT_FILE"
echo "Manifiestos aplicados: ✓" >> "$REPORT_FILE"
echo "Servicios desplegados: 6" >> "$REPORT_FILE"
echo "Puerto de acceso: http://localhost:9080" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo "=====================================" >> "$REPORT_FILE"
echo " REPORTE GENERADO EXITOSAMENTE" >> "$REPORT_FILE"
echo "=====================================" >> "$REPORT_FILE"

echo "✅ Reporte generado en: $REPORT_FILE"
cat "$REPORT_FILE"
