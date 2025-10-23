#!/bin/bash

# Script de pruebas para el proyecto ToDo App
# Examen Final - Containerización y Orquestación UCB

echo "========================================="
echo "  PRUEBAS DEL PROYECTO TODO APP - UCB"
echo "========================================="
echo ""

echo "📊 1. Estado de los contenedores:"
echo "-----------------------------------"
docker compose ps
echo ""

echo "🐳 2. Imágenes Docker creadas:"
echo "-----------------------------------"
docker images | grep todo
echo ""

echo "🌐 3. Redes Docker:"
echo "-----------------------------------"
docker network ls | grep final
echo ""

echo "💾 4. Volúmenes persistentes:"
echo "-----------------------------------"
docker volume ls | grep final
echo ""

echo "🔍 5. Health Check del Backend:"
echo "-----------------------------------"
curl -s http://localhost:5000/health | python3 -m json.tool
echo ""

echo "📝 6. Listado de tareas (API directa):"
echo "-----------------------------------"
curl -s http://localhost:5000/api/tasks | python3 -m json.tool
echo ""

echo "📈 7. Estadísticas de tareas:"
echo "-----------------------------------"
curl -s http://localhost:5000/api/stats | python3 -m json.tool
echo ""

echo "🔄 8. Health Check a través de Nginx:"
echo "-----------------------------------"
curl -s http://localhost/health | python3 -m json.tool
echo ""

echo "🌐 9. API a través de Nginx:"
echo "-----------------------------------"
curl -s http://localhost/api/stats | python3 -m json.tool
echo ""

echo "✅ 10. Crear una nueva tarea:"
echo "-----------------------------------"
curl -s -X POST http://localhost/api/tasks \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Tarea creada desde script de pruebas",
    "description": "Verificación automática del sistema",
    "priority": "high"
  }' | python3 -m json.tool
echo ""

echo "📊 11. Estadísticas actualizadas:"
echo "-----------------------------------"
curl -s http://localhost/api/stats | python3 -m json.tool
echo ""

echo "🔍 12. Logs recientes del Backend:"
echo "-----------------------------------"
docker compose logs --tail=10 backend
echo ""

echo "🔍 13. Logs recientes del Worker:"
echo "-----------------------------------"
docker compose logs --tail=10 worker
echo ""

echo "========================================="
echo "  ✅ PRUEBAS COMPLETADAS EXITOSAMENTE"
echo "========================================="
