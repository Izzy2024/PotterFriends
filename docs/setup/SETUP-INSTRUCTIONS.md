# Instrucciones de Configuración - Hogwarts Community Hub

## ✅ Estado Actual

- ✅ Conexión a Supabase funcionando
- ✅ Autenticación básica funcionando
- ✅ Registro de usuarios funcionando
- ⚠️ Falta crear las tablas en la base de datos

## 🚀 Pasos para Completar la Configuración

### Paso 1: Crear las Tablas en Supabase

1. Ve a tu dashboard de Supabase: https://app.supabase.com
2. Selecciona tu proyecto "Potter Friends"
3. En el menú lateral, haz clic en "SQL Editor"
4. Crea una nueva consulta
5. Copia todo el contenido del archivo `create-tables.sql`
6. Pega el contenido en el editor SQL
7. Haz clic en "Run" para ejecutar el SQL

### Paso 2: Verificar que las Tablas se Crearon

Después de ejecutar el SQL, deberías ver:
- Tabla `profiles` creada
- Tabla `houses` creada con datos de las 4 casas
- Políticas de seguridad (RLS) configuradas
- Trigger para crear perfiles automáticamente

### Paso 3: Iniciar el Servidor HTTP

1. Ejecuta el script para iniciar el servidor:
   ```bash
   ./start-server.sh
   ```
   O alternativamente:
   ```bash
   npx http-server . -p 8080
   ```

2. Verifica que el servidor esté funcionando visitando:
   - http://127.0.0.1:8080/hello.html
   - http://127.0.0.1:8080/index.html

### Paso 4: Probar el Sistema de Autenticación

1. Navega a http://127.0.0.1:8080/pages/user_registration.html
2. Registra un nuevo usuario con:
   - Nombre: Tu nombre
   - Apellido: Tu apellido
   - Nombre de Mago/Bruja: Un nombre mágico
   - Email: Un email válido (ej: tu-email@gmail.com)
   - Contraseña: Mínimo 6 caracteres con mayúscula, minúscula y número
3. Ve a http://127.0.0.1:8080/pages/user_login.html
4. Inicia sesión con las credenciales que acabas de crear

### Paso 4: Configurar Email (Opcional)

Si quieres habilitar la verificación por email:
1. Ve a Authentication > Settings en tu dashboard de Supabase
2. Configura un proveedor de email (SMTP)
3. Habilita "Enable email confirmations"

## 🧪 Scripts de Prueba Disponibles

```bash
# Prueba básica de autenticación
node test-auth-simple.js

# Prueba completa de conexión
node test-supabase-connection.js

# Compilar CSS
npm run build:css

# Modo desarrollo (CSS con watch)
npm run dev
```

## 🎯 Próximos Pasos

Una vez que tengas la autenticación funcionando:

1. **Implementar el Quiz del Sombrero**: Conectar el quiz con la base de datos para guardar la casa asignada
2. **Personalizar las Salas Comunes**: Mostrar contenido específico según la casa del usuario
3. **Sistema de Logros**: Implementar puntos y logros en la base de datos
4. **Foro Interactivo**: Conectar el foro con usuarios reales

## 🐛 Solución de Problemas

### Error: "Invalid API key"
- Verifica que estés usando la clave `anon public` correcta
- La clave actual es: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

### Error: "relation does not exist"
- Asegúrate de haber ejecutado el SQL del archivo `create-tables.sql`
- Ve a tu dashboard de Supabase y verifica que las tablas existan

### Error: "Email address invalid"
- Usa un formato de email válido (ej: usuario@gmail.com)
- Evita dominios ficticios como @hogwarts.edu

### La página no carga
- Asegúrate de estar ejecutando un servidor local
- Verifica que el archivo `css/main.css` esté compilado

## 📞 Soporte

Si tienes problemas:
1. Revisa los logs de la consola del navegador
2. Verifica que todas las dependencias estén instaladas (`npm install`)
3. Asegúrate de que el CSS esté compilado (`npm run build:css`)

¡Tu sistema de autenticación está casi listo! 🧙‍♂️✨