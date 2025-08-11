# Guía de Configuración del Foro Interactivo

## Requisitos Previos
- Cuenta de Supabase activa
- Variables de entorno configuradas (`SUPABASE_URL` y `SUPABASE_ANON_KEY`)
- Sistema de autenticación funcionando (auth.js)

## Pasos de Configuración

### 1. Configurar la Base de Datos

1. Accede a tu proyecto de Supabase
2. Ve a **SQL Editor**
3. Ejecuta el script de migración ubicado en `supabase/migrations/001_create_forum_tables.sql`
4. Verifica que las tablas se hayan creado correctamente en la sección **Table Editor**

### 2. Verificar las Políticas RLS

Las políticas de Row Level Security (RLS) ya están incluidas en el script de migración, pero verifica que estén activas:

1. Ve a **Authentication** > **Policies**
2. Asegúrate de que RLS esté habilitado para las tablas:
   - `posts`
   - `comments`
   - `likes`
   - `forum_user_stats`

### 3. Configurar Real-time

1. Ve a **Database** > **Replication**
2. Habilita la replicación para las siguientes tablas:
   - `posts` (para nuevas discusiones)
   - `comments` (para nuevos comentarios)
3. Esto permitirá actualizaciones en tiempo real en el foro

### 4. Estructura de Archivos

Asegúrate de tener la siguiente estructura:

```
hogwarts_PotterFriends/
├── js/
│   ├── services/
│   │   └── forumApi.js      # API del foro
│   ├── forum.js             # Controlador principal
│   ├── supabase-client.js   # Cliente de Supabase
│   └── auth.js              # Autenticación
├── pages/
│   └── interactive_forum_hub.html
├── supabase/
│   └── migrations/
│       └── 001_create_forum_tables.sql
└── docs/
    ├── prd/
    │   └── interactive_forum_hub_prd.md
    └── setup/
        └── forum_setup_guide.md
```

### 5. Configurar Variables de Entorno

Si no tienes `js/supabase-client.js`, créalo:

```javascript
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'TU_SUPABASE_URL'
const supabaseAnonKey = 'TU_SUPABASE_ANON_KEY'

export const supabase = createClient(supabaseUrl, supabaseAnonKey)
```

### 6. Probar la Funcionalidad

1. **Crear una discusión:**
   - Inicia sesión en la aplicación
   - Haz clic en "Nueva Discusión"
   - Completa el formulario y publica

2. **Filtrar y buscar:**
   - Usa los checkboxes de casas para filtrar
   - Prueba el buscador en tiempo real
   - Cambia el ordenamiento

3. **Interacciones:**
   - Dale like a posts (próximamente)
   - Comenta en discusiones (próximamente)

## Funcionalidades Implementadas

✅ **Completadas:**
- Modelo de datos completo con RLS
- API de servicios (CRUD para posts, comentarios, likes)
- Controlador del foro con filtros y búsqueda
- Modal para crear nuevas discusiones
- Actualización dinámica de contenido
- Estadísticas del foro en tiempo real
- Sistema de notificaciones

⏳ **Próximas características:**
- Vista detallada de posts con comentarios
- Sistema de likes funcional
- Editor de texto enriquecido
- Subida de imágenes
- Sistema de menciones (@usuario)
- Badges y logros del foro
- Sistema de moderación

## Solución de Problemas

### Error: "No se pueden cargar los posts"
- Verifica que las tablas estén creadas en Supabase
- Revisa las credenciales en `supabase-client.js`
- Comprueba la consola del navegador para errores específicos

### Error: "No autorizado"
- Asegúrate de estar autenticado
- Verifica las políticas RLS en Supabase
- Comprueba que el usuario tenga un perfil creado

### Los filtros no funcionan
- Revisa que las casas estén creadas en la base de datos
- Verifica que los IDs de las casas coincidan

## Personalización

### Añadir nuevas categorías:
1. Inserta en la tabla `categories` en Supabase
2. El foro las mostrará automáticamente

### Modificar permisos:
1. Edita las políticas RLS en Supabase
2. Por ejemplo, para moderadores: actualiza la política de UPDATE/DELETE

### Cambiar límite de paginación:
En `js/services/forumApi.js`, modifica:
```javascript
this.pageSize = 20; // Cambia a tu preferencia
```

## Mantenimiento

### Limpieza de datos antiguos:
```sql
-- Eliminar posts antiguos sin actividad
DELETE FROM posts 
WHERE created_at < NOW() - INTERVAL '6 months'
AND id NOT IN (
    SELECT DISTINCT post_id FROM comments 
    WHERE created_at > NOW() - INTERVAL '1 month'
);
```

### Backup de datos:
1. Ve a **Settings** > **Backups** en Supabase
2. Descarga backups regularmente

## Soporte

Para problemas o preguntas:
1. Revisa el PRD en `docs/prd/interactive_forum_hub_prd.md`
2. Consulta los logs en Supabase Dashboard
3. Revisa la documentación de Supabase: https://supabase.com/docs
