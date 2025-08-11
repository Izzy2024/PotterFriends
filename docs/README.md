# Documentación del Proyecto Hogwarts Community Hub

## Visión General

Bienvenido a la documentación del proyecto "Hogwarts Community Hub", una aplicación web moderna que crea una experiencia inmersiva para fans de Harry Potter utilizando HTML5 y Tailwind CSS. Este conjunto de documentos proporciona información detallada sobre la estructura, tecnologías, análisis y posibles mejoras del proyecto.

## Contenido de la Documentación

### [Análisis del Proyecto](./project_analysis.md)
Un análisis detallado de la estructura del proyecto, tecnologías utilizadas, características principales y patrones de diseño implementados.

### [Análisis del Framework](./framework_analysis.md)
Una exploración profunda del framework frontend utilizado, centrado en la implementación de Tailwind CSS, el sistema de componentes y la arquitectura general.

### [Documentación Técnica](./technical_documentation.md)
Guía técnica completa para desarrolladores que incluye la arquitectura, componentes, flujos de trabajo, y guías de estilo para mantener y extender el proyecto.

### [Mejoras Futuras](./future_improvements.md)
Propuestas detalladas para la expansión y mejora del proyecto, organizadas por categorías de prioridad y complejidad.

## Inicio Rápido

Para comenzar a trabajar con el proyecto:

```bash
# Instalar dependencias del frontend
npm install

# Compilar CSS para producción
npm run build:css

# Iniciar servidor de desarrollo con recarga automática de CSS
npm run dev

# Iniciar el servidor HTTP (importante)
./start-server.sh
# O alternativamente: npx http-server . -p 8080

# Acceder a la aplicación
# Abrir en el navegador: http://127.0.0.1:8080/index.html

# Configurar Supabase (ya configurado)
# URL: https://vdcclritlgnwwdxloayt.supabase.co
# Token: sbp_4b0266548d93651854c2e5d8ef5176ac88718a7e

# Configurar tablas en Supabase (opcional)
npm install @supabase/supabase-js
node setup-supabase.js
```

## Estructura del Proyecto

```
hogwarts_community_hub/
├── css/
│   ├── tailwind.css   # Archivo fuente de Tailwind con utilidades personalizadas
│   └── main.css       # CSS compilado (generado automáticamente)
├── js/
│   └── auth.js        # Funcionalidades de autenticación de usuarios
├── pages/             # Páginas HTML de la aplicación
│   ├── community_events_challenges_center.html
│   ├── email_verification_pending.html
│   ├── forgot_password.html
│   ├── homepage_sorting_hat_experience.html
│   ├── house_common_rooms_personalized_dashboards.html
│   ├── house_selection_portal_sorting_hat_quiz.html
│   ├── interactive_forum_hub.html
│   ├── reset_password.html
│   ├── user_login.html
│   ├── user_profile_achievement_system.html
│   └── user_registration.html
├── docs/              # Documentación del proyecto
├── .kiro/             # Configuración de Kiro
│   └── settings/      # Configuraciones para herramientas
│       └── mcp.json   # Configuración de Model Context Protocol para Supabase
├── index.html         # Página de entrada con animación de carga
├── package.json       # Dependencias y scripts del proyecto
└── tailwind.config.js # Configuración personalizada de Tailwind CSS
```

## Características Principales

- **Experiencia Temática**: Diseño inmersivo basado en el universo de Harry Potter
- **Quiz del Sombrero Seleccionador**: Sistema interactivo para asignar usuarios a casas
- **Sistema de Autenticación**: Registro, inicio de sesión, recuperación de contraseña y verificación de email
- **Diseño Responsivo**: Experiencia optimizada para todos los dispositivos
- **Componentes Personalizados**: Sistema de UI coherente y temático
- **Animaciones y Transiciones**: Efectos visuales para mejorar la experiencia
- **Foro Interactivo**: Espacio para discusiones entre miembros de la comunidad

## Tecnologías Utilizadas

### Frontend
- **HTML5**: Estructura semántica moderna
- **Tailwind CSS**: Framework de utilidad para estilos
- **JavaScript**: Interactividad y manipulación del DOM
- **Node.js/npm**: Entorno de desarrollo y gestión de paquetes

### Backend
- **Supabase**: Plataforma de backend como servicio (BaaS)
- **PostgreSQL**: Base de datos relacional para persistencia de datos
- **Supabase Auth**: Sistema de autenticación integrado
- **Supabase Storage**: Almacenamiento de archivos
- **MCP (Model Context Protocol)**: Integración segura con Supabase

## Sistema de Autenticación

El proyecto implementa un sistema completo de autenticación de usuarios con las siguientes características:

- **Registro de Usuarios**: Creación de cuentas con validación de datos
- **Inicio de Sesión**: Autenticación segura con Supabase Auth
- **Verificación de Email**: Proceso de verificación por correo electrónico
- **Recuperación de Contraseña**: Flujo seguro para restablecer contraseñas olvidadas
- **Persistencia de Datos**: Almacenamiento de información de usuarios en PostgreSQL
- **Seguridad**: Encriptación de contraseñas y protección contra ataques comunes
- **MCP Integration**: Uso seguro de Supabase a través del Model Context Protocol

### Verificación de la Conexión a Supabase

Para verificar que la conexión a Supabase funciona correctamente:

```bash
# Instalar dependencias si no lo has hecho
npm install @supabase/supabase-js

# Ejecutar el script de prueba simple
node test-auth-simple.js
```

### Configuración de la Base de Datos

Para configurar las tablas necesarias en Supabase:

1. Ve a tu dashboard de Supabase: https://app.supabase.com
2. Selecciona tu proyecto "Potter Friends"
3. Ve a "SQL Editor" en el menú lateral
4. Copia y pega el contenido del archivo `create-tables.sql`
5. Ejecuta el SQL para crear las tablas necesarias

### Prueba del Sistema de Autenticación

Una vez configuradas las tablas, puedes probar el sistema:

1. Abre `pages/user_registration.html` en tu navegador
2. Registra un nuevo usuario
3. Verifica el email (si está habilitado)
4. Inicia sesión en `pages/user_login.html`

Para más detalles sobre la implementación técnica, consulta la [Documentación Técnica](./technical_documentation.md).

## Contribución

Si deseas contribuir al proyecto:

1. Revisa la [Documentación Técnica](./technical_documentation.md) para entender la arquitectura
2. Consulta las [Mejoras Futuras](./future_improvements.md) para ideas de características
3. Sigue las guías de estilo y convenciones documentadas
4. Asegúrate de probar tus cambios en diferentes dispositivos y navegadores

## Licencia

Este proyecto está bajo la Licencia MIT. Consulta el archivo LICENSE para más detalles.