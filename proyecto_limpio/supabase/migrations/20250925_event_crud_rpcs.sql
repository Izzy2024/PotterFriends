-- RPC function for creating events (admin/staff functionality)
CREATE OR REPLACE FUNCTION public.create_event(
  in_title text,
  in_slug text,
  in_description text,
  in_type text,
  in_start_at timestamptz,
  in_end_at timestamptz,
  in_reward_points int DEFAULT 0,
  in_status text DEFAULT 'draft',
  in_cover_url text DEFAULT NULL,
  in_featured boolean DEFAULT false
)
RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_user uuid := auth.uid();
  v_event_id uuid;
BEGIN
  -- Check if user is authenticated
  IF v_user IS NULL THEN
    RAISE EXCEPTION 'Debe iniciar sesión para crear eventos';
  END IF;

  -- Validate required fields
  IF in_title IS NULL OR trim(in_title) = '' THEN
    RAISE EXCEPTION 'El título del evento es obligatorio';
  END IF;

  IF in_slug IS NULL OR trim(in_slug) = '' THEN
    RAISE EXCEPTION 'El slug del evento es obligatorio';
  END IF;

  -- Check if slug is unique
  IF EXISTS (SELECT 1 FROM public.events WHERE slug = in_slug) THEN
    RAISE EXCEPTION 'Ya existe un evento con este slug';
  END IF;

  -- Validate dates
  IF in_start_at >= in_end_at THEN
    RAISE EXCEPTION 'La fecha de inicio debe ser anterior a la fecha de fin';
  END IF;

  -- Insert the event
  INSERT INTO public.events (
    title,
    slug,
    description,
    type,
    reward_points,
    status,
    start_at,
    end_at,
    cover_url,
    featured,
    created_by
  ) VALUES (
    trim(in_title),
    trim(in_slug),
    trim(in_description),
    in_type,
    in_reward_points,
    in_status,
    in_start_at,
    in_end_at,
    in_cover_url,
    in_featured,
    v_user
  ) RETURNING id INTO v_event_id;

  RETURN v_event_id;
END;$$;

-- RPC function for updating events
CREATE OR REPLACE FUNCTION public.update_event(
  in_event_id uuid,
  in_title text DEFAULT NULL,
  in_slug text DEFAULT NULL,
  in_description text DEFAULT NULL,
  in_type text DEFAULT NULL,
  in_reward_points int DEFAULT NULL,
  in_status text DEFAULT NULL,
  in_start_at timestamptz DEFAULT NULL,
  in_end_at timestamptz DEFAULT NULL,
  in_cover_url text DEFAULT NULL,
  in_featured boolean DEFAULT NULL
)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_user uuid := auth.uid();
BEGIN
  -- Check if user is authenticated
  IF v_user IS NULL THEN
    RAISE EXCEPTION 'Debe iniciar sesión para actualizar eventos';
  END IF;

  -- Check if event exists and user can modify it
  IF NOT EXISTS (
    SELECT 1 FROM public.events
    WHERE id = in_event_id
    AND (created_by = v_user OR created_by IS NULL) -- Allow modification by creator or system
  ) THEN
    RAISE EXCEPTION 'No tiene permisos para modificar este evento';
  END IF;

  -- Check slug uniqueness if being changed
  IF in_slug IS NOT NULL AND EXISTS (
    SELECT 1 FROM public.events
    WHERE slug = in_slug AND id != in_event_id
  ) THEN
    RAISE EXCEPTION 'Ya existe un evento con este slug';
  END IF;

  -- Update the event
  UPDATE public.events SET
    title = COALESCE(in_title, title),
    slug = COALESCE(in_slug, slug),
    description = COALESCE(in_description, description),
    type = COALESCE(in_type, type),
    reward_points = COALESCE(in_reward_points, reward_points),
    status = COALESCE(in_status, status),
    start_at = COALESCE(in_start_at, start_at),
    end_at = COALESCE(in_end_at, end_at),
    cover_url = COALESCE(in_cover_url, cover_url),
    featured = COALESCE(in_featured, featured)
  WHERE id = in_event_id;

END;$$;

-- RPC function for deleting events
CREATE OR REPLACE FUNCTION public.delete_event(in_event_id uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_user uuid := auth.uid();
BEGIN
  -- Check if user is authenticated
  IF v_user IS NULL THEN
    RAISE EXCEPTION 'Debe iniciar sesión para eliminar eventos';
  END IF;

  -- Check if event exists and user can delete it
  IF NOT EXISTS (
    SELECT 1 FROM public.events
    WHERE id = in_event_id
    AND (created_by = v_user OR created_by IS NULL) -- Allow deletion by creator or system
  ) THEN
    RAISE EXCEPTION 'No tiene permisos para eliminar este evento';
  END IF;

  -- Delete the event (cascade will handle related records)
  DELETE FROM public.events WHERE id = in_event_id;

END;$$;

-- Grant permissions
GRANT EXECUTE ON FUNCTION public.create_event TO authenticated;
GRANT EXECUTE ON FUNCTION public.update_event TO authenticated;
GRANT EXECUTE ON FUNCTION public.delete_event TO authenticated;

-- Add function to activate events (for admin use)
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

-- Calendar events with detailed info
CREATE OR REPLACE FUNCTION public.list_calendar_events_detailed(in_month int, in_year int)
RETURNS TABLE (
  event_date date,
  slug text,
  title text,
  type text,
  status text,
  featured boolean,
  start_at timestamptz,
  end_at timestamptz
) LANGUAGE sql SECURITY DEFINER AS $$
  with monthspan as (
    select make_timestamptz(in_year, in_month, 1, 0,0,0) as month_start
  ), span as (
    select month_start, (month_start + interval '1 month') as month_end from monthspan
  )
  select e.start_at::date as event_date, e.slug, e.title, e.type, e.status, e.featured, e.start_at, e.end_at
  from public.events e, span s
  where e.status in ('active','completed')
    and e.start_at >= s.month_start and e.start_at < s.month_end
  order by e.start_at asc;
$$;

-- Grant permissions
GRANT EXECUTE ON FUNCTION public.activate_event TO authenticated;
GRANT EXECUTE ON FUNCTION public.list_calendar_events_detailed TO authenticated;

-- Add comments
COMMENT ON FUNCTION public.activate_event IS 'Activate a draft event (make it visible on the main page)';
COMMENT ON FUNCTION public.list_calendar_events_detailed IS 'Get detailed calendar events for a specific month';</content>
<parameter name="filePath">supabase/migrations/20250925_event_crud_rpcs.sql