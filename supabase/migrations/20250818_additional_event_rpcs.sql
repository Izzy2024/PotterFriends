-- Additional RPC functions for enhanced community events functionality

-- Function to get events for a specific event_id (for event detail page)
CREATE OR REPLACE FUNCTION public.get_event_by_slug(in_slug text)
RETURNS TABLE (
  id uuid,
  slug text,
  title text,
  description text,
  type text,
  featured boolean,
  cover_url text,
  reward_points int,
  start_at timestamptz,
  end_at timestamptz,
  status text,
  created_by uuid,
  created_at timestamptz,
  metadata jsonb,
  participants_count bigint,
  submissions_count bigint
) LANGUAGE sql SECURITY DEFINER AS $$
  SELECT 
    e.id,
    e.slug,
    e.title,
    e.description,
    e.type,
    e.featured,
    e.cover_url,
    e.reward_points,
    e.start_at,
    e.end_at,
    e.status,
    e.created_by,
    e.created_at,
    e.metadata,
    COALESCE((SELECT count(DISTINCT ep.user_id) FROM public.event_participants ep WHERE ep.event_id = e.id), 0) as participants_count,
    COALESCE((SELECT count(DISTINCT ep.user_id) FROM public.event_participants ep WHERE ep.event_id = e.id AND ep.submission_url IS NOT NULL), 0) as submissions_count
  FROM public.events e
  WHERE e.slug = in_slug;
$$;

-- Function to get participants for an event
CREATE OR REPLACE FUNCTION public.get_event_participants(in_event_slug text)
RETURNS TABLE (
  user_id uuid,
  username text,
  house_name text,
  status text,
  submission_url text,
  points_awarded int,
  joined_at timestamptz
) LANGUAGE sql SECURITY DEFINER AS $$
  SELECT 
    ep.user_id,
    COALESCE(p.username, 'Usuario ' || SUBSTR(ep.user_id::text, -4)) as username,
    h.name as house_name,
    ep.status,
    ep.submission_url,
    ep.points_awarded,
    ep.joined_at
  FROM public.event_participants ep
  JOIN public.events e ON e.id = ep.event_id
  LEFT JOIN public.profiles p ON p.id = ep.user_id
  LEFT JOIN public.houses h ON h.id = p.house_id
  WHERE e.slug = in_event_slug
  ORDER BY ep.joined_at ASC;
$$;

-- Function to check user participation in an event
CREATE OR REPLACE FUNCTION public.get_user_participation(in_event_slug text)
RETURNS TABLE (
  status text,
  submission_url text,
  points_awarded int,
  joined_at timestamptz
) LANGUAGE sql SECURITY DEFINER AS $$
  SELECT 
    ep.status,
    ep.submission_url,
    ep.points_awarded,
    ep.joined_at
  FROM public.event_participants ep
  JOIN public.events e ON e.id = ep.event_id
  WHERE e.slug = in_event_slug 
    AND ep.user_id = auth.uid();
$$;

-- Function to submit work for an event
CREATE OR REPLACE FUNCTION public.submit_event_work(in_event_slug text, in_submission_url text, in_description text DEFAULT NULL)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE 
  v_event_id uuid; 
  v_user uuid := auth.uid();
BEGIN
  IF v_user IS NULL THEN 
    RAISE EXCEPTION 'Debe iniciar sesión para enviar trabajo';
  END IF;
  
  SELECT id INTO v_event_id FROM public.events 
    WHERE slug = in_event_slug AND status = 'active' AND now() BETWEEN start_at AND end_at;
    
  IF v_event_id IS NULL THEN 
    RAISE EXCEPTION 'Evento no disponible para envíos';
  END IF;
  
  -- Update existing participation
  UPDATE public.event_participants 
  SET 
    status = 'submitted',
    submission_url = in_submission_url,
    metadata = CASE 
      WHEN in_description IS NOT NULL THEN jsonb_build_object('description', in_description)
      ELSE metadata
    END
  WHERE event_id = v_event_id AND user_id = v_user;
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Debe unirse al evento antes de enviar trabajo';
  END IF;
END;$$;

-- Function to get recent events for admin dashboard
CREATE OR REPLACE FUNCTION public.get_admin_events_stats()
RETURNS jsonb LANGUAGE sql SECURITY DEFINER AS $$
  WITH stats AS (
    SELECT 
      COUNT(*) FILTER (WHERE status = 'active') as active_events,
      COUNT(*) FILTER (WHERE created_at >= date_trunc('month', now())) as monthly_events,
      COALESCE(SUM(
        (SELECT count(DISTINCT user_id) FROM public.event_participants ep WHERE ep.event_id = e.id)
      ), 0) as total_participants
    FROM public.events e
  )
  SELECT jsonb_build_object(
    'active_events', active_events,
    'monthly_events', monthly_events,
    'total_participants', total_participants
  ) FROM stats;
$$;

-- Improved calendar function with event details
CREATE OR REPLACE FUNCTION public.list_calendar_events_detailed(in_month int, in_year int)
RETURNS TABLE (
  event_date date,
  slug text,
  title text,
  type text,
  status text,
  time_info text
) LANGUAGE sql SECURITY DEFINER AS $$
  WITH monthspan AS (
    SELECT make_timestamptz(in_year, in_month, 1, 0,0,0) as month_start
  ), span AS (
    SELECT month_start, (month_start + interval '1 month') as month_end FROM monthspan
  )
  SELECT 
    e.start_at::date as event_date, 
    e.slug, 
    e.title, 
    e.type,
    e.status,
    to_char(e.start_at, 'HH24:MI') as time_info
  FROM public.events e, span s
  WHERE e.status IN ('active','completed')
    AND e.start_at >= s.month_start 
    AND e.start_at < s.month_end
  ORDER BY e.start_at ASC;
$$;

-- Grant permissions
GRANT EXECUTE ON FUNCTION public.get_event_by_slug TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_event_participants TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_user_participation TO authenticated;
GRANT EXECUTE ON FUNCTION public.submit_event_work TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_admin_events_stats TO authenticated;
GRANT EXECUTE ON FUNCTION public.list_calendar_events_detailed TO anon, authenticated;

-- Add comments
COMMENT ON FUNCTION public.get_event_by_slug IS 'Get detailed event information by slug';
COMMENT ON FUNCTION public.get_event_participants IS 'Get all participants for an event';
COMMENT ON FUNCTION public.get_user_participation IS 'Get current user participation status for an event';
COMMENT ON FUNCTION public.submit_event_work IS 'Submit work/evidence for an event';
COMMENT ON FUNCTION public.get_admin_events_stats IS 'Get statistics for admin dashboard';
COMMENT ON FUNCTION public.list_calendar_events_detailed IS 'Get detailed calendar events for a specific month';