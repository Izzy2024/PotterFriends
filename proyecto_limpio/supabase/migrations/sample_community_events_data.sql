-- Add sample participants and house challenge progress for testing
-- Safe to run multiple times

-- First, let's insert some sample user profiles if they don't exist
-- We'll create test users with houses

DO $$
DECLARE 
    gryffindor_id INTEGER;
    ravenclaw_id INTEGER;
    hufflepuff_id INTEGER;
    slytherin_id INTEGER;
    test_event_1 UUID;
    test_event_2 UUID;
    test_event_3 UUID;
BEGIN
    -- Get house IDs
    SELECT id INTO gryffindor_id FROM public.houses WHERE name = 'Gryffindor';
    SELECT id INTO ravenclaw_id FROM public.houses WHERE name = 'Ravenclaw';
    SELECT id INTO hufflepuff_id FROM public.houses WHERE name = 'Hufflepuff';
    SELECT id INTO slytherin_id FROM public.houses WHERE name = 'Slytherin';
    
    -- Get event IDs
    SELECT id INTO test_event_1 FROM public.events WHERE slug = 'torneo-conocimiento';
    SELECT id INTO test_event_2 FROM public.events WHERE slug = 'concurso-arte-magico';
    SELECT id INTO test_event_3 FROM public.events WHERE slug = 'desafio-escritura-creativa';
    
    -- Create sample test user profiles (UUID v4 format)
    INSERT INTO public.profiles (id, username, house_id) VALUES
        ('00000000-1111-4000-8000-000000000001', 'hermione_granger', ravenclaw_id),
        ('00000000-1111-4000-8000-000000000002', 'harry_potter', gryffindor_id),
        ('00000000-1111-4000-8000-000000000003', 'luna_lovegood', ravenclaw_id),
        ('00000000-1111-4000-8000-000000000004', 'neville_longbottom', gryffindor_id),
        ('00000000-1111-4000-8000-000000000005', 'cedric_diggory', hufflepuff_id),
        ('00000000-1111-4000-8000-000000000006', 'draco_malfoy', slytherin_id)
    ON CONFLICT (id) DO NOTHING;
    
    -- Add some event participants if events exist
    IF test_event_1 IS NOT NULL THEN
        INSERT INTO public.event_participants (event_id, user_id, status) VALUES
            (test_event_1, '00000000-1111-4000-8000-000000000001', 'joined'),
            (test_event_1, '00000000-1111-4000-8000-000000000002', 'joined'),
            (test_event_1, '00000000-1111-4000-8000-000000000003', 'joined'),
            (test_event_1, '00000000-1111-4000-8000-000000000004', 'joined'),
            (test_event_1, '00000000-1111-4000-8000-000000000005', 'joined')
        ON CONFLICT (event_id, user_id) DO NOTHING;
    END IF;
    
    IF test_event_2 IS NOT NULL THEN
        INSERT INTO public.event_participants (event_id, user_id, status) VALUES
            (test_event_2, '00000000-1111-4000-8000-000000000001', 'joined'),
            (test_event_2, '00000000-1111-4000-8000-000000000003', 'joined'),
            (test_event_2, '00000000-1111-4000-8000-000000000005', 'joined'),
            (test_event_2, '00000000-1111-4000-8000-000000000006', 'joined')
        ON CONFLICT (event_id, user_id) DO NOTHING;
    END IF;
    
    IF test_event_3 IS NOT NULL THEN
        INSERT INTO public.event_participants (event_id, user_id, status) VALUES
            (test_event_3, '00000000-1111-4000-8000-000000000002', 'joined'),
            (test_event_3, '00000000-1111-4000-8000-000000000004', 'joined'),
            (test_event_3, '00000000-1111-4000-8000-000000000005', 'joined'),
            (test_event_3, '00000000-1111-4000-8000-000000000006', 'joined')
        ON CONFLICT (event_id, user_id) DO NOTHING;
    END IF;
    
    -- Update house challenge progress with realistic numbers
    UPDATE public.house_challenge_progress 
    SET progress_count = CASE 
        WHEN house_id = gryffindor_id AND challenge_id = (SELECT id FROM public.challenges WHERE slug = 'coraje-colectivo') THEN 73
        WHEN house_id = ravenclaw_id AND challenge_id = (SELECT id FROM public.challenges WHERE slug = 'sabiduria-ancestral') THEN 43
        WHEN house_id = hufflepuff_id AND challenge_id = (SELECT id FROM public.challenges WHERE slug = 'lealtad-inquebrantable') THEN 182
        ELSE progress_count
    END,
    updated_at = now()
    WHERE EXISTS (SELECT 1 FROM public.challenges WHERE id = challenge_id AND scope = 'house');
    
    -- Add some completed individual challenge attempts for statistics
    INSERT INTO public.challenge_attempts (challenge_id, user_id, house_id, status, completed_at) 
    SELECT c.id, p.id, p.house_id, 'completed', now() - interval '1 day'
    FROM public.challenges c, public.profiles p
    WHERE c.scope = 'individual' 
      AND c.slug IN ('maestro-de-pociones', 'experto-en-criaturas', 'historiador-magico')
      AND p.username IN ('hermione_granger', 'luna_lovegood', 'cedric_diggory')
      AND NOT EXISTS (
          SELECT 1 FROM public.challenge_attempts ca 
          WHERE ca.challenge_id = c.id AND ca.user_id = p.id
      );
    
    -- Add some votes to active poll for realistic percentages
    INSERT INTO public.votes (poll_id, user_id, option_id)
    SELECT p.id, prof.id, po.id
    FROM public.polls p, public.profiles prof, public.poll_options po
    WHERE p.slug = 'poll-arte-actual' 
      AND po.poll_id = p.id
      AND NOT EXISTS (SELECT 1 FROM public.votes v WHERE v.poll_id = p.id AND v.user_id = prof.id)
      AND (
          (prof.username = 'hermione_granger' AND po.label = 'Hogwarts al Atardecer') OR
          (prof.username = 'harry_potter' AND po.label = 'El Bosque Prohibido') OR
          (prof.username = 'luna_lovegood' AND po.label = 'Hogwarts al Atardecer') OR
          (prof.username = 'neville_longbottom' AND po.label = 'Quidditch en Acción') OR
          (prof.username = 'cedric_diggory' AND po.label = 'Hogwarts al Atardecer') OR
          (prof.username = 'draco_malfoy' AND po.label = 'El Bosque Prohibido')
      )
    LIMIT 6;
    
    RAISE NOTICE 'Sample data for community events created successfully!';
END $$;