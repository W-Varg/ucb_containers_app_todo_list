# Usar imagen oficial de Nginx con Alpine
FROM nginx:alpine

# Información del mantenedor
LABEL maintainer="UCB Student"
LABEL version="1.0"
LABEL description="Nginx Reverse Proxy y Load Balancer"

# Remover configuración por defecto
RUN rm /etc/nginx/conf.d/default.conf

# Copiar configuración personalizada
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Crear página de error personalizada
RUN echo '<!DOCTYPE html><html><head><title>Error</title></head><body><h1>Servicio temporalmente no disponible</h1><p>Por favor, intenta nuevamente en unos momentos.</p></body></html>' > /usr/share/nginx/html/50x.html

# Exponer puerto
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:80/health || exit 1

# Nginx se ejecuta en foreground por defecto
CMD ["nginx", "-g", "daemon off;"]
