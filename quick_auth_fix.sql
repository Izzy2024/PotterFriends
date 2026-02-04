-- CORRECCIÓN RÁPIDA: Sincronizar roles inconsistentes
-- Detectado: profiles.role = "house_head" vs user_profiles.role = "student"

-- 1. Verificar inconsistencias actuales
SELECT 
    p.id,
    p.email,
    p.wizard_name,
    p.role as profiles_role,
    up.role as user_profiles_role,
    up.is_house_head,
    up.is_prefect
FROM profiles p
LEFT JOIN user_profiles up ON p.id = up.id
WHERE p.role != up.role
   OR (p.role = 'house_head' AND up.is_house_head = false)
   OR (p.role = 'prefect' AND up.is_prefect = false);

-- 2. Sincronizar roles: profiles -> user_profiles (profiles es la fuente de verdad para roles)
UPDATE user_profiles 
SET 
    role = profiles.role,
    is_house_head = CASE 
        WHEN profiles.role = 'house_head' THEN true 
        ELSE user_profiles.is_house_head 
    END,
    is_prefect = CASE 
        WHEN profiles.role = 'prefect' THEN true 
        ELSE user_profiles.is_prefect 
    END,
    updated_at = now()
FROM profiles 
WHERE user_profiles.id = profiles.id
    AND (user_profiles.role != profiles.role 
         OR (profiles.role = 'house_head' AND user_profiles.is_house_head = false)
         OR (profiles.role = 'prefect' AND user_profiles.is_prefect = false));

-- 3. Verificar que la sincronización fue exitosa
SELECT 
    'Sincronización completada' as status,
    count(*) as usuarios_sincronizados
FROM profiles p
JOIN user_profiles up ON p.id = up.id
WHERE p.role = up.role;

-- 4. Mostrar estado final del usuario Isaac
SELECT 
    p.wizard_name,
    p.email,
    p.role as profiles_role,
    up.role as user_profiles_role,
    up.is_house_head,
    up.is_prefect,
    p.house as profiles_house,
    up.house as user_profiles_house
FROM profiles p
LEFT JOIN user_profiles up ON p.id = up.id
WHERE p.email = 'akileskenobi@gmail.com';