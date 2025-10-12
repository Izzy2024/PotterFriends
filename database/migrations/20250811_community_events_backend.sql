-- Supabase migration: Community Events and Challenges backend schema
-- NOTE: Review and adapt to your project (schemas, extensions, roles). Run with supabase CLI or in SQL editor.

-- Enable required extension
create extension if not exists pgcrypto;

-- Houses
-- Nota: Ya existe una tabla houses en tu proyecto (id SERIAL, name, color, ...).
-- No la recreamos aquí. Usaremos la existente con su PK: houses.id (INTEGER).

-- Profiles (if not existing; adjust if you already have one)
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique,
  house_id integer references public.houses(id),
  avatar_url text,
  created_at timestamptz default now()
);

-- Events
create table if not exists public.events (
  id uuid primary key default gen_random_uuid(),
  slug text unique not null,
  title text not null,
  description text,
  type text not null check (type in ('tournament','contest','celebration')),
  featured boolean default false,
  cover_url text,
  reward_points int default 0,
  start_at timestamptz not null,
  end_at timestamptz not null,
  status text default 'draft' check (status in ('draft','active','completed','cancelled')),
  created_by uuid references public.profiles(id),
  created_at timestamptz default now(),
  metadata jsonb
);
create index if not exists idx_events_status on public.events(status);
create index if not exists idx_events_featured on public.events(featured);
create index if not exists idx_events_dates on public.events(start_at, end_at);

-- Event participants
create table if not exists public.event_participants (
  event_id uuid references public.events(id) on delete cascade,
  user_id uuid references public.profiles(id) on delete cascade,
  status text default 'joined' check (status in ('joined','submitted','disqualified','winner')),
  submission_url text,
  points_awarded int default 0,
  joined_at timestamptz default now(),
  primary key(event_id, user_id)
);
create index if not exists idx_event_participants_user on public.event_participants(user_id);
create index if not exists idx_event_participants_status on public.event_participants(status);

-- Challenges
create table if not exists public.challenges (
  id uuid primary key default gen_random_uuid(),
  slug text unique not null,
  title text not null,
  description text,
  scope text not null check (scope in ('individual','house')),
  reward_points int not null,
  target_count int,
  start_at timestamptz not null,
  end_at timestamptz not null,
  status text default 'draft' check (status in ('draft','active','completed','cancelled')),
  created_by uuid references public.profiles(id),
  metadata jsonb
);
create index if not exists idx_challenges_scope on public.challenges(scope);
create index if not exists idx_challenges_status on public.challenges(status);
create index if not exists idx_challenges_dates on public.challenges(start_at, end_at);

-- Challenge attempts
create table if not exists public.challenge_attempts (
  id uuid primary key default gen_random_uuid(),
  challenge_id uuid references public.challenges(id) on delete cascade,
  user_id uuid references public.profiles(id) on delete cascade,
  house_id integer references public.houses(id),
  status text default 'in_progress' check (status in ('in_progress','completed','rejected')),
  score int,
  evidence_url text,
  created_at timestamptz default now(),
  completed_at timestamptz
);
create index if not exists idx_attempts_challenge on public.challenge_attempts(challenge_id);
create index if not exists idx_attempts_user on public.challenge_attempts(user_id);
create index if not exists idx_attempts_house on public.challenge_attempts(house_id);
create index if not exists idx_attempts_status on public.challenge_attempts(status);

-- House challenge progress
create table if not exists public.house_challenge_progress (
  challenge_id uuid references public.challenges(id) on delete cascade,
  house_id integer references public.houses(id),
  progress_count int default 0,
  updated_at timestamptz default now(),
  primary key (challenge_id, house_id)
);

-- Polls and votes
create table if not exists public.polls (
  id uuid primary key default gen_random_uuid(),
  slug text unique not null,
  title text not null,
  description text,
  context jsonb,
  start_at timestamptz not null,
  end_at timestamptz not null,
  status text default 'draft' check (status in ('draft','active','completed','cancelled'))
);

create table if not exists public.poll_options (
  id uuid primary key default gen_random_uuid(),
  poll_id uuid references public.polls(id) on delete cascade,
  label text not null,
  author text,
  media_url text,
  sort_order int default 0
);
create index if not exists idx_poll_options_poll on public.poll_options(poll_id);

create table if not exists public.votes (
  id uuid primary key default gen_random_uuid(),
  poll_id uuid references public.polls(id) on delete cascade,
  user_id uuid references public.profiles(id) on delete cascade,
  option_id uuid references public.poll_options(id) on delete cascade,
  created_at timestamptz default now(),
  unique (poll_id, user_id)
);
create index if not exists idx_votes_poll on public.votes(poll_id);

-- Ledgers
create table if not exists public.house_points_ledger (
  id uuid primary key default gen_random_uuid(),
  house_id integer references public.houses(id),
  user_id uuid references public.profiles(id),
  source text check (source in ('event','challenge','vote','manual')),
  source_id uuid,
  points int not null,
  note text,
  created_at timestamptz default now()
);
create index if not exists idx_house_points_house on public.house_points_ledger(house_id);
create index if not exists idx_house_points_created on public.house_points_ledger(created_at);

create table if not exists public.user_points_ledger (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles(id) on delete cascade,
  source text check (source in ('event','challenge','vote','manual')),
  source_id uuid,
  points int not null,
  note text,
  created_at timestamptz default now()
);
create index if not exists idx_user_points_user on public.user_points_ledger(user_id);
create index if not exists idx_user_points_created on public.user_points_ledger(created_at);

-- RLS on
alter table public.houses enable row level security;
alter table public.profiles enable row level security;
alter table public.events enable row level security;
alter table public.event_participants enable row level security;
alter table public.challenges enable row level security;
alter table public.challenge_attempts enable row level security;
alter table public.house_challenge_progress enable row level security;
alter table public.polls enable row level security;
alter table public.poll_options enable row level security;
alter table public.votes enable row level security;
alter table public.house_points_ledger enable row level security;
alter table public.user_points_ledger enable row level security;

-- Basic policies (simplified; refine for production)
-- profiles
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='profiles' AND policyname='profiles_self_select'
  ) THEN
    CREATE POLICY profiles_self_select ON public.profiles FOR SELECT USING (auth.uid() = id);
  END IF;
END $$;
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='profiles' AND policyname='profiles_self_update'
  ) THEN
    CREATE POLICY profiles_self_update ON public.profiles FOR UPDATE USING (auth.uid() = id);
  END IF;
END $$;
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='profiles' AND policyname='profiles_insert_self'
  ) THEN
    CREATE POLICY profiles_insert_self ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);
  END IF;
END $$;

-- events
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='events' AND policyname='events_read_public'
  ) THEN
    CREATE POLICY events_read_public ON public.events FOR SELECT USING (status != 'draft' OR created_by = auth.uid());
  END IF;
END $$;
-- Writing policies for staff/admin should be implemented with a role system; placeholder denies by default.

-- event_participants
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='event_participants' AND policyname='event_participants_select_self'
  ) THEN
    CREATE POLICY event_participants_select_self ON public.event_participants FOR SELECT USING (user_id = auth.uid());
  END IF;
END $$;
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='event_participants' AND policyname='event_participants_insert_self'
  ) THEN
    CREATE POLICY event_participants_insert_self ON public.event_participants FOR INSERT WITH CHECK (user_id = auth.uid());
  END IF;
END $$;
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='event_participants' AND policyname='event_participants_update_self'
  ) THEN
    CREATE POLICY event_participants_update_self ON public.event_participants FOR UPDATE USING (user_id = auth.uid());
  END IF;
END $$;

-- challenges
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='challenges' AND policyname='challenges_read_public'
  ) THEN
    CREATE POLICY challenges_read_public ON public.challenges FOR SELECT USING (status != 'draft');
  END IF;
END $$;

-- challenge_attempts
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='challenge_attempts' AND policyname='attempts_select_self'
  ) THEN
    CREATE POLICY attempts_select_self ON public.challenge_attempts FOR SELECT USING (user_id = auth.uid());
  END IF;
END $$;
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='challenge_attempts' AND policyname='attempts_insert_self'
  ) THEN
    CREATE POLICY attempts_insert_self ON public.challenge_attempts FOR INSERT WITH CHECK (user_id = auth.uid());
  END IF;
END $$;
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='challenge_attempts' AND policyname='attempts_update_self'
  ) THEN
    CREATE POLICY attempts_update_self ON public.challenge_attempts FOR UPDATE USING (user_id = auth.uid());
  END IF;
END $$;

-- house_challenge_progress (read-only, updates via trigger)
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='house_challenge_progress' AND policyname='house_progress_read'
  ) THEN
    CREATE POLICY house_progress_read ON public.house_challenge_progress FOR SELECT USING (true);
  END IF;
END $$;

-- polls and options
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='polls' AND policyname='polls_read_public'
  ) THEN
    CREATE POLICY polls_read_public ON public.polls FOR SELECT USING (status IN ('active','completed'));
  END IF;
END $$;
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='poll_options' AND policyname='poll_options_read_public'
  ) THEN
    CREATE POLICY poll_options_read_public ON public.poll_options FOR SELECT USING (true);
  END IF;
END $$;

-- votes
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='votes' AND policyname='votes_select_self'
  ) THEN
    CREATE POLICY votes_select_self ON public.votes FOR SELECT USING (user_id = auth.uid());
  END IF;
END $$;
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='votes' AND policyname='votes_insert_self'
  ) THEN
    CREATE POLICY votes_insert_self ON public.votes FOR INSERT WITH CHECK (user_id = auth.uid());
  END IF;
END $$;

-- ledgers (restrict raw reads; surface via RPCs)
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='house_points_ledger' AND policyname='house_ledger_no_select'
  ) THEN
    CREATE POLICY house_ledger_no_select ON public.house_points_ledger FOR SELECT USING (false);
  END IF;
END $$;
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='user_points_ledger' AND policyname='user_ledger_self_select'
  ) THEN
    CREATE POLICY user_ledger_self_select ON public.user_points_ledger FOR SELECT USING (user_id = auth.uid());
  END IF;
END $$;

-- Materialized view for participants count
create materialized view if not exists public.v_event_participants_counts as
select event_id, count(distinct user_id) as participants_count
from public.event_participants
group by event_id;

-- RPC: get_quick_stats
create or replace function public.get_quick_stats()
returns jsonb language sql security definer as $$
with active_events as (
  select id, reward_points, end_at
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
  'min_days_remaining', coalesce((select ceil(extract(epoch from min(end_at - now()))/86400.0)::int from active_events), 0)
);
$$;

comment on function public.get_quick_stats is 'Returns quick dashboard stats for the community events page.';

-- Note: Additional RPCs, triggers and detailed RLS for staff/admin to be added per PRD.
-- This migration focuses on enabling quick stats and base schema so the page can start wiring data.

