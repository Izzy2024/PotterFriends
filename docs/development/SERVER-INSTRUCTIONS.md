# Instrucciones del Servidor - Hogwarts Community Hub

## 🚀 Iniciar el Servidor HTTP

Para que la aplicación funcione correctamente, es necesario iniciar un servidor HTTP local que sirva los archivos estáticos. Sigue estos pasos:

### Método 1: Usando el Script (Recomendado)

1. Abre una terminal en el directorio raíz del proyecto
2. Ejecuta el script:
   ```bash
   ./start-server.sh
   ```
3. El servidor se iniciará en el puerto 8080
4. Accede a la aplicación en: http://127.0.0.1:8080/index.html

### Método 2: Usando NPX

1. Abre una terminal en el directorio raíz del proyecto
2. Ejecuta el comando:
   ```bash
   npx http-server . -p 8080
   ```
3. Accede a la aplicación en: http://127.0.0.1:8080/index.html

### Método 3: Usando Python

Si no tienes Node.js instalado, puedes usar Python:

1. Abre una terminal en el directorio raíz del proyecto
2. Ejecuta uno de estos comandos:
   ```bash
   python -m http.server 8080
   ```
   o
   ```bash
   python3 -m http.server 8080
   ```
3. Accede a la aplicación en: http://127.0.0.1:8080/index.html

## 🛑 Detener el Servidor

Para detener el servidor, presiona `Ctrl+C` en la terminal donde está corriendo.

## 🔍 Solución de Problemas

### Error 404 (Not Found)

Si recibes errores 404, asegúrate de:

1. Estar ejecutando el servidor desde el directorio raíz del proyecto
2. Usar la URL correcta (http://127.0.0.1:8080/index.html)
3. Verificar que los archivos existan en las rutas correctas

### Problemas de CORS

Si tienes problemas de CORS (Cross-Origin Resource Sharing):

1. Usa el script `start-server.sh` que está configurado para manejar CORS
2. O agrega la opción `-c-1` al comando http-server:
   ```bash
   npx http-server . -p 8080 -c-1 --cors
   ```

### Puerto en Uso

Si el puerto 8080 está en uso:

1. Cambia el puerto en el comando:
   ```bash
   npx http-server . -p 8081
   ```
2. Actualiza las URLs para usar el nuevo puerto: http://127.0.0.1:8081/index.html

## 📋 Verificación del Servidor

Para verificar que el servidor está funcionando correctamente:

1. Visita http://127.0.0.1:8080/hello.html
2. Deberías ver una página de prueba con enlaces a las principales secciones
3. Si esta página carga correctamente, el servidor está funcionando bien

## 🔄 Reiniciar el Servidor

Si necesitas reiniciar el servidor:

1. Presiona `Ctrl+C` para detenerlo
2. Ejecuta nuevamente `./start-server.sh`

---

Recuerda que el servidor HTTP es necesario para que la aplicación funcione correctamente. Asegúrate de tenerlo en ejecución siempre que estés trabajando en el proyecto.