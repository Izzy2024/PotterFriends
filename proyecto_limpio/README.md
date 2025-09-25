# Hogwarts Community Hub

Una comunidad mágica para fans de Harry Potter donde los usuarios pueden participar en eventos, desafíos y actividades interactivas.

## 🚀 Características Principales

### ✅ Sistema de Eventos Completamente Funcional
- **Centro de Eventos**: Página principal con eventos destacados, próximos eventos y calendario interactivo
- **Panel de Administración**: Interfaz completa para crear y gestionar eventos
- **Sistema de Participación**: Unirse a eventos, seguimiento de progreso y sistema de puntos
- **Calendario Mágico**: Visualización mensual con marcadores de eventos
- **Desafíos**: Individuales y por casa con sistema de recompensas
- **Votación Comunitaria**: Encuestas activas y resultados históricos

### 🎯 Funcionalidades Implementadas
- **Autenticación**: Sistema completo con Supabase Auth
- **Base de Datos**: PostgreSQL con Row Level Security
- **UI/UX Moderna**: Diseño responsivo con Tailwind CSS
- **Navegación Dinámica**: Sistema de rutas y navegación fluida
- **API Integration**: Funciones RPC y real-time subscriptions

## 🛠️ Stack Tecnológico

- **Frontend**: HTML5, CSS3, JavaScript (ES6+)
- **Styling**: Tailwind CSS con tema personalizado
- **Backend**: Supabase (PostgreSQL + Auth)
- **Build Tools**: Node.js, npm, PostCSS

## 📁 Estructura del Proyecto

```
hogwarts_community_hub/
├── css/                    # Estilos compilados
├── pages/                  # Páginas HTML de la aplicación
├── js/                     # JavaScript modular
├── supabase/              # Migraciones y configuración
├── docs/                  # Documentación técnica
├── index.html             # Página de entrada
├── package.json           # Dependencias y scripts
└── tailwind.config.js     # Configuración de Tailwind
```

## 🚀 Inicio Rápido

### Prerrequisitos
- Node.js v12+
- Cuenta de Supabase

### Instalación

```bash
# Clonar el repositorio
git clone <repository-url>
cd hogwarts-community-hub

# Instalar dependencias
npm install

# Configurar Supabase
# 1. Crear proyecto en https://supabase.com
# 2. Ejecutar migraciones de base de datos
# 3. Configurar variables de entorno

# Iniciar servidor de desarrollo
npm run dev
```

### Configuración de Base de Datos

```bash
# Ejecutar migraciones
supabase db push --file supabase/migrations/20250811_community_events_backend.sql
supabase db push --file supabase/migrations/20250925_event_crud_rpcs.sql

# Aplicar datos de ejemplo
supabase db push --file supabase/migrations/20250811_seed_community_events.sql
```

## 📖 Documentación

- **[Documentación Técnica](./docs/technical_documentation.md)**: Arquitectura, componentes y guías de desarrollo
- **[Guía de Instalación](./docs/setup_guide.md)**: Configuración completa del entorno
- **[API Reference](./docs/api_reference.md)**: Referencia de funciones y endpoints

## 🎮 Uso de la Aplicación

1. **Registro/Login**: Crear cuenta o iniciar sesión
2. **Selección de Casa**: Realizar el quiz del Sombrero Seleccionador
3. **Explorar Eventos**: Ver eventos destacados y próximos
4. **Participar**: Unirse a eventos y completar desafíos
5. **Administrar**: Crear nuevos eventos (si tienes permisos)

## 🔧 Scripts Disponibles

```bash
npm run dev          # Desarrollo con hot reload
npm run build:css    # Compilar CSS para producción
npm run watch:css    # Observar cambios en CSS
```

## 🐛 Solución de Problemas

### Eventos no aparecen
- Verificar que las funciones RPC existen en Supabase
- Comprobar estado de eventos (`status = 'active'`)
- Revisar consola del navegador

### Problemas de autenticación
- Verificar configuración de Supabase
- Comprobar variables de entorno
- Revisar políticas RLS

## 🤝 Contribución

1. Fork el proyecto
2. Crear rama para feature (`git checkout -b feature/AmazingFeature`)
3. Commit cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abrir Pull Request

## 📝 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.

## 🙏 Agradecimientos

- Inspirado en el universo de Harry Potter de J.K. Rowling
- Comunidad de fans que hacen posible este proyecto
- Tecnologías open source que lo hacen realidad

---

**Estado del Proyecto**: ✅ Sistema de Eventos Completamente Funcional

Última actualización: Septiembre 2025