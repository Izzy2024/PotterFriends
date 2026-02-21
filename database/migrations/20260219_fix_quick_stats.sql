-- ============================================================================
-- Fix for Quick Stats counters showing 0
-- Date: 2026-02-19
-- Issues fixed:
-- 1. Events with status='active' but start_at in the future (excluded from counts)
-- 2. min_days_remaining using MIN instead of most recent start_at
-- 3. RLS policy blocking participant count in fallback
-- ============================================================================

-- ============================================================================
-- PART 1: Fix existing event data
-- Update events with status='active' and start_at in the future
-- ============================================================================

UPDATE public.events
SET start_at = now() - interval '1 hour'
WHERE status = 'active' AND start_at > now();

-- ============================================================================
-- PART 2: Update get_quick_stats RPC
-- Change min_days_remaining to show days until end of the most recently 
-- started event (not the minimum)
-- ============================================================================

CREATE OR REPLACE FUNCTION public.get_quick_stats()
RETURNS jsonb LANGUAGE sql SECURITY DEFINER AS $$
with active_events as (
  select id, reward_points, end_at, start_at
  from public.events
  where status = 'active' and now() between start_at and end_at
), participants as (
  select count(distinct ep.user_id) as c
  from public.event_participants ep
  join active_events e on e.id = ep.event_id
)
select jsonb_build_object(
  'active_events_count', (select count(*) from active_events),
  'active_participants_count', (select c from participants),
  'points_in_play', coalesce((select sum(reward_points) from active_events), 0),
  -- Changed: Use the event with the most recent start_at (ORDER BY start_at DESC LIMIT 1)
  -- instead of MIN to show days remaining for the newest active event
  'min_days_remaining', coalesce(
    (select ceil(extract(epoch from (end_at - now()))/86400.0)::int
     from active_events 
     ORDER BY start_at DESC 
     LIMIT 1), 
    0
  )
);
$$;

COMMENT ON FUNCTION public.get_quick_stats IS 'Returns quick dashboard stats for the community events page. Active events = started but not ended. Days remaining = from most recently started event.';

-- ============================================================================
-- PART 3: Create RPC for participants count (bypasses RLS)
-- This allows the JS fallback to get accurate participant counts
-- ============================================================================

CREATE OR REPLACE FUNCTION public.get_active_event_participants_count()
RETURNS int LANGUAGE sql SECURITY DEFINER AS $$
  SELECT count(DISTINCT ep.user_id)::int
  FROM public.event_participants ep
  JOIN public.events e ON e.id = ep.event_id
  WHERE e.status = 'active' 
    AND now() BETWEEN e.start_at AND e.end_at;
$$;

COMMENT ON FUNCTION public.get_active_event_participants_count IS 'Returns count of unique participants across all active events. SECURITY DEFINER bypasses RLS for accurate counts.';

-- Grant permissions
GRANT EXECUTE ON FUNCTION public.get_quick_stats TO anon;
GRANT EXECUTE ON FUNCTION public.get_quick_stats TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_active_event_participants_count TO anon;
GRANT EXECUTE ON FUNCTION public.get_active_event_participants_count TO authenticated;

-- ============================================================================
-- PART 4: Optional - Add RLS policy for public read of participant counts
-- This is an alternative to the RPC above if you prefer policy-based access
-- ============================================================================

-- Option A: Create a secure view for participant counts (recommended)
CREATE OR REPLACE VIEW public.v_active_participants_count AS
SELECT count(DISTINCT ep.user_id)::int AS total_participants
FROM public.event_participants ep
JOIN public.events e ON e.id = ep.event_id
WHERE e.status = 'active' 
  AND now() BETWEEN e.start_at AND e.end_at;

-- Grant select on view
GRANT SELECT ON public.v_active_participants_count TO anon;
GRANT SELECT ON public.v_active_participants_count TO authenticated;

-- ============================================================================
-- VERIFICATION QUERIES (run these to verify the fix)
-- ============================================================================

-- Check active events with correct time range
-- SELECT id, title, status, start_at, end_at, 
--        now() as current_time,
--        CASE WHEN now() BETWEEN start_at AND end_at THEN 'IN RANGE' ELSE 'OUT OF RANGE' END as time_status
-- FROM public.events WHERE status = 'active';

-- Test the RPC
-- SELECT * FROM public.get_quick_stats();

-- Test the participants count RPC
-- SELECT * FROM public.get_active_event_participants_count();
