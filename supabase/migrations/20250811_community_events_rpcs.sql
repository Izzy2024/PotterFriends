-- Supabase migration: RPCs and triggers for Community Events backend
-- Run after 20250811_community_events_backend.sql

-- Helper: safe period window
create or replace function public._period_window(in_period text)
returns tstzrange language sql immutable as $$
  select case lower(coalesce(in_period,'month'))
    when 'week' then tstzrange(date_trunc('week', now()), date_trunc('week', now()) + interval '1 week', '[)')
    when 'month' then tstzrange(date_trunc('month', now()), date_trunc('month', now()) + interval '1 month', '[)')
    when 'all' then tstzrange(to_timestamp(0), now() + interval '100 years', '[)')
    else tstzrange(date_trunc('month', now()), date_trunc('month', now()) + interval '1 month', '[)')
  end;
$$;

-- Featured events
create or replace function public.list_featured_events(in_limit int default 6)
returns table (
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
) language sql security definer as $$
  with base as (
    select e.*,
      coalesce(v.participants_count,0) as participants_count
    from public.events e
    left join public.v_event_participants_counts v on v.event_id = e.id
    where e.featured = true and e.status in ('active','completed')
    order by case when e.status='active' then 0 else 1 end, e.end_at asc
    limit coalesce(in_limit,6)
  )
  select b.slug, b.title, b.description, b.cover_url, b.type, b.reward_points, b.start_at, b.end_at,
         b.participants_count,
         ceil(extract(epoch from (b.end_at - now()))/86400.0)::int as ends_in_days
  from base b;
$$;

-- Upcoming events
create or replace function public.list_upcoming_events(in_limit int default 5)
returns table (
  slug text,
  title text,
  start_at timestamptz,
  end_at timestamptz,
  type text,
  reward_points int
) language sql security definer as $$
  select slug, title, start_at, end_at, type, reward_points
  from public.events
  where status='active' and start_at >= now()
  order by start_at asc
  limit coalesce(in_limit,5);
$$;

-- Calendar events (simple): returns events in a month
create or replace function public.list_calendar_events(in_month int, in_year int)
returns table (
  event_date date,
  slug text,
  title text,
  type text
) language sql security definer as $$
  with monthspan as (
    select make_timestamptz(in_year, in_month, 1, 0,0,0) as month_start
  ), span as (
    select month_start, (month_start + interval '1 month') as month_end from monthspan
  )
  select e.start_at::date as event_date, e.slug, e.title, e.type
  from public.events e, span s
  where e.status in ('active','completed')
    and e.start_at >= s.month_start and e.start_at < s.month_end
  order by e.start_at asc;
$$;

-- Join event (idempotent)
create or replace function public.join_event(in_slug text)
returns void language plpgsql security definer as $$
DECLARE v_event_id uuid; v_user uuid := auth.uid();
BEGIN
  if v_user is null then
    raise exception 'Debe iniciar sesión para participar';
  end if;
  select id into v_event_id from public.events 
    where slug=in_slug and status='active' and now() between start_at and end_at;
  if v_event_id is null then raise exception 'Evento no disponible'; end if;
  insert into public.event_participants(event_id, user_id, status)
  values (v_event_id, v_user, 'joined')
  on conflict (event_id, user_id) do nothing;
END;$$;

-- My participations
create or replace function public.my_participations()
returns table (
  slug text,
  title text,
  status text,
  start_at timestamptz,
  end_at timestamptz
) language sql security definer as $$
  select e.slug, e.title, ep.status, e.start_at, e.end_at
  from public.event_participants ep
  join public.events e on e.id = ep.event_id
  where ep.user_id = auth.uid()
  order by e.start_at desc;
$$;

-- Individual challenges
create or replace function public.list_individual_challenges()
returns table (
  slug text,
  title text,
  description text,
  reward_points int,
  completed_count bigint
) language sql security definer as $$
  with base as (
    select c.id, c.slug, c.title, c.description, c.reward_points
    from public.challenges c
    where c.scope='individual' and c.status='active' and now() between c.start_at and c.end_at
  )
  select b.slug, b.title, b.description, b.reward_points,
         coalesce((select count(1) from public.challenge_attempts ca 
                   where ca.challenge_id = b.id and ca.status='completed'),0) as completed_count
  from base b
  order by b.title asc;
$$;

-- House challenges with progress
create or replace function public.list_house_challenges()
returns table (
  slug text,
  title text,
  reward_points int,
  target_count int,
  gryffindor int,
  ravenclaw int,
  hufflepuff int,
  slytherin int
) language sql security definer as $$
  with base as (
    select c.id, c.slug, c.title, c.reward_points, c.target_count
    from public.challenges c
    where c.scope='house' and c.status='active' and now() between c.start_at and c.end_at
  ), agg as (
    select hcp.challenge_id,
      sum(case when h.name ilike 'Gryffindor' then hcp.progress_count else 0 end) as gryffindor,
      sum(case when h.name ilike 'Ravenclaw' then hcp.progress_count else 0 end) as ravenclaw,
      sum(case when h.name ilike 'Hufflepuff' then hcp.progress_count else 0 end) as hufflepuff,
      sum(case when h.name ilike 'Slytherin' then hcp.progress_count else 0 end) as slytherin
    from public.house_challenge_progress hcp
    join public.houses h on h.id = hcp.house_id
    group by hcp.challenge_id
  )
  select b.slug, b.title, b.reward_points, b.target_count,
         coalesce(a.gryffindor,0)::int, coalesce(a.ravenclaw,0)::int, coalesce(a.hufflepuff,0)::int, coalesce(a.slytherin,0)::int
  from base b left join agg a on a.challenge_id = b.id
  order by b.title asc;
$$;

-- Submit challenge attempt (simple)
create or replace function public.submit_challenge_attempt(in_slug text, in_evidence_url text)
returns void language plpgsql security definer as $$
DECLARE v_challenge_id uuid; v_user uuid := auth.uid(); v_house integer; v_scope text;
BEGIN
  if v_user is null then raise exception 'Debe iniciar sesión'; end if;
  select id, scope into v_challenge_id, v_scope from public.challenges 
    where slug=in_slug and status='active' and now() between start_at and end_at;
  if v_challenge_id is null then raise exception 'Desafío no disponible'; end if;
  select house_id into v_house from public.profiles where id = v_user;
  insert into public.challenge_attempts(challenge_id, user_id, house_id, status, evidence_url)
  values (v_challenge_id, v_user, v_house, 'in_progress', in_evidence_url);
END;$$;

-- Leaderboard houses
create or replace function public.leaderboard_houses(in_period text default 'month')
returns table (
  house_id integer,
  house_name text,
  points bigint
) language sql security definer as $$
  with win as (select _period_window(in_period) as w)
  select h.id, h.name, coalesce(sum(l.points),0) as points
  from public.houses h
  left join public.house_points_ledger l on l.house_id = h.id and l.created_at <@ (select w from win)
  group by h.id, h.name
  order by points desc, h.name asc;
$$;

-- Leaderboard users
create or replace function public.leaderboard_users(in_period text default 'month')
returns table (
  user_id uuid,
  username text,
  points bigint
) language sql security definer as $$
  with win as (select _period_window(in_period) as w)
  select u.id,
         max(coalesce(au.raw_user_meta_data->>'username', au.email)) as username,
         coalesce(sum(l.points),0) as points
  from public.profiles u
  left join auth.users au on au.id = u.id
  left join public.user_points_ledger l on l.user_id = u.id and l.created_at <@ (select w from win)
  group by u.id
  order by points desc, username asc nulls last;
$$;

-- Active polls with simple aggregates
create or replace function public.get_polls_active()
returns table (
  poll_id uuid,
  slug text,
  title text,
  end_at timestamptz,
  total_votes bigint
) language sql security definer as $$
  select p.id, p.slug, p.title, p.end_at,
         coalesce((select count(1) from public.votes v where v.poll_id = p.id),0) as total_votes
  from public.polls p
  where p.status='active' and now() between p.start_at and p.end_at
  order by p.end_at asc;
$$;

create or replace function public.get_poll_options_with_counts(in_poll_id uuid)
returns table (
  option_id uuid,
  label text,
  author text,
  media_url text,
  votes bigint,
  percent numeric
) language sql security definer as $$
  with totals as (
    select count(1)::numeric as total from public.votes where poll_id = in_poll_id
  )
  select o.id, o.label, o.author, o.media_url,
         coalesce((select count(1) from public.votes v where v.option_id = o.id),0) as votes,
         case when (select total from totals) > 0 then
           round(100.0 * coalesce((select count(1) from public.votes v where v.option_id = o.id),0) / (select total from totals), 2)
         else 0 end as percent
  from public.poll_options o
  where o.poll_id = in_poll_id
  order by o.sort_order asc, o.label asc;
$$;

-- Vote
create or replace function public.vote_poll(in_slug text, in_option uuid)
returns void language plpgsql security definer as $$
DECLARE v_poll_id uuid; v_user uuid := auth.uid();
BEGIN
  if v_user is null then raise exception 'Debe iniciar sesión para votar'; end if;
  select id into v_poll_id from public.polls where slug=in_slug and status='active' and now() between start_at and end_at;
  if v_poll_id is null then raise exception 'Votación no disponible'; end if;
  insert into public.votes(poll_id, user_id, option_id) values (v_poll_id, v_user, in_option);
END;$$;

-- Recent poll results
create or replace function public.get_recent_poll_results(in_limit int default 1)
returns table (
  poll_id uuid,
  slug text,
  title text,
  ended_at timestamptz,
  total_votes bigint
) language sql security definer as $$
  select p.id, p.slug, p.title, p.end_at as ended_at,
         coalesce((select count(1) from public.votes v where v.poll_id = p.id),0) as total_votes
  from public.polls p
  where p.status='completed'
  order by p.end_at desc
  limit coalesce(in_limit,1);
$$;

-- Trigger: award points and update house progress when a challenge attempt is completed
create or replace function public._on_challenge_attempt_completed()
returns trigger language plpgsql security definer as $$
DECLARE v_reward int; v_scope text; v_user_house integer;
BEGIN
  if TG_OP = 'UPDATE' and NEW.status = 'completed' and (OLD.status is distinct from 'completed') then
    select reward_points, scope into v_reward, v_scope from public.challenges where id = NEW.challenge_id;
    -- award user points
    insert into public.user_points_ledger(user_id, source, source_id, points, note)
      values (NEW.user_id, 'challenge', NEW.challenge_id, coalesce(v_reward,0), 'Challenge completed');
    -- update/award house
    select house_id into v_user_house from public.profiles where id = NEW.user_id;
    if v_user_house is not null then
      if v_scope = 'individual' then
        insert into public.house_points_ledger(house_id, user_id, source, source_id, points, note)
          values (v_user_house, NEW.user_id, 'challenge', NEW.challenge_id, coalesce(v_reward,0), 'Challenge completed');
      elsif v_scope = 'house' then
        -- increment progress
        insert into public.house_challenge_progress(challenge_id, house_id, progress_count)
          values (NEW.challenge_id, v_user_house, 1)
        on conflict (challenge_id, house_id) do update set progress_count = public.house_challenge_progress.progress_count + 1,
                                                         updated_at = now();
      end if;
    end if;
  end if;
  return NEW;
END;$$;

drop trigger if exists trg_attempt_completed on public.challenge_attempts;
create trigger trg_attempt_completed
after update on public.challenge_attempts
for each row execute function public._on_challenge_attempt_completed();

