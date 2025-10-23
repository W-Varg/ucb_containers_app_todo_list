# Usar imagen base ligera de Node.js con Alpine
FROM node:18-alpine

# Información del mantenedor
LABEL maintainer="UCB Student"
LABEL version="1.0"
LABEL description="Backend API para ToDo App"

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

# Exponer puerto
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:5000/health || exit 1

# Variables de entorno por defecto
ENV NODE_ENV=production
ENV PORT=5000

# Comando para iniciar la aplicación
CMD ["node", "server.js"]
