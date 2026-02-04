#!/bin/bash
set -e

API_LOG="/tmp/hogwarts-api.log"
FRONT_LOG="/tmp/hogwarts-frontend.log"
API_PID_FILE="/tmp/hogwarts-api.pid"
FRONT_PID_FILE="/tmp/hogwarts-frontend.pid"

echo "Limpiando procesos anteriores..."
pkill -f "node server/index.js" || true
pkill -f "http-server" || true
pkill -f "python3 -m http.server 8080" || true
rm -f "$API_PID_FILE" "$FRONT_PID_FILE"

echo "Limpiando logs anteriores..."
rm -f "$API_LOG" "$FRONT_LOG"

sleep 1

echo "Iniciando API local en puerto 3001..."
nohup node server/index.js > "$API_LOG" 2>&1 &
API_PID=$!
echo "$API_PID" > "$API_PID_FILE"

echo "Iniciando servidor frontend en puerto 8080..."
nohup npx --yes http-server . -p 8080 -c-1 > "$FRONT_LOG" 2>&1 &
FRONT_PID=$!
sleep 1
if ! kill -0 "$FRONT_PID" >/dev/null 2>&1; then
  echo "http-server falló, intentando con Python..."
  nohup python3 -m http.server 8080 > "$FRONT_LOG" 2>&1 &
  FRONT_PID=$!
fi
echo "$FRONT_PID" > "$FRONT_PID_FILE"

echo "API PID: $API_PID (log: $API_LOG)"
echo "Frontend PID: $FRONT_PID (log: $FRONT_LOG)"
echo "Abre: http://localhost:8080"
