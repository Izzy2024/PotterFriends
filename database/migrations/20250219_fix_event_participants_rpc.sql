-- Fix get_event_participants function to use correct table (user_profiles instead of profiles)
-- The original function referenced public.profiles which doesn't exist
-- The correct table is public.user_profiles with display_name and house (varchar) fields

-- Drop and recreate the function with correct table references
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
    COALESCE(up.display_name, 'Usuario ' || SUBSTR(ep.user_id::text, 1, 8)) as username,
    COALESCE(up.house, 'sin casa') as house_name,
    ep.status,
    ep.submission_url,
    ep.points_awarded,
    ep.joined_at
  FROM public.event_participants ep
  JOIN public.events e ON e.id = ep.event_id
  LEFT JOIN public.user_profiles up ON up.id = ep.user_id
  WHERE e.slug = in_event_slug
  ORDER BY ep.joined_at ASC;
$$;

-- Ensure permissions are granted
GRANT EXECUTE ON FUNCTION public.get_event_participants TO anon, authenticated;

-- Add comment
COMMENT ON FUNCTION public.get_event_participants IS 'Get all participants for an event - Fixed to use user_profiles table';
