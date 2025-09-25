-- Seed data for Community Events and Challenges
-- Safe to run multiple times (uses upserts on unique slugs)

-- 1) Featured/Active events
insert into public.events (slug, title, description, type, featured, cover_url, reward_points, start_at, end_at, status, metadata)
values
  ('torneo-conocimiento', 'Gran Torneo de Conocimiento Mágico', 'Preguntas de historia, hechizos y criaturas.', 'tournament', true,
   'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?q=80&w=1200&auto=format', 500,
   now() - interval '1 day', now() + interval '5 days', 'active', jsonb_build_object('tag','TORNEO INTELECTUAL')),
  ('concurso-arte-magico', 'Concurso de Arte Mágico', 'Ilustraciones y pinturas inspiradas en el mundo mágico.', 'contest', true,
   'https://images.unsplash.com/photo-1513475382585-d06e58bcb0e0?q=80&w=1200&auto=format', 300,
   now() - interval '2 days', now() + interval '12 days', 'active', jsonb_build_object('tag','CONCURSO ARTÍSTICO')),
  ('desafio-escritura-creativa', 'Desafío de Escritura Creativa', 'Historias originales. Tema: Aventuras en Hogwarts durante las vacaciones.', 'contest', true,
   'https://images.pexels.com/photos/261763/pexels-photo-261763.jpeg?auto=compress&cs=tinysrgb&w=1200', 400,
   now() - interval '1 day', now() + interval '8 days', 'active', jsonb_build_object('tag','ESCRITURA'))
ON CONFLICT (slug) DO UPDATE SET
  title=excluded.title,
  description=excluded.description,
  type=excluded.type,
  featured=excluded.featured,
  cover_url=excluded.cover_url,
  reward_points=excluded.reward_points,
  start_at=excluded.start_at,
  end_at=excluded.end_at,
  status=excluded.status,
  metadata=excluded.metadata;

-- 2) Completed past events
insert into public.events (slug, title, description, type, featured, cover_url, reward_points, start_at, end_at, status, metadata)
values
  ('torneo-primavera-2025', 'Torneo de Primavera 2025', 'Inicio del año con múltiples categorías.', 'tournament', false,
   'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=1200&auto=format', 500,
   now() - interval '60 days', now() - interval '55 days', 'completed', jsonb_build_object('winner_house','Ravenclaw')),
  ('festival-arte-magico-2025', 'Festival de Arte Mágico', 'Celebración de la creatividad.', 'celebration', false,
   'https://images.pexels.com/photos/1029141/pexels-photo-1029141.jpeg?auto=compress&cs=tinysrgb&w=1200', 0,
   now() - interval '45 days', now() - interval '40 days', 'completed', jsonb_build_object('winner_house','Hufflepuff')),
  ('maraton-escritura-2025', 'Maratón de Escritura', '48 horas de escritura continua.', 'contest', false,
   'https://images.unsplash.com/photo-1455390582262-044cdead277a?q=80&w=1200&auto=format', 400,
   now() - interval '30 days', now() - interval '29 days', 'completed', jsonb_build_object('winner_house','Gryffindor'))
ON CONFLICT (slug) DO UPDATE SET
  title=excluded.title,
  description=excluded.description,
  type=excluded.type,
  featured=excluded.featured,
  cover_url=excluded.cover_url,
  reward_points=excluded.reward_points,
  start_at=excluded.start_at,
  end_at=excluded.end_at,
  status=excluded.status,
  metadata=excluded.metadata;

-- 3) Individual challenges
insert into public.challenges (slug, title, description, scope, reward_points, start_at, end_at, status)
values
  ('maestro-de-pociones', 'Maestro de Pociones', 'Identifica 20 pociones y sus efectos', 'individual', 150, now() - interval '1 day', now() + interval '20 days', 'active'),
  ('experto-en-criaturas', 'Experto en Criaturas', 'Clasifica 30 criaturas por peligrosidad', 'individual', 200, now() - interval '1 day', now() + interval '20 days', 'active'),
  ('historiador-magico', 'Historiador Mágico', 'Responde preguntas de historia de Hogwarts', 'individual', 250, now() - interval '1 day', now() + interval '20 days', 'active')
ON CONFLICT (slug) DO UPDATE SET
  title=excluded.title,
  description=excluded.description,
  scope=excluded.scope,
  reward_points=excluded.reward_points,
  start_at=excluded.start_at,
  end_at=excluded.end_at,
  status=excluded.status;

-- 4) House challenges (with target and initial zero progress)
insert into public.challenges (slug, title, description, scope, reward_points, target_count, start_at, end_at, status)
values
  ('coraje-colectivo', 'Coraje Colectivo', 'Completar 100 actos de valentía', 'house', 500, 100, now() - interval '1 day', now() + interval '20 days', 'active'),
  ('sabiduria-ancestral', 'Sabiduría Ancestral', 'Resolver 50 acertijos complejos', 'house', 500, 50, now() - interval '1 day', now() + interval '20 days', 'active'),
  ('lealtad-inquebrantable', 'Lealtad Inquebrantable', 'Ayudar a 200 miembros nuevos', 'house', 500, 200, now() - interval '1 day', now() + interval '20 days', 'active')
ON CONFLICT (slug) DO UPDATE SET
  title=excluded.title,
  description=excluded.description,
  scope=excluded.scope,
  reward_points=excluded.reward_points,
  target_count=excluded.target_count,
  start_at=excluded.start_at,
  end_at=excluded.end_at,
  status=excluded.status;

-- Ensure house progress rows exist (0) for each house challenge
DO $$
DECLARE ch_id uuid; h_id integer;
BEGIN
  FOR ch_id IN (
    SELECT id FROM public.challenges WHERE scope='house' AND status='active'
  ) LOOP
    FOR h_id IN (SELECT id FROM public.houses) LOOP
      INSERT INTO public.house_challenge_progress(challenge_id, house_id, progress_count)
      VALUES (ch_id, h_id, 0)
      ON CONFLICT (challenge_id, house_id) DO NOTHING;
    END LOOP;
  END LOOP;
END $$;

-- 5) Active poll with options
insert into public.polls (slug, title, description, start_at, end_at, status)
values ('poll-arte-actual', 'Votación: Concurso de Arte Mágico', 'Elige tu obra favorita', now() - interval '1 day', now() + interval '3 days', 'active')
ON CONFLICT (slug) DO UPDATE SET
  title=excluded.title,
  description=excluded.description,
  start_at=excluded.start_at,
  end_at=excluded.end_at,
  status=excluded.status;

-- Options for active poll
DO $$
DECLARE p_id uuid;
BEGIN
  SELECT id INTO p_id FROM public.polls WHERE slug='poll-arte-actual';
  IF p_id IS NOT NULL THEN
    -- Insert options if none exist
    IF NOT EXISTS (SELECT 1 FROM public.poll_options WHERE poll_id=p_id) THEN
      INSERT INTO public.poll_options (poll_id, label, author, media_url, sort_order) VALUES
        (p_id, 'El Bosque Prohibido', 'María González', NULL, 1),
        (p_id, 'Quidditch en Acción', 'Carlos Mendoza', NULL, 2),
        (p_id, 'Hogwarts al Atardecer', 'Ana Rodríguez', NULL, 3);
    END IF;
  END IF;
END $$;

-- 6) Completed poll (for recent results)
insert into public.polls (slug, title, description, start_at, end_at, status)
values ('poll-arte-pasado', 'Resultados: Concurso de Arte (Mes pasado)', 'Ganadores de la edición pasada', now() - interval '35 days', now() - interval '32 days', 'completed')
ON CONFLICT (slug) DO UPDATE SET
  title=excluded.title,
  description=excluded.description,
  start_at=excluded.start_at,
  end_at=excluded.end_at,
  status=excluded.status;

-- Options for completed poll (no votes seeded here)
DO $$
DECLARE p2 uuid;
BEGIN
  SELECT id INTO p2 FROM public.polls WHERE slug='poll-arte-pasado';
  IF p2 IS NOT NULL THEN
    IF NOT EXISTS (SELECT 1 FROM public.poll_options WHERE poll_id=p2) THEN
      INSERT INTO public.poll_options (poll_id, label, author, media_url, sort_order) VALUES
        (p2, 'Patronus Luminoso', 'Diego Morales', NULL, 1),
        (p2, 'Sala Común de Gryffindor', 'Laura Vega', NULL, 2),
        (p2, 'Expreso de Hogwarts', 'Roberto Silva', NULL, 3);
    END IF;
  END IF;
END $$;

