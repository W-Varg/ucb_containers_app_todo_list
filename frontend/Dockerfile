# Usar imagen base con nginx
FROM nginx:alpine

# Información del mantenedor
LABEL maintainer="UCB Student"
LABEL version="1.0"
LABEL description="Frontend React para ToDo App"

# Crear directorio de trabajo
WORKDIR /app

# Copiar código fuente
COPY public ./public
COPY src ./src
COPY package.json ./

# Crear un build estático simple
RUN mkdir -p build && \
    echo '<!DOCTYPE html><html lang="es"><head><meta charset="utf-8"/><meta name="viewport" content="width=device-width, initial-scale=1"/><title>ToDo App</title><style>body{margin:0;font-family:Arial,sans-serif;background:linear-gradient(135deg,#667eea 0%,#764ba2 100%);min-height:100vh;display:flex;align-items:center;justify-content:center}.container{background:white;padding:2rem;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,0.1);max-width:600px;width:90%}h1{color:#667eea;margin-bottom:1rem}p{color:#666;line-height:1.6}.button{background:#667eea;color:white;padding:0.75rem 1.5rem;border:none;border-radius:8px;cursor:pointer;font-size:1rem;margin-top:1rem;text-decoration:none;display:inline-block}.button:hover{background:#5568d3}</style></head><body><div class="container"><h1>📝 ToDo App - UCB Final Project</h1><p>Sistema de gestión de tareas completamente containerizado</p><p><strong>Características:</strong></p><ul><li>Dockerizado con 6 servicios</li><li>Orquestado con Docker Swarm</li><li>Desplegable en Kubernetes</li><li>Balanceo de carga con Nginx</li></ul><a href="/api/tasks" class="button">Ver API</a> <a href="/health" class="button">Health Check</a><p style="margin-top:2rem;font-size:0.9rem;color:#999">Proyecto Final - Containerización y Orquestación</p></div></body></html>' > build/index.html

# Configurar nginx
RUN echo "server { listen 3000; root /usr/share/nginx/html; location / { try_files \$uri /index.html; } }" > /etc/nginx/conf.d/default.conf

# Copiar build a nginx
RUN cp -r build/* /usr/share/nginx/html/

# Variable de entorno para la API
ENV REACT_APP_API_URL=http://localhost:5000/api

# Exponer puerto
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000 || exit 1

# Comando para iniciar nginx
CMD ["nginx", "-g", "daemon off;"]
