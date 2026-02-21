-- Allow joining active events before they start
-- The original join_event only allowed joining between start_at and end_at

CREATE OR REPLACE FUNCTION public.join_event(in_slug text)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE v_event_id uuid; v_user uuid := auth.uid();
BEGIN
  IF v_user IS NULL THEN
    RAISE EXCEPTION 'Debe iniciar sesión para participar';
  END IF;

  SELECT id INTO v_event_id
  FROM public.events
  WHERE slug = in_slug
    AND status = 'active'
    AND now() <= end_at;

  IF v_event_id IS NULL THEN
    RAISE EXCEPTION 'Evento no disponible';
  END IF;

  INSERT INTO public.event_participants(event_id, user_id, status)
  VALUES (v_event_id, v_user, 'joined')
  ON CONFLICT (event_id, user_id) DO NOTHING;
END;$$;

GRANT EXECUTE ON FUNCTION public.join_event TO authenticated;
COMMENT ON FUNCTION public.join_event IS 'Join event (allows joining before start, until end)';
