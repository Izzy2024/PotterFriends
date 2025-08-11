-- ARREGLAR FUNCIONES EXISTENTES EN SUPABASE
-- Ejecuta este código PRIMERO para limpiar funciones conflictivas

-- Eliminar funciones existentes que pueden causar conflicto
DROP FUNCTION IF EXISTS assign_achievement_to_user(uuid,integer,text);
DROP FUNCTION IF EXISTS assign_achievement_to_user(uuid,integer);
DROP FUNCTION IF EXISTS check_and_award_achievements(uuid);
DROP FUNCTION IF EXISTS update_user_stat(uuid,text,integer);
DROP FUNCTION IF EXISTS update_user_stat(uuid,text);

-- Mensaje de confirmación
SELECT 'Funciones conflictivas eliminadas. Ahora ejecuta el archivo principal.' as message;