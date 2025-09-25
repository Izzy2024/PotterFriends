#!/bin/bash

# Hogwarts Community Hub - Setup Script
# Configuración completa del proyecto con sistema de eventos

echo "🧙‍♂️ Hogwarts Community Hub - Configuración Completa"
echo "=================================================="

# Verificar Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js no está instalado. Por favor instala Node.js v12+ primero."
    exit 1
fi

# Verificar npm
if ! command -v npm &> /dev/null; then
    echo "❌ npm no está instalado. Por favor instala npm primero."
    exit 1
fi

echo "✅ Node.js y npm detectados"

# Instalar dependencias
echo "📦 Instalando dependencias..."
npm install

if [ $? -ne 0 ]; then
    echo "❌ Error instalando dependencias"
    exit 1
fi

echo "✅ Dependencias instaladas"

# Compilar CSS
echo "🎨 Compilando CSS..."
npm run build:css

if [ $? -ne 0 ]; then
    echo "❌ Error compilando CSS"
    exit 1
fi

echo "✅ CSS compilado"

# Verificar Supabase CLI (opcional)
if command -v supabase &> /dev/null; then
    echo "✅ Supabase CLI detectado"
    echo ""
    echo "📋 Para configurar la base de datos completa:"
    echo "1. Crear proyecto en https://supabase.com"
    echo "2. Ejecutar: supabase db push --file supabase/migrations/20250811_community_events_backend.sql"
    echo "3. Ejecutar: supabase db push --file supabase/migrations/20250925_event_crud_rpcs.sql"
    echo "4. Ejecutar: supabase db push --file supabase/migrations/20250811_seed_community_events.sql"
else
    echo "⚠️  Supabase CLI no detectado (opcional)"
    echo "   Para gestión avanzada de BD: npm install -g supabase"
fi

echo ""
echo "🚀 Configuración completada!"
echo ""
echo "Para iniciar el servidor de desarrollo:"
echo "  npm run dev"
echo ""
echo "Para acceder a la aplicación:"
echo "  Abrir http://localhost:8080 en el navegador"
echo ""
echo "📚 Documentación:"
echo "  docs/technical_documentation.md"
echo "  docs/implementation_summary.md"
echo ""
echo "🎯 El sistema de eventos está completamente funcional!"