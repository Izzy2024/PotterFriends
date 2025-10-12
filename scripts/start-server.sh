#!/bin/bash

# Detener cualquier servidor HTTP existente
echo "Deteniendo servidores HTTP existentes..."
pkill -f "http-server" || true

# Esperar un momento
sleep 1

# Iniciar el servidor HTTP en el directorio actual
echo "Iniciando servidor HTTP en el puerto 8080..."
npx http-server . -p 8080

# Si npx no está disponible, intentar con python
if [ $? -ne 0 ]; then
  echo "Intentando con Python..."
  python3 -m http.server 8080
fi
