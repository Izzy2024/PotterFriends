--
-- PostgreSQL database cluster dump
--

\restrict ttGz7rJB4yGMuuudWlvghCMYWnWxCs3EVJ7BhnyLyhIBzwhpYcUJtUoWOrSHQOo

SET default_transaction_read_only = off;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

--
-- Roles
--

DO $$BEGIN CREATE ROLE anon; EXCEPTION WHEN duplicate_object THEN END$$;
ALTER ROLE anon WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB NOLOGIN NOREPLICATION NOBYPASSRLS;
DO $$BEGIN CREATE ROLE authenticated; EXCEPTION WHEN duplicate_object THEN END$$;
ALTER ROLE authenticated WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB NOLOGIN NOREPLICATION NOBYPASSRLS;
DO $$BEGIN CREATE ROLE authenticator; EXCEPTION WHEN duplicate_object THEN END$$;
ALTER ROLE authenticator WITH NOSUPERUSER NOINHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS;
DO $$BEGIN CREATE ROLE dashboard_user; EXCEPTION WHEN duplicate_object THEN END$$;
ALTER ROLE dashboard_user WITH NOSUPERUSER INHERIT CREATEROLE CREATEDB NOLOGIN REPLICATION NOBYPASSRLS;
DO $$BEGIN CREATE ROLE pgbouncer; EXCEPTION WHEN duplicate_object THEN END$$;
ALTER ROLE pgbouncer WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS;
DO $$BEGIN CREATE ROLE postgres; EXCEPTION WHEN duplicate_object THEN END$$;
ALTER ROLE postgres WITH NOSUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS;
DO $$BEGIN CREATE ROLE service_role; EXCEPTION WHEN duplicate_object THEN END$$;
ALTER ROLE service_role WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB NOLOGIN NOREPLICATION BYPASSRLS;
DO $$BEGIN CREATE ROLE supabase_admin; EXCEPTION WHEN duplicate_object THEN END$$;
ALTER ROLE supabase_admin WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS;
DO $$BEGIN CREATE ROLE supabase_auth_admin; EXCEPTION WHEN duplicate_object THEN END$$;
ALTER ROLE supabase_auth_admin WITH NOSUPERUSER NOINHERIT CREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS;
DO $$BEGIN CREATE ROLE supabase_read_only_user; EXCEPTION WHEN duplicate_object THEN END$$;
ALTER ROLE supabase_read_only_user WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION BYPASSRLS;
DO $$BEGIN CREATE ROLE supabase_realtime_admin; EXCEPTION WHEN duplicate_object THEN END$$;
ALTER ROLE supabase_realtime_admin WITH NOSUPERUSER NOINHERIT NOCREATEROLE NOCREATEDB NOLOGIN NOREPLICATION NOBYPASSRLS;
DO $$BEGIN CREATE ROLE supabase_replication_admin; EXCEPTION WHEN duplicate_object THEN END$$;
ALTER ROLE supabase_replication_admin WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN REPLICATION NOBYPASSRLS;
DO $$BEGIN CREATE ROLE supabase_storage_admin; EXCEPTION WHEN duplicate_object THEN END$$;
ALTER ROLE supabase_storage_admin WITH NOSUPERUSER NOINHERIT CREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS;

--
-- User Configurations
--

--
-- User Config "anon"
--

ALTER ROLE anon SET statement_timeout TO '3s';

--
-- User Config "authenticated"
--

ALTER ROLE authenticated SET statement_timeout TO '8s';

--
-- User Config "authenticator"
--

ALTER ROLE authenticator SET session_preload_libraries TO 'safeupdate';
ALTER ROLE authenticator SET statement_timeout TO '8s';
ALTER ROLE authenticator SET lock_timeout TO '8s';

--
-- User Config "postgres"
--

ALTER ROLE postgres SET search_path TO E'\\$user', 'public', 'extensions';

--
-- User Config "supabase_admin"
--

ALTER ROLE supabase_admin SET search_path TO '$user', 'public', 'auth', 'extensions';
ALTER ROLE supabase_admin SET log_statement TO 'none';

--
-- User Config "supabase_auth_admin"
--

ALTER ROLE supabase_auth_admin SET search_path TO 'auth';
ALTER ROLE supabase_auth_admin SET idle_in_transaction_session_timeout TO '60000';
ALTER ROLE supabase_auth_admin SET log_statement TO 'none';

--
-- User Config "supabase_storage_admin"
--

ALTER ROLE supabase_storage_admin SET search_path TO 'storage';
ALTER ROLE supabase_storage_admin SET log_statement TO 'none';


--
-- Role memberships
--

GRANT anon TO authenticator;
GRANT anon TO postgres WITH ADMIN OPTION;
GRANT authenticated TO authenticator;
GRANT authenticated TO postgres WITH ADMIN OPTION;
GRANT authenticator TO postgres WITH ADMIN OPTION;
GRANT authenticator TO supabase_storage_admin;
GRANT pg_monitor TO postgres WITH ADMIN OPTION;
GRANT pg_read_all_data TO postgres WITH ADMIN OPTION;
GRANT pg_read_all_data TO supabase_read_only_user;
GRANT pg_signal_backend TO postgres WITH ADMIN OPTION;
GRANT service_role TO authenticator;
GRANT service_role TO postgres WITH ADMIN OPTION;
GRANT supabase_realtime_admin TO postgres;






\unrestrict ttGz7rJB4yGMuuudWlvghCMYWnWxCs3EVJ7BhnyLyhIBzwhpYcUJtUoWOrSHQOo

--
-- Databases
--

--
-- Database "template1" dump
--

\connect template1

--
-- PostgreSQL database dump
--

\restrict JoHdACozTCs5kichOwuABp2vNc4KWap7vgknn5CHycQgEc153hE8EV9pdHzhCXG

-- Dumped from database version 17.4
-- Dumped by pg_dump version 17.6 (Debian 17.6-1.pgdg12+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- PostgreSQL database dump complete
--

\unrestrict JoHdACozTCs5kichOwuABp2vNc4KWap7vgknn5CHycQgEc153hE8EV9pdHzhCXG

--
-- Database "postgres" dump
--

\connect postgres

--
-- PostgreSQL database dump
--

\restrict Z0tdWi4mDmvSiANaBkOxEa84I3ZdTiS6Z65eOwOcaGbwRqvEkNGcK5idRO2nEnk

-- Dumped from database version 17.4
-- Dumped by pg_dump version 17.6 (Debian 17.6-1.pgdg12+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: auth; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA IF NOT EXISTS auth;


ALTER SCHEMA auth OWNER TO supabase_admin;

--
-- Name: extensions; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA IF NOT EXISTS extensions;


ALTER SCHEMA extensions OWNER TO postgres;

--
-- Name: pgbouncer; Type: SCHEMA; Schema: -; Owner: pgbouncer
--

CREATE SCHEMA IF NOT EXISTS pgbouncer;


ALTER SCHEMA pgbouncer OWNER TO pgbouncer;

--
-- Name: realtime; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA IF NOT EXISTS realtime;


ALTER SCHEMA realtime OWNER TO supabase_admin;

--
-- Name: storage; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA IF NOT EXISTS storage;


ALTER SCHEMA storage OWNER TO supabase_admin;


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA extensions;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA extensions;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: aal_level; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.aal_level AS ENUM (
    'aal1',
    'aal2',
    'aal3'
);


ALTER TYPE auth.aal_level OWNER TO supabase_auth_admin;

--
-- Name: code_challenge_method; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.code_challenge_method AS ENUM (
    's256',
    'plain'
);


ALTER TYPE auth.code_challenge_method OWNER TO supabase_auth_admin;

--
-- Name: factor_status; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.factor_status AS ENUM (
    'unverified',
    'verified'
);


ALTER TYPE auth.factor_status OWNER TO supabase_auth_admin;

--
-- Name: factor_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.factor_type AS ENUM (
    'totp',
    'webauthn',
    'phone'
);


ALTER TYPE auth.factor_type OWNER TO supabase_auth_admin;

--
-- Name: one_time_token_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.one_time_token_type AS ENUM (
    'confirmation_token',
    'reauthentication_token',
    'recovery_token',
    'email_change_token_new',
    'email_change_token_current',
    'phone_change_token'
);


ALTER TYPE auth.one_time_token_type OWNER TO supabase_auth_admin;

--
-- Name: post_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.post_status AS ENUM (
    'open',
    'closed',
    'resolved',
    'live'
);


ALTER TYPE public.post_status OWNER TO postgres;

--
-- Name: action; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.action AS ENUM (
    'INSERT',
    'UPDATE',
    'DELETE',
    'TRUNCATE',
    'ERROR'
);


ALTER TYPE realtime.action OWNER TO supabase_admin;

--
-- Name: equality_op; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.equality_op AS ENUM (
    'eq',
    'neq',
    'lt',
    'lte',
    'gt',
    'gte',
    'in'
);


ALTER TYPE realtime.equality_op OWNER TO supabase_admin;

--
-- Name: user_defined_filter; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.user_defined_filter AS (
	column_name text,
	op realtime.equality_op,
	value text
);


ALTER TYPE realtime.user_defined_filter OWNER TO supabase_admin;

--
-- Name: wal_column; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.wal_column AS (
	name text,
	type_name text,
	type_oid oid,
	value jsonb,
	is_pkey boolean,
	is_selectable boolean
);


ALTER TYPE realtime.wal_column OWNER TO supabase_admin;

--
-- Name: wal_rls; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.wal_rls AS (
	wal jsonb,
	is_rls_enabled boolean,
	subscription_ids uuid[],
	errors text[]
);


ALTER TYPE realtime.wal_rls OWNER TO supabase_admin;

--
-- Name: email(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.email() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.email', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'email')
  )::text
$$;


ALTER FUNCTION auth.email() OWNER TO supabase_auth_admin;

--
-- Name: FUNCTION email(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.email() IS 'Deprecated. Use auth.jwt() -> ''email'' instead.';


--
-- Name: jwt(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.jwt() RETURNS jsonb
    LANGUAGE sql STABLE
    AS $$
  select 
    coalesce(
        nullif(current_setting('request.jwt.claim', true), ''),
        nullif(current_setting('request.jwt.claims', true), '')
    )::jsonb
$$;


ALTER FUNCTION auth.jwt() OWNER TO supabase_auth_admin;

--
-- Name: role(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.role() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.role', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role')
  )::text
$$;


ALTER FUNCTION auth.role() OWNER TO supabase_auth_admin;

--
-- Name: FUNCTION role(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.role() IS 'Deprecated. Use auth.jwt() -> ''role'' instead.';


--
-- Name: uid(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.uid() RETURNS uuid
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
  )::uuid
$$;


ALTER FUNCTION auth.uid() OWNER TO supabase_auth_admin;

--
-- Name: FUNCTION uid(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.uid() IS 'Deprecated. Use auth.jwt() -> ''sub'' instead.';


--
-- Name: grant_pg_cron_access(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.grant_pg_cron_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_cron'
  )
  THEN
    grant usage on schema cron to postgres with grant option;

    alter default privileges in schema cron grant all on tables to postgres with grant option;
    alter default privileges in schema cron grant all on functions to postgres with grant option;
    alter default privileges in schema cron grant all on sequences to postgres with grant option;

    alter default privileges for user supabase_admin in schema cron grant all
        on sequences to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on tables to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on functions to postgres with grant option;

    grant all privileges on all tables in schema cron to postgres with grant option;
    revoke all on table cron.job from postgres;
    grant select on table cron.job to postgres with grant option;
  END IF;
END;
$$;


ALTER FUNCTION extensions.grant_pg_cron_access() OWNER TO supabase_admin;

--
-- Name: FUNCTION grant_pg_cron_access(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION extensions.grant_pg_cron_access() IS 'Grants access to pg_cron';


--
-- Name: grant_pg_net_access(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.grant_pg_net_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_net'
  )
  THEN
    IF NOT EXISTS (
      SELECT 1
      FROM pg_roles
      WHERE rolname = 'supabase_functions_admin'
    )
    THEN
      CREATE USER supabase_functions_admin NOINHERIT CREATEROLE LOGIN NOREPLICATION;
    END IF;

    GRANT USAGE ON SCHEMA net TO supabase_functions_admin, postgres, anon, authenticated, service_role;

    IF EXISTS (
      SELECT FROM pg_extension
      WHERE extname = 'pg_net'
      -- all versions in use on existing projects as of 2025-02-20
      -- version 0.12.0 onwards don't need these applied
      AND extversion IN ('0.2', '0.6', '0.7', '0.7.1', '0.8', '0.10.0', '0.11.0')
    ) THEN
      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;

      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;

      REVOKE ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;
      REVOKE ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;

      GRANT EXECUTE ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
      GRANT EXECUTE ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
    END IF;
  END IF;
END;
$$;


ALTER FUNCTION extensions.grant_pg_net_access() OWNER TO supabase_admin;

--
-- Name: FUNCTION grant_pg_net_access(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION extensions.grant_pg_net_access() IS 'Grants access to pg_net';


--
-- Name: pgrst_ddl_watch(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.pgrst_ddl_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  cmd record;
BEGIN
  FOR cmd IN SELECT * FROM pg_event_trigger_ddl_commands()
  LOOP
    IF cmd.command_tag IN (
      'CREATE SCHEMA', 'ALTER SCHEMA'
    , 'CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO', 'ALTER TABLE'
    , 'CREATE FOREIGN TABLE', 'ALTER FOREIGN TABLE'
    , 'CREATE VIEW', 'ALTER VIEW'
    , 'CREATE MATERIALIZED VIEW', 'ALTER MATERIALIZED VIEW'
    , 'CREATE FUNCTION', 'ALTER FUNCTION'
    , 'CREATE TRIGGER'
    , 'CREATE TYPE', 'ALTER TYPE'
    , 'CREATE RULE'
    , 'COMMENT'
    )
    -- don't notify in case of CREATE TEMP table or other objects created on pg_temp
    AND cmd.schema_name is distinct from 'pg_temp'
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


ALTER FUNCTION extensions.pgrst_ddl_watch() OWNER TO supabase_admin;

--
-- Name: pgrst_drop_watch(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.pgrst_drop_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  obj record;
BEGIN
  FOR obj IN SELECT * FROM pg_event_trigger_dropped_objects()
  LOOP
    IF obj.object_type IN (
      'schema'
    , 'table'
    , 'foreign table'
    , 'view'
    , 'materialized view'
    , 'function'
    , 'trigger'
    , 'type'
    , 'rule'
    )
    AND obj.is_temporary IS false -- no pg_temp objects
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


ALTER FUNCTION extensions.pgrst_drop_watch() OWNER TO supabase_admin;


--
-- Name: get_auth(text); Type: FUNCTION; Schema: pgbouncer; Owner: supabase_admin
--

CREATE FUNCTION pgbouncer.get_auth(p_usename text) RETURNS TABLE(username text, password text)
    LANGUAGE plpgsql SECURITY DEFINER
    AS $_$
begin
    raise debug 'PgBouncer auth request: %', p_usename;

    return query
    select 
        rolname::text, 
        case when rolvaliduntil < now() 
            then null 
            else rolpassword::text 
        end 
    from pg_authid 
    where rolname=$1 and rolcanlogin;
end;
$_$;


ALTER FUNCTION pgbouncer.get_auth(p_usename text) OWNER TO supabase_admin;

--
-- Name: _on_challenge_attempt_completed(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public._on_challenge_attempt_completed() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
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


ALTER FUNCTION public._on_challenge_attempt_completed() OWNER TO postgres;

--
-- Name: _period_window(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public._period_window(in_period text) RETURNS tstzrange
    LANGUAGE sql IMMUTABLE
    AS $$
  select case lower(coalesce(in_period,'month'))
    when 'week' then tstzrange(date_trunc('week', now()), date_trunc('week', now()) + interval '1 week', '[)')
    when 'month' then tstzrange(date_trunc('month', now()), date_trunc('month', now()) + interval '1 month', '[)')
    when 'all' then tstzrange(to_timestamp(0), now() + interval '100 years', '[)')
    else tstzrange(date_trunc('month', now()), date_trunc('month', now()) + interval '1 month', '[)')
  end;
$$;


ALTER FUNCTION public._period_window(in_period text) OWNER TO postgres;

--
-- Name: accept_friend_request(uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.accept_friend_request(p_requester_id uuid) RETURNS json
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_user_id UUID;
    v_result JSON;
BEGIN
    v_user_id := auth.uid();
    
    -- Actualizar el estado de la solicitud
    UPDATE friendships 
    SET status = 'accepted', 
        responded_at = CURRENT_TIMESTAMP,
        updated_at = CURRENT_TIMESTAMP
    WHERE user_id = p_requester_id 
      AND friend_id = v_user_id 
      AND status = 'pending';
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No se encontró solicitud pendiente';
    END IF;
    
    -- Crear notificación para el solicitante
    INSERT INTO social_notifications (user_id, from_user_id, type, message)
    VALUES (p_requester_id, v_user_id, 'friend_accepted', 'Ha aceptado tu solicitud de amistad');
    
    v_result := json_build_object(
        'success', true,
        'message', 'Solicitud de amistad aceptada'
    );
    
    RETURN v_result;
END;
$$;


ALTER FUNCTION public.accept_friend_request(p_requester_id uuid) OWNER TO postgres;

--
-- Name: assign_achievement_to_user(uuid, integer, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.assign_achievement_to_user(p_user_id uuid, p_achievement_type_id integer, p_reason text DEFAULT NULL::text) RETURNS json
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_achievement RECORD;
    v_awarded_by UUID;
BEGIN
    -- Obtener el usuario que está asignando el logro
    v_awarded_by := auth.uid();
    
    -- Verificar que el logro existe
    SELECT * FROM achievement_types WHERE id = p_achievement_type_id INTO v_achievement;
    IF NOT FOUND THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Achievement type not found'
        );
    END IF;
    
    -- Verificar que el usuario no tenga ya este logro
    IF EXISTS (
        SELECT 1 FROM user_achievements 
        WHERE user_id = p_user_id AND achievement_type_id = p_achievement_type_id
    ) THEN
        RETURN json_build_object(
            'success', false,
            'error', 'User already has this achievement'
        );
    END IF;
    
    -- Asignar el logro
    INSERT INTO user_achievements (user_id, achievement_type_id, awarded_by, reason)
    VALUES (p_user_id, p_achievement_type_id, v_awarded_by, p_reason);
    
    RETURN json_build_object(
        'success', true,
        'achievement_name', v_achievement.name,
        'points_awarded', v_achievement.points_reward
    );
END;
$$;


ALTER FUNCTION public.assign_achievement_to_user(p_user_id uuid, p_achievement_type_id integer, p_reason text) OWNER TO postgres;

--
-- Name: calculate_reputation_level(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calculate_reputation_level(points integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN GREATEST(1, FLOOR(points / 100) + 1);
END;
$$;


ALTER FUNCTION public.calculate_reputation_level(points integer) OWNER TO postgres;

--
-- Name: check_and_award_achievements(uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_and_award_achievements(p_user_id uuid) RETURNS json
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_achievement RECORD;
    v_user_stats RECORD;
    v_awarded_count INTEGER := 0;
BEGIN
    -- Obtener estadísticas del usuario
    SELECT * FROM user_statistics WHERE user_id = p_user_id INTO v_user_stats;
    
    -- Verificar logros automáticos basados en estadísticas
    FOR v_achievement IN 
        SELECT * FROM achievement_types 
        WHERE trigger_condition IS NOT NULL
    LOOP
        -- Verificar si el usuario ya tiene este logro
        IF NOT EXISTS (
            SELECT 1 FROM user_achievements 
            WHERE user_id = p_user_id AND achievement_type_id = v_achievement.id
        ) THEN
            -- Lógica simple de verificación (expandir según necesidades)
            IF v_achievement.trigger_condition = 'posts_count_50' AND 
               (SELECT stat_value FROM user_statistics 
                WHERE user_id = p_user_id AND stat_name = 'posts_count') >= 50 THEN
                
                INSERT INTO user_achievements (user_id, achievement_type_id, awarded_by, reason)
                VALUES (p_user_id, v_achievement.id, p_user_id, 'Logro automático: 50 posts');
                v_awarded_count := v_awarded_count + 1;
                
            ELSIF v_achievement.trigger_condition = 'active_days_30' AND 
                  (SELECT stat_value FROM user_statistics 
                   WHERE user_id = p_user_id AND stat_name = 'active_days') >= 30 THEN
                   
                INSERT INTO user_achievements (user_id, achievement_type_id, awarded_by, reason)
                VALUES (p_user_id, v_achievement.id, p_user_id, 'Logro automático: 30 días activo');
                v_awarded_count := v_awarded_count + 1;
            END IF;
        END IF;
    END LOOP;
    
    RETURN json_build_object(
        'success', true,
        'achievements_awarded', v_awarded_count
    );
END;
$$;


ALTER FUNCTION public.check_and_award_achievements(p_user_id uuid) OWNER TO postgres;

--
-- Name: decline_friend_request(uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.decline_friend_request(p_requester_id uuid) RETURNS json
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_user_id UUID;
    v_result JSON;
BEGIN
    v_user_id := auth.uid();
    
    -- Actualizar el estado de la solicitud
    UPDATE friendships 
    SET status = 'declined', 
        responded_at = CURRENT_TIMESTAMP,
        updated_at = CURRENT_TIMESTAMP
    WHERE user_id = p_requester_id 
      AND friend_id = v_user_id 
      AND status = 'pending';
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No se encontró solicitud pendiente';
    END IF;
    
    v_result := json_build_object(
        'success', true,
        'message', 'Solicitud de amistad rechazada'
    );
    
    RETURN v_result;
END;
$$;


ALTER FUNCTION public.decline_friend_request(p_requester_id uuid) OWNER TO postgres;

--
-- Name: follow_user(uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.follow_user(p_user_to_follow_id uuid) RETURNS json
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_follower_id UUID;
    v_result JSON;
BEGIN
    v_follower_id := auth.uid();
    
    -- Verificar que no es el mismo usuario
    IF v_follower_id = p_user_to_follow_id THEN
        RAISE EXCEPTION 'No puedes seguirte a ti mismo';
    END IF;
    
    -- Insertar relación de seguidor
    INSERT INTO followers (user_id, follower_id) 
    VALUES (p_user_to_follow_id, v_follower_id)
    ON CONFLICT (user_id, follower_id) DO NOTHING;
    
    -- Crear notificación
    INSERT INTO social_notifications (user_id, from_user_id, type, message)
    VALUES (p_user_to_follow_id, v_follower_id, 'new_follower', 'Ahora te sigue');
    
    v_result := json_build_object(
        'success', true,
        'message', 'Ahora sigues a este usuario'
    );
    
    RETURN v_result;
END;
$$;


ALTER FUNCTION public.follow_user(p_user_to_follow_id uuid) OWNER TO postgres;

--
-- Name: generate_share_token(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.generate_share_token() RETURNS character varying
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN CONCAT('profile_', SUBSTRING(MD5(RANDOM()::TEXT), 1, 20));
END;
$$;


ALTER FUNCTION public.generate_share_token() OWNER TO postgres;

--
-- Name: get_house_points_breakdown(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_house_points_breakdown(target_house_id integer) RETURNS TABLE(source text, points bigint)
    LANGUAGE sql SECURITY DEFINER
    AS $$
    SELECT 
        CASE 
            WHEN hpl.source = 'event' THEN 'Eventos Especiales'
            WHEN hpl.source = 'challenge' THEN 'Desafíos Completados'
            WHEN hpl.source = 'manual' THEN 'Contribuciones'
            WHEN hpl.source = 'vote' THEN 'Foro y Discusiones'
            ELSE 'Otros'
        END as source,
        COALESCE(SUM(hpl.points), 0)::BIGINT as points
    FROM house_points_ledger hpl
    WHERE hpl.house_id = target_house_id
    GROUP BY 
        CASE 
            WHEN hpl.source = 'event' THEN 'Eventos Especiales'
            WHEN hpl.source = 'challenge' THEN 'Desafíos Completados'
            WHEN hpl.source = 'manual' THEN 'Contribuciones'
            WHEN hpl.source = 'vote' THEN 'Foro y Discusiones'
            ELSE 'Otros'
        END
    ORDER BY points DESC;
$$;


ALTER FUNCTION public.get_house_points_breakdown(target_house_id integer) OWNER TO postgres;

--
-- Name: get_house_statistics(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_house_statistics(p_house character varying) RETURNS json
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_result JSON;
BEGIN
    SELECT json_build_object(
        'total_members', (
            SELECT COUNT(*) FROM public.user_profiles WHERE house = p_house
        ),
        'total_points', (
            SELECT COALESCE(SUM(house_points), 0) FROM public.user_profiles WHERE house = p_house
        ),
        'active_members_week', (
            SELECT COUNT(DISTINCT user_id) 
            FROM public.user_activities 
            WHERE created_at > NOW() - INTERVAL '7 days'
            AND user_id IN (SELECT id FROM public.user_profiles WHERE house = p_house)
        ),
        'achievements_this_month', (
            SELECT COUNT(*) 
            FROM public.user_achievements ua
            JOIN public.user_profiles up ON ua.user_id = up.id
            WHERE up.house = p_house 
            AND ua.awarded_at > DATE_TRUNC('month', NOW())
        ),
        'top_contributors', (
            SELECT json_agg(json_build_object(
                'name', display_name,
                'points', house_points,
                'contributions', contributions_count
            ))
            FROM (
                SELECT display_name, house_points, contributions_count
                FROM public.user_profiles 
                WHERE house = p_house 
                ORDER BY house_points DESC 
                LIMIT 5
            ) top_users
        )
    ) INTO v_result;
    
    RETURN v_result;
END;
$$;


ALTER FUNCTION public.get_house_statistics(p_house character varying) OWNER TO postgres;

--
-- Name: get_poll_options_with_counts(uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_poll_options_with_counts(in_poll_id uuid) RETURNS TABLE(option_id uuid, label text, author text, media_url text, votes bigint, percent numeric)
    LANGUAGE sql SECURITY DEFINER
    AS $$
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


ALTER FUNCTION public.get_poll_options_with_counts(in_poll_id uuid) OWNER TO postgres;

--
-- Name: get_polls_active(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_polls_active() RETURNS TABLE(poll_id uuid, slug text, title text, end_at timestamp with time zone, total_votes bigint)
    LANGUAGE sql SECURITY DEFINER
    AS $$
  select p.id, p.slug, p.title, p.end_at,
         coalesce((select count(1) from public.votes v where v.poll_id = p.id),0) as total_votes
  from public.polls p
  where p.status='active' and now() between p.start_at and p.end_at
  order by p.end_at asc;
$$;


ALTER FUNCTION public.get_polls_active() OWNER TO postgres;

--
-- Name: get_quick_stats(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_quick_stats() RETURNS jsonb
    LANGUAGE sql SECURITY DEFINER
    AS $$
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


ALTER FUNCTION public.get_quick_stats() OWNER TO postgres;

--
-- Name: FUNCTION get_quick_stats(); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION public.get_quick_stats() IS 'Returns quick dashboard stats for the community events page.';


--
-- Name: get_recent_friends(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_recent_friends(p_limit integer DEFAULT 6) RETURNS json
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_user_id UUID;
    v_friends JSON;
BEGIN
    v_user_id := auth.uid();
    
    SELECT json_agg(
        json_build_object(
            'id', friend_profile.id,
            'display_name', friend_profile.display_name,
            'avatar_url', friend_profile.avatar_url,
            'house', friend_profile.house,
            'became_friends_at', f.updated_at
        )
    ) INTO v_friends
    FROM (
        SELECT 
            CASE 
                WHEN user_id = v_user_id THEN friend_id 
                ELSE user_id 
            END as friend_user_id,
            updated_at
        FROM friendships 
        WHERE (user_id = v_user_id OR friend_id = v_user_id) 
          AND status = 'accepted'
        ORDER BY updated_at DESC
        LIMIT p_limit
    ) f
    JOIN user_profiles friend_profile ON friend_profile.id = f.friend_user_id;
    
    RETURN COALESCE(v_friends, '[]'::json);
END;
$$;


ALTER FUNCTION public.get_recent_friends(p_limit integer) OWNER TO postgres;

--
-- Name: get_recent_poll_results(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_recent_poll_results(in_limit integer DEFAULT 1) RETURNS TABLE(poll_id uuid, slug text, title text, ended_at timestamp with time zone, total_votes bigint)
    LANGUAGE sql SECURITY DEFINER
    AS $$
  select p.id, p.slug, p.title, p.end_at as ended_at,
         coalesce((select count(1) from public.votes v where v.poll_id = p.id),0) as total_votes
  from public.polls p
  where p.status='completed'
  order by p.end_at desc
  limit coalesce(in_limit,1);
$$;


ALTER FUNCTION public.get_recent_poll_results(in_limit integer) OWNER TO postgres;

--
-- Name: get_user_social_stats(uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_user_social_stats(p_user_id uuid DEFAULT NULL::uuid) RETURNS json
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_user_id UUID;
    v_friends_count INTEGER;
    v_house_members_count INTEGER;
    v_followers_count INTEGER;
    v_following_count INTEGER;
    v_user_house TEXT;
    v_result JSON;
BEGIN
    v_user_id := COALESCE(p_user_id, auth.uid());
    
    -- Obtener casa del usuario
    SELECT house INTO v_user_house 
    FROM user_profiles 
    WHERE id = v_user_id;
    
    -- Contar amigos
    SELECT COUNT(*) INTO v_friends_count
    FROM friendships 
    WHERE (user_id = v_user_id OR friend_id = v_user_id) 
      AND status = 'accepted';
    
    -- Contar compañeros de casa
    SELECT COUNT(*) INTO v_house_members_count
    FROM user_profiles 
    WHERE house = v_user_house 
      AND id != v_user_id;
    
    -- Contar seguidores
    SELECT COUNT(*) INTO v_followers_count
    FROM followers 
    WHERE user_id = v_user_id;
    
    -- Contar siguiendo
    SELECT COUNT(*) INTO v_following_count
    FROM followers 
    WHERE follower_id = v_user_id;
    
    v_result := json_build_object(
        'friends_count', v_friends_count,
        'house_members_count', v_house_members_count,
        'followers_count', v_followers_count,
        'following_count', v_following_count,
        'house', v_user_house
    );
    
    RETURN v_result;
END;
$$;


ALTER FUNCTION public.get_user_social_stats(p_user_id uuid) OWNER TO postgres;

--
-- Name: handle_new_user(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.handle_new_user() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    INSERT INTO public.profiles (id, email, wizard_name, first_name, last_name)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'wizard_name', 'Mago'),
        COALESCE(NEW.raw_user_meta_data->>'first_name', ''),
        COALESCE(NEW.raw_user_meta_data->>'last_name', '')
    );
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.handle_new_user() OWNER TO postgres;

--
-- Name: increment_post_views(uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.increment_post_views(post_id uuid) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE posts SET views = views + 1 WHERE id = post_id;
END;
$$;


ALTER FUNCTION public.increment_post_views(post_id uuid) OWNER TO postgres;

--
-- Name: join_event(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.join_event(in_slug text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
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


ALTER FUNCTION public.join_event(in_slug text) OWNER TO postgres;

--
-- Name: leaderboard_houses(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.leaderboard_houses(in_period text DEFAULT 'month'::text) RETURNS TABLE(house_id integer, house_name text, points bigint)
    LANGUAGE sql SECURITY DEFINER
    AS $$
  with win as (select _period_window(in_period) as w)
  select h.id, h.name, coalesce(sum(l.points),0) as points
  from public.houses h
  left join public.house_points_ledger l on l.house_id = h.id and l.created_at <@ (select w from win)
  group by h.id, h.name
  order by points desc, h.name asc;
$$;


ALTER FUNCTION public.leaderboard_houses(in_period text) OWNER TO postgres;

--
-- Name: leaderboard_users(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.leaderboard_users(in_period text DEFAULT 'month'::text) RETURNS TABLE(user_id uuid, username text, points bigint)
    LANGUAGE sql SECURITY DEFINER
    AS $$
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


ALTER FUNCTION public.leaderboard_users(in_period text) OWNER TO postgres;

--
-- Name: list_calendar_events(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.list_calendar_events(in_month integer, in_year integer) RETURNS TABLE(event_date date, slug text, title text, type text)
    LANGUAGE sql SECURITY DEFINER
    AS $$
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


ALTER FUNCTION public.list_calendar_events(in_month integer, in_year integer) OWNER TO postgres;

--
-- Name: list_featured_events(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.list_featured_events(in_limit integer DEFAULT 6) RETURNS TABLE(slug text, title text, description text, cover_url text, type text, reward_points integer, start_at timestamp with time zone, end_at timestamp with time zone, participants_count bigint, ends_in_days integer)
    LANGUAGE sql SECURITY DEFINER
    AS $$
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


ALTER FUNCTION public.list_featured_events(in_limit integer) OWNER TO postgres;

--
-- Name: list_house_challenges(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.list_house_challenges() RETURNS TABLE(slug text, title text, reward_points integer, target_count integer, gryffindor integer, ravenclaw integer, hufflepuff integer, slytherin integer)
    LANGUAGE sql SECURITY DEFINER
    AS $$
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


ALTER FUNCTION public.list_house_challenges() OWNER TO postgres;

--
-- Name: list_individual_challenges(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.list_individual_challenges() RETURNS TABLE(slug text, title text, description text, reward_points integer, completed_count bigint)
    LANGUAGE sql SECURITY DEFINER
    AS $$
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


ALTER FUNCTION public.list_individual_challenges() OWNER TO postgres;

--
-- Name: list_upcoming_events(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.list_upcoming_events(in_limit integer DEFAULT 5) RETURNS TABLE(slug text, title text, start_at timestamp with time zone, end_at timestamp with time zone, type text, reward_points integer)
    LANGUAGE sql SECURITY DEFINER
    AS $$
  select slug, title, start_at, end_at, type, reward_points
  from public.events
  where status='active' and start_at >= now()
  order by start_at asc
  limit coalesce(in_limit,5);
$$;


ALTER FUNCTION public.list_upcoming_events(in_limit integer) OWNER TO postgres;

--
-- Name: my_participations(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.my_participations() RETURNS TABLE(slug text, title text, status text, start_at timestamp with time zone, end_at timestamp with time zone)
    LANGUAGE sql SECURITY DEFINER
    AS $$
  select e.slug, e.title, ep.status, e.start_at, e.end_at
  from public.event_participants ep
  join public.events e on e.id = ep.event_id
  where ep.user_id = auth.uid()
  order by e.start_at desc;
$$;


ALTER FUNCTION public.my_participations() OWNER TO postgres;

--
-- Name: send_friend_request(uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.send_friend_request(p_friend_id uuid) RETURNS json
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_user_id UUID;
    v_existing_request friendships%ROWTYPE;
    v_result JSON;
BEGIN
    v_user_id := auth.uid();
    
    -- Verificar que no es el mismo usuario
    IF v_user_id = p_friend_id THEN
        RAISE EXCEPTION 'No puedes enviarte una solicitud de amistad a ti mismo';
    END IF;
    
    -- Verificar si ya existe una solicitud
    SELECT * INTO v_existing_request 
    FROM friendships 
    WHERE (user_id = v_user_id AND friend_id = p_friend_id) 
       OR (user_id = p_friend_id AND friend_id = v_user_id);
    
    IF FOUND THEN
        IF v_existing_request.status = 'accepted' THEN
            RAISE EXCEPTION 'Ya son amigos';
        ELSIF v_existing_request.status = 'pending' THEN
            RAISE EXCEPTION 'Ya existe una solicitud pendiente';
        ELSIF v_existing_request.status = 'blocked' THEN
            RAISE EXCEPTION 'No se puede enviar solicitud a este usuario';
        END IF;
    END IF;
    
    -- Crear la solicitud
    INSERT INTO friendships (user_id, friend_id, status) 
    VALUES (v_user_id, p_friend_id, 'pending');
    
    -- Crear notificación
    INSERT INTO social_notifications (user_id, from_user_id, type, message)
    VALUES (p_friend_id, v_user_id, 'friend_request', 'Te ha enviado una solicitud de amistad');
    
    v_result := json_build_object(
        'success', true,
        'message', 'Solicitud de amistad enviada'
    );
    
    RETURN v_result;
END;
$$;


ALTER FUNCTION public.send_friend_request(p_friend_id uuid) OWNER TO postgres;

--
-- Name: submit_challenge_attempt(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.submit_challenge_attempt(in_slug text, in_evidence_url text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
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


ALTER FUNCTION public.submit_challenge_attempt(in_slug text, in_evidence_url text) OWNER TO postgres;

--
-- Name: unfollow_user(uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.unfollow_user(p_user_to_unfollow_id uuid) RETURNS json
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_follower_id UUID;
    v_result JSON;
BEGIN
    v_follower_id := auth.uid();
    
    -- Eliminar relación de seguidor
    DELETE FROM followers 
    WHERE user_id = p_user_to_unfollow_id 
      AND follower_id = v_follower_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No estabas siguiendo a este usuario';
    END IF;
    
    v_result := json_build_object(
        'success', true,
        'message', 'Has dejado de seguir a este usuario'
    );
    
    RETURN v_result;
END;
$$;


ALTER FUNCTION public.unfollow_user(p_user_to_unfollow_id uuid) OWNER TO postgres;

--
-- Name: update_reputation_level(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_reputation_level() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.reputation_level = calculate_reputation_level(NEW.house_points);
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_reputation_level() OWNER TO postgres;

--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updated_at_column() OWNER TO postgres;

--
-- Name: update_user_forum_stats(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_user_forum_stats() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF TG_TABLE_NAME = 'posts' THEN
        IF TG_OP = 'INSERT' THEN
            INSERT INTO forum_user_stats (user_id, total_posts)
            VALUES (NEW.user_id, 1)
            ON CONFLICT (user_id) 
            DO UPDATE SET total_posts = forum_user_stats.total_posts + 1;
        ELSIF TG_OP = 'DELETE' THEN
            UPDATE forum_user_stats 
            SET total_posts = GREATEST(0, total_posts - 1)
            WHERE user_id = OLD.user_id;
        END IF;
    ELSIF TG_TABLE_NAME = 'comments' THEN
        IF TG_OP = 'INSERT' THEN
            INSERT INTO forum_user_stats (user_id, total_comments)
            VALUES (NEW.user_id, 1)
            ON CONFLICT (user_id) 
            DO UPDATE SET total_comments = forum_user_stats.total_comments + 1;
        ELSIF TG_OP = 'DELETE' THEN
            UPDATE forum_user_stats 
            SET total_comments = GREATEST(0, total_comments - 1)
            WHERE user_id = OLD.user_id;
        END IF;
    END IF;
    RETURN NULL;
END;
$$;


ALTER FUNCTION public.update_user_forum_stats() OWNER TO postgres;

--
-- Name: update_user_stat(uuid, text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_user_stat(p_user_id uuid, p_stat_name text, p_increment integer DEFAULT 1) RETURNS json
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_new_value INTEGER;
BEGIN
    -- Insertar o actualizar estadística
    INSERT INTO user_statistics (user_id, stat_name, stat_value, updated_at)
    VALUES (p_user_id, p_stat_name, p_increment, CURRENT_TIMESTAMP)
    ON CONFLICT (user_id, stat_name)
    DO UPDATE SET 
        stat_value = user_statistics.stat_value + p_increment,
        updated_at = CURRENT_TIMESTAMP
    RETURNING stat_value INTO v_new_value;
    
    RETURN json_build_object(
        'success', true,
        'stat_name', p_stat_name,
        'new_value', v_new_value
    );
END;
$$;


ALTER FUNCTION public.update_user_stat(p_user_id uuid, p_stat_name text, p_increment integer) OWNER TO postgres;

--
-- Name: vote_poll(text, uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.vote_poll(in_slug text, in_option uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE v_poll_id uuid; v_user uuid := auth.uid();
BEGIN
  if v_user is null then raise exception 'Debe iniciar sesión para votar'; end if;
  select id into v_poll_id from public.polls where slug=in_slug and status='active' and now() between start_at and end_at;
  if v_poll_id is null then raise exception 'Votación no disponible'; end if;
  insert into public.votes(poll_id, user_id, option_id) values (v_poll_id, v_user, in_option);
END;$$;


ALTER FUNCTION public.vote_poll(in_slug text, in_option uuid) OWNER TO postgres;

--
-- Name: apply_rls(jsonb, integer); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer DEFAULT (1024 * 1024)) RETURNS SETOF realtime.wal_rls
    LANGUAGE plpgsql
    AS $$
declare
-- Regclass of the table e.g. public.notes
entity_ regclass = (quote_ident(wal ->> 'schema') || '.' || quote_ident(wal ->> 'table'))::regclass;

-- I, U, D, T: insert, update ...
action realtime.action = (
    case wal ->> 'action'
        when 'I' then 'INSERT'
        when 'U' then 'UPDATE'
        when 'D' then 'DELETE'
        else 'ERROR'
    end
);

-- Is row level security enabled for the table
is_rls_enabled bool = relrowsecurity from pg_class where oid = entity_;

subscriptions realtime.subscription[] = array_agg(subs)
    from
        realtime.subscription subs
    where
        subs.entity = entity_;

-- Subscription vars
roles regrole[] = array_agg(distinct us.claims_role::text)
    from
        unnest(subscriptions) us;

working_role regrole;
claimed_role regrole;
claims jsonb;

subscription_id uuid;
subscription_has_access bool;
visible_to_subscription_ids uuid[] = '{}';

-- structured info for wal's columns
columns realtime.wal_column[];
-- previous identity values for update/delete
old_columns realtime.wal_column[];

error_record_exceeds_max_size boolean = octet_length(wal::text) > max_record_bytes;

-- Primary jsonb output for record
output jsonb;

begin
perform set_config('role', null, true);

columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'columns') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

old_columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'identity') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

for working_role in select * from unnest(roles) loop

    -- Update `is_selectable` for columns and old_columns
    columns =
        array_agg(
            (
                c.name,
                c.type_name,
                c.type_oid,
                c.value,
                c.is_pkey,
                pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
            )::realtime.wal_column
        )
        from
            unnest(columns) c;

    old_columns =
            array_agg(
                (
                    c.name,
                    c.type_name,
                    c.type_oid,
                    c.value,
                    c.is_pkey,
                    pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
                )::realtime.wal_column
            )
            from
                unnest(old_columns) c;

    if action <> 'DELETE' and count(1) = 0 from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            -- subscriptions is already filtered by entity
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 400: Bad Request, no primary key']
        )::realtime.wal_rls;

    -- The claims role does not have SELECT permission to the primary key of entity
    elsif action <> 'DELETE' and sum(c.is_selectable::int) <> count(1) from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 401: Unauthorized']
        )::realtime.wal_rls;

    else
        output = jsonb_build_object(
            'schema', wal ->> 'schema',
            'table', wal ->> 'table',
            'type', action,
            'commit_timestamp', to_char(
                ((wal ->> 'timestamp')::timestamptz at time zone 'utc'),
                'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'
            ),
            'columns', (
                select
                    jsonb_agg(
                        jsonb_build_object(
                            'name', pa.attname,
                            'type', pt.typname
                        )
                        order by pa.attnum asc
                    )
                from
                    pg_attribute pa
                    join pg_type pt
                        on pa.atttypid = pt.oid
                where
                    attrelid = entity_
                    and attnum > 0
                    and pg_catalog.has_column_privilege(working_role, entity_, pa.attname, 'SELECT')
            )
        )
        -- Add "record" key for insert and update
        || case
            when action in ('INSERT', 'UPDATE') then
                jsonb_build_object(
                    'record',
                    (
                        select
                            jsonb_object_agg(
                                -- if unchanged toast, get column name and value from old record
                                coalesce((c).name, (oc).name),
                                case
                                    when (c).name is null then (oc).value
                                    else (c).value
                                end
                            )
                        from
                            unnest(columns) c
                            full outer join unnest(old_columns) oc
                                on (c).name = (oc).name
                        where
                            coalesce((c).is_selectable, (oc).is_selectable)
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                    )
                )
            else '{}'::jsonb
        end
        -- Add "old_record" key for update and delete
        || case
            when action = 'UPDATE' then
                jsonb_build_object(
                        'old_record',
                        (
                            select jsonb_object_agg((c).name, (c).value)
                            from unnest(old_columns) c
                            where
                                (c).is_selectable
                                and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                        )
                    )
            when action = 'DELETE' then
                jsonb_build_object(
                    'old_record',
                    (
                        select jsonb_object_agg((c).name, (c).value)
                        from unnest(old_columns) c
                        where
                            (c).is_selectable
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                            and ( not is_rls_enabled or (c).is_pkey ) -- if RLS enabled, we can't secure deletes so filter to pkey
                    )
                )
            else '{}'::jsonb
        end;

        -- Create the prepared statement
        if is_rls_enabled and action <> 'DELETE' then
            if (select 1 from pg_prepared_statements where name = 'walrus_rls_stmt' limit 1) > 0 then
                deallocate walrus_rls_stmt;
            end if;
            execute realtime.build_prepared_statement_sql('walrus_rls_stmt', entity_, columns);
        end if;

        visible_to_subscription_ids = '{}';

        for subscription_id, claims in (
                select
                    subs.subscription_id,
                    subs.claims
                from
                    unnest(subscriptions) subs
                where
                    subs.entity = entity_
                    and subs.claims_role = working_role
                    and (
                        realtime.is_visible_through_filters(columns, subs.filters)
                        or (
                          action = 'DELETE'
                          and realtime.is_visible_through_filters(old_columns, subs.filters)
                        )
                    )
        ) loop

            if not is_rls_enabled or action = 'DELETE' then
                visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
            else
                -- Check if RLS allows the role to see the record
                perform
                    -- Trim leading and trailing quotes from working_role because set_config
                    -- doesn't recognize the role as valid if they are included
                    set_config('role', trim(both '"' from working_role::text), true),
                    set_config('request.jwt.claims', claims::text, true);

                execute 'execute walrus_rls_stmt' into subscription_has_access;

                if subscription_has_access then
                    visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
                end if;
            end if;
        end loop;

        perform set_config('role', null, true);

        return next (
            output,
            is_rls_enabled,
            visible_to_subscription_ids,
            case
                when error_record_exceeds_max_size then array['Error 413: Payload Too Large']
                else '{}'
            end
        )::realtime.wal_rls;

    end if;
end loop;

perform set_config('role', null, true);
end;
$$;


ALTER FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) OWNER TO supabase_admin;

--
-- Name: broadcast_changes(text, text, text, text, text, record, record, text); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text DEFAULT 'ROW'::text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    -- Declare a variable to hold the JSONB representation of the row
    row_data jsonb := '{}'::jsonb;
BEGIN
    IF level = 'STATEMENT' THEN
        RAISE EXCEPTION 'function can only be triggered for each row, not for each statement';
    END IF;
    -- Check the operation type and handle accordingly
    IF operation = 'INSERT' OR operation = 'UPDATE' OR operation = 'DELETE' THEN
        row_data := jsonb_build_object('old_record', OLD, 'record', NEW, 'operation', operation, 'table', table_name, 'schema', table_schema);
        PERFORM realtime.send (row_data, event_name, topic_name);
    ELSE
        RAISE EXCEPTION 'Unexpected operation type: %', operation;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to process the row: %', SQLERRM;
END;

$$;


ALTER FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text) OWNER TO supabase_admin;

--
-- Name: build_prepared_statement_sql(text, regclass, realtime.wal_column[]); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) RETURNS text
    LANGUAGE sql
    AS $$
      /*
      Builds a sql string that, if executed, creates a prepared statement to
      tests retrive a row from *entity* by its primary key columns.
      Example
          select realtime.build_prepared_statement_sql('public.notes', '{"id"}'::text[], '{"bigint"}'::text[])
      */
          select
      'prepare ' || prepared_statement_name || ' as
          select
              exists(
                  select
                      1
                  from
                      ' || entity || '
                  where
                      ' || string_agg(quote_ident(pkc.name) || '=' || quote_nullable(pkc.value #>> '{}') , ' and ') || '
              )'
          from
              unnest(columns) pkc
          where
              pkc.is_pkey
          group by
              entity
      $$;


ALTER FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) OWNER TO supabase_admin;

--
-- Name: cast(text, regtype); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime."cast"(val text, type_ regtype) RETURNS jsonb
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    declare
      res jsonb;
    begin
      execute format('select to_jsonb(%L::'|| type_::text || ')', val)  into res;
      return res;
    end
    $$;


ALTER FUNCTION realtime."cast"(val text, type_ regtype) OWNER TO supabase_admin;

--
-- Name: check_equality_op(realtime.equality_op, regtype, text, text); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
      /*
      Casts *val_1* and *val_2* as type *type_* and check the *op* condition for truthiness
      */
      declare
          op_symbol text = (
              case
                  when op = 'eq' then '='
                  when op = 'neq' then '!='
                  when op = 'lt' then '<'
                  when op = 'lte' then '<='
                  when op = 'gt' then '>'
                  when op = 'gte' then '>='
                  when op = 'in' then '= any'
                  else 'UNKNOWN OP'
              end
          );
          res boolean;
      begin
          execute format(
              'select %L::'|| type_::text || ' ' || op_symbol
              || ' ( %L::'
              || (
                  case
                      when op = 'in' then type_::text || '[]'
                      else type_::text end
              )
              || ')', val_1, val_2) into res;
          return res;
      end;
      $$;


ALTER FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) OWNER TO supabase_admin;

--
-- Name: is_visible_through_filters(realtime.wal_column[], realtime.user_defined_filter[]); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) RETURNS boolean
    LANGUAGE sql IMMUTABLE
    AS $_$
    /*
    Should the record be visible (true) or filtered out (false) after *filters* are applied
    */
        select
            -- Default to allowed when no filters present
            $2 is null -- no filters. this should not happen because subscriptions has a default
            or array_length($2, 1) is null -- array length of an empty array is null
            or bool_and(
                coalesce(
                    realtime.check_equality_op(
                        op:=f.op,
                        type_:=coalesce(
                            col.type_oid::regtype, -- null when wal2json version <= 2.4
                            col.type_name::regtype
                        ),
                        -- cast jsonb to text
                        val_1:=col.value #>> '{}',
                        val_2:=f.value
                    ),
                    false -- if null, filter does not match
                )
            )
        from
            unnest(filters) f
            join unnest(columns) col
                on f.column_name = col.name;
    $_$;


ALTER FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) OWNER TO supabase_admin;

--
-- Name: list_changes(name, name, integer, integer); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) RETURNS SETOF realtime.wal_rls
    LANGUAGE sql
    SET log_min_messages TO 'fatal'
    AS $$
      with pub as (
        select
          concat_ws(
            ',',
            case when bool_or(pubinsert) then 'insert' else null end,
            case when bool_or(pubupdate) then 'update' else null end,
            case when bool_or(pubdelete) then 'delete' else null end
          ) as w2j_actions,
          coalesce(
            string_agg(
              realtime.quote_wal2json(format('%I.%I', schemaname, tablename)::regclass),
              ','
            ) filter (where ppt.tablename is not null and ppt.tablename not like '% %'),
            ''
          ) w2j_add_tables
        from
          pg_publication pp
          left join pg_publication_tables ppt
            on pp.pubname = ppt.pubname
        where
          pp.pubname = publication
        group by
          pp.pubname
        limit 1
      ),
      w2j as (
        select
          x.*, pub.w2j_add_tables
        from
          pub,
          pg_logical_slot_get_changes(
            slot_name, null, max_changes,
            'include-pk', 'true',
            'include-transaction', 'false',
            'include-timestamp', 'true',
            'include-type-oids', 'true',
            'format-version', '2',
            'actions', pub.w2j_actions,
            'add-tables', pub.w2j_add_tables
          ) x
      )
      select
        xyz.wal,
        xyz.is_rls_enabled,
        xyz.subscription_ids,
        xyz.errors
      from
        w2j,
        realtime.apply_rls(
          wal := w2j.data::jsonb,
          max_record_bytes := max_record_bytes
        ) xyz(wal, is_rls_enabled, subscription_ids, errors)
      where
        w2j.w2j_add_tables <> ''
        and xyz.subscription_ids[1] is not null
    $$;


ALTER FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) OWNER TO supabase_admin;

--
-- Name: quote_wal2json(regclass); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.quote_wal2json(entity regclass) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
      select
        (
          select string_agg('' || ch,'')
          from unnest(string_to_array(nsp.nspname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
        )
        || '.'
        || (
          select string_agg('' || ch,'')
          from unnest(string_to_array(pc.relname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
          )
      from
        pg_class pc
        join pg_namespace nsp
          on pc.relnamespace = nsp.oid
      where
        pc.oid = entity
    $$;


ALTER FUNCTION realtime.quote_wal2json(entity regclass) OWNER TO supabase_admin;

--
-- Name: send(jsonb, text, text, boolean); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean DEFAULT true) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  BEGIN
    -- Set the topic configuration
    EXECUTE format('SET LOCAL realtime.topic TO %L', topic);

    -- Attempt to insert the message
    INSERT INTO realtime.messages (payload, event, topic, private, extension)
    VALUES (payload, event, topic, private, 'broadcast');
  EXCEPTION
    WHEN OTHERS THEN
      -- Capture and notify the error
      RAISE WARNING 'ErrorSendingBroadcastMessage: %', SQLERRM;
  END;
END;
$$;


ALTER FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean) OWNER TO supabase_admin;

--
-- Name: subscription_check_filters(); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.subscription_check_filters() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    /*
    Validates that the user defined filters for a subscription:
    - refer to valid columns that the claimed role may access
    - values are coercable to the correct column type
    */
    declare
        col_names text[] = coalesce(
                array_agg(c.column_name order by c.ordinal_position),
                '{}'::text[]
            )
            from
                information_schema.columns c
            where
                format('%I.%I', c.table_schema, c.table_name)::regclass = new.entity
                and pg_catalog.has_column_privilege(
                    (new.claims ->> 'role'),
                    format('%I.%I', c.table_schema, c.table_name)::regclass,
                    c.column_name,
                    'SELECT'
                );
        filter realtime.user_defined_filter;
        col_type regtype;

        in_val jsonb;
    begin
        for filter in select * from unnest(new.filters) loop
            -- Filtered column is valid
            if not filter.column_name = any(col_names) then
                raise exception 'invalid column for filter %', filter.column_name;
            end if;

            -- Type is sanitized and safe for string interpolation
            col_type = (
                select atttypid::regtype
                from pg_catalog.pg_attribute
                where attrelid = new.entity
                      and attname = filter.column_name
            );
            if col_type is null then
                raise exception 'failed to lookup type for column %', filter.column_name;
            end if;

            -- Set maximum number of entries for in filter
            if filter.op = 'in'::realtime.equality_op then
                in_val = realtime.cast(filter.value, (col_type::text || '[]')::regtype);
                if coalesce(jsonb_array_length(in_val), 0) > 100 then
                    raise exception 'too many values for `in` filter. Maximum 100';
                end if;
            else
                -- raises an exception if value is not coercable to type
                perform realtime.cast(filter.value, col_type);
            end if;

        end loop;

        -- Apply consistent order to filters so the unique constraint on
        -- (subscription_id, entity, filters) can't be tricked by a different filter order
        new.filters = coalesce(
            array_agg(f order by f.column_name, f.op, f.value),
            '{}'
        ) from unnest(new.filters) f;

        return new;
    end;
    $$;


ALTER FUNCTION realtime.subscription_check_filters() OWNER TO supabase_admin;

--
-- Name: to_regrole(text); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.to_regrole(role_name text) RETURNS regrole
    LANGUAGE sql IMMUTABLE
    AS $$ select role_name::regrole $$;


ALTER FUNCTION realtime.to_regrole(role_name text) OWNER TO supabase_admin;

--
-- Name: topic(); Type: FUNCTION; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE FUNCTION realtime.topic() RETURNS text
    LANGUAGE sql STABLE
    AS $$
select nullif(current_setting('realtime.topic', true), '')::text;
$$;


ALTER FUNCTION realtime.topic() OWNER TO supabase_realtime_admin;

--
-- Name: can_insert_object(text, text, uuid, jsonb); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "storage"."objects" ("bucket_id", "name", "owner", "metadata") VALUES (bucketid, name, owner, metadata);
  -- hack to rollback the successful insert
  RAISE sqlstate 'PT200' using
  message = 'ROLLBACK',
  detail = 'rollback successful insert';
END
$$;


ALTER FUNCTION storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb) OWNER TO supabase_storage_admin;

--
-- Name: extension(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.extension(name text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
_parts text[];
_filename text;
BEGIN
	select string_to_array(name, '/') into _parts;
	select _parts[array_length(_parts,1)] into _filename;
	-- @todo return the last part instead of 2
	return reverse(split_part(reverse(_filename), '.', 1));
END
$$;


ALTER FUNCTION storage.extension(name text) OWNER TO supabase_storage_admin;

--
-- Name: filename(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.filename(name text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
_parts text[];
BEGIN
	select string_to_array(name, '/') into _parts;
	return _parts[array_length(_parts,1)];
END
$$;


ALTER FUNCTION storage.filename(name text) OWNER TO supabase_storage_admin;

--
-- Name: foldername(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.foldername(name text) RETURNS text[]
    LANGUAGE plpgsql
    AS $$
DECLARE
_parts text[];
BEGIN
	select string_to_array(name, '/') into _parts;
	return _parts[1:array_length(_parts,1)-1];
END
$$;


ALTER FUNCTION storage.foldername(name text) OWNER TO supabase_storage_admin;

--
-- Name: get_size_by_bucket(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.get_size_by_bucket() RETURNS TABLE(size bigint, bucket_id text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    return query
        select sum((metadata->>'size')::int) as size, obj.bucket_id
        from "storage".objects as obj
        group by obj.bucket_id;
END
$$;


ALTER FUNCTION storage.get_size_by_bucket() OWNER TO supabase_storage_admin;

--
-- Name: list_multipart_uploads_with_delimiter(text, text, text, integer, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, next_key_token text DEFAULT ''::text, next_upload_token text DEFAULT ''::text) RETURNS TABLE(key text, id text, created_at timestamp with time zone)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(key COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                        substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1)))
                    ELSE
                        key
                END AS key, id, created_at
            FROM
                storage.s3_multipart_uploads
            WHERE
                bucket_id = $5 AND
                key ILIKE $1 || ''%'' AND
                CASE
                    WHEN $4 != '''' AND $6 = '''' THEN
                        CASE
                            WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                                substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                key COLLATE "C" > $4
                            END
                    ELSE
                        true
                END AND
                CASE
                    WHEN $6 != '''' THEN
                        id COLLATE "C" > $6
                    ELSE
                        true
                    END
            ORDER BY
                key COLLATE "C" ASC, created_at ASC) as e order by key COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_key_token, bucket_id, next_upload_token;
END;
$_$;


ALTER FUNCTION storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer, next_key_token text, next_upload_token text) OWNER TO supabase_storage_admin;

--
-- Name: list_objects_with_delimiter(text, text, text, integer, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.list_objects_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, start_after text DEFAULT ''::text, next_token text DEFAULT ''::text) RETURNS TABLE(name text, id uuid, metadata jsonb, updated_at timestamp with time zone)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(name COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(name from length($1) + 1)) > 0 THEN
                        substring(name from 1 for length($1) + position($2 IN substring(name from length($1) + 1)))
                    ELSE
                        name
                END AS name, id, metadata, updated_at
            FROM
                storage.objects
            WHERE
                bucket_id = $5 AND
                name ILIKE $1 || ''%'' AND
                CASE
                    WHEN $6 != '''' THEN
                    name COLLATE "C" > $6
                ELSE true END
                AND CASE
                    WHEN $4 != '''' THEN
                        CASE
                            WHEN position($2 IN substring(name from length($1) + 1)) > 0 THEN
                                substring(name from 1 for length($1) + position($2 IN substring(name from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                name COLLATE "C" > $4
                            END
                    ELSE
                        true
                END
            ORDER BY
                name COLLATE "C" ASC) as e order by name COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_token, bucket_id, start_after;
END;
$_$;


ALTER FUNCTION storage.list_objects_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer, start_after text, next_token text) OWNER TO supabase_storage_admin;

--
-- Name: operation(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.operation() RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    RETURN current_setting('storage.operation', true);
END;
$$;


ALTER FUNCTION storage.operation() OWNER TO supabase_storage_admin;

--
-- Name: search(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.search(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
declare
  v_order_by text;
  v_sort_order text;
begin
  case
    when sortcolumn = 'name' then
      v_order_by = 'name';
    when sortcolumn = 'updated_at' then
      v_order_by = 'updated_at';
    when sortcolumn = 'created_at' then
      v_order_by = 'created_at';
    when sortcolumn = 'last_accessed_at' then
      v_order_by = 'last_accessed_at';
    else
      v_order_by = 'name';
  end case;

  case
    when sortorder = 'asc' then
      v_sort_order = 'asc';
    when sortorder = 'desc' then
      v_sort_order = 'desc';
    else
      v_sort_order = 'asc';
  end case;

  v_order_by = v_order_by || ' ' || v_sort_order;

  return query execute
    'with folders as (
       select path_tokens[$1] as folder
       from storage.objects
         where objects.name ilike $2 || $3 || ''%''
           and bucket_id = $4
           and array_length(objects.path_tokens, 1) <> $1
       group by folder
       order by folder ' || v_sort_order || '
     )
     (select folder as "name",
            null as id,
            null as updated_at,
            null as created_at,
            null as last_accessed_at,
            null as metadata from folders)
     union all
     (select path_tokens[$1] as "name",
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
     from storage.objects
     where objects.name ilike $2 || $3 || ''%''
       and bucket_id = $4
       and array_length(objects.path_tokens, 1) = $1
     order by ' || v_order_by || ')
     limit $5
     offset $6' using levels, prefix, search, bucketname, limits, offsets;
end;
$_$;


ALTER FUNCTION storage.search(prefix text, bucketname text, limits integer, levels integer, offsets integer, search text, sortcolumn text, sortorder text) OWNER TO supabase_storage_admin;

--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW; 
END;
$$;


ALTER FUNCTION storage.update_updated_at_column() OWNER TO supabase_storage_admin;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audit_log_entries; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.audit_log_entries (
    instance_id uuid,
    id uuid NOT NULL,
    payload json,
    created_at timestamp with time zone,
    ip_address character varying(64) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE auth.audit_log_entries OWNER TO supabase_auth_admin;

--
-- Name: TABLE audit_log_entries; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.audit_log_entries IS 'Auth: Audit trail for user actions.';


--
-- Name: flow_state; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.flow_state (
    id uuid NOT NULL,
    user_id uuid,
    auth_code text NOT NULL,
    code_challenge_method auth.code_challenge_method NOT NULL,
    code_challenge text NOT NULL,
    provider_type text NOT NULL,
    provider_access_token text,
    provider_refresh_token text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    authentication_method text NOT NULL,
    auth_code_issued_at timestamp with time zone
);


ALTER TABLE auth.flow_state OWNER TO supabase_auth_admin;

--
-- Name: TABLE flow_state; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.flow_state IS 'stores metadata for pkce logins';


--
-- Name: identities; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.identities (
    provider_id text NOT NULL,
    user_id uuid NOT NULL,
    identity_data jsonb NOT NULL,
    provider text NOT NULL,
    last_sign_in_at timestamp with time zone,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    email text GENERATED ALWAYS AS (lower((identity_data ->> 'email'::text))) STORED,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE auth.identities OWNER TO supabase_auth_admin;

--
-- Name: TABLE identities; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.identities IS 'Auth: Stores identities associated to a user.';


--
-- Name: COLUMN identities.email; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.identities.email IS 'Auth: Email is a generated column that references the optional email property in the identity_data';


--
-- Name: instances; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.instances (
    id uuid NOT NULL,
    uuid uuid,
    raw_base_config text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE auth.instances OWNER TO supabase_auth_admin;

--
-- Name: TABLE instances; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.instances IS 'Auth: Manages users across multiple sites.';


--
-- Name: mfa_amr_claims; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.mfa_amr_claims (
    session_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    authentication_method text NOT NULL,
    id uuid NOT NULL
);


ALTER TABLE auth.mfa_amr_claims OWNER TO supabase_auth_admin;

--
-- Name: TABLE mfa_amr_claims; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_amr_claims IS 'auth: stores authenticator method reference claims for multi factor authentication';


--
-- Name: mfa_challenges; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.mfa_challenges (
    id uuid NOT NULL,
    factor_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    verified_at timestamp with time zone,
    ip_address inet NOT NULL,
    otp_code text,
    web_authn_session_data jsonb
);


ALTER TABLE auth.mfa_challenges OWNER TO supabase_auth_admin;

--
-- Name: TABLE mfa_challenges; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_challenges IS 'auth: stores metadata about challenge requests made';


--
-- Name: mfa_factors; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.mfa_factors (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    friendly_name text,
    factor_type auth.factor_type NOT NULL,
    status auth.factor_status NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    secret text,
    phone text,
    last_challenged_at timestamp with time zone,
    web_authn_credential jsonb,
    web_authn_aaguid uuid
);


ALTER TABLE auth.mfa_factors OWNER TO supabase_auth_admin;

--
-- Name: TABLE mfa_factors; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_factors IS 'auth: stores metadata about factors';


--
-- Name: one_time_tokens; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.one_time_tokens (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    token_type auth.one_time_token_type NOT NULL,
    token_hash text NOT NULL,
    relates_to text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT one_time_tokens_token_hash_check CHECK ((char_length(token_hash) > 0))
);


ALTER TABLE auth.one_time_tokens OWNER TO supabase_auth_admin;

--
-- Name: refresh_tokens; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.refresh_tokens (
    instance_id uuid,
    id bigint NOT NULL,
    token character varying(255),
    user_id character varying(255),
    revoked boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    parent character varying(255),
    session_id uuid
);


ALTER TABLE auth.refresh_tokens OWNER TO supabase_auth_admin;

--
-- Name: TABLE refresh_tokens; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.refresh_tokens IS 'Auth: Store of tokens used to refresh JWT tokens once they expire.';


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE; Schema: auth; Owner: supabase_auth_admin
--

CREATE SEQUENCE auth.refresh_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE auth.refresh_tokens_id_seq OWNER TO supabase_auth_admin;

--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: auth; Owner: supabase_auth_admin
--

ALTER SEQUENCE auth.refresh_tokens_id_seq OWNED BY auth.refresh_tokens.id;


--
-- Name: saml_providers; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.saml_providers (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    entity_id text NOT NULL,
    metadata_xml text NOT NULL,
    metadata_url text,
    attribute_mapping jsonb,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    name_id_format text,
    CONSTRAINT "entity_id not empty" CHECK ((char_length(entity_id) > 0)),
    CONSTRAINT "metadata_url not empty" CHECK (((metadata_url = NULL::text) OR (char_length(metadata_url) > 0))),
    CONSTRAINT "metadata_xml not empty" CHECK ((char_length(metadata_xml) > 0))
);


ALTER TABLE auth.saml_providers OWNER TO supabase_auth_admin;

--
-- Name: TABLE saml_providers; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.saml_providers IS 'Auth: Manages SAML Identity Provider connections.';


--
-- Name: saml_relay_states; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.saml_relay_states (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    request_id text NOT NULL,
    for_email text,
    redirect_to text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    flow_state_id uuid,
    CONSTRAINT "request_id not empty" CHECK ((char_length(request_id) > 0))
);


ALTER TABLE auth.saml_relay_states OWNER TO supabase_auth_admin;

--
-- Name: TABLE saml_relay_states; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.saml_relay_states IS 'Auth: Contains SAML Relay State information for each Service Provider initiated login.';


--
-- Name: schema_migrations; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.schema_migrations (
    version character varying(255) NOT NULL
);


ALTER TABLE auth.schema_migrations OWNER TO supabase_auth_admin;

--
-- Name: TABLE schema_migrations; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.schema_migrations IS 'Auth: Manages updates to the auth system.';


--
-- Name: sessions; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sessions (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    factor_id uuid,
    aal auth.aal_level,
    not_after timestamp with time zone,
    refreshed_at timestamp without time zone,
    user_agent text,
    ip inet,
    tag text
);


ALTER TABLE auth.sessions OWNER TO supabase_auth_admin;

--
-- Name: TABLE sessions; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sessions IS 'Auth: Stores session data associated to a user.';


--
-- Name: COLUMN sessions.not_after; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.sessions.not_after IS 'Auth: Not after is a nullable column that contains a timestamp after which the session should be regarded as expired.';


--
-- Name: sso_domains; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sso_domains (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    domain text NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT "domain not empty" CHECK ((char_length(domain) > 0))
);


ALTER TABLE auth.sso_domains OWNER TO supabase_auth_admin;

--
-- Name: TABLE sso_domains; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sso_domains IS 'Auth: Manages SSO email address domain mapping to an SSO Identity Provider.';


--
-- Name: sso_providers; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sso_providers (
    id uuid NOT NULL,
    resource_id text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT "resource_id not empty" CHECK (((resource_id = NULL::text) OR (char_length(resource_id) > 0)))
);


ALTER TABLE auth.sso_providers OWNER TO supabase_auth_admin;

--
-- Name: TABLE sso_providers; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sso_providers IS 'Auth: Manages SSO identity provider information; see saml_providers for SAML.';


--
-- Name: COLUMN sso_providers.resource_id; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.sso_providers.resource_id IS 'Auth: Uniquely identifies a SSO provider according to a user-chosen resource ID (case insensitive), useful in infrastructure as code.';


--
-- Name: users; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.users (
    instance_id uuid,
    id uuid NOT NULL,
    aud character varying(255),
    role character varying(255),
    email character varying(255),
    encrypted_password character varying(255),
    email_confirmed_at timestamp with time zone,
    invited_at timestamp with time zone,
    confirmation_token character varying(255),
    confirmation_sent_at timestamp with time zone,
    recovery_token character varying(255),
    recovery_sent_at timestamp with time zone,
    email_change_token_new character varying(255),
    email_change character varying(255),
    email_change_sent_at timestamp with time zone,
    last_sign_in_at timestamp with time zone,
    raw_app_meta_data jsonb,
    raw_user_meta_data jsonb,
    is_super_admin boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    phone text DEFAULT NULL::character varying,
    phone_confirmed_at timestamp with time zone,
    phone_change text DEFAULT ''::character varying,
    phone_change_token character varying(255) DEFAULT ''::character varying,
    phone_change_sent_at timestamp with time zone,
    confirmed_at timestamp with time zone GENERATED ALWAYS AS (LEAST(email_confirmed_at, phone_confirmed_at)) STORED,
    email_change_token_current character varying(255) DEFAULT ''::character varying,
    email_change_confirm_status smallint DEFAULT 0,
    banned_until timestamp with time zone,
    reauthentication_token character varying(255) DEFAULT ''::character varying,
    reauthentication_sent_at timestamp with time zone,
    is_sso_user boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    is_anonymous boolean DEFAULT false NOT NULL,
    CONSTRAINT users_email_change_confirm_status_check CHECK (((email_change_confirm_status >= 0) AND (email_change_confirm_status <= 2)))
);


ALTER TABLE auth.users OWNER TO supabase_auth_admin;

--
-- Name: TABLE users; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.users IS 'Auth: Stores user login data within a secure schema.';


--
-- Name: COLUMN users.is_sso_user; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.users.is_sso_user IS 'Auth: Set this column to true when the account comes from SSO. These accounts can have duplicate emails.';


--
-- Name: achievement_assignments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.achievement_assignments (
    id integer NOT NULL,
    achievement_id integer,
    assigned_by uuid,
    assigned_to uuid,
    reason text,
    assigned_at timestamp with time zone DEFAULT now(),
    status character varying(20) DEFAULT 'active'::character varying,
    CONSTRAINT achievement_assignments_status_check CHECK (((status)::text = ANY ((ARRAY['active'::character varying, 'revoked'::character varying, 'pending'::character varying])::text[])))
);


ALTER TABLE public.achievement_assignments OWNER TO postgres;

--
-- Name: achievement_assignments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.achievement_assignments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.achievement_assignments_id_seq OWNER TO postgres;

--
-- Name: achievement_assignments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.achievement_assignments_id_seq OWNED BY public.achievement_assignments.id;


--
-- Name: achievement_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.achievement_types (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    icon_name character varying(50),
    color character varying(20),
    category character varying(50),
    points_reward integer DEFAULT 0,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    icon text DEFAULT '🏆'::text,
    trigger_condition text,
    auto_award boolean DEFAULT true
);


ALTER TABLE public.achievement_types OWNER TO postgres;

--
-- Name: achievement_types_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.achievement_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.achievement_types_id_seq OWNER TO postgres;

--
-- Name: achievement_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.achievement_types_id_seq OWNED BY public.achievement_types.id;


--
-- Name: activity_participations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.activity_participations (
    id integer NOT NULL,
    activity_id integer,
    user_id uuid,
    participation_status character varying(20) DEFAULT 'registered'::character varying,
    completion_notes text,
    points_earned integer DEFAULT 0,
    completed_at timestamp with time zone,
    registered_at timestamp with time zone DEFAULT now(),
    CONSTRAINT activity_participations_participation_status_check CHECK (((participation_status)::text = ANY ((ARRAY['registered'::character varying, 'completed'::character varying, 'withdrawn'::character varying, 'disqualified'::character varying])::text[])))
);


ALTER TABLE public.activity_participations OWNER TO postgres;

--
-- Name: activity_participations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.activity_participations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.activity_participations_id_seq OWNER TO postgres;

--
-- Name: activity_participations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.activity_participations_id_seq OWNED BY public.activity_participations.id;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categories (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    icon character varying(50),
    color character varying(7),
    order_index integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.categories OWNER TO postgres;

--
-- Name: challenge_attempts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.challenge_attempts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    challenge_id uuid,
    user_id uuid,
    house_id integer,
    status text DEFAULT 'in_progress'::text,
    score integer,
    evidence_url text,
    created_at timestamp with time zone DEFAULT now(),
    completed_at timestamp with time zone,
    CONSTRAINT challenge_attempts_status_check CHECK ((status = ANY (ARRAY['in_progress'::text, 'completed'::text, 'rejected'::text])))
);


ALTER TABLE public.challenge_attempts OWNER TO postgres;

--
-- Name: challenges; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.challenges (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    slug text NOT NULL,
    title text NOT NULL,
    description text,
    scope text NOT NULL,
    reward_points integer NOT NULL,
    target_count integer,
    start_at timestamp with time zone NOT NULL,
    end_at timestamp with time zone NOT NULL,
    status text DEFAULT 'draft'::text,
    created_by uuid,
    metadata jsonb,
    CONSTRAINT challenges_scope_check CHECK ((scope = ANY (ARRAY['individual'::text, 'house'::text]))),
    CONSTRAINT challenges_status_check CHECK ((status = ANY (ARRAY['draft'::text, 'active'::text, 'completed'::text, 'cancelled'::text])))
);


ALTER TABLE public.challenges OWNER TO postgres;

--
-- Name: comments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.comments (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    post_id uuid NOT NULL,
    user_id uuid NOT NULL,
    content text NOT NULL,
    is_solution boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.comments OWNER TO postgres;

--
-- Name: event_participants; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.event_participants (
    event_id uuid NOT NULL,
    user_id uuid NOT NULL,
    status text DEFAULT 'joined'::text,
    submission_url text,
    points_awarded integer DEFAULT 0,
    joined_at timestamp with time zone DEFAULT now(),
    CONSTRAINT event_participants_status_check CHECK ((status = ANY (ARRAY['joined'::text, 'submitted'::text, 'disqualified'::text, 'winner'::text])))
);


ALTER TABLE public.event_participants OWNER TO postgres;

--
-- Name: events; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    slug text NOT NULL,
    title text NOT NULL,
    description text,
    type text NOT NULL,
    featured boolean DEFAULT false,
    cover_url text,
    reward_points integer DEFAULT 0,
    start_at timestamp with time zone NOT NULL,
    end_at timestamp with time zone NOT NULL,
    status text DEFAULT 'draft'::text,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now(),
    metadata jsonb,
    CONSTRAINT events_status_check CHECK ((status = ANY (ARRAY['draft'::text, 'active'::text, 'completed'::text, 'cancelled'::text]))),
    CONSTRAINT events_type_check CHECK ((type = ANY (ARRAY['tournament'::text, 'contest'::text, 'celebration'::text])))
);


ALTER TABLE public.events OWNER TO postgres;

--
-- Name: followers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.followers (
    id integer NOT NULL,
    user_id uuid,
    follower_id uuid,
    followed_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT followers_check CHECK ((user_id <> follower_id))
);


ALTER TABLE public.followers OWNER TO postgres;

--
-- Name: followers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.followers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.followers_id_seq OWNER TO postgres;

--
-- Name: followers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.followers_id_seq OWNED BY public.followers.id;


--
-- Name: forum_user_stats; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.forum_user_stats (
    user_id uuid NOT NULL,
    total_posts integer DEFAULT 0,
    total_comments integer DEFAULT 0,
    total_likes_received integer DEFAULT 0,
    reputation_points integer DEFAULT 0,
    is_moderator boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.forum_user_stats OWNER TO postgres;

--
-- Name: friendships; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.friendships (
    id integer NOT NULL,
    user_id uuid,
    friend_id uuid,
    status text DEFAULT 'pending'::text,
    requested_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    responded_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT friendships_check CHECK ((user_id <> friend_id)),
    CONSTRAINT friendships_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'accepted'::text, 'declined'::text, 'blocked'::text])))
);


ALTER TABLE public.friendships OWNER TO postgres;

--
-- Name: friendships_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.friendships_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.friendships_id_seq OWNER TO postgres;

--
-- Name: friendships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.friendships_id_seq OWNED BY public.friendships.id;


--
-- Name: house_activities; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.house_activities (
    id integer NOT NULL,
    house character varying(20),
    title character varying(200) NOT NULL,
    description text,
    activity_type character varying(50),
    points_reward integer DEFAULT 0,
    start_date timestamp with time zone,
    end_date timestamp with time zone,
    created_by uuid,
    is_active boolean DEFAULT true,
    max_participants integer,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT house_activities_house_check CHECK (((house)::text = ANY ((ARRAY['gryffindor'::character varying, 'hufflepuff'::character varying, 'ravenclaw'::character varying, 'slytherin'::character varying])::text[])))
);


ALTER TABLE public.house_activities OWNER TO postgres;

--
-- Name: house_activities_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.house_activities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.house_activities_id_seq OWNER TO postgres;

--
-- Name: house_activities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.house_activities_id_seq OWNED BY public.house_activities.id;


--
-- Name: house_challenge_progress; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.house_challenge_progress (
    challenge_id uuid NOT NULL,
    house_id integer NOT NULL,
    progress_count integer DEFAULT 0,
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.house_challenge_progress OWNER TO postgres;

--
-- Name: house_points_ledger; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.house_points_ledger (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    house_id integer,
    user_id uuid,
    source text,
    source_id uuid,
    points integer NOT NULL,
    note text,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT house_points_ledger_source_check CHECK ((source = ANY (ARRAY['event'::text, 'challenge'::text, 'vote'::text, 'manual'::text])))
);


ALTER TABLE public.house_points_ledger OWNER TO postgres;

--
-- Name: houses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.houses (
    id integer NOT NULL,
    name text NOT NULL,
    description text,
    color text,
    emblem_url text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.houses OWNER TO postgres;

--
-- Name: houses_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.houses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.houses_id_seq OWNER TO postgres;

--
-- Name: houses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.houses_id_seq OWNED BY public.houses.id;


--
-- Name: likes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.likes (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    post_id uuid,
    comment_id uuid,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT like_target CHECK ((((post_id IS NOT NULL) AND (comment_id IS NULL)) OR ((post_id IS NULL) AND (comment_id IS NOT NULL))))
);


ALTER TABLE public.likes OWNER TO postgres;

--
-- Name: moderation_reports; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.moderation_reports (
    id integer NOT NULL,
    reported_user_id uuid,
    reported_by uuid,
    report_type character varying(50),
    description text,
    status character varying(20) DEFAULT 'pending'::character varying,
    reviewed_by uuid,
    resolution_notes text,
    created_at timestamp with time zone DEFAULT now(),
    resolved_at timestamp with time zone,
    CONSTRAINT moderation_reports_status_check CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'reviewed'::character varying, 'resolved'::character varying, 'dismissed'::character varying])::text[])))
);


ALTER TABLE public.moderation_reports OWNER TO postgres;

--
-- Name: moderation_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.moderation_reports_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.moderation_reports_id_seq OWNER TO postgres;

--
-- Name: moderation_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.moderation_reports_id_seq OWNED BY public.moderation_reports.id;


--
-- Name: poll_options; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.poll_options (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    poll_id uuid,
    label text NOT NULL,
    author text,
    media_url text,
    sort_order integer DEFAULT 0
);


ALTER TABLE public.poll_options OWNER TO postgres;

--
-- Name: polls; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.polls (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    slug text NOT NULL,
    title text NOT NULL,
    description text,
    context jsonb,
    start_at timestamp with time zone NOT NULL,
    end_at timestamp with time zone NOT NULL,
    status text DEFAULT 'draft'::text,
    CONSTRAINT polls_status_check CHECK ((status = ANY (ARRAY['draft'::text, 'active'::text, 'completed'::text, 'cancelled'::text])))
);


ALTER TABLE public.polls OWNER TO postgres;

--
-- Name: posts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.posts (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    house_id integer,
    category_id uuid NOT NULL,
    title character varying(255) NOT NULL,
    content text NOT NULL,
    status public.post_status DEFAULT 'open'::public.post_status,
    views integer DEFAULT 0,
    is_pinned boolean DEFAULT false,
    is_featured boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.posts OWNER TO postgres;

--
-- Name: profile_shares; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.profile_shares (
    id integer NOT NULL,
    user_id uuid,
    share_token character varying(50) NOT NULL,
    platform character varying(20),
    clicks_count integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now(),
    expires_at timestamp with time zone
);


ALTER TABLE public.profile_shares OWNER TO postgres;

--
-- Name: profile_shares_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.profile_shares_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.profile_shares_id_seq OWNER TO postgres;

--
-- Name: profile_shares_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.profile_shares_id_seq OWNED BY public.profile_shares.id;


--
-- Name: profiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.profiles (
    id uuid NOT NULL,
    first_name text,
    last_name text,
    wizard_name text NOT NULL,
    email text NOT NULL,
    house text,
    avatar_url text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    house_selected_at timestamp with time zone,
    role character varying(20) DEFAULT 'student'::character varying
);


ALTER TABLE public.profiles OWNER TO postgres;

--
-- Name: social_notifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.social_notifications (
    id integer NOT NULL,
    user_id uuid,
    from_user_id uuid,
    type text NOT NULL,
    message text,
    is_read boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    expires_at timestamp with time zone DEFAULT (CURRENT_TIMESTAMP + '30 days'::interval),
    CONSTRAINT social_notifications_type_check CHECK ((type = ANY (ARRAY['friend_request'::text, 'friend_accepted'::text, 'new_follower'::text, 'house_mention'::text])))
);


ALTER TABLE public.social_notifications OWNER TO postgres;

--
-- Name: social_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.social_notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.social_notifications_id_seq OWNER TO postgres;

--
-- Name: social_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.social_notifications_id_seq OWNED BY public.social_notifications.id;


--
-- Name: system_notifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.system_notifications (
    id integer NOT NULL,
    user_id uuid,
    title character varying(200),
    message text,
    notification_type character varying(50),
    is_read boolean DEFAULT false,
    action_url text,
    created_at timestamp with time zone DEFAULT now(),
    expires_at timestamp with time zone
);


ALTER TABLE public.system_notifications OWNER TO postgres;

--
-- Name: system_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.system_notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.system_notifications_id_seq OWNER TO postgres;

--
-- Name: system_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.system_notifications_id_seq OWNED BY public.system_notifications.id;


--
-- Name: user_achievements; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_achievements (
    id integer NOT NULL,
    user_id uuid,
    achievement_type_id integer,
    awarded_by uuid,
    awarded_at timestamp with time zone DEFAULT now(),
    description text,
    is_featured boolean DEFAULT false,
    reason text
);


ALTER TABLE public.user_achievements OWNER TO postgres;

--
-- Name: user_achievements_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_achievements_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_achievements_id_seq OWNER TO postgres;

--
-- Name: user_achievements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_achievements_id_seq OWNED BY public.user_achievements.id;


--
-- Name: user_activities; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_activities (
    id integer NOT NULL,
    user_id uuid,
    activity_type character varying(50),
    title character varying(200),
    description text,
    points_earned integer DEFAULT 0,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.user_activities OWNER TO postgres;

--
-- Name: user_activities_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_activities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_activities_id_seq OWNER TO postgres;

--
-- Name: user_activities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_activities_id_seq OWNED BY public.user_activities.id;


--
-- Name: user_connections; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_connections (
    id integer NOT NULL,
    follower_id uuid,
    following_id uuid,
    connection_type character varying(20) DEFAULT 'follow'::character varying,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.user_connections OWNER TO postgres;

--
-- Name: user_connections_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_connections_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_connections_id_seq OWNER TO postgres;

--
-- Name: user_connections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_connections_id_seq OWNED BY public.user_connections.id;


--
-- Name: user_points_ledger; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_points_ledger (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    source text,
    source_id uuid,
    points integer NOT NULL,
    note text,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT user_points_ledger_source_check CHECK ((source = ANY (ARRAY['event'::text, 'challenge'::text, 'vote'::text, 'manual'::text])))
);


ALTER TABLE public.user_points_ledger OWNER TO postgres;

--
-- Name: user_profiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_profiles (
    id uuid NOT NULL,
    display_name character varying(100),
    bio text,
    avatar_url text,
    house character varying(20),
    house_points integer DEFAULT 0,
    reputation_level integer DEFAULT 1,
    join_date timestamp with time zone DEFAULT now(),
    contributions_count integer DEFAULT 0,
    is_house_head boolean DEFAULT false,
    is_prefect boolean DEFAULT false,
    specialization character varying(100),
    favorite_topics text[],
    privacy_public_profile boolean DEFAULT true,
    privacy_show_stats boolean DEFAULT true,
    privacy_allow_messages boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    role character varying(20) DEFAULT 'student'::character varying,
    CONSTRAINT user_profiles_house_check CHECK (((house)::text = ANY ((ARRAY['gryffindor'::character varying, 'hufflepuff'::character varying, 'ravenclaw'::character varying, 'slytherin'::character varying])::text[]))),
    CONSTRAINT user_profiles_role_check CHECK (((role)::text = ANY ((ARRAY['student'::character varying, 'prefect'::character varying, 'house_head'::character varying, 'admin'::character varying])::text[])))
);


ALTER TABLE public.user_profiles OWNER TO postgres;

--
-- Name: user_statistics; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_statistics (
    id integer NOT NULL,
    user_id uuid,
    stat_name text NOT NULL,
    stat_value integer DEFAULT 0,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.user_statistics OWNER TO postgres;

--
-- Name: user_statistics_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_statistics_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_statistics_id_seq OWNER TO postgres;

--
-- Name: user_statistics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_statistics_id_seq OWNED BY public.user_statistics.id;


--
-- Name: v_event_participants_counts; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.v_event_participants_counts AS
 SELECT event_id,
    count(DISTINCT user_id) AS participants_count
   FROM public.event_participants
  GROUP BY event_id
  WITH NO DATA;


ALTER MATERIALIZED VIEW public.v_event_participants_counts OWNER TO postgres;

--
-- Name: votes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.votes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    poll_id uuid,
    user_id uuid,
    option_id uuid,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.votes OWNER TO postgres;

--
-- Name: messages; Type: TABLE; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE TABLE realtime.messages (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
)
PARTITION BY RANGE (inserted_at);


ALTER TABLE realtime.messages OWNER TO supabase_realtime_admin;

--
-- Name: messages_2025_08_29; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.messages_2025_08_29 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE realtime.messages_2025_08_29 OWNER TO supabase_admin;

--
-- Name: messages_2025_08_30; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.messages_2025_08_30 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE realtime.messages_2025_08_30 OWNER TO supabase_admin;

--
-- Name: messages_2025_08_31; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.messages_2025_08_31 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE realtime.messages_2025_08_31 OWNER TO supabase_admin;

--
-- Name: messages_2025_09_01; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.messages_2025_09_01 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE realtime.messages_2025_09_01 OWNER TO supabase_admin;

--
-- Name: messages_2025_09_02; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.messages_2025_09_02 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE realtime.messages_2025_09_02 OWNER TO supabase_admin;

--
-- Name: messages_2025_09_03; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.messages_2025_09_03 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE realtime.messages_2025_09_03 OWNER TO supabase_admin;

--
-- Name: messages_2025_09_04; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.messages_2025_09_04 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE realtime.messages_2025_09_04 OWNER TO supabase_admin;

--
-- Name: schema_migrations; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


ALTER TABLE realtime.schema_migrations OWNER TO supabase_admin;

--
-- Name: subscription; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.subscription (
    id bigint NOT NULL,
    subscription_id uuid NOT NULL,
    entity regclass NOT NULL,
    filters realtime.user_defined_filter[] DEFAULT '{}'::realtime.user_defined_filter[] NOT NULL,
    claims jsonb NOT NULL,
    claims_role regrole GENERATED ALWAYS AS (realtime.to_regrole((claims ->> 'role'::text))) STORED NOT NULL,
    created_at timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);


ALTER TABLE realtime.subscription OWNER TO supabase_admin;

--
-- Name: subscription_id_seq; Type: SEQUENCE; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE realtime.subscription ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME realtime.subscription_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: buckets; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.buckets (
    id text NOT NULL,
    name text NOT NULL,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    public boolean DEFAULT false,
    avif_autodetection boolean DEFAULT false,
    file_size_limit bigint,
    allowed_mime_types text[],
    owner_id text
);


ALTER TABLE storage.buckets OWNER TO supabase_storage_admin;

--
-- Name: COLUMN buckets.owner; Type: COMMENT; Schema: storage; Owner: supabase_storage_admin
--

COMMENT ON COLUMN storage.buckets.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: migrations; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.migrations (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    hash character varying(40) NOT NULL,
    executed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE storage.migrations OWNER TO supabase_storage_admin;

--
-- Name: objects; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.objects (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    bucket_id text,
    name text,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    last_accessed_at timestamp with time zone DEFAULT now(),
    metadata jsonb,
    path_tokens text[] GENERATED ALWAYS AS (string_to_array(name, '/'::text)) STORED,
    version text,
    owner_id text,
    user_metadata jsonb
);


ALTER TABLE storage.objects OWNER TO supabase_storage_admin;

--
-- Name: COLUMN objects.owner; Type: COMMENT; Schema: storage; Owner: supabase_storage_admin
--

COMMENT ON COLUMN storage.objects.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: s3_multipart_uploads; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.s3_multipart_uploads (
    id text NOT NULL,
    in_progress_size bigint DEFAULT 0 NOT NULL,
    upload_signature text NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    version text NOT NULL,
    owner_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    user_metadata jsonb
);


ALTER TABLE storage.s3_multipart_uploads OWNER TO supabase_storage_admin;

--
-- Name: s3_multipart_uploads_parts; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.s3_multipart_uploads_parts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    upload_id text NOT NULL,
    size bigint DEFAULT 0 NOT NULL,
    part_number integer NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    etag text NOT NULL,
    owner_id text,
    version text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE storage.s3_multipart_uploads_parts OWNER TO supabase_storage_admin;

--
-- Name: messages_2025_08_29; Type: TABLE ATTACH; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2025_08_29 FOR VALUES FROM ('2025-08-29 00:00:00') TO ('2025-08-30 00:00:00');


--
-- Name: messages_2025_08_30; Type: TABLE ATTACH; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2025_08_30 FOR VALUES FROM ('2025-08-30 00:00:00') TO ('2025-08-31 00:00:00');


--
-- Name: messages_2025_08_31; Type: TABLE ATTACH; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2025_08_31 FOR VALUES FROM ('2025-08-31 00:00:00') TO ('2025-09-01 00:00:00');


--
-- Name: messages_2025_09_01; Type: TABLE ATTACH; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2025_09_01 FOR VALUES FROM ('2025-09-01 00:00:00') TO ('2025-09-02 00:00:00');


--
-- Name: messages_2025_09_02; Type: TABLE ATTACH; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2025_09_02 FOR VALUES FROM ('2025-09-02 00:00:00') TO ('2025-09-03 00:00:00');


--
-- Name: messages_2025_09_03; Type: TABLE ATTACH; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2025_09_03 FOR VALUES FROM ('2025-09-03 00:00:00') TO ('2025-09-04 00:00:00');


--
-- Name: messages_2025_09_04; Type: TABLE ATTACH; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2025_09_04 FOR VALUES FROM ('2025-09-04 00:00:00') TO ('2025-09-05 00:00:00');


--
-- Name: refresh_tokens id; Type: DEFAULT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens ALTER COLUMN id SET DEFAULT nextval('auth.refresh_tokens_id_seq'::regclass);


--
-- Name: achievement_assignments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.achievement_assignments ALTER COLUMN id SET DEFAULT nextval('public.achievement_assignments_id_seq'::regclass);


--
-- Name: achievement_types id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.achievement_types ALTER COLUMN id SET DEFAULT nextval('public.achievement_types_id_seq'::regclass);


--
-- Name: activity_participations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activity_participations ALTER COLUMN id SET DEFAULT nextval('public.activity_participations_id_seq'::regclass);


--
-- Name: followers id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.followers ALTER COLUMN id SET DEFAULT nextval('public.followers_id_seq'::regclass);


--
-- Name: friendships id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.friendships ALTER COLUMN id SET DEFAULT nextval('public.friendships_id_seq'::regclass);


--
-- Name: house_activities id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.house_activities ALTER COLUMN id SET DEFAULT nextval('public.house_activities_id_seq'::regclass);


--
-- Name: houses id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.houses ALTER COLUMN id SET DEFAULT nextval('public.houses_id_seq'::regclass);


--
-- Name: moderation_reports id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.moderation_reports ALTER COLUMN id SET DEFAULT nextval('public.moderation_reports_id_seq'::regclass);


--
-- Name: profile_shares id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profile_shares ALTER COLUMN id SET DEFAULT nextval('public.profile_shares_id_seq'::regclass);


--
-- Name: social_notifications id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.social_notifications ALTER COLUMN id SET DEFAULT nextval('public.social_notifications_id_seq'::regclass);


--
-- Name: system_notifications id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.system_notifications ALTER COLUMN id SET DEFAULT nextval('public.system_notifications_id_seq'::regclass);


--
-- Name: user_achievements id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_achievements ALTER COLUMN id SET DEFAULT nextval('public.user_achievements_id_seq'::regclass);


--
-- Name: user_activities id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_activities ALTER COLUMN id SET DEFAULT nextval('public.user_activities_id_seq'::regclass);


--
-- Name: user_connections id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_connections ALTER COLUMN id SET DEFAULT nextval('public.user_connections_id_seq'::regclass);


--
-- Name: user_statistics id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_statistics ALTER COLUMN id SET DEFAULT nextval('public.user_statistics_id_seq'::regclass);


--
-- Data for Name: audit_log_entries; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.audit_log_entries (instance_id, id, payload, created_at, ip_address) FROM stdin;
00000000-0000-0000-0000-000000000000	2e3e838b-fbb2-46d0-aef5-66e4185ab693	{"action":"user_confirmation_requested","actor_id":"511d8cc2-a383-4856-8427-47d60191e6b6","actor_username":"harry.potter@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-07-22 17:47:36.634469+00	
00000000-0000-0000-0000-000000000000	1896e729-40f3-4905-b769-110a167f2ec1	{"action":"user_confirmation_requested","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-07-22 19:51:56.535288+00	
00000000-0000-0000-0000-000000000000	39cd6c92-dacd-4868-9120-2176744e1cc4	{"action":"user_signedup","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-07-22 19:52:43.090782+00	
00000000-0000-0000-0000-000000000000	b0f81990-9326-4e05-a9cc-f2988a7c2b11	{"action":"login","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-07-22 19:53:08.002689+00	
00000000-0000-0000-0000-000000000000	101f3547-40e4-4737-88d1-039dc2076240	{"action":"login","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-07-22 20:07:31.157532+00	
00000000-0000-0000-0000-000000000000	1c56567b-3b5b-4e3d-b911-81bf2145fc54	{"action":"logout","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-07-22 20:08:33.710935+00	
00000000-0000-0000-0000-000000000000	18cf9151-3cb6-4221-acee-0a55fa327153	{"action":"login","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-07-22 20:08:42.25076+00	
00000000-0000-0000-0000-000000000000	de3dbac5-1f24-4537-8cdf-bf1a452d3a98	{"action":"login","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-07-22 20:15:22.955397+00	
00000000-0000-0000-0000-000000000000	9c5323fa-331f-4739-abdb-bf217ba2ff9f	{"action":"login","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-07-22 20:40:55.931585+00	
00000000-0000-0000-0000-000000000000	5cc61970-5196-4fdc-95cc-bfa7d768568b	{"action":"token_refreshed","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-07-23 14:28:53.132038+00	
00000000-0000-0000-0000-000000000000	06af2729-6dbf-4524-a1df-bcdb24531faf	{"action":"token_revoked","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-07-23 14:28:53.139441+00	
00000000-0000-0000-0000-000000000000	94a32b97-3ddf-4e54-bec3-44213a92a47c	{"action":"login","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-07-23 14:35:15.568349+00	
00000000-0000-0000-0000-000000000000	424563a0-053f-46b0-97c4-c8d6d3e7a0c2	{"action":"login","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-07-23 14:36:20.018034+00	
00000000-0000-0000-0000-000000000000	e810cf4e-3308-449e-8da1-bcf1668165dc	{"action":"login","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-07-23 14:38:51.903339+00	
00000000-0000-0000-0000-000000000000	3e5818b3-6ca1-44f5-ad31-84d78de670ed	{"action":"login","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-07-23 15:14:34.921823+00	
00000000-0000-0000-0000-000000000000	fbf7a031-836b-4cf3-836b-b143465e0610	{"action":"login","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-07-23 15:23:15.756229+00	
00000000-0000-0000-0000-000000000000	6b87c637-fe27-4e69-be71-25d34cc813d5	{"action":"logout","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-07-23 15:26:06.727335+00	
00000000-0000-0000-0000-000000000000	6dfd527c-47e6-414d-a2ee-c928bdee094f	{"action":"login","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-07-29 22:08:50.246366+00	
00000000-0000-0000-0000-000000000000	91d44208-6d75-455f-a4c5-64d6a53e3979	{"action":"login","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-07-29 23:07:09.377827+00	
00000000-0000-0000-0000-000000000000	90096cb8-5874-41b9-af5e-a3c5d000aa66	{"action":"token_refreshed","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-07-30 00:05:30.492711+00	
00000000-0000-0000-0000-000000000000	82b38d2d-d52e-43d7-8a82-db890be7be2f	{"action":"token_revoked","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-07-30 00:05:30.495332+00	
00000000-0000-0000-0000-000000000000	7d639b2e-a403-435f-adcf-21684f7948f0	{"action":"logout","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-07-30 00:10:44.236754+00	
00000000-0000-0000-0000-000000000000	57f62c48-742b-4255-bf72-1b76695442be	{"action":"login","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-07-30 00:11:05.97876+00	
00000000-0000-0000-0000-000000000000	56e432f5-5244-41fd-bb04-df5c1126c813	{"action":"token_refreshed","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-07-30 15:56:44.337882+00	
00000000-0000-0000-0000-000000000000	10e3e78e-91a6-4533-bd92-99029e2e8f12	{"action":"token_revoked","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-07-30 15:56:44.347381+00	
00000000-0000-0000-0000-000000000000	a6bc683b-a795-4171-882e-a9aca38d7771	{"action":"token_refreshed","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-07-30 17:44:52.923995+00	
00000000-0000-0000-0000-000000000000	a0691524-117f-4a70-b152-6200b245fe2b	{"action":"token_revoked","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-07-30 17:44:52.925536+00	
00000000-0000-0000-0000-000000000000	1312a87a-613a-404f-a361-a6bc4e8e3c0e	{"action":"token_refreshed","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-07-31 16:45:10.701481+00	
00000000-0000-0000-0000-000000000000	cc3da632-ab7c-43f3-ae67-ef21bbe483ea	{"action":"token_revoked","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-07-31 16:45:10.71646+00	
00000000-0000-0000-0000-000000000000	bf801068-a777-4598-a99b-9ac08b81898a	{"action":"token_refreshed","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-07-31 17:43:38.733145+00	
00000000-0000-0000-0000-000000000000	d97b7517-dd28-4550-a807-563369f24b0f	{"action":"token_revoked","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-07-31 17:43:38.738773+00	
00000000-0000-0000-0000-000000000000	fca9a01a-63a1-4d9e-82f0-37a1d14e5332	{"action":"token_refreshed","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-07-31 19:14:51.38892+00	
00000000-0000-0000-0000-000000000000	5d3b60df-7117-4d3f-92b1-b51d96dfb27f	{"action":"token_revoked","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-07-31 19:14:51.392317+00	
00000000-0000-0000-0000-000000000000	fb8e7728-e395-44b1-92ca-886065df660d	{"action":"token_refreshed","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-07-31 20:12:53.122809+00	
00000000-0000-0000-0000-000000000000	e2a7301e-8f51-4481-a033-bd8fc06b967b	{"action":"token_revoked","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-07-31 20:12:53.124216+00	
00000000-0000-0000-0000-000000000000	a2345c5d-9ac9-4b87-8475-b5b34a290908	{"action":"token_refreshed","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-01 15:46:29.474805+00	
00000000-0000-0000-0000-000000000000	591e1017-fae8-429b-94f4-d1e191853780	{"action":"token_revoked","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-01 15:46:29.487143+00	
00000000-0000-0000-0000-000000000000	4a23dbc7-f132-4872-8e50-d49ab27e5790	{"action":"token_refreshed","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-01 16:56:31.272336+00	
00000000-0000-0000-0000-000000000000	e64efe2a-6bd6-4ac8-92cb-7e53d36de7bf	{"action":"token_revoked","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-01 16:56:31.279088+00	
00000000-0000-0000-0000-000000000000	690dc874-8490-48e7-b633-659a444210d9	{"action":"token_refreshed","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-01 18:29:58.955728+00	
00000000-0000-0000-0000-000000000000	715e7fd2-18d0-494a-8777-8f3c35210807	{"action":"token_revoked","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-01 18:29:58.95789+00	
00000000-0000-0000-0000-000000000000	070e14d1-c65f-4c3b-a8a6-c40708ba77c6	{"action":"token_refreshed","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-01 19:28:04.535645+00	
00000000-0000-0000-0000-000000000000	b454feed-27ad-43ca-997a-417630cc5245	{"action":"token_revoked","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-01 19:28:04.538944+00	
00000000-0000-0000-0000-000000000000	0d31b6de-b4c1-4891-9d15-ad1ad504e660	{"action":"token_refreshed","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-01 20:26:54.963971+00	
00000000-0000-0000-0000-000000000000	c6241490-0a86-4f62-a08e-ea7ffcfa9654	{"action":"token_revoked","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-01 20:26:54.96912+00	
00000000-0000-0000-0000-000000000000	2075fad4-4ead-4c28-ae83-66e991ba1e5b	{"action":"token_refreshed","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-01 21:32:17.181292+00	
00000000-0000-0000-0000-000000000000	ddec2d6b-57c7-472e-8aca-438a390eb3d3	{"action":"token_revoked","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-01 21:32:17.188549+00	
00000000-0000-0000-0000-000000000000	a8481deb-ca81-4b91-b282-65153473d9c4	{"action":"token_refreshed","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-02 13:14:59.541137+00	
00000000-0000-0000-0000-000000000000	1854cbe3-5cbb-408c-bf74-9347ecc0cbaa	{"action":"token_revoked","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-02 13:14:59.558221+00	
00000000-0000-0000-0000-000000000000	46e29c68-e371-444b-ba0c-82cef523b8fa	{"action":"token_refreshed","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-02 15:24:23.234168+00	
00000000-0000-0000-0000-000000000000	7c867ea1-fbbd-44ae-8919-7775eed76ea5	{"action":"token_revoked","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-02 15:24:23.239269+00	
00000000-0000-0000-0000-000000000000	f4024bec-039f-4ec2-b4a1-f01b15011596	{"action":"token_refreshed","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-02 16:22:41.156864+00	
00000000-0000-0000-0000-000000000000	9d317bb9-32a3-415f-847f-1ba4beece5ff	{"action":"token_revoked","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-02 16:22:41.15951+00	
00000000-0000-0000-0000-000000000000	97c84bbd-7da9-4ac3-8444-b537c6485f7d	{"action":"token_refreshed","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-02 17:20:52.136959+00	
00000000-0000-0000-0000-000000000000	8bbead8d-bb4d-4bfe-b7f4-e3b1b3947638	{"action":"token_revoked","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-02 17:20:52.138888+00	
00000000-0000-0000-0000-000000000000	d6be3c51-3d2c-44e3-8b4c-648003a31e13	{"action":"token_refreshed","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-03 22:47:33.707453+00	
00000000-0000-0000-0000-000000000000	4f4299a7-6c2e-40b1-84ed-e9acd2b91e6c	{"action":"token_revoked","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-03 22:47:33.719411+00	
00000000-0000-0000-0000-000000000000	b59df7b9-114b-4111-ac2d-f9354619aee5	{"action":"token_refreshed","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-03 23:49:24.890082+00	
00000000-0000-0000-0000-000000000000	e0f16a1c-fd5a-426c-ab5b-c417a32979eb	{"action":"token_revoked","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-03 23:49:24.892837+00	
00000000-0000-0000-0000-000000000000	280f5a9c-5f6f-4e0c-baad-46110a9e47ff	{"action":"token_refreshed","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-04 00:47:34.140569+00	
00000000-0000-0000-0000-000000000000	dcd46efa-c5f4-4374-af9e-5d22d486646e	{"action":"token_revoked","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-04 00:47:34.143394+00	
00000000-0000-0000-0000-000000000000	cc916930-7b33-4fe7-86d6-16015452440b	{"action":"login","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-08-04 01:13:37.658021+00	
00000000-0000-0000-0000-000000000000	3dcf537e-0ff8-4bcb-926f-0ce3d4436ee4	{"action":"token_refreshed","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-04 02:12:01.783293+00	
00000000-0000-0000-0000-000000000000	77f1d249-83ec-4b95-bb06-3f3764bb38bd	{"action":"token_revoked","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-04 02:12:01.786699+00	
00000000-0000-0000-0000-000000000000	23e1ea27-aa3b-4de6-8be6-78f87c1698ae	{"action":"token_refreshed","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-05 20:44:33.618609+00	
00000000-0000-0000-0000-000000000000	a466744a-9c92-44f2-8a48-e40dc3c25e9e	{"action":"token_revoked","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-05 20:44:33.635542+00	
00000000-0000-0000-0000-000000000000	16ec0566-3a47-40d8-aee1-6e06566067b4	{"action":"token_refreshed","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-05 21:43:31.652509+00	
00000000-0000-0000-0000-000000000000	0142223c-c842-4026-8dd4-b236b3018d3e	{"action":"token_revoked","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-05 21:43:31.657103+00	
00000000-0000-0000-0000-000000000000	9901f342-702c-412a-89a5-6b9ce8f5ddee	{"action":"login","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-08-06 14:25:37.265663+00	
00000000-0000-0000-0000-000000000000	86f7c6e0-4f0c-4ba2-923b-0fef82edb442	{"action":"login","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-08-06 15:27:12.248406+00	
00000000-0000-0000-0000-000000000000	6512f077-da3f-4420-a37e-9b68073b8901	{"action":"token_refreshed","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-06 19:27:05.991933+00	
00000000-0000-0000-0000-000000000000	2f90fb34-ea07-4d41-b688-a24699378cb7	{"action":"token_revoked","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-06 19:27:05.993419+00	
00000000-0000-0000-0000-000000000000	1dcf4a46-d370-4bb1-9e13-47e5450f9779	{"action":"token_refreshed","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-06 20:25:17.436791+00	
00000000-0000-0000-0000-000000000000	eab0b30a-a20e-41aa-a73a-a04303d166e9	{"action":"token_revoked","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-06 20:25:17.440028+00	
00000000-0000-0000-0000-000000000000	65ca0953-5b22-45f2-b94f-064ac7205804	{"action":"token_refreshed","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-06 21:52:05.193109+00	
00000000-0000-0000-0000-000000000000	1ada3927-bd86-4f38-96fb-aceb123d67eb	{"action":"token_revoked","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-06 21:52:05.194581+00	
00000000-0000-0000-0000-000000000000	1a109cb0-2fb8-4299-8fa6-a4fe5a1bd4e2	{"action":"token_refreshed","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-11 17:22:30.462931+00	
00000000-0000-0000-0000-000000000000	a5192e6a-5851-4501-9ee3-f260492a7c98	{"action":"token_revoked","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-11 17:22:30.483543+00	
00000000-0000-0000-0000-000000000000	8680f444-c50b-4197-88ed-d8057e3b128e	{"action":"token_refreshed","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-11 18:40:14.841449+00	
00000000-0000-0000-0000-000000000000	8bc7d4cc-42df-4ace-ab80-0b09e2623223	{"action":"token_revoked","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-11 18:40:14.845906+00	
00000000-0000-0000-0000-000000000000	e9350100-2309-4bbe-9e8c-101991e57241	{"action":"login","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-08-11 19:02:44.100174+00	
00000000-0000-0000-0000-000000000000	d3747a71-5d48-4d8e-a2e6-3e7a7515e9ab	{"action":"token_refreshed","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-11 20:01:02.601749+00	
00000000-0000-0000-0000-000000000000	32dec686-2b82-46b0-a327-8b705139d828	{"action":"token_revoked","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-11 20:01:02.607665+00	
00000000-0000-0000-0000-000000000000	ebb693bf-30b6-414c-a70b-2abe84ba45dd	{"action":"token_refreshed","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-11 21:03:28.592576+00	
00000000-0000-0000-0000-000000000000	39255ef5-350c-4e3c-980c-9a0938860e70	{"action":"token_revoked","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-11 21:03:28.597914+00	
00000000-0000-0000-0000-000000000000	d0d4a2e9-6f10-43b3-b72e-f0d7d67ea9e0	{"action":"token_refreshed","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-11 21:53:26.040519+00	
00000000-0000-0000-0000-000000000000	aaf8a78f-7f90-4aa3-a924-bc18d32b38dd	{"action":"token_revoked","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-11 21:53:26.043777+00	
00000000-0000-0000-0000-000000000000	c17dc712-9813-4be3-bf19-36314a43ded3	{"action":"token_refreshed","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-12 09:53:12.353365+00	
00000000-0000-0000-0000-000000000000	bc2e03f6-e110-4771-b35e-9dfa7a83d034	{"action":"token_revoked","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-12 09:53:12.376352+00	
00000000-0000-0000-0000-000000000000	f20c3773-a54e-49c0-bf4f-0ca6d7271ff8	{"action":"token_refreshed","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-14 13:43:44.639943+00	
00000000-0000-0000-0000-000000000000	745ba705-2d18-47cd-b66b-25484f2f2cdf	{"action":"token_revoked","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-14 13:43:44.657087+00	
00000000-0000-0000-0000-000000000000	b434e14b-7690-40e4-a211-47215c078f89	{"action":"token_refreshed","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-15 15:21:16.767943+00	
00000000-0000-0000-0000-000000000000	bfb8f35d-895b-4ed9-8289-d89399f4d001	{"action":"token_revoked","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-15 15:21:16.778733+00	
00000000-0000-0000-0000-000000000000	82c28b43-935f-4b3d-8ba8-71c34a58af89	{"action":"token_refreshed","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-18 20:42:19.627185+00	
00000000-0000-0000-0000-000000000000	469d89cc-19c8-492a-b7b2-48f4acf079fc	{"action":"token_revoked","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-18 20:42:19.63949+00	
00000000-0000-0000-0000-000000000000	627b30b7-a8fb-4035-9462-3ee6425345a3	{"action":"token_refreshed","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-18 21:40:44.991891+00	
00000000-0000-0000-0000-000000000000	9bc66a68-c984-4669-9c2d-c880c4d1fa19	{"action":"token_revoked","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-18 21:40:44.999891+00	
00000000-0000-0000-0000-000000000000	6c643bd4-cef4-47aa-86ec-da61eb31f580	{"action":"login","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-08-18 21:42:31.257064+00	
00000000-0000-0000-0000-000000000000	e0582035-2884-4ca2-a8ff-9c36ee382783	{"action":"token_refreshed","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-20 14:09:13.708207+00	
00000000-0000-0000-0000-000000000000	662a7de3-1826-43c9-9092-53332d6f0bc6	{"action":"token_revoked","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-20 14:09:13.718573+00	
00000000-0000-0000-0000-000000000000	ba9fb044-ac41-45d5-b424-29e5928f075c	{"action":"token_refreshed","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-20 19:36:37.457966+00	
00000000-0000-0000-0000-000000000000	3fa23982-c705-4c86-a05c-55aba5244a6e	{"action":"token_revoked","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-20 19:36:37.468545+00	
00000000-0000-0000-0000-000000000000	237ff059-187c-42a4-b11c-aeba93c980e1	{"action":"token_refreshed","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-29 18:00:47.125765+00	
00000000-0000-0000-0000-000000000000	a7df1f64-fb5f-42c5-91ab-e2826286fe42	{"action":"token_revoked","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-29 18:00:47.136965+00	
00000000-0000-0000-0000-000000000000	154ae04b-2973-4eae-8f72-f70f9ded8ccc	{"action":"token_refreshed","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-29 20:13:17.453048+00	
00000000-0000-0000-0000-000000000000	793e3bbf-410d-4c56-a6c5-ec70b5b8fb0d	{"action":"token_revoked","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-29 20:13:17.455221+00	
00000000-0000-0000-0000-000000000000	f595a0a7-4b4b-4f07-9f44-236b186898b0	{"action":"token_refreshed","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-29 21:12:51.333594+00	
00000000-0000-0000-0000-000000000000	d547564c-bf19-4bdd-974a-d581b46e9010	{"action":"token_revoked","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-08-29 21:12:51.335027+00	
00000000-0000-0000-0000-000000000000	806d4fbc-4af0-4605-a676-5cefa665bf9e	{"action":"login","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-09-01 20:20:34.233829+00	
00000000-0000-0000-0000-000000000000	152d5121-30e9-4e26-a20b-ab816396127c	{"action":"token_refreshed","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-01 21:18:58.01678+00	
00000000-0000-0000-0000-000000000000	b4082f0e-a2a2-4bd1-9a9b-f1558e87a67a	{"action":"token_revoked","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-01 21:18:58.021516+00	
00000000-0000-0000-0000-000000000000	bd1032e8-a709-4d88-b7a1-743a44859021	{"action":"token_refreshed","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-01 21:53:23.766513+00	
00000000-0000-0000-0000-000000000000	1b893083-9a06-4e4c-a810-69885c1c18d5	{"action":"token_revoked","actor_id":"3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0","actor_username":"akileskenobi@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-09-01 21:53:23.771569+00	
\.


--
-- Data for Name: flow_state; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.flow_state (id, user_id, auth_code, code_challenge_method, code_challenge, provider_type, provider_access_token, provider_refresh_token, created_at, updated_at, authentication_method, auth_code_issued_at) FROM stdin;
\.


--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at, id) FROM stdin;
511d8cc2-a383-4856-8427-47d60191e6b6	511d8cc2-a383-4856-8427-47d60191e6b6	{"sub": "511d8cc2-a383-4856-8427-47d60191e6b6", "email": "harry.potter@gmail.com", "last_name": "Potter", "first_name": "Harry", "wizard_name": "The Boy Who Lived", "email_verified": false, "phone_verified": false}	email	2025-07-22 17:47:36.631945+00	2025-07-22 17:47:36.63199+00	2025-07-22 17:47:36.63199+00	4dfa1545-53eb-4340-a579-fc794da02470
3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	{"sub": "3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0", "email": "akileskenobi@gmail.com", "last_name": "Castillo", "first_name": "Isaac", "wizard_name": "Isaac", "email_verified": true, "phone_verified": false}	email	2025-07-22 19:51:56.532826+00	2025-07-22 19:51:56.532875+00	2025-07-22 19:51:56.532875+00	96ab4f38-baf1-4515-9922-3d39f2f1f805
\.


--
-- Data for Name: instances; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.instances (id, uuid, raw_base_config, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: mfa_amr_claims; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.mfa_amr_claims (session_id, created_at, updated_at, authentication_method, id) FROM stdin;
5458a121-fd21-40e3-9253-b01f9361efaa	2025-07-30 00:11:05.984201+00	2025-07-30 00:11:05.984201+00	password	4501a4df-620e-44bf-a513-766f2ffdd890
455d0d42-df58-4d73-af5a-ae00827c129b	2025-08-04 01:13:37.676933+00	2025-08-04 01:13:37.676933+00	password	7b9448db-89b3-4b5a-93f0-26b17d144fec
bda80767-ef8d-462f-954b-12a51b3e9e82	2025-08-06 14:25:37.311169+00	2025-08-06 14:25:37.311169+00	password	f385a83e-9d9e-4e0f-838d-7bbba39539b8
d18187d5-5c4c-4466-b465-b7617a80476f	2025-08-06 15:27:12.255209+00	2025-08-06 15:27:12.255209+00	password	a3d5513e-2e74-43b2-9f45-c7d2dbe9e698
3a1b563c-afe7-4cba-b70d-63df5b83bbf5	2025-08-11 19:02:44.121246+00	2025-08-11 19:02:44.121246+00	password	89dcf451-4877-473c-91c9-984110acf20f
e6d2f6e1-92fb-4da1-80e6-a0e1f52c4b10	2025-08-18 21:42:31.269522+00	2025-08-18 21:42:31.269522+00	password	e443db67-1274-4dad-ae31-1f6fbeb8c773
fa773f3e-9b76-4412-a982-60599894ddef	2025-09-01 20:20:34.2871+00	2025-09-01 20:20:34.2871+00	password	0424712d-99f2-4643-ac8d-65207b05d4e7
\.


--
-- Data for Name: mfa_challenges; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.mfa_challenges (id, factor_id, created_at, verified_at, ip_address, otp_code, web_authn_session_data) FROM stdin;
\.


--
-- Data for Name: mfa_factors; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.mfa_factors (id, user_id, friendly_name, factor_type, status, created_at, updated_at, secret, phone, last_challenged_at, web_authn_credential, web_authn_aaguid) FROM stdin;
\.


--
-- Data for Name: one_time_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.one_time_tokens (id, user_id, token_type, token_hash, relates_to, created_at, updated_at) FROM stdin;
b8146198-812e-4e3d-a8e7-df9934db52b7	511d8cc2-a383-4856-8427-47d60191e6b6	confirmation_token	cf2fa06f9ff9e9f83390a5064c7bd054fd551516362283b9b009dee4	harry.potter@gmail.com	2025-07-22 17:47:37.064094	2025-07-22 17:47:37.064094
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.refresh_tokens (instance_id, id, token, user_id, revoked, created_at, updated_at, parent, session_id) FROM stdin;
00000000-0000-0000-0000-000000000000	61	nuw3xvjg35yv	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	t	2025-08-29 21:12:51.337859+00	2025-09-01 21:53:23.774679+00	6qyt2lhuup2l	e6d2f6e1-92fb-4da1-80e6-a0e1f52c4b10
00000000-0000-0000-0000-000000000000	64	borgq7cp5sd7	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	f	2025-09-01 21:53:23.776587+00	2025-09-01 21:53:23.776587+00	nuw3xvjg35yv	e6d2f6e1-92fb-4da1-80e6-a0e1f52c4b10
00000000-0000-0000-0000-000000000000	16	c3uo47c53wsh	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	t	2025-07-30 00:11:05.981813+00	2025-07-30 15:56:44.349332+00	\N	5458a121-fd21-40e3-9253-b01f9361efaa
00000000-0000-0000-0000-000000000000	17	yxezg7czxkrg	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	t	2025-07-30 15:56:44.358692+00	2025-07-30 17:44:52.926053+00	c3uo47c53wsh	5458a121-fd21-40e3-9253-b01f9361efaa
00000000-0000-0000-0000-000000000000	18	utw5zo73ri4u	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	t	2025-07-30 17:44:52.927338+00	2025-07-31 16:45:10.717553+00	yxezg7czxkrg	5458a121-fd21-40e3-9253-b01f9361efaa
00000000-0000-0000-0000-000000000000	19	5h4crobcqqxn	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	t	2025-07-31 16:45:10.722503+00	2025-07-31 17:43:38.739249+00	utw5zo73ri4u	5458a121-fd21-40e3-9253-b01f9361efaa
00000000-0000-0000-0000-000000000000	20	nb6t4ncxkex5	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	t	2025-07-31 17:43:38.744896+00	2025-07-31 19:14:51.3935+00	5h4crobcqqxn	5458a121-fd21-40e3-9253-b01f9361efaa
00000000-0000-0000-0000-000000000000	21	egqh63mkn6pa	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	t	2025-07-31 19:14:51.396093+00	2025-07-31 20:12:53.12702+00	nb6t4ncxkex5	5458a121-fd21-40e3-9253-b01f9361efaa
00000000-0000-0000-0000-000000000000	22	oexkjb5zr2ze	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	t	2025-07-31 20:12:53.128285+00	2025-08-01 15:46:29.49036+00	egqh63mkn6pa	5458a121-fd21-40e3-9253-b01f9361efaa
00000000-0000-0000-0000-000000000000	23	nxggqqp627vw	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	t	2025-08-01 15:46:29.497775+00	2025-08-01 16:56:31.279588+00	oexkjb5zr2ze	5458a121-fd21-40e3-9253-b01f9361efaa
00000000-0000-0000-0000-000000000000	24	5wfr6cfukldn	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	t	2025-08-01 16:56:31.284713+00	2025-08-01 18:29:58.958475+00	nxggqqp627vw	5458a121-fd21-40e3-9253-b01f9361efaa
00000000-0000-0000-0000-000000000000	25	tduf727qyahc	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	t	2025-08-01 18:29:58.960485+00	2025-08-01 19:28:04.540121+00	5wfr6cfukldn	5458a121-fd21-40e3-9253-b01f9361efaa
00000000-0000-0000-0000-000000000000	26	uiqshqgama3o	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	t	2025-08-01 19:28:04.544579+00	2025-08-01 20:26:54.969662+00	tduf727qyahc	5458a121-fd21-40e3-9253-b01f9361efaa
00000000-0000-0000-0000-000000000000	27	an5m5vpjnyg2	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	t	2025-08-01 20:26:54.972888+00	2025-08-01 21:32:17.189128+00	uiqshqgama3o	5458a121-fd21-40e3-9253-b01f9361efaa
00000000-0000-0000-0000-000000000000	28	7iifhbkyy7at	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	t	2025-08-01 21:32:17.194933+00	2025-08-02 13:14:59.55937+00	an5m5vpjnyg2	5458a121-fd21-40e3-9253-b01f9361efaa
00000000-0000-0000-0000-000000000000	29	zp5ezzgnovk4	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	t	2025-08-02 13:14:59.577164+00	2025-08-02 15:24:23.239781+00	7iifhbkyy7at	5458a121-fd21-40e3-9253-b01f9361efaa
00000000-0000-0000-0000-000000000000	30	dhquxbtavc3g	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	t	2025-08-02 15:24:23.244705+00	2025-08-02 16:22:41.160066+00	zp5ezzgnovk4	5458a121-fd21-40e3-9253-b01f9361efaa
00000000-0000-0000-0000-000000000000	31	olwcxm2os6ui	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	t	2025-08-02 16:22:41.161903+00	2025-08-02 17:20:52.140907+00	dhquxbtavc3g	5458a121-fd21-40e3-9253-b01f9361efaa
00000000-0000-0000-0000-000000000000	32	cl3btz62pm35	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	t	2025-08-02 17:20:52.143337+00	2025-08-03 22:47:33.723162+00	olwcxm2os6ui	5458a121-fd21-40e3-9253-b01f9361efaa
00000000-0000-0000-0000-000000000000	33	2nwxsos6ox3r	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	t	2025-08-03 22:47:33.736079+00	2025-08-03 23:49:24.893386+00	cl3btz62pm35	5458a121-fd21-40e3-9253-b01f9361efaa
00000000-0000-0000-0000-000000000000	34	chfbfjvr6gyt	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	t	2025-08-03 23:49:24.895824+00	2025-08-04 00:47:34.144617+00	2nwxsos6ox3r	5458a121-fd21-40e3-9253-b01f9361efaa
00000000-0000-0000-0000-000000000000	35	ze4y56qrckgu	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	f	2025-08-04 00:47:34.145322+00	2025-08-04 00:47:34.145322+00	chfbfjvr6gyt	5458a121-fd21-40e3-9253-b01f9361efaa
00000000-0000-0000-0000-000000000000	36	66vl7vi7murr	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	t	2025-08-04 01:13:37.672407+00	2025-08-04 02:12:01.787292+00	\N	455d0d42-df58-4d73-af5a-ae00827c129b
00000000-0000-0000-0000-000000000000	37	epyspikywvt6	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	t	2025-08-04 02:12:01.791066+00	2025-08-05 20:44:33.636827+00	66vl7vi7murr	455d0d42-df58-4d73-af5a-ae00827c129b
00000000-0000-0000-0000-000000000000	38	rvxcghpnez6l	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	t	2025-08-05 20:44:33.650842+00	2025-08-05 21:43:31.657725+00	epyspikywvt6	455d0d42-df58-4d73-af5a-ae00827c129b
00000000-0000-0000-0000-000000000000	40	5ulnzhoa4uye	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	f	2025-08-06 14:25:37.288652+00	2025-08-06 14:25:37.288652+00	\N	bda80767-ef8d-462f-954b-12a51b3e9e82
00000000-0000-0000-0000-000000000000	41	bu46jwu5ucgm	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	f	2025-08-06 15:27:12.251899+00	2025-08-06 15:27:12.251899+00	\N	d18187d5-5c4c-4466-b465-b7617a80476f
00000000-0000-0000-0000-000000000000	39	yug6vqfir76a	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	t	2025-08-05 21:43:31.659967+00	2025-08-06 19:27:05.993926+00	rvxcghpnez6l	455d0d42-df58-4d73-af5a-ae00827c129b
00000000-0000-0000-0000-000000000000	42	i6kqymu2mcay	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	t	2025-08-06 19:27:05.998096+00	2025-08-06 20:25:17.440518+00	yug6vqfir76a	455d0d42-df58-4d73-af5a-ae00827c129b
00000000-0000-0000-0000-000000000000	43	mpwdgpzhoxv6	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	t	2025-08-06 20:25:17.443527+00	2025-08-06 21:52:05.195065+00	i6kqymu2mcay	455d0d42-df58-4d73-af5a-ae00827c129b
00000000-0000-0000-0000-000000000000	44	gnx3fkxo6n5y	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	t	2025-08-06 21:52:05.198093+00	2025-08-11 17:22:30.487224+00	mpwdgpzhoxv6	455d0d42-df58-4d73-af5a-ae00827c129b
00000000-0000-0000-0000-000000000000	45	65tmamw3g2b2	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	t	2025-08-11 17:22:30.502995+00	2025-08-11 18:40:14.846416+00	gnx3fkxo6n5y	455d0d42-df58-4d73-af5a-ae00827c129b
00000000-0000-0000-0000-000000000000	47	baknczdmmfcr	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	t	2025-08-11 19:02:44.11201+00	2025-08-11 20:01:02.60836+00	\N	3a1b563c-afe7-4cba-b70d-63df5b83bbf5
00000000-0000-0000-0000-000000000000	48	qqmkychcrf6w	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	t	2025-08-11 20:01:02.614183+00	2025-08-11 21:03:28.598439+00	baknczdmmfcr	3a1b563c-afe7-4cba-b70d-63df5b83bbf5
00000000-0000-0000-0000-000000000000	49	fyfqehivp6mj	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	f	2025-08-11 21:03:28.605309+00	2025-08-11 21:03:28.605309+00	qqmkychcrf6w	3a1b563c-afe7-4cba-b70d-63df5b83bbf5
00000000-0000-0000-0000-000000000000	46	5e3kwocolfcy	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	t	2025-08-11 18:40:14.853951+00	2025-08-11 21:53:26.044318+00	65tmamw3g2b2	455d0d42-df58-4d73-af5a-ae00827c129b
00000000-0000-0000-0000-000000000000	50	pjcbygwrfyj4	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	t	2025-08-11 21:53:26.047372+00	2025-08-12 09:53:12.377713+00	5e3kwocolfcy	455d0d42-df58-4d73-af5a-ae00827c129b
00000000-0000-0000-0000-000000000000	51	frp2eotxolm6	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	t	2025-08-12 09:53:12.399231+00	2025-08-14 13:43:44.658277+00	pjcbygwrfyj4	455d0d42-df58-4d73-af5a-ae00827c129b
00000000-0000-0000-0000-000000000000	52	iwwuxs6oel3x	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	t	2025-08-14 13:43:44.677841+00	2025-08-15 15:21:16.780012+00	frp2eotxolm6	455d0d42-df58-4d73-af5a-ae00827c129b
00000000-0000-0000-0000-000000000000	53	iisiekn5tjl2	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	t	2025-08-15 15:21:16.79452+00	2025-08-18 20:42:19.641363+00	iwwuxs6oel3x	455d0d42-df58-4d73-af5a-ae00827c129b
00000000-0000-0000-0000-000000000000	54	67xtnf46xkxf	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	t	2025-08-18 20:42:19.652772+00	2025-08-18 21:40:45.000543+00	iisiekn5tjl2	455d0d42-df58-4d73-af5a-ae00827c129b
00000000-0000-0000-0000-000000000000	55	r5ykkf657fuw	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	f	2025-08-18 21:40:45.010601+00	2025-08-18 21:40:45.010601+00	67xtnf46xkxf	455d0d42-df58-4d73-af5a-ae00827c129b
00000000-0000-0000-0000-000000000000	56	7lubsoqcpft3	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	t	2025-08-18 21:42:31.266814+00	2025-08-20 14:09:13.720393+00	\N	e6d2f6e1-92fb-4da1-80e6-a0e1f52c4b10
00000000-0000-0000-0000-000000000000	57	zv2yqzkv3j2d	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	t	2025-08-20 14:09:13.735338+00	2025-08-20 19:36:37.469189+00	7lubsoqcpft3	e6d2f6e1-92fb-4da1-80e6-a0e1f52c4b10
00000000-0000-0000-0000-000000000000	58	t4m5xkts2agf	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	t	2025-08-20 19:36:37.481331+00	2025-08-29 18:00:47.139399+00	zv2yqzkv3j2d	e6d2f6e1-92fb-4da1-80e6-a0e1f52c4b10
00000000-0000-0000-0000-000000000000	59	wecr7z56bpyz	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	t	2025-08-29 18:00:47.155355+00	2025-08-29 20:13:17.45787+00	t4m5xkts2agf	e6d2f6e1-92fb-4da1-80e6-a0e1f52c4b10
00000000-0000-0000-0000-000000000000	60	6qyt2lhuup2l	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	t	2025-08-29 20:13:17.462476+00	2025-08-29 21:12:51.335521+00	wecr7z56bpyz	e6d2f6e1-92fb-4da1-80e6-a0e1f52c4b10
00000000-0000-0000-0000-000000000000	62	mc4uycecmwwb	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	t	2025-09-01 20:20:34.269795+00	2025-09-01 21:18:58.022063+00	\N	fa773f3e-9b76-4412-a982-60599894ddef
00000000-0000-0000-0000-000000000000	63	tu6byx3cs7qy	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	f	2025-09-01 21:18:58.030798+00	2025-09-01 21:18:58.030798+00	mc4uycecmwwb	fa773f3e-9b76-4412-a982-60599894ddef
\.


--
-- Data for Name: saml_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.saml_providers (id, sso_provider_id, entity_id, metadata_xml, metadata_url, attribute_mapping, created_at, updated_at, name_id_format) FROM stdin;
\.


--
-- Data for Name: saml_relay_states; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.saml_relay_states (id, sso_provider_id, request_id, for_email, redirect_to, created_at, updated_at, flow_state_id) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.schema_migrations (version) FROM stdin;
20171026211738
20171026211808
20171026211834
20180103212743
20180108183307
20180119214651
20180125194653
00
20210710035447
20210722035447
20210730183235
20210909172000
20210927181326
20211122151130
20211124214934
20211202183645
20220114185221
20220114185340
20220224000811
20220323170000
20220429102000
20220531120530
20220614074223
20220811173540
20221003041349
20221003041400
20221011041400
20221020193600
20221021073300
20221021082433
20221027105023
20221114143122
20221114143410
20221125140132
20221208132122
20221215195500
20221215195800
20221215195900
20230116124310
20230116124412
20230131181311
20230322519590
20230402418590
20230411005111
20230508135423
20230523124323
20230818113222
20230914180801
20231027141322
20231114161723
20231117164230
20240115144230
20240214120130
20240306115329
20240314092811
20240427152123
20240612123726
20240729123726
20240802193726
20240806073726
20241009103726
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.sessions (id, user_id, created_at, updated_at, factor_id, aal, not_after, refreshed_at, user_agent, ip, tag) FROM stdin;
5458a121-fd21-40e3-9253-b01f9361efaa	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	2025-07-30 00:11:05.980204+00	2025-08-04 00:47:34.14981+00	\N	aal1	\N	2025-08-04 00:47:34.14974	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	190.218.166.163	\N
bda80767-ef8d-462f-954b-12a51b3e9e82	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	2025-08-06 14:25:37.281937+00	2025-08-06 14:25:37.281937+00	\N	aal1	\N	\N	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36	186.74.247.10	\N
d18187d5-5c4c-4466-b465-b7617a80476f	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	2025-08-06 15:27:12.250062+00	2025-08-06 15:27:12.250062+00	\N	aal1	\N	\N	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36	186.74.247.10	\N
3a1b563c-afe7-4cba-b70d-63df5b83bbf5	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	2025-08-11 19:02:44.106597+00	2025-08-11 21:03:28.611439+00	\N	aal1	\N	2025-08-11 21:03:28.611359	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Safari/605.1.15	186.74.247.10	\N
455d0d42-df58-4d73-af5a-ae00827c129b	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	2025-08-04 01:13:37.666381+00	2025-08-18 21:40:45.016547+00	\N	aal1	\N	2025-08-18 21:40:45.016464	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Safari/605.1.15	186.74.247.10	\N
fa773f3e-9b76-4412-a982-60599894ddef	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	2025-09-01 20:20:34.257634+00	2025-09-01 21:18:58.038807+00	\N	aal1	\N	2025-09-01 21:18:58.038732	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Safari/605.1.15	186.74.247.10	\N
e6d2f6e1-92fb-4da1-80e6-a0e1f52c4b10	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	2025-08-18 21:42:31.261188+00	2025-09-01 21:53:23.781352+00	\N	aal1	\N	2025-09-01 21:53:23.781276	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Safari/605.1.15	186.74.247.10	\N
\.


--
-- Data for Name: sso_domains; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.sso_domains (id, sso_provider_id, domain, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: sso_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.sso_providers (id, resource_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, invited_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at, email_change_token_new, email_change, email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, email_change_token_current, email_change_confirm_status, banned_until, reauthentication_token, reauthentication_sent_at, is_sso_user, deleted_at, is_anonymous) FROM stdin;
00000000-0000-0000-0000-000000000000	511d8cc2-a383-4856-8427-47d60191e6b6	authenticated	authenticated	harry.potter@gmail.com	$2a$10$ZwqHIejiCbEhKGtk1Lrogexn1ZnOefEdFmb8esybXqGea8lSxSkee	\N	\N	cf2fa06f9ff9e9f83390a5064c7bd054fd551516362283b9b009dee4	2025-07-22 17:47:36.63497+00		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"sub": "511d8cc2-a383-4856-8427-47d60191e6b6", "email": "harry.potter@gmail.com", "last_name": "Potter", "first_name": "Harry", "wizard_name": "The Boy Who Lived", "email_verified": false, "phone_verified": false}	\N	2025-07-22 17:47:36.629604+00	2025-07-22 17:47:37.05421+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	authenticated	authenticated	akileskenobi@gmail.com	$2a$10$fuWHbSMO3zAqtO2Vk7cF.eXO5Gkc.6fHM3bR2uTswkxWZikHu9K.W	2025-07-22 19:52:43.092844+00	\N		2025-07-22 19:51:56.536585+00		\N			\N	2025-09-01 20:20:34.255947+00	{"provider": "email", "providers": ["email"]}	{"sub": "3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0", "email": "akileskenobi@gmail.com", "last_name": "Castillo", "first_name": "Isaac", "wizard_name": "Isaac", "email_verified": true, "phone_verified": false}	\N	2025-07-22 19:51:56.523824+00	2025-09-01 21:53:23.778832+00	\N	\N			\N		0	\N		\N	f	\N	f
\.


--
-- Data for Name: achievement_assignments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.achievement_assignments (id, achievement_id, assigned_by, assigned_to, reason, assigned_at, status) FROM stdin;
\.


--
-- Data for Name: achievement_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.achievement_types (id, name, description, icon_name, color, category, points_reward, is_active, created_at, icon, trigger_condition, auto_award) FROM stdin;
1	Primer Paso	Completó su primer quiz de selección	star	primary	automatic	10	t	2025-07-29 22:29:18.133404+00	🏆	\N	t
2	Bienvenido	Se unió a la comunidad	heart	success	automatic	5	t	2025-07-29 22:29:18.133404+00	🏆	\N	t
3	Participativo	Realizó su primera contribución al foro	chat	accent	automatic	15	t	2025-07-29 22:29:18.133404+00	🏆	\N	t
4	Escritor Prolífico	Escribió más de 10 publicaciones	pen	warning	automatic	50	t	2025-07-29 22:29:18.133404+00	🏆	\N	t
5	Mentor Querido	Ayudó a más de 5 nuevos miembros	users	primary	automatic	75	t	2025-07-29 22:29:18.133404+00	🏆	\N	t
6	Coraje Excepcional	Demostró valentía extraordinaria	shield	gryffindor	house_head_assigned	100	t	2025-07-29 22:29:18.133404+00	🏆	\N	t
7	Sabiduría Profunda	Compartió conocimiento valioso	book	ravenclaw	house_head_assigned	100	t	2025-07-29 22:29:18.133404+00	🏆	\N	t
8	Lealtad Inquebrantable	Mostró dedicación a su casa	heart	hufflepuff	house_head_assigned	100	t	2025-07-29 22:29:18.133404+00	🏆	\N	t
9	Ambición Destacada	Logró objetivos excepcionales	trophy	slytherin	house_head_assigned	100	t	2025-07-29 22:29:18.133404+00	🏆	\N	t
10	Prefecto	Nombrado prefecto de su casa	badge	secondary	house_head_assigned	200	t	2025-07-29 22:29:18.133404+00	🏆	\N	t
11	La Carta de Hogwarts	¡Has sido aceptado! Creaste tu cuenta en nuestra comunidad mágica.	\N	\N	primer_ano	10	t	2025-07-31 20:27:42.741512+00	✉️	user_registration	t
12	El Sombrero Seleccionador	Completaste el Test y fuiste seleccionado para tu noble Casa.	\N	\N	primer_ano	15	t	2025-07-31 20:27:42.741512+00	🎓	house_selection	t
13	De Compras en el Callejón Diagon	Completaste tu perfil de usuario con toda la información mágica.	\N	\N	primer_ano	20	t	2025-07-31 20:27:42.741512+00	🛍️	profile_completion	t
14	Primera Clase Asistida	Visitaste la sección de Guías o Roles por primera vez.	\N	\N	primer_ano	10	t	2025-07-31 20:27:42.741512+00	📚	first_guide_visit	t
15	Plataforma 9¾	Te presentaste a la comunidad en el foro de bienvenida.	\N	\N	primer_ano	15	t	2025-07-31 20:27:42.741512+00	🚂	first_forum_post	t
16	Primer Hechizo Verbal	Publicaste tu primer tema en el foro.	\N	\N	vida_social_hogwarts	15	t	2025-07-31 20:27:42.741512+00	💬	first_topic_created	t
17	Eco en el Gran Comedor	Tu tema ha recibido más de 10 respuestas.	\N	\N	vida_social_hogwarts	25	t	2025-07-31 20:27:42.741512+00	🔊	topic_10_replies	t
18	Conjurando Amistad	Interactuaste positivamente con otros miembros.	\N	\N	vida_social_hogwarts	20	t	2025-07-31 20:27:42.741512+00	🤝	first_interaction	t
19	El Trío de Oro	Has participado en conversaciones con múltiples miembros.	\N	\N	vida_social_hogwarts	35	t	2025-07-31 20:27:42.741512+00	🧑‍🤝‍🧑	social_interaction_3	t
20	Lumos Maxima	Tu contenido fue muy bien recibido por la comunidad.	\N	\N	vida_social_hogwarts	40	t	2025-07-31 20:27:42.741512+00	💡	popular_content	t
21	Conversador del Caldero Chorreante	Has escrito 50 mensajes en los foros.	\N	\N	vida_social_hogwarts	50	t	2025-07-31 20:27:42.741512+00	🗣️	posts_count_50	t
22	Orgullo de Casa	Visitaste la sala común de tu Casa por primera vez.	\N	\N	lealtad_casa	25	t	2025-07-31 20:27:42.741512+00	🏠	house_room_visit	t
23	Guardián de la Sala Común	Participaste activamente en actividades de tu Casa.	\N	\N	lealtad_casa	40	t	2025-07-31 20:27:42.741512+00	🛡️	house_activities_5	t
24	Campeón de la Casa	Aportaste 100 puntos a tu Casa a través de tus logros.	\N	\N	lealtad_casa	60	t	2025-07-31 20:27:42.741512+00	🏆	house_points_100	t
25	¡Diez puntos para tu Casa!	Tu participación destacó y fue reconocida.	\N	\N	lealtad_casa	50	t	2025-07-31 20:27:42.741512+00	🔟	recognized_contribution	t
26	Erudito de Biblioteca	Has explorado múltiples secciones de conocimiento.	\N	\N	maestria_academica	20	t	2025-07-31 20:27:42.741512+00	📖	sections_visited_10	t
27	Supera los T.I.M.O.s	Completaste desafíos o quizzes con excelentes resultados.	\N	\N	maestria_academica	50	t	2025-07-31 20:27:42.741512+00	📝	quiz_completion	t
28	Maestro de Pociones	Creaste contenido valioso para la comunidad.	\N	\N	maestria_academica	75	t	2025-07-31 20:27:42.741512+00	🧪	content_creation	t
29	Historiador de la Magia	Has estado activo en la comunidad por más de 30 días.	\N	\N	maestria_academica	100	t	2025-07-31 20:27:42.741512+00	⏳	active_days_30	t
30	Redactor de El Profeta	Has contribuido significativamente con contenido.	\N	\N	maestria_academica	80	t	2025-07-31 20:27:42.741512+00	📰	content_contributions_5	t
31	Cazador de la Snitch Dorada	Fuiste rápido en participar en eventos especiales.	\N	\N	exploracion_magica	40	t	2025-07-31 20:27:42.741512+00	✨	quick_participation	t
32	Coleccionista de Cromos	Descubriste características ocultas de la página.	\N	\N	exploracion_magica	30	t	2025-07-31 20:27:42.741512+00	🐸	easter_egg_discovery	t
33	¡Alohomora!	Accediste a secciones especiales por primera vez.	\N	\N	exploracion_magica	50	t	2025-07-31 20:27:42.741512+00	🔓	special_access	t
34	Viajero del Giratiempo	Visitaste la página consistentemente durante una semana.	\N	\N	exploracion_magica	35	t	2025-07-31 20:27:42.741512+00	⌛	daily_visits_7	t
35	Explorador de Hogwarts	Has visitado todas las secciones principales de la página.	\N	\N	exploracion_magica	45	t	2025-07-31 20:27:42.741512+00	🗺️	all_sections_visited	t
36	Espíritu Navideño	Participaste en eventos especiales de temporada.	\N	\N	eventos_especiales	30	t	2025-07-31 20:27:42.741512+00	🎄	seasonal_participation	t
37	Baile de Navidad	Participaste en eventos sociales especiales.	\N	\N	eventos_especiales	40	t	2025-07-31 20:27:42.741512+00	💃	special_event_participation	t
38	Cazador de Huevos de Pascua	Encontraste sorpresas ocultas durante eventos.	\N	\N	eventos_especiales	35	t	2025-07-31 20:27:42.741512+00	🥚	event_easter_eggs	t
39	Primer Amigo Mágico	Hiciste tu primer amigo en Hogwarts	\N	\N	vida_social_hogwarts	20	t	2025-08-02 17:11:13.106643+00	🤝	first_friend	t
40	Popular en el Castillo	Tienes 10 o más amigos	\N	\N	vida_social_hogwarts	50	t	2025-08-02 17:11:13.106643+00	👥	friends_count_10	t
41	Influencer de Casa	Tienes 50 o más seguidores	\N	\N	vida_social_hogwarts	75	t	2025-08-02 17:11:13.106643+00	⭐	followers_count_50	t
42	Espíritu Social	Sigues a 25 o más compañeros	\N	\N	vida_social_hogwarts	30	t	2025-08-02 17:11:13.106643+00	👀	following_count_25	t
43	Unión de Casa	Eres amigo de 5 compañeros de tu casa	\N	\N	lealtad_casa	40	t	2025-08-02 17:11:13.106643+00	🏠	house_friends_5	t
\.


--
-- Data for Name: activity_participations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.activity_participations (id, activity_id, user_id, participation_status, completion_notes, points_earned, completed_at, registered_at) FROM stdin;
\.


--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.categories (id, name, description, icon, color, order_index, created_at) FROM stdin;
4211e7be-8eb8-4d77-a084-f4a09cc52ef6	Teorías y Análisis	Discusiones profundas sobre el mundo mágico	lightbulb	#9C27B0	1	2025-08-04 00:29:46.70324+00
995c3c32-2a5f-44a9-84ed-7803e415bed6	Fanfiction	Historias originales del mundo mágico	edit	#FF5722	2	2025-08-04 00:29:46.70324+00
f62c1ff2-1873-49b7-87fc-10e9bbb12552	Arte y Creatividad	Fanart, ilustraciones y creaciones visuales	image	#FF9800	3	2025-08-04 00:29:46.70324+00
37847e2f-a3fc-4be2-9c75-9b435f2b9ced	Debates Mágicos	Discusiones acaloradas sobre temas controvertidos	chat	#F44336	4	2025-08-04 00:29:46.70324+00
b2e0e4c2-d596-4a7e-a652-105222f16a6f	Ayuda y Preguntas	Soporte de la comunidad y preguntas generales	help	#4CAF50	5	2025-08-04 00:29:46.70324+00
\.


--
-- Data for Name: challenge_attempts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.challenge_attempts (id, challenge_id, user_id, house_id, status, score, evidence_url, created_at, completed_at) FROM stdin;
\.


--
-- Data for Name: challenges; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.challenges (id, slug, title, description, scope, reward_points, target_count, start_at, end_at, status, created_by, metadata) FROM stdin;
\.


--
-- Data for Name: comments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.comments (id, post_id, user_id, content, is_solution, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: event_participants; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.event_participants (event_id, user_id, status, submission_url, points_awarded, joined_at) FROM stdin;
\.


--
-- Data for Name: events; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.events (id, slug, title, description, type, featured, cover_url, reward_points, start_at, end_at, status, created_by, created_at, metadata) FROM stdin;
\.


--
-- Data for Name: followers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.followers (id, user_id, follower_id, followed_at) FROM stdin;
\.


--
-- Data for Name: forum_user_stats; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.forum_user_stats (user_id, total_posts, total_comments, total_likes_received, reputation_points, is_moderator, created_at, updated_at) FROM stdin;
3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	2	0	0	0	f	2025-08-04 01:03:30.364089+00	2025-09-01 21:37:11.003824+00
\.


--
-- Data for Name: friendships; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.friendships (id, user_id, friend_id, status, requested_at, responded_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: house_activities; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.house_activities (id, house, title, description, activity_type, points_reward, start_date, end_date, created_by, is_active, max_participants, created_at) FROM stdin;
\.


--
-- Data for Name: house_challenge_progress; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.house_challenge_progress (challenge_id, house_id, progress_count, updated_at) FROM stdin;
\.


--
-- Data for Name: house_points_ledger; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.house_points_ledger (id, house_id, user_id, source, source_id, points, note, created_at) FROM stdin;
fcb909da-e46e-498e-872d-6e1d384cf7ec	4	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	event	\N	108	Evento de prueba	2025-08-10 16:28:09.922877+00
71bb88df-5176-4422-b81a-aa1446a42b7b	4	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	event	\N	92	Evento de prueba	2025-08-10 00:01:06.882674+00
547526e8-973d-46fd-a85b-4657f01ae89e	4	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	event	\N	98	Evento de prueba	2025-08-06 08:25:19.532796+00
642c83f0-cf0b-4967-bd21-a9ecb047800b	4	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	event	\N	55	Evento de prueba	2025-08-08 13:15:37.716059+00
47e174a6-0aaf-447b-9847-5930ddcbb32c	4	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	event	\N	73	Evento de prueba	2025-08-16 17:16:37.478804+00
e6d81f86-bfa9-4c8a-8f4d-2d018ee06378	4	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	challenge	\N	114	Desafío completado	2025-08-19 19:59:05.282989+00
5614b5bb-dacd-404c-860c-153730b93647	4	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	challenge	\N	132	Desafío completado	2025-08-31 10:39:38.810599+00
02fae897-2bd0-4788-b3c9-6488a1e700ec	4	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	challenge	\N	165	Desafío completado	2025-08-21 03:52:52.946543+00
\.


--
-- Data for Name: houses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.houses (id, name, description, color, emblem_url, created_at) FROM stdin;
1	gryffindor	Casa de los valientes y osados	#740001	/images/gryffindor.png	2025-07-22 17:50:10.111335+00
2	hufflepuff	Casa de los leales y trabajadores	#FFD800	/images/hufflepuff.png	2025-07-22 17:50:10.111335+00
3	ravenclaw	Casa de los sabios e inteligentes	#0E1A40	/images/ravenclaw.png	2025-07-22 17:50:10.111335+00
4	slytherin	Casa de los astutos y ambiciosos	#1A472A	/images/slytherin.png	2025-07-22 17:50:10.111335+00
\.


--
-- Data for Name: likes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.likes (id, user_id, post_id, comment_id, created_at) FROM stdin;
23e09df0-2759-4513-87fb-ce7abd7b94a5	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	0c615d3a-b441-4d61-95e4-517cb2cd0aee	\N	2025-08-04 01:28:26.680237+00
\.


--
-- Data for Name: moderation_reports; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.moderation_reports (id, reported_user_id, reported_by, report_type, description, status, reviewed_by, resolution_notes, created_at, resolved_at) FROM stdin;
\.


--
-- Data for Name: poll_options; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.poll_options (id, poll_id, label, author, media_url, sort_order) FROM stdin;
\.


--
-- Data for Name: polls; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.polls (id, slug, title, description, context, start_at, end_at, status) FROM stdin;
\.


--
-- Data for Name: posts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.posts (id, user_id, house_id, category_id, title, content, status, views, is_pinned, is_featured, created_at, updated_at) FROM stdin;
0c615d3a-b441-4d61-95e4-517cb2cd0aee	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	\N	4211e7be-8eb8-4d77-a084-f4a09cc52ef6	Prueba de discusión	a veces la teoria le gana a la práctica	open	0	f	f	2025-08-04 01:03:30.364089+00	2025-08-04 01:03:30.364089+00
3db63ade-c54a-44b4-a55e-f68ee17aae48	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	4	4211e7be-8eb8-4d77-a084-f4a09cc52ef6	Saludo desde Slytherin	Post de prueba para actividad del dashboard	open	0	f	f	2025-09-01 21:37:11.003824+00	2025-09-01 21:37:11.003824+00
\.


--
-- Data for Name: profile_shares; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.profile_shares (id, user_id, share_token, platform, clicks_count, created_at, expires_at) FROM stdin;
1	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	profile_iggqn661gnm	general	0	2025-07-29 23:08:56.246924+00	\N
\.


--
-- Data for Name: profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.profiles (id, first_name, last_name, wizard_name, email, house, avatar_url, created_at, updated_at, house_selected_at, role) FROM stdin;
3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	Isaac	Castillo	Isaac	akileskenobi@gmail.com	slytherin	\N	2025-07-22 19:51:56.523486+00	2025-07-22 19:51:56.523486+00	2025-07-23 15:15:17.11+00	house_head
\.


--
-- Data for Name: social_notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.social_notifications (id, user_id, from_user_id, type, message, is_read, created_at, expires_at) FROM stdin;
\.


--
-- Data for Name: system_notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.system_notifications (id, user_id, title, message, notification_type, is_read, action_url, created_at, expires_at) FROM stdin;
\.


--
-- Data for Name: user_achievements; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_achievements (id, user_id, achievement_type_id, awarded_by, awarded_at, description, is_featured, reason) FROM stdin;
2	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	1	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	2025-08-01 16:31:56.643148+00	\N	f	Test desde script de verificación
4	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	22	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	2025-08-01 19:45:40.511927+00	\N	f	Maquina
6	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	10	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	2025-09-01 21:36:26.234119+00	\N	f	Test desde dashboard
7	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	6	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	2025-09-01 21:56:15.292477+00	\N	f	Feed test
\.


--
-- Data for Name: user_activities; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_activities (id, user_id, activity_type, title, description, points_earned, metadata, created_at) FROM stdin;
\.


--
-- Data for Name: user_connections; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_connections (id, follower_id, following_id, connection_type, created_at) FROM stdin;
\.


--
-- Data for Name: user_points_ledger; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_points_ledger (id, user_id, source, source_id, points, note, created_at) FROM stdin;
\.


--
-- Data for Name: user_profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_profiles (id, display_name, bio, avatar_url, house, house_points, reputation_level, join_date, contributions_count, is_house_head, is_prefect, specialization, favorite_topics, privacy_public_profile, privacy_show_stats, privacy_allow_messages, created_at, updated_at, role) FROM stdin;
3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	akileskenobi	Nuevo miembro de la comunidad mágica de Hogwarts. test\n	\N	slytherin	0	1	2025-07-29 23:07:17.441402+00	0	t	f	\N	{}	t	t	f	2025-07-29 23:07:17.441402+00	2025-08-03 22:54:09.970393+00	student
\.


--
-- Data for Name: user_statistics; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_statistics (id, user_id, stat_name, stat_value, updated_at) FROM stdin;
2	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	test_posts	1	2025-08-01 16:31:50.808983+00
1	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	time_spent_minutes	91	2025-08-11 19:13:54.082773+00
73	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	navigation_clicks	2	2025-08-11 18:46:45.800103+00
42	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	trigger_profile_visit	19	2025-09-01 20:21:53.890117+00
3	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	pages_visited	22	2025-09-01 20:21:53.917906+00
40	3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0	button_clicks	1	2025-08-01 19:45:40.464123+00
\.


--
-- Data for Name: votes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.votes (id, poll_id, user_id, option_id, created_at) FROM stdin;
\.


--
-- Data for Name: messages_2025_08_29; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

COPY realtime.messages_2025_08_29 (topic, extension, payload, event, private, updated_at, inserted_at, id) FROM stdin;
\.


--
-- Data for Name: messages_2025_08_30; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

COPY realtime.messages_2025_08_30 (topic, extension, payload, event, private, updated_at, inserted_at, id) FROM stdin;
\.


--
-- Data for Name: messages_2025_08_31; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

COPY realtime.messages_2025_08_31 (topic, extension, payload, event, private, updated_at, inserted_at, id) FROM stdin;
\.


--
-- Data for Name: messages_2025_09_01; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

COPY realtime.messages_2025_09_01 (topic, extension, payload, event, private, updated_at, inserted_at, id) FROM stdin;
\.


--
-- Data for Name: messages_2025_09_02; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

COPY realtime.messages_2025_09_02 (topic, extension, payload, event, private, updated_at, inserted_at, id) FROM stdin;
\.


--
-- Data for Name: messages_2025_09_03; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

COPY realtime.messages_2025_09_03 (topic, extension, payload, event, private, updated_at, inserted_at, id) FROM stdin;
\.


--
-- Data for Name: messages_2025_09_04; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

COPY realtime.messages_2025_09_04 (topic, extension, payload, event, private, updated_at, inserted_at, id) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

COPY realtime.schema_migrations (version, inserted_at) FROM stdin;
20211116024918	2025-07-21 13:19:25
20211116045059	2025-07-21 13:19:28
20211116050929	2025-07-21 13:19:30
20211116051442	2025-07-21 13:19:32
20211116212300	2025-07-21 13:19:34
20211116213355	2025-07-21 13:19:36
20211116213934	2025-07-21 13:19:38
20211116214523	2025-07-21 13:19:41
20211122062447	2025-07-21 13:19:43
20211124070109	2025-07-21 13:19:45
20211202204204	2025-07-21 13:19:47
20211202204605	2025-07-21 13:19:49
20211210212804	2025-07-21 13:19:55
20211228014915	2025-07-21 13:19:57
20220107221237	2025-07-21 13:20:00
20220228202821	2025-07-21 13:20:02
20220312004840	2025-07-21 13:20:04
20220603231003	2025-07-21 13:20:07
20220603232444	2025-07-21 13:20:09
20220615214548	2025-07-21 13:20:11
20220712093339	2025-07-21 13:20:13
20220908172859	2025-07-21 13:20:15
20220916233421	2025-07-21 13:20:17
20230119133233	2025-07-21 13:20:19
20230128025114	2025-07-21 13:20:22
20230128025212	2025-07-21 13:20:24
20230227211149	2025-07-21 13:20:26
20230228184745	2025-07-21 13:20:28
20230308225145	2025-07-21 13:20:30
20230328144023	2025-07-21 13:20:32
20231018144023	2025-07-21 13:20:35
20231204144023	2025-07-21 13:20:38
20231204144024	2025-07-21 13:20:40
20231204144025	2025-07-21 13:20:42
20240108234812	2025-07-21 13:20:44
20240109165339	2025-07-21 13:20:46
20240227174441	2025-07-21 13:20:49
20240311171622	2025-07-21 13:20:52
20240321100241	2025-07-21 13:20:57
20240401105812	2025-07-21 13:21:02
20240418121054	2025-07-21 13:21:05
20240523004032	2025-07-21 13:21:12
20240618124746	2025-07-21 13:21:14
20240801235015	2025-07-21 13:21:16
20240805133720	2025-07-21 13:21:18
20240827160934	2025-07-21 13:21:21
20240919163303	2025-07-21 13:21:23
20240919163305	2025-07-21 13:21:25
20241019105805	2025-07-21 13:21:27
20241030150047	2025-07-21 13:21:35
20241108114728	2025-07-21 13:21:38
20241121104152	2025-07-21 13:21:40
20241130184212	2025-07-21 13:21:42
20241220035512	2025-07-21 13:21:44
20241220123912	2025-07-21 13:21:46
20241224161212	2025-07-21 13:21:48
20250107150512	2025-07-21 13:21:50
20250110162412	2025-07-21 13:21:52
20250123174212	2025-07-21 13:21:54
20250128220012	2025-07-21 13:21:56
20250506224012	2025-07-21 13:21:58
20250523164012	2025-07-21 13:22:00
20250714121412	2025-07-21 13:22:02
\.


--
-- Data for Name: subscription; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

COPY realtime.subscription (id, subscription_id, entity, filters, claims, created_at) FROM stdin;
\.


--
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.buckets (id, name, owner, created_at, updated_at, public, avif_autodetection, file_size_limit, allowed_mime_types, owner_id) FROM stdin;
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.migrations (id, name, hash, executed_at) FROM stdin;
0	create-migrations-table	e18db593bcde2aca2a408c4d1100f6abba2195df	2025-07-21 12:27:14.607435
1	initialmigration	6ab16121fbaa08bbd11b712d05f358f9b555d777	2025-07-21 12:27:14.817582
2	storage-schema	5c7968fd083fcea04050c1b7f6253c9771b99011	2025-07-21 12:27:15.133472
3	pathtoken-column	2cb1b0004b817b29d5b0a971af16bafeede4b70d	2025-07-21 12:27:15.519811
4	add-migrations-rls	427c5b63fe1c5937495d9c635c263ee7a5905058	2025-07-21 12:27:15.922195
5	add-size-functions	79e081a1455b63666c1294a440f8ad4b1e6a7f84	2025-07-21 12:27:16.228377
6	change-column-name-in-get-size	f93f62afdf6613ee5e7e815b30d02dc990201044	2025-07-21 12:27:16.511941
7	add-rls-to-buckets	e7e7f86adbc51049f341dfe8d30256c1abca17aa	2025-07-21 12:27:16.792566
8	add-public-to-buckets	fd670db39ed65f9d08b01db09d6202503ca2bab3	2025-07-21 12:27:17.477346
9	fix-search-function	3a0af29f42e35a4d101c259ed955b67e1bee6825	2025-07-21 12:27:17.92164
10	search-files-search-function	68dc14822daad0ffac3746a502234f486182ef6e	2025-07-21 12:27:18.186574
11	add-trigger-to-auto-update-updated_at-column	7425bdb14366d1739fa8a18c83100636d74dcaa2	2025-07-21 12:27:18.479335
12	add-automatic-avif-detection-flag	8e92e1266eb29518b6a4c5313ab8f29dd0d08df9	2025-07-21 12:27:18.707547
13	add-bucket-custom-limits	cce962054138135cd9a8c4bcd531598684b25e7d	2025-07-21 12:27:19.090247
14	use-bytes-for-max-size	941c41b346f9802b411f06f30e972ad4744dad27	2025-07-21 12:27:19.398832
15	add-can-insert-object-function	934146bc38ead475f4ef4b555c524ee5d66799e5	2025-07-21 12:27:19.699159
16	add-version	76debf38d3fd07dcfc747ca49096457d95b1221b	2025-07-21 12:27:19.991284
17	drop-owner-foreign-key	f1cbb288f1b7a4c1eb8c38504b80ae2a0153d101	2025-07-21 12:27:20.328644
18	add_owner_id_column_deprecate_owner	e7a511b379110b08e2f214be852c35414749fe66	2025-07-21 12:27:20.799757
19	alter-default-value-objects-id	02e5e22a78626187e00d173dc45f58fa66a4f043	2025-07-21 12:27:21.403601
20	list-objects-with-delimiter	cd694ae708e51ba82bf012bba00caf4f3b6393b7	2025-07-21 12:27:21.918597
21	s3-multipart-uploads	8c804d4a566c40cd1e4cc5b3725a664a9303657f	2025-07-21 12:27:22.249346
22	s3-multipart-uploads-big-ints	9737dc258d2397953c9953d9b86920b8be0cdb73	2025-07-21 12:27:22.508738
23	optimize-search-function	9d7e604cddc4b56a5422dc68c9313f4a1b6f132c	2025-07-21 12:27:22.710722
24	operation-function	8312e37c2bf9e76bbe841aa5fda889206d2bf8aa	2025-07-21 12:27:22.922159
25	custom-metadata	d974c6057c3db1c1f847afa0e291e6165693b990	2025-07-21 12:27:23.137153
\.


--
-- Data for Name: objects; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.objects (id, bucket_id, name, owner, created_at, updated_at, last_accessed_at, metadata, version, owner_id, user_metadata) FROM stdin;
\.


--
-- Data for Name: s3_multipart_uploads; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.s3_multipart_uploads (id, in_progress_size, upload_signature, bucket_id, key, version, owner_id, created_at, user_metadata) FROM stdin;
\.


--
-- Data for Name: s3_multipart_uploads_parts; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.s3_multipart_uploads_parts (id, upload_id, size, part_number, bucket_id, key, etag, owner_id, version, created_at) FROM stdin;
\.


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: supabase_auth_admin
--

SELECT pg_catalog.setval('auth.refresh_tokens_id_seq', 64, true);


--
-- Name: achievement_assignments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.achievement_assignments_id_seq', 1, false);


--
-- Name: achievement_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.achievement_types_id_seq', 46, true);


--
-- Name: activity_participations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.activity_participations_id_seq', 1, false);


--
-- Name: followers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.followers_id_seq', 1, false);


--
-- Name: friendships_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.friendships_id_seq', 1, false);


--
-- Name: house_activities_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.house_activities_id_seq', 1, false);


--
-- Name: houses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.houses_id_seq', 8, true);


--
-- Name: moderation_reports_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.moderation_reports_id_seq', 1, false);


--
-- Name: profile_shares_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.profile_shares_id_seq', 1, true);


--
-- Name: social_notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.social_notifications_id_seq', 1, false);


--
-- Name: system_notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.system_notifications_id_seq', 1, false);


--
-- Name: user_achievements_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_achievements_id_seq', 7, true);


--
-- Name: user_activities_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_activities_id_seq', 1, false);


--
-- Name: user_connections_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_connections_id_seq', 1, false);


--
-- Name: user_statistics_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_statistics_id_seq', 136, true);


--
-- Name: subscription_id_seq; Type: SEQUENCE SET; Schema: realtime; Owner: supabase_admin
--

SELECT pg_catalog.setval('realtime.subscription_id_seq', 1, false);


--
-- Name: mfa_amr_claims amr_id_pk; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT amr_id_pk PRIMARY KEY (id);


--
-- Name: audit_log_entries audit_log_entries_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.audit_log_entries
    ADD CONSTRAINT audit_log_entries_pkey PRIMARY KEY (id);


--
-- Name: flow_state flow_state_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.flow_state
    ADD CONSTRAINT flow_state_pkey PRIMARY KEY (id);


--
-- Name: identities identities_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_pkey PRIMARY KEY (id);


--
-- Name: identities identities_provider_id_provider_unique; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_provider_id_provider_unique UNIQUE (provider_id, provider);


--
-- Name: instances instances_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.instances
    ADD CONSTRAINT instances_pkey PRIMARY KEY (id);


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_authentication_method_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_authentication_method_pkey UNIQUE (session_id, authentication_method);


--
-- Name: mfa_challenges mfa_challenges_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_pkey PRIMARY KEY (id);


--
-- Name: mfa_factors mfa_factors_last_challenged_at_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_last_challenged_at_key UNIQUE (last_challenged_at);


--
-- Name: mfa_factors mfa_factors_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_pkey PRIMARY KEY (id);


--
-- Name: one_time_tokens one_time_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_token_unique; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_unique UNIQUE (token);


--
-- Name: saml_providers saml_providers_entity_id_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_entity_id_key UNIQUE (entity_id);


--
-- Name: saml_providers saml_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_pkey PRIMARY KEY (id);


--
-- Name: saml_relay_states saml_relay_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sso_domains sso_domains_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_pkey PRIMARY KEY (id);


--
-- Name: sso_providers sso_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_providers
    ADD CONSTRAINT sso_providers_pkey PRIMARY KEY (id);


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: achievement_assignments achievement_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.achievement_assignments
    ADD CONSTRAINT achievement_assignments_pkey PRIMARY KEY (id);


--
-- Name: achievement_types achievement_types_name_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.achievement_types
    ADD CONSTRAINT achievement_types_name_unique UNIQUE (name);


--
-- Name: achievement_types achievement_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.achievement_types
    ADD CONSTRAINT achievement_types_pkey PRIMARY KEY (id);


--
-- Name: activity_participations activity_participations_activity_id_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activity_participations
    ADD CONSTRAINT activity_participations_activity_id_user_id_key UNIQUE (activity_id, user_id);


--
-- Name: activity_participations activity_participations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activity_participations
    ADD CONSTRAINT activity_participations_pkey PRIMARY KEY (id);


--
-- Name: categories categories_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_name_key UNIQUE (name);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: challenge_attempts challenge_attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.challenge_attempts
    ADD CONSTRAINT challenge_attempts_pkey PRIMARY KEY (id);


--
-- Name: challenges challenges_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.challenges
    ADD CONSTRAINT challenges_pkey PRIMARY KEY (id);


--
-- Name: challenges challenges_slug_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.challenges
    ADD CONSTRAINT challenges_slug_key UNIQUE (slug);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: event_participants event_participants_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event_participants
    ADD CONSTRAINT event_participants_pkey PRIMARY KEY (event_id, user_id);


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: events events_slug_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_slug_key UNIQUE (slug);


--
-- Name: followers followers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.followers
    ADD CONSTRAINT followers_pkey PRIMARY KEY (id);


--
-- Name: followers followers_user_id_follower_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.followers
    ADD CONSTRAINT followers_user_id_follower_id_key UNIQUE (user_id, follower_id);


--
-- Name: forum_user_stats forum_user_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.forum_user_stats
    ADD CONSTRAINT forum_user_stats_pkey PRIMARY KEY (user_id);


--
-- Name: friendships friendships_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.friendships
    ADD CONSTRAINT friendships_pkey PRIMARY KEY (id);


--
-- Name: friendships friendships_user_id_friend_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.friendships
    ADD CONSTRAINT friendships_user_id_friend_id_key UNIQUE (user_id, friend_id);


--
-- Name: house_activities house_activities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.house_activities
    ADD CONSTRAINT house_activities_pkey PRIMARY KEY (id);


--
-- Name: house_challenge_progress house_challenge_progress_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.house_challenge_progress
    ADD CONSTRAINT house_challenge_progress_pkey PRIMARY KEY (challenge_id, house_id);


--
-- Name: house_points_ledger house_points_ledger_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.house_points_ledger
    ADD CONSTRAINT house_points_ledger_pkey PRIMARY KEY (id);


--
-- Name: houses houses_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.houses
    ADD CONSTRAINT houses_name_key UNIQUE (name);


--
-- Name: houses houses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.houses
    ADD CONSTRAINT houses_pkey PRIMARY KEY (id);


--
-- Name: likes likes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.likes
    ADD CONSTRAINT likes_pkey PRIMARY KEY (id);


--
-- Name: moderation_reports moderation_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.moderation_reports
    ADD CONSTRAINT moderation_reports_pkey PRIMARY KEY (id);


--
-- Name: poll_options poll_options_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.poll_options
    ADD CONSTRAINT poll_options_pkey PRIMARY KEY (id);


--
-- Name: polls polls_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.polls
    ADD CONSTRAINT polls_pkey PRIMARY KEY (id);


--
-- Name: polls polls_slug_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.polls
    ADD CONSTRAINT polls_slug_key UNIQUE (slug);


--
-- Name: posts posts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- Name: profile_shares profile_shares_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profile_shares
    ADD CONSTRAINT profile_shares_pkey PRIMARY KEY (id);


--
-- Name: profile_shares profile_shares_share_token_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profile_shares
    ADD CONSTRAINT profile_shares_share_token_key UNIQUE (share_token);


--
-- Name: profiles profiles_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_email_key UNIQUE (email);


--
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);


--
-- Name: social_notifications social_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.social_notifications
    ADD CONSTRAINT social_notifications_pkey PRIMARY KEY (id);


--
-- Name: system_notifications system_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.system_notifications
    ADD CONSTRAINT system_notifications_pkey PRIMARY KEY (id);


--
-- Name: likes unique_comment_like; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.likes
    ADD CONSTRAINT unique_comment_like UNIQUE (user_id, comment_id);


--
-- Name: likes unique_post_like; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.likes
    ADD CONSTRAINT unique_post_like UNIQUE (user_id, post_id);


--
-- Name: user_achievements user_achievements_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_achievements
    ADD CONSTRAINT user_achievements_pkey PRIMARY KEY (id);


--
-- Name: user_achievements user_achievements_user_id_achievement_type_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_achievements
    ADD CONSTRAINT user_achievements_user_id_achievement_type_id_key UNIQUE (user_id, achievement_type_id);


--
-- Name: user_activities user_activities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_activities
    ADD CONSTRAINT user_activities_pkey PRIMARY KEY (id);


--
-- Name: user_connections user_connections_follower_id_following_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_connections
    ADD CONSTRAINT user_connections_follower_id_following_id_key UNIQUE (follower_id, following_id);


--
-- Name: user_connections user_connections_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_connections
    ADD CONSTRAINT user_connections_pkey PRIMARY KEY (id);


--
-- Name: user_points_ledger user_points_ledger_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_points_ledger
    ADD CONSTRAINT user_points_ledger_pkey PRIMARY KEY (id);


--
-- Name: user_profiles user_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_profiles
    ADD CONSTRAINT user_profiles_pkey PRIMARY KEY (id);


--
-- Name: user_statistics user_statistics_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_statistics
    ADD CONSTRAINT user_statistics_pkey PRIMARY KEY (id);


--
-- Name: user_statistics user_statistics_user_id_stat_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_statistics
    ADD CONSTRAINT user_statistics_user_id_stat_name_key UNIQUE (user_id, stat_name);


--
-- Name: votes votes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.votes
    ADD CONSTRAINT votes_pkey PRIMARY KEY (id);


--
-- Name: votes votes_poll_id_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.votes
    ADD CONSTRAINT votes_poll_id_user_id_key UNIQUE (poll_id, user_id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER TABLE ONLY realtime.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2025_08_29 messages_2025_08_29_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages_2025_08_29
    ADD CONSTRAINT messages_2025_08_29_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2025_08_30 messages_2025_08_30_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages_2025_08_30
    ADD CONSTRAINT messages_2025_08_30_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2025_08_31 messages_2025_08_31_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages_2025_08_31
    ADD CONSTRAINT messages_2025_08_31_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2025_09_01 messages_2025_09_01_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages_2025_09_01
    ADD CONSTRAINT messages_2025_09_01_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2025_09_02 messages_2025_09_02_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages_2025_09_02
    ADD CONSTRAINT messages_2025_09_02_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2025_09_03 messages_2025_09_03_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages_2025_09_03
    ADD CONSTRAINT messages_2025_09_03_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2025_09_04 messages_2025_09_04_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages_2025_09_04
    ADD CONSTRAINT messages_2025_09_04_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: subscription pk_subscription; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.subscription
    ADD CONSTRAINT pk_subscription PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: buckets buckets_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.buckets
    ADD CONSTRAINT buckets_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_name_key; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_name_key UNIQUE (name);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: objects objects_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT objects_pkey PRIMARY KEY (id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_pkey PRIMARY KEY (id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_pkey PRIMARY KEY (id);


--
-- Name: audit_logs_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX audit_logs_instance_id_idx ON auth.audit_log_entries USING btree (instance_id);


--
-- Name: confirmation_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX confirmation_token_idx ON auth.users USING btree (confirmation_token) WHERE ((confirmation_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_current_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX email_change_token_current_idx ON auth.users USING btree (email_change_token_current) WHERE ((email_change_token_current)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_new_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX email_change_token_new_idx ON auth.users USING btree (email_change_token_new) WHERE ((email_change_token_new)::text !~ '^[0-9 ]*$'::text);


--
-- Name: factor_id_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX factor_id_created_at_idx ON auth.mfa_factors USING btree (user_id, created_at);


--
-- Name: flow_state_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX flow_state_created_at_idx ON auth.flow_state USING btree (created_at DESC);


--
-- Name: identities_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX identities_email_idx ON auth.identities USING btree (email text_pattern_ops);


--
-- Name: INDEX identities_email_idx; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON INDEX auth.identities_email_idx IS 'Auth: Ensures indexed queries on the email column';


--
-- Name: identities_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX identities_user_id_idx ON auth.identities USING btree (user_id);


--
-- Name: idx_auth_code; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX idx_auth_code ON auth.flow_state USING btree (auth_code);


--
-- Name: idx_user_id_auth_method; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX idx_user_id_auth_method ON auth.flow_state USING btree (user_id, authentication_method);


--
-- Name: mfa_challenge_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX mfa_challenge_created_at_idx ON auth.mfa_challenges USING btree (created_at DESC);


--
-- Name: mfa_factors_user_friendly_name_unique; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX mfa_factors_user_friendly_name_unique ON auth.mfa_factors USING btree (friendly_name, user_id) WHERE (TRIM(BOTH FROM friendly_name) <> ''::text);


--
-- Name: mfa_factors_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX mfa_factors_user_id_idx ON auth.mfa_factors USING btree (user_id);


--
-- Name: one_time_tokens_relates_to_hash_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX one_time_tokens_relates_to_hash_idx ON auth.one_time_tokens USING hash (relates_to);


--
-- Name: one_time_tokens_token_hash_hash_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX one_time_tokens_token_hash_hash_idx ON auth.one_time_tokens USING hash (token_hash);


--
-- Name: one_time_tokens_user_id_token_type_key; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX one_time_tokens_user_id_token_type_key ON auth.one_time_tokens USING btree (user_id, token_type);


--
-- Name: reauthentication_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX reauthentication_token_idx ON auth.users USING btree (reauthentication_token) WHERE ((reauthentication_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: recovery_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX recovery_token_idx ON auth.users USING btree (recovery_token) WHERE ((recovery_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: refresh_tokens_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_instance_id_idx ON auth.refresh_tokens USING btree (instance_id);


--
-- Name: refresh_tokens_instance_id_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_instance_id_user_id_idx ON auth.refresh_tokens USING btree (instance_id, user_id);


--
-- Name: refresh_tokens_parent_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_parent_idx ON auth.refresh_tokens USING btree (parent);


--
-- Name: refresh_tokens_session_id_revoked_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_session_id_revoked_idx ON auth.refresh_tokens USING btree (session_id, revoked);


--
-- Name: refresh_tokens_updated_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_updated_at_idx ON auth.refresh_tokens USING btree (updated_at DESC);


--
-- Name: saml_providers_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_providers_sso_provider_id_idx ON auth.saml_providers USING btree (sso_provider_id);


--
-- Name: saml_relay_states_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_created_at_idx ON auth.saml_relay_states USING btree (created_at DESC);


--
-- Name: saml_relay_states_for_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_for_email_idx ON auth.saml_relay_states USING btree (for_email);


--
-- Name: saml_relay_states_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_sso_provider_id_idx ON auth.saml_relay_states USING btree (sso_provider_id);


--
-- Name: sessions_not_after_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sessions_not_after_idx ON auth.sessions USING btree (not_after DESC);


--
-- Name: sessions_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sessions_user_id_idx ON auth.sessions USING btree (user_id);


--
-- Name: sso_domains_domain_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX sso_domains_domain_idx ON auth.sso_domains USING btree (lower(domain));


--
-- Name: sso_domains_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sso_domains_sso_provider_id_idx ON auth.sso_domains USING btree (sso_provider_id);


--
-- Name: sso_providers_resource_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX sso_providers_resource_id_idx ON auth.sso_providers USING btree (lower(resource_id));


--
-- Name: unique_phone_factor_per_user; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX unique_phone_factor_per_user ON auth.mfa_factors USING btree (user_id, phone);


--
-- Name: user_id_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX user_id_created_at_idx ON auth.sessions USING btree (user_id, created_at);


--
-- Name: users_email_partial_key; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX users_email_partial_key ON auth.users USING btree (email) WHERE (is_sso_user = false);


--
-- Name: INDEX users_email_partial_key; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON INDEX auth.users_email_partial_key IS 'Auth: A partial unique index that applies only when is_sso_user is false';


--
-- Name: users_instance_id_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_instance_id_email_idx ON auth.users USING btree (instance_id, lower((email)::text));


--
-- Name: users_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_instance_id_idx ON auth.users USING btree (instance_id);


--
-- Name: users_is_anonymous_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_is_anonymous_idx ON auth.users USING btree (is_anonymous);


--
-- Name: idx_attempts_challenge; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_attempts_challenge ON public.challenge_attempts USING btree (challenge_id);


--
-- Name: idx_attempts_house; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_attempts_house ON public.challenge_attempts USING btree (house_id);


--
-- Name: idx_attempts_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_attempts_status ON public.challenge_attempts USING btree (status);


--
-- Name: idx_attempts_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_attempts_user ON public.challenge_attempts USING btree (user_id);


--
-- Name: idx_challenges_dates; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_challenges_dates ON public.challenges USING btree (start_at, end_at);


--
-- Name: idx_challenges_scope; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_challenges_scope ON public.challenges USING btree (scope);


--
-- Name: idx_challenges_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_challenges_status ON public.challenges USING btree (status);


--
-- Name: idx_comments_post_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_comments_post_id ON public.comments USING btree (post_id);


--
-- Name: idx_comments_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_comments_user_id ON public.comments USING btree (user_id);


--
-- Name: idx_event_participants_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_event_participants_status ON public.event_participants USING btree (status);


--
-- Name: idx_event_participants_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_event_participants_user ON public.event_participants USING btree (user_id);


--
-- Name: idx_events_dates; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_events_dates ON public.events USING btree (start_at, end_at);


--
-- Name: idx_events_featured; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_events_featured ON public.events USING btree (featured);


--
-- Name: idx_events_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_events_status ON public.events USING btree (status);


--
-- Name: idx_followers_follower_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_followers_follower_id ON public.followers USING btree (follower_id);


--
-- Name: idx_followers_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_followers_user_id ON public.followers USING btree (user_id);


--
-- Name: idx_friendships_friend_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_friendships_friend_id ON public.friendships USING btree (friend_id);


--
-- Name: idx_friendships_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_friendships_status ON public.friendships USING btree (status);


--
-- Name: idx_friendships_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_friendships_user_id ON public.friendships USING btree (user_id);


--
-- Name: idx_house_points_created; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_house_points_created ON public.house_points_ledger USING btree (created_at);


--
-- Name: idx_house_points_house; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_house_points_house ON public.house_points_ledger USING btree (house_id);


--
-- Name: idx_likes_comment_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_likes_comment_id ON public.likes USING btree (comment_id);


--
-- Name: idx_likes_post_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_likes_post_id ON public.likes USING btree (post_id);


--
-- Name: idx_likes_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_likes_user_id ON public.likes USING btree (user_id);


--
-- Name: idx_poll_options_poll; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_poll_options_poll ON public.poll_options USING btree (poll_id);


--
-- Name: idx_posts_category_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_posts_category_id ON public.posts USING btree (category_id);


--
-- Name: idx_posts_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_posts_created_at ON public.posts USING btree (created_at DESC);


--
-- Name: idx_posts_house_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_posts_house_id ON public.posts USING btree (house_id);


--
-- Name: idx_posts_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_posts_status ON public.posts USING btree (status);


--
-- Name: idx_posts_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_posts_user_id ON public.posts USING btree (user_id);


--
-- Name: idx_profiles_house; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_profiles_house ON public.profiles USING btree (house);


--
-- Name: idx_social_notifications_is_read; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_social_notifications_is_read ON public.social_notifications USING btree (is_read);


--
-- Name: idx_social_notifications_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_social_notifications_user_id ON public.social_notifications USING btree (user_id);


--
-- Name: idx_user_points_created; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_points_created ON public.user_points_ledger USING btree (created_at);


--
-- Name: idx_user_points_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_points_user ON public.user_points_ledger USING btree (user_id);


--
-- Name: idx_votes_poll; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_votes_poll ON public.votes USING btree (poll_id);


--
-- Name: ix_realtime_subscription_entity; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX ix_realtime_subscription_entity ON realtime.subscription USING btree (entity);


--
-- Name: subscription_subscription_id_entity_filters_key; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE UNIQUE INDEX subscription_subscription_id_entity_filters_key ON realtime.subscription USING btree (subscription_id, entity, filters);


--
-- Name: bname; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX bname ON storage.buckets USING btree (name);


--
-- Name: bucketid_objname; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX bucketid_objname ON storage.objects USING btree (bucket_id, name);


--
-- Name: idx_multipart_uploads_list; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX idx_multipart_uploads_list ON storage.s3_multipart_uploads USING btree (bucket_id, key, created_at);


--
-- Name: idx_objects_bucket_id_name; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX idx_objects_bucket_id_name ON storage.objects USING btree (bucket_id, name COLLATE "C");


--
-- Name: name_prefix_search; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX name_prefix_search ON storage.objects USING btree (name text_pattern_ops);


--
-- Name: messages_2025_08_29_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2025_08_29_pkey;


--
-- Name: messages_2025_08_30_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2025_08_30_pkey;


--
-- Name: messages_2025_08_31_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2025_08_31_pkey;


--
-- Name: messages_2025_09_01_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2025_09_01_pkey;


--
-- Name: messages_2025_09_02_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2025_09_02_pkey;


--
-- Name: messages_2025_09_03_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2025_09_03_pkey;


--
-- Name: messages_2025_09_04_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2025_09_04_pkey;


--
-- Name: users on_auth_user_created; Type: TRIGGER; Schema: auth; Owner: supabase_auth_admin
--

CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


--
-- Name: challenge_attempts trg_attempt_completed; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_attempt_completed AFTER UPDATE ON public.challenge_attempts FOR EACH ROW EXECUTE FUNCTION public._on_challenge_attempt_completed();


--
-- Name: user_profiles trigger_update_reputation; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_update_reputation BEFORE UPDATE ON public.user_profiles FOR EACH ROW EXECUTE FUNCTION public.update_reputation_level();


--
-- Name: comments update_comments_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_comments_updated_at BEFORE UPDATE ON public.comments FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: forum_user_stats update_forum_user_stats_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_forum_user_stats_updated_at BEFORE UPDATE ON public.forum_user_stats FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: friendships update_friendships_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_friendships_updated_at BEFORE UPDATE ON public.friendships FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: posts update_posts_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_posts_updated_at BEFORE UPDATE ON public.posts FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: comments update_user_comments_stats; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_user_comments_stats AFTER INSERT OR DELETE ON public.comments FOR EACH ROW EXECUTE FUNCTION public.update_user_forum_stats();


--
-- Name: posts update_user_posts_stats; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_user_posts_stats AFTER INSERT OR DELETE ON public.posts FOR EACH ROW EXECUTE FUNCTION public.update_user_forum_stats();


--
-- Name: subscription tr_check_filters; Type: TRIGGER; Schema: realtime; Owner: supabase_admin
--

CREATE TRIGGER tr_check_filters BEFORE INSERT OR UPDATE ON realtime.subscription FOR EACH ROW EXECUTE FUNCTION realtime.subscription_check_filters();


--
-- Name: objects update_objects_updated_at; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER update_objects_updated_at BEFORE UPDATE ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.update_updated_at_column();


--
-- Name: identities identities_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: mfa_challenges mfa_challenges_auth_factor_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_auth_factor_id_fkey FOREIGN KEY (factor_id) REFERENCES auth.mfa_factors(id) ON DELETE CASCADE;


--
-- Name: mfa_factors mfa_factors_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: one_time_tokens one_time_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: refresh_tokens refresh_tokens_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: saml_providers saml_providers_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_flow_state_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_flow_state_id_fkey FOREIGN KEY (flow_state_id) REFERENCES auth.flow_state(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: sso_domains sso_domains_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: achievement_assignments achievement_assignments_achievement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.achievement_assignments
    ADD CONSTRAINT achievement_assignments_achievement_id_fkey FOREIGN KEY (achievement_id) REFERENCES public.user_achievements(id);


--
-- Name: achievement_assignments achievement_assignments_assigned_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.achievement_assignments
    ADD CONSTRAINT achievement_assignments_assigned_by_fkey FOREIGN KEY (assigned_by) REFERENCES public.user_profiles(id);


--
-- Name: achievement_assignments achievement_assignments_assigned_to_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.achievement_assignments
    ADD CONSTRAINT achievement_assignments_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES public.user_profiles(id);


--
-- Name: activity_participations activity_participations_activity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activity_participations
    ADD CONSTRAINT activity_participations_activity_id_fkey FOREIGN KEY (activity_id) REFERENCES public.house_activities(id);


--
-- Name: activity_participations activity_participations_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activity_participations
    ADD CONSTRAINT activity_participations_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.user_profiles(id);


--
-- Name: challenge_attempts challenge_attempts_challenge_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.challenge_attempts
    ADD CONSTRAINT challenge_attempts_challenge_id_fkey FOREIGN KEY (challenge_id) REFERENCES public.challenges(id) ON DELETE CASCADE;


--
-- Name: challenge_attempts challenge_attempts_house_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.challenge_attempts
    ADD CONSTRAINT challenge_attempts_house_id_fkey FOREIGN KEY (house_id) REFERENCES public.houses(id);


--
-- Name: challenge_attempts challenge_attempts_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.challenge_attempts
    ADD CONSTRAINT challenge_attempts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: challenges challenges_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.challenges
    ADD CONSTRAINT challenges_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.profiles(id);


--
-- Name: comments comments_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id) ON DELETE CASCADE;


--
-- Name: comments comments_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: event_participants event_participants_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event_participants
    ADD CONSTRAINT event_participants_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(id) ON DELETE CASCADE;


--
-- Name: event_participants event_participants_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event_participants
    ADD CONSTRAINT event_participants_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: events events_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.profiles(id);


--
-- Name: followers followers_follower_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.followers
    ADD CONSTRAINT followers_follower_id_fkey FOREIGN KEY (follower_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: followers followers_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.followers
    ADD CONSTRAINT followers_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: forum_user_stats forum_user_stats_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.forum_user_stats
    ADD CONSTRAINT forum_user_stats_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: friendships friendships_friend_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.friendships
    ADD CONSTRAINT friendships_friend_id_fkey FOREIGN KEY (friend_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: friendships friendships_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.friendships
    ADD CONSTRAINT friendships_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: house_activities house_activities_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.house_activities
    ADD CONSTRAINT house_activities_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.user_profiles(id);


--
-- Name: house_challenge_progress house_challenge_progress_challenge_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.house_challenge_progress
    ADD CONSTRAINT house_challenge_progress_challenge_id_fkey FOREIGN KEY (challenge_id) REFERENCES public.challenges(id) ON DELETE CASCADE;


--
-- Name: house_challenge_progress house_challenge_progress_house_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.house_challenge_progress
    ADD CONSTRAINT house_challenge_progress_house_id_fkey FOREIGN KEY (house_id) REFERENCES public.houses(id);


--
-- Name: house_points_ledger house_points_ledger_house_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.house_points_ledger
    ADD CONSTRAINT house_points_ledger_house_id_fkey FOREIGN KEY (house_id) REFERENCES public.houses(id);


--
-- Name: house_points_ledger house_points_ledger_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.house_points_ledger
    ADD CONSTRAINT house_points_ledger_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id);


--
-- Name: likes likes_comment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.likes
    ADD CONSTRAINT likes_comment_id_fkey FOREIGN KEY (comment_id) REFERENCES public.comments(id) ON DELETE CASCADE;


--
-- Name: likes likes_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.likes
    ADD CONSTRAINT likes_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id) ON DELETE CASCADE;


--
-- Name: likes likes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.likes
    ADD CONSTRAINT likes_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: moderation_reports moderation_reports_reported_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.moderation_reports
    ADD CONSTRAINT moderation_reports_reported_by_fkey FOREIGN KEY (reported_by) REFERENCES public.user_profiles(id);


--
-- Name: moderation_reports moderation_reports_reported_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.moderation_reports
    ADD CONSTRAINT moderation_reports_reported_user_id_fkey FOREIGN KEY (reported_user_id) REFERENCES public.user_profiles(id);


--
-- Name: moderation_reports moderation_reports_reviewed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.moderation_reports
    ADD CONSTRAINT moderation_reports_reviewed_by_fkey FOREIGN KEY (reviewed_by) REFERENCES public.user_profiles(id);


--
-- Name: poll_options poll_options_poll_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.poll_options
    ADD CONSTRAINT poll_options_poll_id_fkey FOREIGN KEY (poll_id) REFERENCES public.polls(id) ON DELETE CASCADE;


--
-- Name: posts posts_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id);


--
-- Name: posts posts_house_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_house_id_fkey FOREIGN KEY (house_id) REFERENCES public.houses(id);


--
-- Name: posts posts_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: profile_shares profile_shares_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profile_shares
    ADD CONSTRAINT profile_shares_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.user_profiles(id);


--
-- Name: profiles profiles_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: social_notifications social_notifications_from_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.social_notifications
    ADD CONSTRAINT social_notifications_from_user_id_fkey FOREIGN KEY (from_user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: social_notifications social_notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.social_notifications
    ADD CONSTRAINT social_notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: system_notifications system_notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.system_notifications
    ADD CONSTRAINT system_notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.user_profiles(id);


--
-- Name: user_achievements user_achievements_achievement_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_achievements
    ADD CONSTRAINT user_achievements_achievement_type_id_fkey FOREIGN KEY (achievement_type_id) REFERENCES public.achievement_types(id);


--
-- Name: user_achievements user_achievements_awarded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_achievements
    ADD CONSTRAINT user_achievements_awarded_by_fkey FOREIGN KEY (awarded_by) REFERENCES public.user_profiles(id);


--
-- Name: user_achievements user_achievements_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_achievements
    ADD CONSTRAINT user_achievements_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.user_profiles(id);


--
-- Name: user_activities user_activities_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_activities
    ADD CONSTRAINT user_activities_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.user_profiles(id);


--
-- Name: user_connections user_connections_follower_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_connections
    ADD CONSTRAINT user_connections_follower_id_fkey FOREIGN KEY (follower_id) REFERENCES public.user_profiles(id);


--
-- Name: user_connections user_connections_following_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_connections
    ADD CONSTRAINT user_connections_following_id_fkey FOREIGN KEY (following_id) REFERENCES public.user_profiles(id);


--
-- Name: user_points_ledger user_points_ledger_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_points_ledger
    ADD CONSTRAINT user_points_ledger_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: user_profiles user_profiles_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_profiles
    ADD CONSTRAINT user_profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id);


--
-- Name: user_statistics user_statistics_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_statistics
    ADD CONSTRAINT user_statistics_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: votes votes_option_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.votes
    ADD CONSTRAINT votes_option_id_fkey FOREIGN KEY (option_id) REFERENCES public.poll_options(id) ON DELETE CASCADE;


--
-- Name: votes votes_poll_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.votes
    ADD CONSTRAINT votes_poll_id_fkey FOREIGN KEY (poll_id) REFERENCES public.polls(id) ON DELETE CASCADE;


--
-- Name: votes votes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.votes
    ADD CONSTRAINT votes_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: objects objects_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT "objects_bucketId_fkey" FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_upload_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_upload_id_fkey FOREIGN KEY (upload_id) REFERENCES storage.s3_multipart_uploads(id) ON DELETE CASCADE;


--
-- Name: audit_log_entries; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.audit_log_entries ENABLE ROW LEVEL SECURITY;

--
-- Name: flow_state; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.flow_state ENABLE ROW LEVEL SECURITY;

--
-- Name: identities; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.identities ENABLE ROW LEVEL SECURITY;

--
-- Name: instances; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.instances ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_amr_claims; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.mfa_amr_claims ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_challenges; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.mfa_challenges ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_factors; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.mfa_factors ENABLE ROW LEVEL SECURITY;

--
-- Name: one_time_tokens; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.one_time_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: refresh_tokens; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.refresh_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_providers; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.saml_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_relay_states; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.saml_relay_states ENABLE ROW LEVEL SECURITY;

--
-- Name: schema_migrations; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.schema_migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: sessions; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_domains; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.sso_domains ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_providers; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.sso_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: users; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;

--
-- Name: user_achievements Achievements viewable based on profile privacy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Achievements viewable based on profile privacy" ON public.user_achievements FOR SELECT USING ((EXISTS ( SELECT 1
   FROM public.user_profiles
  WHERE ((user_profiles.id = user_achievements.user_id) AND ((user_profiles.privacy_public_profile = true) OR (user_profiles.id = auth.uid()))))));


--
-- Name: user_activities Activities viewable based on profile privacy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Activities viewable based on profile privacy" ON public.user_activities FOR SELECT USING ((EXISTS ( SELECT 1
   FROM public.user_profiles
  WHERE ((user_profiles.id = user_activities.user_id) AND ((user_profiles.privacy_public_profile = true) OR (user_profiles.id = auth.uid()))))));


--
-- Name: moderation_reports Anyone can create reports; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Anyone can create reports" ON public.moderation_reports FOR INSERT WITH CHECK ((reported_by = auth.uid()));


--
-- Name: user_achievements Anyone can view achievements; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Anyone can view achievements" ON public.user_achievements FOR SELECT USING (true);


--
-- Name: houses Anyone can view houses; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Anyone can view houses" ON public.houses FOR SELECT USING (true);


--
-- Name: comments Comments are viewable by everyone; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Comments are viewable by everyone" ON public.comments FOR SELECT USING (true);


--
-- Name: user_connections Connections viewable by involved users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Connections viewable by involved users" ON public.user_connections FOR SELECT USING (((follower_id = auth.uid()) OR (following_id = auth.uid())));


--
-- Name: achievement_types Everyone can view achievement types; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Everyone can view achievement types" ON public.achievement_types FOR SELECT USING (true);


--
-- Name: forum_user_stats Forum stats are viewable by everyone; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Forum stats are viewable by everyone" ON public.forum_user_stats FOR SELECT USING (true);


--
-- Name: achievement_assignments House heads can assign achievements; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "House heads can assign achievements" ON public.achievement_assignments FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM public.user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND (((user_profiles.role)::text = 'house_head'::text) OR ((user_profiles.role)::text = 'admin'::text))))));


--
-- Name: user_achievements House heads can assign achievements; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "House heads can assign achievements" ON public.user_achievements FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM public.user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND (user_profiles.is_house_head = true)))));


--
-- Name: user_achievements House heads can insert achievements; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "House heads can insert achievements" ON public.user_achievements FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM public.profiles p1,
    public.profiles p2
  WHERE ((p1.id = auth.uid()) AND (p2.id = user_achievements.user_id) AND ((p1.role)::text = 'house_head'::text) AND (p1.house = p2.house)))));


--
-- Name: house_activities House heads can manage their house activities; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "House heads can manage their house activities" ON public.house_activities USING ((EXISTS ( SELECT 1
   FROM public.user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND ((user_profiles.house)::text = (house_activities.house)::text) AND ((user_profiles.role)::text = ANY ((ARRAY['house_head'::character varying, 'admin'::character varying])::text[]))))));


--
-- Name: user_achievements House heads can view house achievements; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "House heads can view house achievements" ON public.user_achievements FOR SELECT USING ((EXISTS ( SELECT 1
   FROM public.profiles p1,
    public.profiles p2
  WHERE ((p1.id = auth.uid()) AND (p2.id = user_achievements.user_id) AND ((p1.role)::text = 'house_head'::text) AND (p1.house = p2.house)))));


--
-- Name: activity_participations House heads can view participations in their activities; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "House heads can view participations in their activities" ON public.activity_participations FOR SELECT USING ((EXISTS ( SELECT 1
   FROM public.house_activities ha,
    public.user_profiles up
  WHERE ((ha.id = activity_participations.activity_id) AND (up.id = auth.uid()) AND ((up.house)::text = (ha.house)::text) AND ((up.role)::text = ANY ((ARRAY['house_head'::character varying, 'admin'::character varying])::text[]))))));


--
-- Name: moderation_reports House heads can view reports from their house; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "House heads can view reports from their house" ON public.moderation_reports FOR SELECT USING (((reported_by = auth.uid()) OR (EXISTS ( SELECT 1
   FROM public.user_profiles up1,
    public.user_profiles up2
  WHERE ((up1.id = auth.uid()) AND (up2.id = moderation_reports.reported_user_id) AND ((up1.house)::text = (up2.house)::text) AND ((up1.role)::text = ANY ((ARRAY['house_head'::character varying, 'admin'::character varying])::text[])))))));


--
-- Name: house_activities House members can view their house activities; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "House members can view their house activities" ON public.house_activities FOR SELECT USING ((EXISTS ( SELECT 1
   FROM public.user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND ((user_profiles.house)::text = (house_activities.house)::text)))));


--
-- Name: likes Likes are viewable by everyone; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Likes are viewable by everyone" ON public.likes FOR SELECT USING (true);


--
-- Name: posts Posts are viewable by everyone; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Posts are viewable by everyone" ON public.posts FOR SELECT USING (true);


--
-- Name: user_profiles Public profiles are viewable by everyone; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Public profiles are viewable by everyone" ON public.user_profiles FOR SELECT USING ((privacy_public_profile = true));


--
-- Name: system_notifications System can create notifications; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "System can create notifications" ON public.system_notifications FOR INSERT WITH CHECK (true);


--
-- Name: forum_user_stats System can update forum stats; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "System can update forum stats" ON public.forum_user_stats USING (true);


--
-- Name: user_connections Users can create connections; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can create connections" ON public.user_connections FOR INSERT WITH CHECK ((follower_id = auth.uid()));


--
-- Name: friendships Users can create friend requests; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can create friend requests" ON public.friendships FOR INSERT WITH CHECK ((auth.uid() = user_id));


--
-- Name: comments Users can create their own comments; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can create their own comments" ON public.comments FOR INSERT WITH CHECK ((auth.uid() = user_id));


--
-- Name: likes Users can create their own likes; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can create their own likes" ON public.likes FOR INSERT WITH CHECK ((auth.uid() = user_id));


--
-- Name: posts Users can create their own posts; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can create their own posts" ON public.posts FOR INSERT WITH CHECK ((auth.uid() = user_id));


--
-- Name: comments Users can delete their own comments; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can delete their own comments" ON public.comments FOR DELETE USING (((auth.uid() = user_id) OR (EXISTS ( SELECT 1
   FROM public.forum_user_stats
  WHERE ((forum_user_stats.user_id = auth.uid()) AND (forum_user_stats.is_moderator = true))))));


--
-- Name: likes Users can delete their own likes; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can delete their own likes" ON public.likes FOR DELETE USING ((auth.uid() = user_id));


--
-- Name: posts Users can delete their own posts; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can delete their own posts" ON public.posts FOR DELETE USING (((auth.uid() = user_id) OR (EXISTS ( SELECT 1
   FROM public.forum_user_stats
  WHERE ((forum_user_stats.user_id = auth.uid()) AND (forum_user_stats.is_moderator = true))))));


--
-- Name: followers Users can follow others; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can follow others" ON public.followers FOR INSERT WITH CHECK ((auth.uid() = follower_id));


--
-- Name: profiles Users can insert their own profile; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can insert their own profile" ON public.profiles FOR INSERT WITH CHECK ((auth.uid() = id));


--
-- Name: user_profiles Users can insert their own profile; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can insert their own profile" ON public.user_profiles FOR INSERT WITH CHECK ((auth.uid() = id));


--
-- Name: activity_participations Users can manage their own participations; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage their own participations" ON public.activity_participations USING ((user_id = auth.uid()));


--
-- Name: followers Users can unfollow others; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can unfollow others" ON public.followers FOR DELETE USING ((auth.uid() = follower_id));


--
-- Name: user_statistics Users can update own stats; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can update own stats" ON public.user_statistics USING ((auth.uid() = user_id));


--
-- Name: friendships Users can update their friend requests; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can update their friend requests" ON public.friendships FOR UPDATE USING (((auth.uid() = friend_id) OR (auth.uid() = user_id)));


--
-- Name: comments Users can update their own comments; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can update their own comments" ON public.comments FOR UPDATE USING (((auth.uid() = user_id) OR (EXISTS ( SELECT 1
   FROM public.forum_user_stats
  WHERE ((forum_user_stats.user_id = auth.uid()) AND (forum_user_stats.is_moderator = true))))));


--
-- Name: social_notifications Users can update their own notifications; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can update their own notifications" ON public.social_notifications FOR UPDATE USING ((auth.uid() = user_id));


--
-- Name: posts Users can update their own posts; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can update their own posts" ON public.posts FOR UPDATE USING (((auth.uid() = user_id) OR (EXISTS ( SELECT 1
   FROM public.forum_user_stats
  WHERE ((forum_user_stats.user_id = auth.uid()) AND (forum_user_stats.is_moderator = true))))));


--
-- Name: profiles Users can update their own profile; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can update their own profile" ON public.profiles FOR UPDATE USING ((auth.uid() = id));


--
-- Name: user_profiles Users can update their own profile; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can update their own profile" ON public.user_profiles FOR UPDATE USING ((auth.uid() = id));


--
-- Name: followers Users can view followers; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view followers" ON public.followers FOR SELECT USING (((auth.uid() = user_id) OR (auth.uid() = follower_id)));


--
-- Name: user_achievements Users can view own achievements; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view own achievements" ON public.user_achievements FOR SELECT USING ((auth.uid() = user_id));


--
-- Name: user_statistics Users can view own stats; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view own stats" ON public.user_statistics FOR SELECT USING ((auth.uid() = user_id));


--
-- Name: achievement_assignments Users can view their achievement assignments; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view their achievement assignments" ON public.achievement_assignments FOR SELECT USING (((assigned_to = auth.uid()) OR (assigned_by = auth.uid()) OR (EXISTS ( SELECT 1
   FROM public.user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND (((user_profiles.role)::text = 'house_head'::text) OR ((user_profiles.role)::text = 'admin'::text)))))));


--
-- Name: friendships Users can view their own friendships; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view their own friendships" ON public.friendships FOR SELECT USING (((auth.uid() = user_id) OR (auth.uid() = friend_id)));


--
-- Name: social_notifications Users can view their own notifications; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view their own notifications" ON public.social_notifications FOR SELECT USING ((auth.uid() = user_id));


--
-- Name: system_notifications Users can view their own notifications; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view their own notifications" ON public.system_notifications FOR SELECT USING ((user_id = auth.uid()));


--
-- Name: profiles Users can view their own profile; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view their own profile" ON public.profiles FOR SELECT USING ((auth.uid() = id));


--
-- Name: user_profiles Users can view their own profile; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view their own profile" ON public.user_profiles FOR SELECT USING ((auth.uid() = id));


--
-- Name: achievement_assignments; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.achievement_assignments ENABLE ROW LEVEL SECURITY;

--
-- Name: achievement_types; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.achievement_types ENABLE ROW LEVEL SECURITY;

--
-- Name: activity_participations; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.activity_participations ENABLE ROW LEVEL SECURITY;

--
-- Name: challenge_attempts attempts_insert_self; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY attempts_insert_self ON public.challenge_attempts FOR INSERT WITH CHECK ((user_id = auth.uid()));


--
-- Name: challenge_attempts attempts_select_self; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY attempts_select_self ON public.challenge_attempts FOR SELECT USING ((user_id = auth.uid()));


--
-- Name: challenge_attempts attempts_update_self; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY attempts_update_self ON public.challenge_attempts FOR UPDATE USING ((user_id = auth.uid()));


--
-- Name: challenge_attempts; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.challenge_attempts ENABLE ROW LEVEL SECURITY;

--
-- Name: challenges; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.challenges ENABLE ROW LEVEL SECURITY;

--
-- Name: challenges challenges_read_public; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY challenges_read_public ON public.challenges FOR SELECT USING ((status <> 'draft'::text));


--
-- Name: comments; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;

--
-- Name: event_participants; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.event_participants ENABLE ROW LEVEL SECURITY;

--
-- Name: event_participants event_participants_insert_self; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY event_participants_insert_self ON public.event_participants FOR INSERT WITH CHECK ((user_id = auth.uid()));


--
-- Name: event_participants event_participants_select_self; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY event_participants_select_self ON public.event_participants FOR SELECT USING ((user_id = auth.uid()));


--
-- Name: event_participants event_participants_update_self; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY event_participants_update_self ON public.event_participants FOR UPDATE USING ((user_id = auth.uid()));


--
-- Name: events; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;

--
-- Name: events events_read_public; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY events_read_public ON public.events FOR SELECT USING (((status <> 'draft'::text) OR (created_by = auth.uid())));


--
-- Name: followers; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.followers ENABLE ROW LEVEL SECURITY;

--
-- Name: forum_user_stats; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.forum_user_stats ENABLE ROW LEVEL SECURITY;

--
-- Name: friendships; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.friendships ENABLE ROW LEVEL SECURITY;

--
-- Name: house_activities; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.house_activities ENABLE ROW LEVEL SECURITY;

--
-- Name: house_challenge_progress; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.house_challenge_progress ENABLE ROW LEVEL SECURITY;

--
-- Name: house_points_ledger house_ledger_no_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY house_ledger_no_select ON public.house_points_ledger FOR SELECT USING (false);


--
-- Name: house_points_ledger; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.house_points_ledger ENABLE ROW LEVEL SECURITY;

--
-- Name: house_challenge_progress house_progress_read; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY house_progress_read ON public.house_challenge_progress FOR SELECT USING (true);


--
-- Name: houses; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.houses ENABLE ROW LEVEL SECURITY;

--
-- Name: likes; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.likes ENABLE ROW LEVEL SECURITY;

--
-- Name: moderation_reports; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.moderation_reports ENABLE ROW LEVEL SECURITY;

--
-- Name: poll_options; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.poll_options ENABLE ROW LEVEL SECURITY;

--
-- Name: poll_options poll_options_read_public; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY poll_options_read_public ON public.poll_options FOR SELECT USING (true);


--
-- Name: polls; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.polls ENABLE ROW LEVEL SECURITY;

--
-- Name: polls polls_read_public; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY polls_read_public ON public.polls FOR SELECT USING ((status = ANY (ARRAY['active'::text, 'completed'::text])));


--
-- Name: posts; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;

--
-- Name: profiles; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

--
-- Name: profiles profiles_insert_self; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY profiles_insert_self ON public.profiles FOR INSERT WITH CHECK ((auth.uid() = id));


--
-- Name: profiles profiles_self_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY profiles_self_select ON public.profiles FOR SELECT USING ((auth.uid() = id));


--
-- Name: profiles profiles_self_update; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY profiles_self_update ON public.profiles FOR UPDATE USING ((auth.uid() = id));


--
-- Name: social_notifications; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.social_notifications ENABLE ROW LEVEL SECURITY;

--
-- Name: system_notifications; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.system_notifications ENABLE ROW LEVEL SECURITY;

--
-- Name: user_achievements; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.user_achievements ENABLE ROW LEVEL SECURITY;

--
-- Name: user_activities; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.user_activities ENABLE ROW LEVEL SECURITY;

--
-- Name: user_connections; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.user_connections ENABLE ROW LEVEL SECURITY;

--
-- Name: user_points_ledger user_ledger_self_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY user_ledger_self_select ON public.user_points_ledger FOR SELECT USING ((user_id = auth.uid()));


--
-- Name: user_points_ledger; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.user_points_ledger ENABLE ROW LEVEL SECURITY;

--
-- Name: user_profiles; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

--
-- Name: user_statistics; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.user_statistics ENABLE ROW LEVEL SECURITY;

--
-- Name: votes; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.votes ENABLE ROW LEVEL SECURITY;

--
-- Name: votes votes_insert_self; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY votes_insert_self ON public.votes FOR INSERT WITH CHECK ((user_id = auth.uid()));


--
-- Name: votes votes_select_self; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY votes_select_self ON public.votes FOR SELECT USING ((user_id = auth.uid()));


--
-- Name: messages; Type: ROW SECURITY; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER TABLE realtime.messages ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.buckets ENABLE ROW LEVEL SECURITY;

--
-- Name: migrations; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: objects; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.s3_multipart_uploads ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads_parts; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.s3_multipart_uploads_parts ENABLE ROW LEVEL SECURITY;

--
-- Name: supabase_realtime; Type: PUBLICATION; Schema: -; Owner: postgres
--

CREATE PUBLICATION supabase_realtime WITH (publish = 'insert, update, delete, truncate');


ALTER PUBLICATION supabase_realtime OWNER TO postgres;

--
-- Name: supabase_realtime_messages_publication; Type: PUBLICATION; Schema: -; Owner: supabase_admin
--

CREATE PUBLICATION supabase_realtime_messages_publication WITH (publish = 'insert, update, delete, truncate');


ALTER PUBLICATION supabase_realtime_messages_publication OWNER TO supabase_admin;

--
-- Name: supabase_realtime_messages_publication messages; Type: PUBLICATION TABLE; Schema: realtime; Owner: supabase_admin
--

ALTER PUBLICATION supabase_realtime_messages_publication ADD TABLE ONLY realtime.messages;


--
-- Name: SCHEMA auth; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA auth TO anon;
GRANT USAGE ON SCHEMA auth TO authenticated;
GRANT USAGE ON SCHEMA auth TO service_role;
GRANT ALL ON SCHEMA auth TO supabase_auth_admin;
GRANT ALL ON SCHEMA auth TO dashboard_user;
GRANT USAGE ON SCHEMA auth TO postgres;


--
-- Name: SCHEMA extensions; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA extensions TO anon;
GRANT USAGE ON SCHEMA extensions TO authenticated;
GRANT USAGE ON SCHEMA extensions TO service_role;
GRANT ALL ON SCHEMA extensions TO dashboard_user;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT USAGE ON SCHEMA public TO postgres;
GRANT USAGE ON SCHEMA public TO anon;
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO service_role;


--
-- Name: SCHEMA realtime; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA realtime TO postgres;
GRANT USAGE ON SCHEMA realtime TO anon;
GRANT USAGE ON SCHEMA realtime TO authenticated;
GRANT USAGE ON SCHEMA realtime TO service_role;
GRANT ALL ON SCHEMA realtime TO supabase_realtime_admin;


--
-- Name: SCHEMA storage; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA storage TO postgres WITH GRANT OPTION;
GRANT USAGE ON SCHEMA storage TO anon;
GRANT USAGE ON SCHEMA storage TO authenticated;
GRANT USAGE ON SCHEMA storage TO service_role;
GRANT ALL ON SCHEMA storage TO supabase_storage_admin;
GRANT ALL ON SCHEMA storage TO dashboard_user;


--
-- Name: FUNCTION email(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.email() TO dashboard_user;


--
-- Name: FUNCTION jwt(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.jwt() TO postgres;
GRANT ALL ON FUNCTION auth.jwt() TO dashboard_user;


--
-- Name: FUNCTION role(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.role() TO dashboard_user;


--
-- Name: FUNCTION uid(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.uid() TO dashboard_user;


--
-- Name: FUNCTION armor(bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.armor(bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.armor(bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.armor(bytea) TO dashboard_user;


--
-- Name: FUNCTION armor(bytea, text[], text[]); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.armor(bytea, text[], text[]) FROM postgres;
GRANT ALL ON FUNCTION extensions.armor(bytea, text[], text[]) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.armor(bytea, text[], text[]) TO dashboard_user;


--
-- Name: FUNCTION crypt(text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.crypt(text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.crypt(text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.crypt(text, text) TO dashboard_user;


--
-- Name: FUNCTION dearmor(text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.dearmor(text) FROM postgres;
GRANT ALL ON FUNCTION extensions.dearmor(text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.dearmor(text) TO dashboard_user;


--
-- Name: FUNCTION decrypt(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.decrypt(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.decrypt(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.decrypt(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION decrypt_iv(bytea, bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.decrypt_iv(bytea, bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.decrypt_iv(bytea, bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.decrypt_iv(bytea, bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION digest(bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.digest(bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.digest(bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.digest(bytea, text) TO dashboard_user;


--
-- Name: FUNCTION digest(text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.digest(text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.digest(text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.digest(text, text) TO dashboard_user;


--
-- Name: FUNCTION encrypt(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.encrypt(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.encrypt(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.encrypt(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION encrypt_iv(bytea, bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.encrypt_iv(bytea, bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.encrypt_iv(bytea, bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.encrypt_iv(bytea, bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION gen_random_bytes(integer); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.gen_random_bytes(integer) FROM postgres;
GRANT ALL ON FUNCTION extensions.gen_random_bytes(integer) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.gen_random_bytes(integer) TO dashboard_user;


--
-- Name: FUNCTION gen_random_uuid(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.gen_random_uuid() FROM postgres;
GRANT ALL ON FUNCTION extensions.gen_random_uuid() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.gen_random_uuid() TO dashboard_user;


--
-- Name: FUNCTION gen_salt(text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.gen_salt(text) FROM postgres;
GRANT ALL ON FUNCTION extensions.gen_salt(text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.gen_salt(text) TO dashboard_user;


--
-- Name: FUNCTION gen_salt(text, integer); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.gen_salt(text, integer) FROM postgres;
GRANT ALL ON FUNCTION extensions.gen_salt(text, integer) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.gen_salt(text, integer) TO dashboard_user;


--
-- Name: FUNCTION grant_pg_cron_access(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

REVOKE ALL ON FUNCTION extensions.grant_pg_cron_access() FROM supabase_admin;
GRANT ALL ON FUNCTION extensions.grant_pg_cron_access() TO supabase_admin WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.grant_pg_cron_access() TO dashboard_user;


--
-- Name: FUNCTION grant_pg_net_access(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

REVOKE ALL ON FUNCTION extensions.grant_pg_net_access() FROM supabase_admin;
GRANT ALL ON FUNCTION extensions.grant_pg_net_access() TO supabase_admin WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.grant_pg_net_access() TO dashboard_user;


--
-- Name: FUNCTION hmac(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.hmac(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.hmac(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.hmac(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION hmac(text, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.hmac(text, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.hmac(text, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.hmac(text, text, text) TO dashboard_user;


--
-- Name: FUNCTION pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT shared_blk_read_time double precision, OUT shared_blk_write_time double precision, OUT local_blk_read_time double precision, OUT local_blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision, OUT jit_deform_count bigint, OUT jit_deform_time double precision, OUT stats_since timestamp with time zone, OUT minmax_stats_since timestamp with time zone); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT shared_blk_read_time double precision, OUT shared_blk_write_time double precision, OUT local_blk_read_time double precision, OUT local_blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision, OUT jit_deform_count bigint, OUT jit_deform_time double precision, OUT stats_since timestamp with time zone, OUT minmax_stats_since timestamp with time zone) FROM postgres;
GRANT ALL ON FUNCTION extensions.pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT shared_blk_read_time double precision, OUT shared_blk_write_time double precision, OUT local_blk_read_time double precision, OUT local_blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision, OUT jit_deform_count bigint, OUT jit_deform_time double precision, OUT stats_since timestamp with time zone, OUT minmax_stats_since timestamp with time zone) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT shared_blk_read_time double precision, OUT shared_blk_write_time double precision, OUT local_blk_read_time double precision, OUT local_blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision, OUT jit_deform_count bigint, OUT jit_deform_time double precision, OUT stats_since timestamp with time zone, OUT minmax_stats_since timestamp with time zone) TO dashboard_user;


--
-- Name: FUNCTION pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone) FROM postgres;
GRANT ALL ON FUNCTION extensions.pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone) TO dashboard_user;


--
-- Name: FUNCTION pgp_armor_headers(text, OUT key text, OUT value text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_armor_headers(text, OUT key text, OUT value text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_armor_headers(text, OUT key text, OUT value text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_armor_headers(text, OUT key text, OUT value text) TO dashboard_user;


--
-- Name: FUNCTION pgp_key_id(bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_key_id(bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_key_id(bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_key_id(bytea) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_encrypt(text, bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_encrypt(text, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_encrypt_bytea(bytea, bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_encrypt_bytea(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_decrypt(bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_decrypt(bytea, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_decrypt_bytea(bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_decrypt_bytea(bytea, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_encrypt(text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_encrypt(text, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_encrypt_bytea(bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_encrypt_bytea(bytea, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgrst_ddl_watch(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgrst_ddl_watch() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgrst_drop_watch(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgrst_drop_watch() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION uuid_generate_v1(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_generate_v1() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1() TO dashboard_user;


--
-- Name: FUNCTION uuid_generate_v1mc(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_generate_v1mc() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1mc() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1mc() TO dashboard_user;


--
-- Name: FUNCTION uuid_generate_v3(namespace uuid, name text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_generate_v3(namespace uuid, name text) FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_generate_v3(namespace uuid, name text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v3(namespace uuid, name text) TO dashboard_user;


--
-- Name: FUNCTION uuid_generate_v4(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_generate_v4() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_generate_v4() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v4() TO dashboard_user;


--
-- Name: FUNCTION uuid_generate_v5(namespace uuid, name text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_generate_v5(namespace uuid, name text) FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_generate_v5(namespace uuid, name text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v5(namespace uuid, name text) TO dashboard_user;


--
-- Name: FUNCTION uuid_nil(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_nil() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_nil() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_nil() TO dashboard_user;


--
-- Name: FUNCTION uuid_ns_dns(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_ns_dns() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_ns_dns() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_ns_dns() TO dashboard_user;


--
-- Name: FUNCTION uuid_ns_oid(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_ns_oid() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_ns_oid() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_ns_oid() TO dashboard_user;


--
-- Name: FUNCTION uuid_ns_url(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_ns_url() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_ns_url() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_ns_url() TO dashboard_user;


--
-- Name: FUNCTION uuid_ns_x500(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_ns_x500() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_ns_x500() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_ns_x500() TO dashboard_user;


--
-- Name: FUNCTION get_auth(p_usename text); Type: ACL; Schema: pgbouncer; Owner: supabase_admin
--

REVOKE ALL ON FUNCTION pgbouncer.get_auth(p_usename text) FROM PUBLIC;
GRANT ALL ON FUNCTION pgbouncer.get_auth(p_usename text) TO pgbouncer;
GRANT ALL ON FUNCTION pgbouncer.get_auth(p_usename text) TO postgres;


--
-- Name: FUNCTION _on_challenge_attempt_completed(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._on_challenge_attempt_completed() TO anon;
GRANT ALL ON FUNCTION public._on_challenge_attempt_completed() TO authenticated;
GRANT ALL ON FUNCTION public._on_challenge_attempt_completed() TO service_role;


--
-- Name: FUNCTION _period_window(in_period text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._period_window(in_period text) TO anon;
GRANT ALL ON FUNCTION public._period_window(in_period text) TO authenticated;
GRANT ALL ON FUNCTION public._period_window(in_period text) TO service_role;


--
-- Name: FUNCTION accept_friend_request(p_requester_id uuid); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.accept_friend_request(p_requester_id uuid) TO anon;
GRANT ALL ON FUNCTION public.accept_friend_request(p_requester_id uuid) TO authenticated;
GRANT ALL ON FUNCTION public.accept_friend_request(p_requester_id uuid) TO service_role;


--
-- Name: FUNCTION assign_achievement_to_user(p_user_id uuid, p_achievement_type_id integer, p_reason text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.assign_achievement_to_user(p_user_id uuid, p_achievement_type_id integer, p_reason text) TO anon;
GRANT ALL ON FUNCTION public.assign_achievement_to_user(p_user_id uuid, p_achievement_type_id integer, p_reason text) TO authenticated;
GRANT ALL ON FUNCTION public.assign_achievement_to_user(p_user_id uuid, p_achievement_type_id integer, p_reason text) TO service_role;


--
-- Name: FUNCTION calculate_reputation_level(points integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.calculate_reputation_level(points integer) TO anon;
GRANT ALL ON FUNCTION public.calculate_reputation_level(points integer) TO authenticated;
GRANT ALL ON FUNCTION public.calculate_reputation_level(points integer) TO service_role;


--
-- Name: FUNCTION check_and_award_achievements(p_user_id uuid); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.check_and_award_achievements(p_user_id uuid) TO anon;
GRANT ALL ON FUNCTION public.check_and_award_achievements(p_user_id uuid) TO authenticated;
GRANT ALL ON FUNCTION public.check_and_award_achievements(p_user_id uuid) TO service_role;


--
-- Name: FUNCTION decline_friend_request(p_requester_id uuid); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.decline_friend_request(p_requester_id uuid) TO anon;
GRANT ALL ON FUNCTION public.decline_friend_request(p_requester_id uuid) TO authenticated;
GRANT ALL ON FUNCTION public.decline_friend_request(p_requester_id uuid) TO service_role;


--
-- Name: FUNCTION follow_user(p_user_to_follow_id uuid); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.follow_user(p_user_to_follow_id uuid) TO anon;
GRANT ALL ON FUNCTION public.follow_user(p_user_to_follow_id uuid) TO authenticated;
GRANT ALL ON FUNCTION public.follow_user(p_user_to_follow_id uuid) TO service_role;


--
-- Name: FUNCTION generate_share_token(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.generate_share_token() TO anon;
GRANT ALL ON FUNCTION public.generate_share_token() TO authenticated;
GRANT ALL ON FUNCTION public.generate_share_token() TO service_role;


--
-- Name: FUNCTION get_house_points_breakdown(target_house_id integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_house_points_breakdown(target_house_id integer) TO anon;
GRANT ALL ON FUNCTION public.get_house_points_breakdown(target_house_id integer) TO authenticated;
GRANT ALL ON FUNCTION public.get_house_points_breakdown(target_house_id integer) TO service_role;


--
-- Name: FUNCTION get_house_statistics(p_house character varying); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_house_statistics(p_house character varying) TO anon;
GRANT ALL ON FUNCTION public.get_house_statistics(p_house character varying) TO authenticated;
GRANT ALL ON FUNCTION public.get_house_statistics(p_house character varying) TO service_role;


--
-- Name: FUNCTION get_poll_options_with_counts(in_poll_id uuid); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_poll_options_with_counts(in_poll_id uuid) TO anon;
GRANT ALL ON FUNCTION public.get_poll_options_with_counts(in_poll_id uuid) TO authenticated;
GRANT ALL ON FUNCTION public.get_poll_options_with_counts(in_poll_id uuid) TO service_role;


--
-- Name: FUNCTION get_polls_active(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_polls_active() TO anon;
GRANT ALL ON FUNCTION public.get_polls_active() TO authenticated;
GRANT ALL ON FUNCTION public.get_polls_active() TO service_role;


--
-- Name: FUNCTION get_quick_stats(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_quick_stats() TO anon;
GRANT ALL ON FUNCTION public.get_quick_stats() TO authenticated;
GRANT ALL ON FUNCTION public.get_quick_stats() TO service_role;


--
-- Name: FUNCTION get_recent_friends(p_limit integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_recent_friends(p_limit integer) TO anon;
GRANT ALL ON FUNCTION public.get_recent_friends(p_limit integer) TO authenticated;
GRANT ALL ON FUNCTION public.get_recent_friends(p_limit integer) TO service_role;


--
-- Name: FUNCTION get_recent_poll_results(in_limit integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_recent_poll_results(in_limit integer) TO anon;
GRANT ALL ON FUNCTION public.get_recent_poll_results(in_limit integer) TO authenticated;
GRANT ALL ON FUNCTION public.get_recent_poll_results(in_limit integer) TO service_role;


--
-- Name: FUNCTION get_user_social_stats(p_user_id uuid); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_user_social_stats(p_user_id uuid) TO anon;
GRANT ALL ON FUNCTION public.get_user_social_stats(p_user_id uuid) TO authenticated;
GRANT ALL ON FUNCTION public.get_user_social_stats(p_user_id uuid) TO service_role;


--
-- Name: FUNCTION handle_new_user(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.handle_new_user() TO anon;
GRANT ALL ON FUNCTION public.handle_new_user() TO authenticated;
GRANT ALL ON FUNCTION public.handle_new_user() TO service_role;


--
-- Name: FUNCTION increment_post_views(post_id uuid); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.increment_post_views(post_id uuid) TO anon;
GRANT ALL ON FUNCTION public.increment_post_views(post_id uuid) TO authenticated;
GRANT ALL ON FUNCTION public.increment_post_views(post_id uuid) TO service_role;


--
-- Name: FUNCTION join_event(in_slug text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.join_event(in_slug text) TO anon;
GRANT ALL ON FUNCTION public.join_event(in_slug text) TO authenticated;
GRANT ALL ON FUNCTION public.join_event(in_slug text) TO service_role;


--
-- Name: FUNCTION leaderboard_houses(in_period text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.leaderboard_houses(in_period text) TO anon;
GRANT ALL ON FUNCTION public.leaderboard_houses(in_period text) TO authenticated;
GRANT ALL ON FUNCTION public.leaderboard_houses(in_period text) TO service_role;


--
-- Name: FUNCTION leaderboard_users(in_period text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.leaderboard_users(in_period text) TO anon;
GRANT ALL ON FUNCTION public.leaderboard_users(in_period text) TO authenticated;
GRANT ALL ON FUNCTION public.leaderboard_users(in_period text) TO service_role;


--
-- Name: FUNCTION list_calendar_events(in_month integer, in_year integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.list_calendar_events(in_month integer, in_year integer) TO anon;
GRANT ALL ON FUNCTION public.list_calendar_events(in_month integer, in_year integer) TO authenticated;
GRANT ALL ON FUNCTION public.list_calendar_events(in_month integer, in_year integer) TO service_role;


--
-- Name: FUNCTION list_featured_events(in_limit integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.list_featured_events(in_limit integer) TO anon;
GRANT ALL ON FUNCTION public.list_featured_events(in_limit integer) TO authenticated;
GRANT ALL ON FUNCTION public.list_featured_events(in_limit integer) TO service_role;


--
-- Name: FUNCTION list_house_challenges(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.list_house_challenges() TO anon;
GRANT ALL ON FUNCTION public.list_house_challenges() TO authenticated;
GRANT ALL ON FUNCTION public.list_house_challenges() TO service_role;


--
-- Name: FUNCTION list_individual_challenges(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.list_individual_challenges() TO anon;
GRANT ALL ON FUNCTION public.list_individual_challenges() TO authenticated;
GRANT ALL ON FUNCTION public.list_individual_challenges() TO service_role;


--
-- Name: FUNCTION list_upcoming_events(in_limit integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.list_upcoming_events(in_limit integer) TO anon;
GRANT ALL ON FUNCTION public.list_upcoming_events(in_limit integer) TO authenticated;
GRANT ALL ON FUNCTION public.list_upcoming_events(in_limit integer) TO service_role;


--
-- Name: FUNCTION my_participations(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.my_participations() TO anon;
GRANT ALL ON FUNCTION public.my_participations() TO authenticated;
GRANT ALL ON FUNCTION public.my_participations() TO service_role;


--
-- Name: FUNCTION send_friend_request(p_friend_id uuid); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.send_friend_request(p_friend_id uuid) TO anon;
GRANT ALL ON FUNCTION public.send_friend_request(p_friend_id uuid) TO authenticated;
GRANT ALL ON FUNCTION public.send_friend_request(p_friend_id uuid) TO service_role;


--
-- Name: FUNCTION submit_challenge_attempt(in_slug text, in_evidence_url text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.submit_challenge_attempt(in_slug text, in_evidence_url text) TO anon;
GRANT ALL ON FUNCTION public.submit_challenge_attempt(in_slug text, in_evidence_url text) TO authenticated;
GRANT ALL ON FUNCTION public.submit_challenge_attempt(in_slug text, in_evidence_url text) TO service_role;


--
-- Name: FUNCTION unfollow_user(p_user_to_unfollow_id uuid); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.unfollow_user(p_user_to_unfollow_id uuid) TO anon;
GRANT ALL ON FUNCTION public.unfollow_user(p_user_to_unfollow_id uuid) TO authenticated;
GRANT ALL ON FUNCTION public.unfollow_user(p_user_to_unfollow_id uuid) TO service_role;


--
-- Name: FUNCTION update_reputation_level(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.update_reputation_level() TO anon;
GRANT ALL ON FUNCTION public.update_reputation_level() TO authenticated;
GRANT ALL ON FUNCTION public.update_reputation_level() TO service_role;


--
-- Name: FUNCTION update_updated_at_column(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.update_updated_at_column() TO anon;
GRANT ALL ON FUNCTION public.update_updated_at_column() TO authenticated;
GRANT ALL ON FUNCTION public.update_updated_at_column() TO service_role;


--
-- Name: FUNCTION update_user_forum_stats(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.update_user_forum_stats() TO anon;
GRANT ALL ON FUNCTION public.update_user_forum_stats() TO authenticated;
GRANT ALL ON FUNCTION public.update_user_forum_stats() TO service_role;


--
-- Name: FUNCTION update_user_stat(p_user_id uuid, p_stat_name text, p_increment integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.update_user_stat(p_user_id uuid, p_stat_name text, p_increment integer) TO anon;
GRANT ALL ON FUNCTION public.update_user_stat(p_user_id uuid, p_stat_name text, p_increment integer) TO authenticated;
GRANT ALL ON FUNCTION public.update_user_stat(p_user_id uuid, p_stat_name text, p_increment integer) TO service_role;


--
-- Name: FUNCTION vote_poll(in_slug text, in_option uuid); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.vote_poll(in_slug text, in_option uuid) TO anon;
GRANT ALL ON FUNCTION public.vote_poll(in_slug text, in_option uuid) TO authenticated;
GRANT ALL ON FUNCTION public.vote_poll(in_slug text, in_option uuid) TO service_role;


--
-- Name: FUNCTION apply_rls(wal jsonb, max_record_bytes integer); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO postgres;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO anon;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO authenticated;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO service_role;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO supabase_realtime_admin;


--
-- Name: FUNCTION broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text) TO postgres;
GRANT ALL ON FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text) TO dashboard_user;


--
-- Name: FUNCTION build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO postgres;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO anon;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO authenticated;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO service_role;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO supabase_realtime_admin;


--
-- Name: FUNCTION "cast"(val text, type_ regtype); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO postgres;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO dashboard_user;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO anon;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO authenticated;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO service_role;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO supabase_realtime_admin;


--
-- Name: FUNCTION check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO postgres;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO anon;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO authenticated;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO service_role;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO supabase_realtime_admin;


--
-- Name: FUNCTION is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO postgres;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO anon;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO authenticated;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO service_role;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO supabase_realtime_admin;


--
-- Name: FUNCTION list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO postgres;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO anon;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO authenticated;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO service_role;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO supabase_realtime_admin;


--
-- Name: FUNCTION quote_wal2json(entity regclass); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO postgres;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO anon;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO authenticated;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO service_role;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO supabase_realtime_admin;


--
-- Name: FUNCTION send(payload jsonb, event text, topic text, private boolean); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean) TO postgres;
GRANT ALL ON FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean) TO dashboard_user;


--
-- Name: FUNCTION subscription_check_filters(); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO postgres;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO dashboard_user;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO anon;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO authenticated;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO service_role;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO supabase_realtime_admin;


--
-- Name: FUNCTION to_regrole(role_name text); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO postgres;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO anon;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO authenticated;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO service_role;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO supabase_realtime_admin;


--
-- Name: FUNCTION topic(); Type: ACL; Schema: realtime; Owner: supabase_realtime_admin
--

GRANT ALL ON FUNCTION realtime.topic() TO postgres;
GRANT ALL ON FUNCTION realtime.topic() TO dashboard_user;


--
-- Name: TABLE audit_log_entries; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.audit_log_entries TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.audit_log_entries TO postgres;
GRANT SELECT ON TABLE auth.audit_log_entries TO postgres WITH GRANT OPTION;


--
-- Name: TABLE flow_state; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.flow_state TO postgres;
GRANT SELECT ON TABLE auth.flow_state TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.flow_state TO dashboard_user;


--
-- Name: TABLE identities; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.identities TO postgres;
GRANT SELECT ON TABLE auth.identities TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.identities TO dashboard_user;


--
-- Name: TABLE instances; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.instances TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.instances TO postgres;
GRANT SELECT ON TABLE auth.instances TO postgres WITH GRANT OPTION;


--
-- Name: TABLE mfa_amr_claims; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.mfa_amr_claims TO postgres;
GRANT SELECT ON TABLE auth.mfa_amr_claims TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.mfa_amr_claims TO dashboard_user;


--
-- Name: TABLE mfa_challenges; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.mfa_challenges TO postgres;
GRANT SELECT ON TABLE auth.mfa_challenges TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.mfa_challenges TO dashboard_user;


--
-- Name: TABLE mfa_factors; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.mfa_factors TO postgres;
GRANT SELECT ON TABLE auth.mfa_factors TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.mfa_factors TO dashboard_user;


--
-- Name: TABLE one_time_tokens; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.one_time_tokens TO postgres;
GRANT SELECT ON TABLE auth.one_time_tokens TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.one_time_tokens TO dashboard_user;


--
-- Name: TABLE refresh_tokens; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.refresh_tokens TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.refresh_tokens TO postgres;
GRANT SELECT ON TABLE auth.refresh_tokens TO postgres WITH GRANT OPTION;


--
-- Name: SEQUENCE refresh_tokens_id_seq; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON SEQUENCE auth.refresh_tokens_id_seq TO dashboard_user;
GRANT ALL ON SEQUENCE auth.refresh_tokens_id_seq TO postgres;


--
-- Name: TABLE saml_providers; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.saml_providers TO postgres;
GRANT SELECT ON TABLE auth.saml_providers TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.saml_providers TO dashboard_user;


--
-- Name: TABLE saml_relay_states; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.saml_relay_states TO postgres;
GRANT SELECT ON TABLE auth.saml_relay_states TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.saml_relay_states TO dashboard_user;


--
-- Name: TABLE schema_migrations; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT SELECT ON TABLE auth.schema_migrations TO postgres WITH GRANT OPTION;


--
-- Name: TABLE sessions; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.sessions TO postgres;
GRANT SELECT ON TABLE auth.sessions TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.sessions TO dashboard_user;


--
-- Name: TABLE sso_domains; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.sso_domains TO postgres;
GRANT SELECT ON TABLE auth.sso_domains TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.sso_domains TO dashboard_user;


--
-- Name: TABLE sso_providers; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.sso_providers TO postgres;
GRANT SELECT ON TABLE auth.sso_providers TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.sso_providers TO dashboard_user;


--
-- Name: TABLE users; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.users TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.users TO postgres;
GRANT SELECT ON TABLE auth.users TO postgres WITH GRANT OPTION;


--
-- Name: TABLE pg_stat_statements; Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON TABLE extensions.pg_stat_statements FROM postgres;
GRANT ALL ON TABLE extensions.pg_stat_statements TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE extensions.pg_stat_statements TO dashboard_user;


--
-- Name: TABLE pg_stat_statements_info; Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON TABLE extensions.pg_stat_statements_info FROM postgres;
GRANT ALL ON TABLE extensions.pg_stat_statements_info TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE extensions.pg_stat_statements_info TO dashboard_user;


--
-- Name: TABLE achievement_assignments; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.achievement_assignments TO anon;
GRANT ALL ON TABLE public.achievement_assignments TO authenticated;
GRANT ALL ON TABLE public.achievement_assignments TO service_role;


--
-- Name: SEQUENCE achievement_assignments_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.achievement_assignments_id_seq TO anon;
GRANT ALL ON SEQUENCE public.achievement_assignments_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.achievement_assignments_id_seq TO service_role;


--
-- Name: TABLE achievement_types; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.achievement_types TO anon;
GRANT ALL ON TABLE public.achievement_types TO authenticated;
GRANT ALL ON TABLE public.achievement_types TO service_role;


--
-- Name: SEQUENCE achievement_types_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.achievement_types_id_seq TO anon;
GRANT ALL ON SEQUENCE public.achievement_types_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.achievement_types_id_seq TO service_role;


--
-- Name: TABLE activity_participations; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.activity_participations TO anon;
GRANT ALL ON TABLE public.activity_participations TO authenticated;
GRANT ALL ON TABLE public.activity_participations TO service_role;


--
-- Name: SEQUENCE activity_participations_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.activity_participations_id_seq TO anon;
GRANT ALL ON SEQUENCE public.activity_participations_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.activity_participations_id_seq TO service_role;


--
-- Name: TABLE categories; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.categories TO anon;
GRANT ALL ON TABLE public.categories TO authenticated;
GRANT ALL ON TABLE public.categories TO service_role;


--
-- Name: TABLE challenge_attempts; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.challenge_attempts TO anon;
GRANT ALL ON TABLE public.challenge_attempts TO authenticated;
GRANT ALL ON TABLE public.challenge_attempts TO service_role;


--
-- Name: TABLE challenges; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.challenges TO anon;
GRANT ALL ON TABLE public.challenges TO authenticated;
GRANT ALL ON TABLE public.challenges TO service_role;


--
-- Name: TABLE comments; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.comments TO anon;
GRANT ALL ON TABLE public.comments TO authenticated;
GRANT ALL ON TABLE public.comments TO service_role;


--
-- Name: TABLE event_participants; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.event_participants TO anon;
GRANT ALL ON TABLE public.event_participants TO authenticated;
GRANT ALL ON TABLE public.event_participants TO service_role;


--
-- Name: TABLE events; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.events TO anon;
GRANT ALL ON TABLE public.events TO authenticated;
GRANT ALL ON TABLE public.events TO service_role;


--
-- Name: TABLE followers; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.followers TO anon;
GRANT ALL ON TABLE public.followers TO authenticated;
GRANT ALL ON TABLE public.followers TO service_role;


--
-- Name: SEQUENCE followers_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.followers_id_seq TO anon;
GRANT ALL ON SEQUENCE public.followers_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.followers_id_seq TO service_role;


--
-- Name: TABLE forum_user_stats; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.forum_user_stats TO anon;
GRANT ALL ON TABLE public.forum_user_stats TO authenticated;
GRANT ALL ON TABLE public.forum_user_stats TO service_role;


--
-- Name: TABLE friendships; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.friendships TO anon;
GRANT ALL ON TABLE public.friendships TO authenticated;
GRANT ALL ON TABLE public.friendships TO service_role;


--
-- Name: SEQUENCE friendships_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.friendships_id_seq TO anon;
GRANT ALL ON SEQUENCE public.friendships_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.friendships_id_seq TO service_role;


--
-- Name: TABLE house_activities; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.house_activities TO anon;
GRANT ALL ON TABLE public.house_activities TO authenticated;
GRANT ALL ON TABLE public.house_activities TO service_role;


--
-- Name: SEQUENCE house_activities_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.house_activities_id_seq TO anon;
GRANT ALL ON SEQUENCE public.house_activities_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.house_activities_id_seq TO service_role;


--
-- Name: TABLE house_challenge_progress; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.house_challenge_progress TO anon;
GRANT ALL ON TABLE public.house_challenge_progress TO authenticated;
GRANT ALL ON TABLE public.house_challenge_progress TO service_role;


--
-- Name: TABLE house_points_ledger; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.house_points_ledger TO anon;
GRANT ALL ON TABLE public.house_points_ledger TO authenticated;
GRANT ALL ON TABLE public.house_points_ledger TO service_role;


--
-- Name: TABLE houses; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.houses TO anon;
GRANT ALL ON TABLE public.houses TO authenticated;
GRANT ALL ON TABLE public.houses TO service_role;


--
-- Name: SEQUENCE houses_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.houses_id_seq TO anon;
GRANT ALL ON SEQUENCE public.houses_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.houses_id_seq TO service_role;


--
-- Name: TABLE likes; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.likes TO anon;
GRANT ALL ON TABLE public.likes TO authenticated;
GRANT ALL ON TABLE public.likes TO service_role;


--
-- Name: TABLE moderation_reports; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.moderation_reports TO anon;
GRANT ALL ON TABLE public.moderation_reports TO authenticated;
GRANT ALL ON TABLE public.moderation_reports TO service_role;


--
-- Name: SEQUENCE moderation_reports_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.moderation_reports_id_seq TO anon;
GRANT ALL ON SEQUENCE public.moderation_reports_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.moderation_reports_id_seq TO service_role;


--
-- Name: TABLE poll_options; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.poll_options TO anon;
GRANT ALL ON TABLE public.poll_options TO authenticated;
GRANT ALL ON TABLE public.poll_options TO service_role;


--
-- Name: TABLE polls; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.polls TO anon;
GRANT ALL ON TABLE public.polls TO authenticated;
GRANT ALL ON TABLE public.polls TO service_role;


--
-- Name: TABLE posts; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.posts TO anon;
GRANT ALL ON TABLE public.posts TO authenticated;
GRANT ALL ON TABLE public.posts TO service_role;


--
-- Name: TABLE profile_shares; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.profile_shares TO anon;
GRANT ALL ON TABLE public.profile_shares TO authenticated;
GRANT ALL ON TABLE public.profile_shares TO service_role;


--
-- Name: SEQUENCE profile_shares_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.profile_shares_id_seq TO anon;
GRANT ALL ON SEQUENCE public.profile_shares_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.profile_shares_id_seq TO service_role;


--
-- Name: TABLE profiles; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.profiles TO anon;
GRANT ALL ON TABLE public.profiles TO authenticated;
GRANT ALL ON TABLE public.profiles TO service_role;


--
-- Name: TABLE social_notifications; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.social_notifications TO anon;
GRANT ALL ON TABLE public.social_notifications TO authenticated;
GRANT ALL ON TABLE public.social_notifications TO service_role;


--
-- Name: SEQUENCE social_notifications_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.social_notifications_id_seq TO anon;
GRANT ALL ON SEQUENCE public.social_notifications_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.social_notifications_id_seq TO service_role;


--
-- Name: TABLE system_notifications; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.system_notifications TO anon;
GRANT ALL ON TABLE public.system_notifications TO authenticated;
GRANT ALL ON TABLE public.system_notifications TO service_role;


--
-- Name: SEQUENCE system_notifications_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.system_notifications_id_seq TO anon;
GRANT ALL ON SEQUENCE public.system_notifications_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.system_notifications_id_seq TO service_role;


--
-- Name: TABLE user_achievements; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.user_achievements TO anon;
GRANT ALL ON TABLE public.user_achievements TO authenticated;
GRANT ALL ON TABLE public.user_achievements TO service_role;


--
-- Name: SEQUENCE user_achievements_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.user_achievements_id_seq TO anon;
GRANT ALL ON SEQUENCE public.user_achievements_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.user_achievements_id_seq TO service_role;


--
-- Name: TABLE user_activities; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.user_activities TO anon;
GRANT ALL ON TABLE public.user_activities TO authenticated;
GRANT ALL ON TABLE public.user_activities TO service_role;


--
-- Name: SEQUENCE user_activities_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.user_activities_id_seq TO anon;
GRANT ALL ON SEQUENCE public.user_activities_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.user_activities_id_seq TO service_role;


--
-- Name: TABLE user_connections; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.user_connections TO anon;
GRANT ALL ON TABLE public.user_connections TO authenticated;
GRANT ALL ON TABLE public.user_connections TO service_role;


--
-- Name: SEQUENCE user_connections_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.user_connections_id_seq TO anon;
GRANT ALL ON SEQUENCE public.user_connections_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.user_connections_id_seq TO service_role;


--
-- Name: TABLE user_points_ledger; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.user_points_ledger TO anon;
GRANT ALL ON TABLE public.user_points_ledger TO authenticated;
GRANT ALL ON TABLE public.user_points_ledger TO service_role;


--
-- Name: TABLE user_profiles; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.user_profiles TO anon;
GRANT ALL ON TABLE public.user_profiles TO authenticated;
GRANT ALL ON TABLE public.user_profiles TO service_role;


--
-- Name: TABLE user_statistics; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.user_statistics TO anon;
GRANT ALL ON TABLE public.user_statistics TO authenticated;
GRANT ALL ON TABLE public.user_statistics TO service_role;


--
-- Name: SEQUENCE user_statistics_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.user_statistics_id_seq TO anon;
GRANT ALL ON SEQUENCE public.user_statistics_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.user_statistics_id_seq TO service_role;


--
-- Name: TABLE v_event_participants_counts; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.v_event_participants_counts TO anon;
GRANT ALL ON TABLE public.v_event_participants_counts TO authenticated;
GRANT ALL ON TABLE public.v_event_participants_counts TO service_role;


--
-- Name: TABLE votes; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.votes TO anon;
GRANT ALL ON TABLE public.votes TO authenticated;
GRANT ALL ON TABLE public.votes TO service_role;


--
-- Name: TABLE messages; Type: ACL; Schema: realtime; Owner: supabase_realtime_admin
--

GRANT ALL ON TABLE realtime.messages TO postgres;
GRANT ALL ON TABLE realtime.messages TO dashboard_user;
GRANT SELECT,INSERT,UPDATE ON TABLE realtime.messages TO anon;
GRANT SELECT,INSERT,UPDATE ON TABLE realtime.messages TO authenticated;
GRANT SELECT,INSERT,UPDATE ON TABLE realtime.messages TO service_role;


--
-- Name: TABLE messages_2025_08_29; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.messages_2025_08_29 TO postgres;
GRANT ALL ON TABLE realtime.messages_2025_08_29 TO dashboard_user;


--
-- Name: TABLE messages_2025_08_30; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.messages_2025_08_30 TO postgres;
GRANT ALL ON TABLE realtime.messages_2025_08_30 TO dashboard_user;


--
-- Name: TABLE messages_2025_08_31; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.messages_2025_08_31 TO postgres;
GRANT ALL ON TABLE realtime.messages_2025_08_31 TO dashboard_user;


--
-- Name: TABLE messages_2025_09_01; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.messages_2025_09_01 TO postgres;
GRANT ALL ON TABLE realtime.messages_2025_09_01 TO dashboard_user;


--
-- Name: TABLE messages_2025_09_02; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.messages_2025_09_02 TO postgres;
GRANT ALL ON TABLE realtime.messages_2025_09_02 TO dashboard_user;


--
-- Name: TABLE messages_2025_09_03; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.messages_2025_09_03 TO postgres;
GRANT ALL ON TABLE realtime.messages_2025_09_03 TO dashboard_user;


--
-- Name: TABLE messages_2025_09_04; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.messages_2025_09_04 TO postgres;
GRANT ALL ON TABLE realtime.messages_2025_09_04 TO dashboard_user;


--
-- Name: TABLE schema_migrations; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.schema_migrations TO postgres;
GRANT ALL ON TABLE realtime.schema_migrations TO dashboard_user;
GRANT SELECT ON TABLE realtime.schema_migrations TO anon;
GRANT SELECT ON TABLE realtime.schema_migrations TO authenticated;
GRANT SELECT ON TABLE realtime.schema_migrations TO service_role;
GRANT ALL ON TABLE realtime.schema_migrations TO supabase_realtime_admin;


--
-- Name: TABLE subscription; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.subscription TO postgres;
GRANT ALL ON TABLE realtime.subscription TO dashboard_user;
GRANT SELECT ON TABLE realtime.subscription TO anon;
GRANT SELECT ON TABLE realtime.subscription TO authenticated;
GRANT SELECT ON TABLE realtime.subscription TO service_role;
GRANT ALL ON TABLE realtime.subscription TO supabase_realtime_admin;


--
-- Name: SEQUENCE subscription_id_seq; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON SEQUENCE realtime.subscription_id_seq TO postgres;
GRANT ALL ON SEQUENCE realtime.subscription_id_seq TO dashboard_user;
GRANT USAGE ON SEQUENCE realtime.subscription_id_seq TO anon;
GRANT USAGE ON SEQUENCE realtime.subscription_id_seq TO authenticated;
GRANT USAGE ON SEQUENCE realtime.subscription_id_seq TO service_role;
GRANT ALL ON SEQUENCE realtime.subscription_id_seq TO supabase_realtime_admin;


--
-- Name: TABLE buckets; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.buckets TO anon;
GRANT ALL ON TABLE storage.buckets TO authenticated;
GRANT ALL ON TABLE storage.buckets TO service_role;
GRANT ALL ON TABLE storage.buckets TO postgres WITH GRANT OPTION;


--
-- Name: TABLE objects; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.objects TO anon;
GRANT ALL ON TABLE storage.objects TO authenticated;
GRANT ALL ON TABLE storage.objects TO service_role;
GRANT ALL ON TABLE storage.objects TO postgres WITH GRANT OPTION;


--
-- Name: TABLE s3_multipart_uploads; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.s3_multipart_uploads TO service_role;
GRANT SELECT ON TABLE storage.s3_multipart_uploads TO authenticated;
GRANT SELECT ON TABLE storage.s3_multipart_uploads TO anon;


--
-- Name: TABLE s3_multipart_uploads_parts; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.s3_multipart_uploads_parts TO service_role;
GRANT SELECT ON TABLE storage.s3_multipart_uploads_parts TO authenticated;
GRANT SELECT ON TABLE storage.s3_multipart_uploads_parts TO anon;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON SEQUENCES TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON FUNCTIONS TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON TABLES TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: extensions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA extensions GRANT ALL ON SEQUENCES TO postgres WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: extensions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA extensions GRANT ALL ON FUNCTIONS TO postgres WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: extensions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA extensions GRANT ALL ON TABLES TO postgres WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON SEQUENCES TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON FUNCTIONS TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON TABLES TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES TO service_role;

--
-- Name: v_event_participants_counts; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: postgres
--

REFRESH MATERIALIZED VIEW public.v_event_participants_counts;


--
-- PostgreSQL database dump complete
--

\unrestrict Z0tdWi4mDmvSiANaBkOxEa84I3ZdTiS6Z65eOwOcaGbwRqvEkNGcK5idRO2nEnk

--
-- PostgreSQL database cluster dump complete
--

