#!/bin/bash

# Script para construir, versionar y subir imágenes a DockerHub
# Universidad Católica Boliviana - Proyecto Final

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuración
DOCKERHUB_USERNAME="wvarg"  # Usuario de Docker Hub
IMAGE_NAME="todo-backend"
VERSION="$1"

# Función para mostrar uso
show_usage() {
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  Script de Versionamiento y Push a DockerHub            ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Uso:${NC}"
    echo "  ./build-and-push.sh <version> [service]"
    echo ""
    echo -e "${YELLOW}Ejemplos:${NC}"
    echo "  ./build-and-push.sh 0.0.1           # Construir backend v0.0.1"
    echo "  ./build-and-push.sh 0.0.2 backend   # Construir backend v0.0.2"
    echo "  ./build-and-push.sh 0.0.3 all       # Construir todas las imágenes v0.0.3"
    echo ""
    echo -e "${YELLOW}Servicios disponibles:${NC}"
    echo "  • backend  (API Node.js)"
    echo "  • frontend (React + Nginx)"
    echo "  • worker   (Background Jobs)"
    echo "  • nginx    (Load Balancer)"
    echo "  • all      (Todas las imágenes)"
    echo ""
}

# Verificar argumentos
if [ -z "$VERSION" ]; then
    show_usage
    exit 1
fi

SERVICE="${2:-backend}"

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Construcción y Push de Imágenes Docker - v${VERSION}${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Función para construir y pushear una imagen
build_and_push() {
    local service=$1
    local context_dir=$2
    local dockerfile=$3
    
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}📦 Procesando: ${service}${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    # Construir imagen
    echo -e "${YELLOW}[1/5]${NC} Construyendo imagen..."
    docker build -t ${DOCKERHUB_USERNAME}/todo-${service}:${VERSION} \
                 -f ${dockerfile} ${context_dir}
    
    echo -e "${GREEN}✓${NC} Imagen construida correctamente"
    echo ""
    
    # Extraer versión minor (1.0 de 1.0.1)
    MINOR_VERSION=$(echo ${VERSION} | cut -d. -f1,2)
    
    # Crear tags adicionales
    echo -e "${YELLOW}[2/5]${NC} Creando tags adicionales..."
    docker tag ${DOCKERHUB_USERNAME}/todo-${service}:${VERSION} ${DOCKERHUB_USERNAME}/todo-${service}:${MINOR_VERSION}
    docker tag ${DOCKERHUB_USERNAME}/todo-${service}:${VERSION} ${DOCKERHUB_USERNAME}/todo-${service}:latest
    echo -e "${GREEN}✓${NC} Tags creados: ${VERSION}, ${MINOR_VERSION}, latest"
    echo ""
    
    # Mostrar información de la imagen
    echo -e "${YELLOW}[3/5]${NC} Información de las imágenes:"
    docker images ${DOCKERHUB_USERNAME}/todo-${service} --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
    echo ""
    
    # Preguntar si desea subir a DockerHub
    echo -e "${YELLOW}[4/5]${NC} ¿Desea subir la imagen a DockerHub? (s/N): "
    read -r PUSH_CONFIRM
    
    if [[ $PUSH_CONFIRM =~ ^[Ss]$ ]]; then
        # Login a DockerHub (si no está logueado)
        echo -e "${YELLOW}Verificando login en DockerHub...${NC}"
        if ! docker info 2>/dev/null | grep -q "Username:"; then
            echo -e "${YELLOW}Iniciando sesión en DockerHub...${NC}"
            docker login
        else
            echo -e "${GREEN}✓${NC} Ya está autenticado en DockerHub"
        fi
        
        # Push de la versión específica
        echo -e "${YELLOW}[5/5]${NC} Subiendo imagen versión ${VERSION}..."
        docker push ${DOCKERHUB_USERNAME}/todo-${service}:${VERSION}
        echo -e "${GREEN}✓${NC} Versión ${VERSION} subida correctamente"
        
        # Push del tag minor
        echo -e "${YELLOW}[5/5]${NC} Subiendo imagen versión ${MINOR_VERSION}..."
        docker push ${DOCKERHUB_USERNAME}/todo-${service}:${MINOR_VERSION}
        echo -e "${GREEN}✓${NC} Versión ${MINOR_VERSION} actualizada"
        
        # Push del tag latest
        echo -e "${YELLOW}[5/5]${NC} Subiendo imagen latest..."
        docker push ${DOCKERHUB_USERNAME}/todo-${service}:latest
        echo -e "${GREEN}✓${NC} Tag latest actualizado"
        
        echo ""
        echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║  ✓ Imagen subida exitosamente a DockerHub              ║${NC}"
        echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${CYAN}🔗 Ver en DockerHub:${NC}"
        echo "  https://hub.docker.com/r/${DOCKERHUB_USERNAME}/todo-${service}/tags"
        echo ""
        echo -e "${CYAN}📦 Imágenes disponibles:${NC}"
        echo "  • ${DOCKERHUB_USERNAME}/todo-${service}:${VERSION}"
        echo "  • ${DOCKERHUB_USERNAME}/todo-${service}:${MINOR_VERSION}"
        echo "  • ${DOCKERHUB_USERNAME}/todo-${service}:latest"
        echo ""
        echo -e "${CYAN}☸️  Para actualizar en Kubernetes:${NC}"
        echo "  kubectl set image deployment/${service} ${service}=${DOCKERHUB_USERNAME}/todo-${service}:${VERSION} -n todo-app"
        echo ""
        echo -e "${CYAN}↩️  Para hacer rollback:${NC}"
        echo "  kubectl rollout undo deployment/${service} -n todo-app"
        echo "  # O a versión específica:"
        echo "  kubectl set image deployment/${service} ${service}=${DOCKERHUB_USERNAME}/todo-${service}:1.0.1 -n todo-app"
        echo ""
        
        # Guardar log de versionamiento
        LOG_FILE="version-history.log"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] ${service} v${VERSION} - Subida a DockerHub" >> ${LOG_FILE}
        echo -e "${GREEN}✓${NC} Versión registrada en ${LOG_FILE}"
        echo ""
    else
        echo -e "${YELLOW}⚠${NC} Subida cancelada. Imagen solo disponible localmente."
    fi
    
    echo ""
}

# Construir según el servicio seleccionado
case $SERVICE in
    backend)
        build_and_push "backend" "./backend" "./backend/Dockerfile"
        ;;
    frontend)
        build_and_push "frontend" "./frontend" "./frontend/Dockerfile"
        ;;
    worker)
        build_and_push "worker" "./worker" "./worker/Dockerfile"
        ;;
    nginx)
        build_and_push "nginx" "./nginx" "./nginx/Dockerfile"
        ;;
    all)
        echo -e "${GREEN}Construyendo todas las imágenes...${NC}"
        echo ""
        build_and_push "backend" "./backend" "./backend/Dockerfile"
        build_and_push "frontend" "./frontend" "./frontend/Dockerfile"
        build_and_push "worker" "./worker" "./worker/Dockerfile"
        build_and_push "nginx" "./nginx" "./nginx/Dockerfile"
        ;;
    *)
        echo -e "${RED}Error: Servicio desconocido: $SERVICE${NC}"
        show_usage
        exit 1
        ;;
esac

echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✓ Proceso completado exitosamente                      ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
