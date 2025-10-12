# Hogwarts PotterFriends

Una plataforma social interactiva inspirada en el mundo de Harry Potter, donde los usuarios pueden unirse a casas, participar en desafíos, ganar logros y conectarse con otros fans.

## 🏰 Características

- **Sistema de Casas**: Los usuarios son asignados a una de las cuatro casas de Hogwarts
- **Sistema de Logros**: Completa desafíos y gana insignias especiales
- **Foro Interactivo**: Participa en discusiones y gana puntos para tu casa
- **Eventos Comunitarios**: Participa en eventos especiales y desafíos
- **Panel de Administración**: Gestión de casas, usuarios y eventos
- **Sistema de Puntos**: Competencia entre casas por la Copa de las Casas

## 🚀 Estructura del Proyecto

```
hogwarts_PotterFriends/
├── src/                    # Código fuente
│   ├── components/         # Componentes reutilizables
│   ├── pages/             # Páginas HTML
│   ├── scripts/           # Archivos JavaScript
│   ├── styles/            # Archivos CSS
│   ├── utils/             # Utilidades y helpers
│   └── api/               # Clientes API y servicios
├── public/                # Recursos estáticos
│   ├── images/            # Imágenes
│   └── icons/             # Iconos
├── database/              # Archivos de base de datos
│   ├── migrations/        # Migraciones de Supabase
│   └── seeds/             # Datos de prueba
├── docs/                  # Documentación
├── tests/                 # Pruebas
├── tools/                 # Herramientas de desarrollo
├── scripts/               # Scripts de instalación y configuración
└── temp/                 # Archivos temporales
```

## 🛠️ Tecnologías

- **Frontend**: HTML5, CSS3, JavaScript (ES6+)
- **Estilos**: Tailwind CSS
- **Base de Datos**: Supabase (PostgreSQL)
- **Autenticación**: Supabase Auth
- **Testing**: Playwright

## 📦 Instalación

1. Clona el repositorio
2. Instala las dependencias:
   ```bash
   npm install
   ```
3. Configura la base de datos:
   ```bash
   ./scripts/setup-supabase.sh
   ```
4. Inicia el servidor de desarrollo:
   ```bash
   npm run dev
   ```

## 🔧 Configuración

Crea un archivo `.env` en la raíz del proyecto con las siguientes variables:

```env
SUPABASE_URL=tu_supabase_url
SUPABASE_ANON_KEY=tu_supabase_anon_key
SUPABASE_SERVICE_ROLE_KEY=tu_supabase_service_role_key
```

## 📚 Documentación

La documentación detallada se encuentra en la carpeta `docs/`:

- `docs/technical_documentation.md` - Documentación técnica
- `docs/setup/` - Guías de configuración
- `docs/prd/` - Documentos de requisitos del producto
- `docs/implementation_summary.md` - Resumen de implementación del sistema de eventos
- `docs/ARCHIVOS_RECUPERADOS.md` - Información sobre archivos recuperados de proyecto_limpio

### 🎯 Sistema de Eventos

El proyecto incluye un sistema de eventos completamente funcional según la documentación recuperada:

- **Centro de Eventos**: Página principal con eventos destacados y calendario interactivo
- **Panel de Administración**: Interfaz completa para crear y gestionar eventos
- **Sistema de Participación**: Unirse a eventos y seguimiento de progreso
- **Desafíos**: Individuales y por casa con sistema de recompensas
- **Votación Comunitaria**: Encuestas activas y resultados históricos

### 🚀 Instalación Automatizada

Para una instalación completa del sistema:

```bash
# Ejecutar script de instalación automatizada
chmod +x scripts/setup.sh
./scripts/setup.sh
```

## 🤝 Contribuir

1. Haz un fork del proyecto
2. Crea una rama para tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -am 'Añadir nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Crea un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - mira el archivo LICENSE para detalles.

## 🏆 Créditos

Desarrollado con ❤️ para los fans de Harry Potter

---

_¡Las alas de la libertad se rompen con las cadenas de la ignorancia!_
