-- Arreglar políticas de seguridad para achievement_types
-- Permitir que los administradores y usuarios autenticados puedan insertar tipos de logros (para testing)

-- Primero, eliminar políticas existentes que puedan estar causando conflicto
DROP POLICY IF EXISTS "Anyone can view achievement types" ON achievement_types;
DROP POLICY IF EXISTS "Admins can insert achievement types" ON achievement_types;
DROP POLICY IF EXISTS "Admins can update achievement types" ON achievement_types;
DROP POLICY IF EXISTS "Admins can delete achievement types" ON achievement_types;

-- Crear políticas nuevas más permisivas
-- Todos pueden ver los tipos de logros
CREATE POLICY "Anyone can view achievement types" 
    ON achievement_types FOR SELECT 
    USING (true);

-- Solo administradores o house heads pueden insertar nuevos tipos
-- Para desarrollo, temporalmente permitir a todos los usuarios autenticados
CREATE POLICY "Authenticated users can insert achievement types" 
    ON achievement_types FOR INSERT 
    WITH CHECK (
        auth.uid() IS NOT NULL
        -- En producción, cambiar a:
        -- EXISTS (
        --     SELECT 1 FROM user_profiles 
        --     WHERE id = auth.uid() 
        --     AND (role = 'admin' OR role = 'house_head' OR is_house_head = true)
        -- )
    );

-- Solo administradores pueden actualizar
CREATE POLICY "Admins can update achievement types" 
    ON achievement_types FOR UPDATE 
    USING (
        EXISTS (
            SELECT 1 FROM user_profiles 
            WHERE id = auth.uid() 
            AND role = 'admin'
        )
    );

-- Solo administradores pueden eliminar
CREATE POLICY "Admins can delete achievement types" 
    ON achievement_types FOR DELETE 
    USING (
        EXISTS (
            SELECT 1 FROM user_profiles 
            WHERE id = auth.uid() 
            AND role = 'admin'
        )
    );

-- Mensaje de confirmación
SELECT 'Políticas de achievement_types actualizadas para permitir testing' as message;
