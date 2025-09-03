-- Fix materialized view and refresh it
-- This file should be run after the main migrations to ensure data consistency

-- Drop and recreate the materialized view with proper refresh
DROP MATERIALIZED VIEW IF EXISTS public.v_event_participants_counts;

CREATE MATERIALIZED VIEW public.v_event_participants_counts AS
SELECT 
    event_id, 
    count(DISTINCT user_id) as participants_count
FROM public.event_participants
GROUP BY event_id;

-- Create unique index for faster refreshes
CREATE UNIQUE INDEX IF NOT EXISTS idx_v_event_participants_counts_event_id 
ON public.v_event_participants_counts (event_id);

-- Refresh the view with current data
REFRESH MATERIALIZED VIEW public.v_event_participants_counts;

-- Grant permissions
GRANT SELECT ON public.v_event_participants_counts TO anon, authenticated;

-- Also let's fix the list_featured_events function to handle missing view gracefully
CREATE OR REPLACE FUNCTION public.list_featured_events(in_limit int default 6)
RETURNS TABLE (
  slug text,
  title text,
  description text,
  cover_url text,
  type text,
  reward_points int,
  start_at timestamptz,
  end_at timestamptz,
  participants_count bigint,
  ends_in_days int
) LANGUAGE sql SECURITY DEFINER AS $$
  WITH base AS (
    SELECT e.*,
      COALESCE(
        (SELECT count(DISTINCT ep.user_id) 
         FROM public.event_participants ep 
         WHERE ep.event_id = e.id), 0
      ) as participants_count
    FROM public.events e
    WHERE e.featured = true AND e.status IN ('active','completed')
    ORDER BY 
      CASE WHEN e.status='active' THEN 0 ELSE 1 END, 
      e.end_at ASC
    LIMIT COALESCE(in_limit,6)
  )
  SELECT 
    b.slug, 
    b.title, 
    b.description, 
    b.cover_url, 
    b.type, 
    b.reward_points, 
    b.start_at, 
    b.end_at,
    b.participants_count,
    GREATEST(0, CEIL(EXTRACT(EPOCH FROM (b.end_at - now()))/86400.0)::int) as ends_in_days
  FROM base b;
$$;

-- Ensure we have proper RLS policies for the materialized view
DROP POLICY IF EXISTS v_event_participants_counts_read ON public.v_event_participants_counts;
CREATE POLICY v_event_participants_counts_read ON public.v_event_participants_counts FOR SELECT USING (true);

COMMENT ON FUNCTION public.list_featured_events IS 'Returns featured events with participant counts and days remaining';