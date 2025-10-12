-- ============================================================================
-- SCRIPT SIMPLIFICADO: Solucionar Usuario Anónimo en el Foro
-- ============================================================================
-- Este script es más seguro y verifica la estructura antes de hacer cambios
-- ============================================================================

-- PASO 1: Ver estructura actual de user_profiles
-- ============================================================================
SELECT 
    '=== COLUMNAS ACTUALES DE user_profiles ===' as info;

SELECT 
    column_name, 
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public' 
AND table_name = 'user_profiles'
ORDER BY ordinal_position;

-- PASO 2: Agregar columnas necesarias (si no existen)
-- ============================================================================

-- Agregar wizard_name
ALTER TABLE public.user_profiles 
ADD COLUMN IF NOT EXISTS wizard_name TEXT;

-- Agregar display_name
ALTER TABLE public.user_profiles 
ADD COLUMN IF NOT EXISTS display_name TEXT;

-- Agregar username
ALTER TABLE public.user_profiles 
ADD COLUMN IF NOT EXISTS username TEXT;

-- Agregar avatar_url
ALTER TABLE public.user_profiles 
ADD COLUMN IF NOT EXISTS avatar_url TEXT;

-- Agregar house_id (si no existe)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'user_profiles' 
        AND column_name = 'house_id'
    ) THEN
        ALTER TABLE public.user_profiles ADD COLUMN house_id INTEGER;
        
        -- Agregar foreign key solo si la tabla houses existe
        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'houses') THEN
            ALTER TABLE public.user_profiles 
            ADD CONSTRAINT fk_user_profiles_house 
            FOREIGN KEY (house_id) REFERENCES houses(id);
        END IF;
    END IF;
END $$;

-- Agregar updated_at
ALTER TABLE public.user_profiles 
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

SELECT '✅ Columnas agregadas/verificadas' as resultado;

-- PASO 3: Ver columnas después de agregar
-- ============================================================================
SELECT 
    '=== COLUMNAS DESPUÉS DE AGREGAR ===' as info;

SELECT 
    column_name, 
    data_type
FROM information_schema.columns 
WHERE table_schema = 'public' 
AND table_name = 'user_profiles'
ORDER BY ordinal_position;
