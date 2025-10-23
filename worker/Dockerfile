# Usar imagen base ligera de Node.js con Alpine
FROM node:18-alpine

# Información del mantenedor
LABEL maintainer="UCB Student"
LABEL version="1.0"
LABEL description="Worker para procesamiento en background"

# Crear directorio de trabajo
WORKDIR /app

# Copiar archivos de dependencias
COPY package*.json ./

# Instalar dependencias de producción
RUN npm install --only=production && npm cache clean --force

# Copiar código fuente
COPY . .

# Crear usuario no-root para seguridad
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 && \
    chown -R nodejs:nodejs /app

# Cambiar a usuario no-root
USER nodejs

# Variables de entorno por defecto
ENV NODE_ENV=production

# Health check (verifica que el proceso está ejecutándose)
HEALTHCHECK --interval=60s --timeout=3s --start-period=10s --retries=3 \
  CMD ps aux | grep -v grep | grep -q worker.js || exit 1

# Comando para iniciar el worker
CMD ["node", "worker.js"]
