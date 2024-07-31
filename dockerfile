# Usa una imagen base desde Docker Hub
FROM romanfandrich/alien-tetris:latest

# (Opcional) Copiar archivos adicionales o configurar el entorno según sea necesario
# COPY . /app
# WORKDIR /app

# (Opcional) Instalar dependencias adicionales si es necesario
# RUN apt-get update && apt-get install -y <additional-dependencies>

# Exponer el puerto que la aplicación usa (ajústalo según sea necesario)
EXPOSE 8080

# (Opcional) Comando para ejecutar la aplicación, si no está definido en la imagen base
# CMD ["node", "app.js"]