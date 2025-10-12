-- ARREGLAR TABLA ACHIEVEMENT_TYPES EXISTENTE
-- Ejecuta este código para actualizar la tabla existente

-- Agregar columnas faltantes a la tabla existente
ALTER TABLE achievement_types 
ADD COLUMN IF NOT EXISTS icon TEXT DEFAULT '🏆',
ADD COLUMN IF NOT EXISTS category TEXT,
ADD COLUMN IF NOT EXISTS trigger_condition TEXT,
ADD COLUMN IF NOT EXISTS auto_award BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;

-- Verificar estructura de la tabla
SELECT column_name, data_type, is_nullable, column_default 
FROM information_schema.columns 
WHERE table_name = 'achievement_types' 
ORDER BY ordinal_position;

-- Mensaje de confirmación
SELECT 'Tabla achievement_types actualizada correctamente. Ahora ejecuta los logros.' as message;