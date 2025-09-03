-- Script para insertar datos de prueba en el dashboard
-- Se ejecuta a través del debug-dashboard.html o directamente en Supabase

-- 1. Insertar datos de prueba en house_points_ledger
INSERT INTO public.house_points_ledger (house_id, points, source, note) VALUES
    (1, 150, 'event', 'Participación en Torneo de Quidditch'),
    (1, 75, 'challenge', 'Completó el Desafío de Pociones'),
    (1, 50, 'vote', 'Contribución destacada en el foro'),
    (1, 100, 'manual', 'Actividad excepcional en debates'),
    
    (2, 120, 'event', 'Victoria en Duelo de Hechizos'),
    (2, 85, 'challenge', 'Desafío de Artes Oscuras completado'),
    (2, 60, 'vote', 'Participación en votaciones'),
    (2, 90, 'manual', 'Excelente participación en foro'),
    
    (3, 140, 'event', 'Ganador del Concurso de Conocimiento'),
    (3, 70, 'challenge', 'Enigmas de Ravenclaw resueltos'),
    (3, 45, 'vote', 'Votaciones activas'),
    (3, 80, 'manual', 'Debates intelectuales'),
    
    (4, 110, 'event', 'Competencia de Herbología'),
    (4, 65, 'challenge', 'Desafío de Lealtad completado'),
    (4, 55, 'vote', 'Participación comunitaria'),
    (4, 95, 'manual', 'Apoyo constante en foro')
ON CONFLICT DO NOTHING;

-- 2. Insertar eventos de prueba
INSERT INTO public.events (title, description, type, status, start_at, end_at, reward_points) VALUES
    ('Torneo de Quidditch 2025', 'El torneo anual entre las casas de Hogwarts', 'tournament', 'active', 
     NOW() + INTERVAL '7 days', NOW() + INTERVAL '14 days', 200),
    ('Concurso de Pociones', 'Demuestra tus habilidades en la preparación de pociones mágicas', 'contest', 'active',
     NOW() + INTERVAL '3 days', NOW() + INTERVAL '10 days', 150),
    ('Celebración del Día del Fundador', 'Festividad especial en honor a los fundadores', 'celebration', 'active',
     NOW() + INTERVAL '5 days', NOW() + INTERVAL '6 days', 100)
ON CONFLICT (title) DO NOTHING;

-- 3. Crear algunos posts de ejemplo para el foro (si la estructura lo permite)
-- Nota: Esto requiere que existan categorías y usuarios

-- 4. Verificar que los datos se insertaron correctamente
SELECT 'house_points_ledger' as tabla, COUNT(*) as registros FROM public.house_points_ledger
UNION ALL
SELECT 'events' as tabla, COUNT(*) as registros FROM public.events
UNION ALL  
SELECT 'houses' as tabla, COUNT(*) as registros FROM public.houses;

-- 5. Mostrar el leaderboard resultante
SELECT h.name, SUM(COALESCE(hpl.points, 0)) as total_points
FROM public.houses h
LEFT JOIN public.house_points_ledger hpl ON h.id = hpl.house_id
GROUP BY h.id, h.name
ORDER BY total_points DESC;