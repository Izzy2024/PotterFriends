-- Add function to activate events
CREATE OR REPLACE FUNCTION public.activate_event(in_event_id uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_user uuid := auth.uid();
BEGIN
  -- Check if user is authenticated
  IF v_user IS NULL THEN
    RAISE EXCEPTION 'Debe iniciar sesión para activar eventos';
  END IF;

  -- Update the event status to active
  UPDATE public.events SET
    status = 'active'
  WHERE id = in_event_id;

  -- Check if the update affected any rows
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Evento no encontrado';
  END IF;

END;$$;

-- Grant permissions
GRANT EXECUTE ON FUNCTION public.activate_event TO authenticated;

-- Add comment
COMMENT ON FUNCTION public.activate_event IS 'Activate a draft event (make it visible on the main page)';
