-- ADVERTENCIA: Este script eliminará y recreará la tabla houses
-- Solo úsalo si no tienes datos importantes en la tabla houses actual

-- 1. Eliminar la tabla houses existente si existe
DROP TABLE IF EXISTS houses CASCADE;

-- 2. Recrear houses con id INTEGER (SERIAL)
CREATE TABLE houses (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    color VARCHAR(7) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Insertar las casas por defecto
INSERT INTO houses (name, color) VALUES 
    ('Gryffindor', '#D32F2F'),
    ('Slytherin', '#388E3C'),
    ('Ravenclaw', '#1976D2'),
    ('Hufflepuff', '#FBC02D');

-- 4. Ahora ejecuta el resto del script 002_create_forum_tables_fixed.sql
-- (Las tablas del foro)
