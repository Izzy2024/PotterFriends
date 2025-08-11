-- ARREGLAR RESTRICCIÓN UNIQUE EN ACHIEVEMENT_TYPES
-- Ejecuta este código para agregar la restricción faltante

-- Agregar restricción UNIQUE a la columna name si no existe
ALTER TABLE achievement_types 
ADD CONSTRAINT achievement_types_name_unique UNIQUE (name);

-- Verificar que la restricción se creó correctamente
SELECT constraint_name, constraint_type 
FROM information_schema.table_constraints 
WHERE table_name = 'achievement_types' 
AND constraint_type = 'UNIQUE';

-- Mensaje de confirmación
SELECT 'Restricción UNIQUE agregada correctamente. Ahora puedes insertar los logros.' as message;