-- Configuraciones de privacidad para user_profiles
-- Ejecutar en Supabase SQL Editor

-- Agregar columnas de privacidad si no existen
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS privacy_public_profile BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS privacy_show_stats BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS privacy_allow_messages BOOLEAN DEFAULT false;

-- Crear índices para mejorar el rendimiento
CREATE INDEX IF NOT EXISTS idx_user_profiles_privacy_public 
ON user_profiles(privacy_public_profile);

CREATE INDEX IF NOT EXISTS idx_user_profiles_privacy_messages 
ON user_profiles(privacy_allow_messages);

-- Actualizar perfiles existentes con valores por defecto
UPDATE user_profiles 
SET 
    privacy_public_profile = COALESCE(privacy_public_profile, true),
    privacy_show_stats = COALESCE(privacy_show_stats, true),    
    privacy_allow_messages = COALESCE(privacy_allow_messages, false)
WHERE 
    privacy_public_profile IS NULL 
    OR privacy_show_stats IS NULL 
    OR privacy_allow_messages IS NULL;

-- Comentarios para documentación
COMMENT ON COLUMN user_profiles.privacy_public_profile IS 'Si el perfil es público y visible para otros usuarios';
COMMENT ON COLUMN user_profiles.privacy_show_stats IS 'Si mostrar estadísticas públicamente (puntos, logros, etc.)';
COMMENT ON COLUMN user_profiles.privacy_allow_messages IS 'Si permitir que otros usuarios envíen mensajes';
