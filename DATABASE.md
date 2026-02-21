# Hogwarts Community Hub - Local Database Documentation

## Overview

This project uses a **local PostgreSQL database** with an Express.js backend API. The frontend connects via `window.supabaseClient` which is an API wrapper that mimics Supabase's client interface but routes all requests to the local backend at `http://localhost:3001`.

## Architecture

```
Frontend (HTML/JS)
       |
       v
auth.js (creates window.supabaseClient)
       |
       v
Local Backend (Express.js @ localhost:3001)
       |
       v
PostgreSQL Database
```

## Running the Backend

```bash
# Install dependencies
npm install

# Start the server
npm run api
# or
npm start
```

## Environment Configuration

Create a `.env` file in the `server/` directory (see `server/.env.example`):

```env
PORT=3001
DATABASE_URL=postgres://admin@localhost:5432/postgres
JWT_SECRET=your-secret-key-change-in-production
JWT_EXPIRES_IN=7d
```

---

## API Endpoints

### Health Check
- `GET /health` - Returns `{ ok: true }` if database is reachable

### Authentication

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/auth/signup` | POST | Register new user |
| `/auth/signin` | POST | Login with email/password |
| `/auth/user` | GET | Get current user (requires auth) |
| `/auth/session` | GET | Get current session (requires auth) |
| `/auth/signout` | POST | Logout user |
| `/auth/reset-password` | POST | Request password reset |

### Database Operations (Generic)

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/db/select` | POST | SELECT query |
| `/api/db/insert` | POST | INSERT query |
| `/api/db/update` | POST | UPDATE query |
| `/api/db/delete` | POST | DELETE query |
| `/api/db/rpc` | POST | Call stored procedures/functions |

---

## Database Schema

### Auth Schema (`auth.users`)

```sql
CREATE TABLE auth.users (
    id UUID PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    encrypted_password TEXT NOT NULL,
    raw_user_meta_data JSONB,
    role TEXT DEFAULT 'authenticated',
    is_sso_user BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Houses Table

```sql
CREATE TABLE houses (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    primary_color VARCHAR(7),
    secondary_color VARCHAR(7),
    animal VARCHAR(50),
    element VARCHAR(50),
    founder VARCHAR(100),
    ghost VARCHAR(100),
    head_of_house VARCHAR(100),
    common_room_location TEXT,
    traits TEXT[],
    total_points INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### User Profiles

```sql
CREATE TABLE user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id),
    display_name VARCHAR(100),
    wizard_name VARCHAR(100),
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    bio TEXT,
    house VARCHAR(50),
    avatar_url TEXT,
    house_points INTEGER DEFAULT 0,
    reputation_level INTEGER DEFAULT 1,
    community_days INTEGER DEFAULT 0,
    contributions_count INTEGER DEFAULT 0,
    role VARCHAR(50) DEFAULT 'student',
    is_house_head BOOLEAN DEFAULT false,
    specialization VARCHAR(100),
    favorite_topics TEXT[],
    privacy_public_profile BOOLEAN DEFAULT true,
    privacy_show_stats BOOLEAN DEFAULT true,
    privacy_allow_messages BOOLEAN DEFAULT true,
    join_date TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Events System

```sql
CREATE TABLE events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    slug TEXT UNIQUE NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    cover_url TEXT,
    type TEXT, -- 'quest', 'tournament', 'celebration', etc.
    status TEXT DEFAULT 'active', -- 'draft', 'active', 'completed', 'cancelled'
    featured BOOLEAN DEFAULT false,
    reward_points INTEGER DEFAULT 0,
    start_at TIMESTAMPTZ,
    end_at TIMESTAMPTZ,
    created_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE event_participants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID REFERENCES events(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    status TEXT DEFAULT 'joined', -- 'joined', 'completed', 'withdrawn'
    joined_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    UNIQUE(event_id, user_id)
);

-- Materialized view for participant counts
CREATE MATERIALIZED VIEW v_event_participants_counts AS
SELECT event_id, COUNT(*) AS participants_count
FROM event_participants
GROUP BY event_id;
```

### Challenges System

```sql
CREATE TABLE challenges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    slug TEXT UNIQUE NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    scope TEXT, -- 'individual', 'house'
    status TEXT DEFAULT 'active',
    reward_points INTEGER DEFAULT 0,
    target_count INTEGER,
    start_at TIMESTAMPTZ,
    end_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE challenge_attempts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    challenge_id UUID REFERENCES challenges(id),
    user_id UUID REFERENCES auth.users(id),
    house VARCHAR(50),
    status TEXT DEFAULT 'in_progress', -- 'in_progress', 'completed', 'failed'
    progress INTEGER DEFAULT 0,
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Achievement System

```sql
CREATE TABLE achievement_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    icon VARCHAR(50),
    category VARCHAR(50),
    points_reward INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE user_achievements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    achievement_type_id INTEGER REFERENCES achievement_types(id),
    awarded_by UUID REFERENCES auth.users(id),
    reason TEXT,
    awarded_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Forum System

```sql
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    icon VARCHAR(50),
    color VARCHAR(7),
    order_index INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE posts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    house_id INTEGER REFERENCES houses(id),
    category_id UUID REFERENCES categories(id),
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    status post_status DEFAULT 'open', -- ENUM: 'open', 'closed', 'resolved', 'live'
    views INTEGER DEFAULT 0,
    is_pinned BOOLEAN DEFAULT FALSE,
    is_featured BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    is_solution BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE likes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
    comment_id UUID REFERENCES comments(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, post_id),
    UNIQUE(user_id, comment_id)
);

CREATE TABLE forum_user_stats (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id),
    total_posts INTEGER DEFAULT 0,
    total_comments INTEGER DEFAULT 0,
    total_likes_received INTEGER DEFAULT 0,
    reputation_points INTEGER DEFAULT 0,
    is_moderator BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## Key RPC Functions

### Events

| Function | Description |
|----------|-------------|
| `list_featured_events(limit)` | Get featured events with participant counts |
| `list_upcoming_events(limit)` | Get upcoming active events |
| `list_calendar_events(month, year)` | Get events for calendar view |
| `join_event(slug)` | Join an event (requires auth) |
| `my_participations()` | Get current user's event participations |
| `get_event_detail(slug)` | Get full event details including participants |

### Challenges

| Function | Description |
|----------|-------------|
| `list_individual_challenges()` | Get active individual challenges |
| `list_house_challenges()` | Get house challenges with progress |

### Leaderboards

| Function | Description |
|----------|-------------|
| `get_house_leaderboard()` | Get houses ranked by points |
| `get_top_contributors(period, limit)` | Get top contributors |
| `get_quick_stats()` | Get community statistics |

---

## Migrations

Migration files are located in `database/migrations/`. Key files:

| File | Description |
|------|-------------|
| `004_create_forum_tables_final.sql` | Forum tables and triggers |
| `20250811_community_events_backend.sql` | Events and challenges tables |
| `20250811_community_events_rpcs.sql` | Event-related RPC functions |
| `20250818_additional_event_rpcs.sql` | Additional event functions |
| `20250925_event_crud_rpcs.sql` | CRUD operations for events |
| `20260219_fix_quick_stats.sql` | Quick stats function fix |

To apply migrations, run them against your PostgreSQL database:

```bash
psql -d postgres -f database/migrations/004_create_forum_tables_final.sql
```

---

## Frontend Integration

The frontend uses `window.supabaseClient` which provides a Supabase-like API:

```javascript
// In auth.js, the client is created and exposed globally
window.supabaseClient = createDatabaseClient();

// Usage in other files
const client = window.supabaseClient;

// SELECT
const { data, error } = await client
    .from('user_profiles')
    .select('*')
    .eq('house', 'gryffindor');

// INSERT
const { data, error } = await client
    .from('posts')
    .insert({ title: 'Hello', content: 'World' });

// UPDATE
const { data, error } = await client
    .from('user_profiles')
    .update({ bio: 'New bio' })
    .eq('id', userId);

// DELETE
const { error } = await client
    .from('posts')
    .delete()
    .eq('id', postId);

// RPC (stored procedures)
const { data, error } = await client
    .rpc('get_event_detail', { in_slug: 'event-slug' });

// Auth
const { data, error } = await client.auth.signInWithPassword({
    email: 'user@example.com',
    password: 'password'
});
```

---

## Notes

1. **No Supabase dependency**: This project previously used Supabase but has been migrated to a fully local PostgreSQL setup.

2. **Backward compatibility**: `window.supabaseClient` is maintained as an alias to ensure existing code continues to work.

3. **JWT Authentication**: The backend uses JWT tokens for authentication. Tokens are stored in localStorage.

4. **CORS**: The backend allows all origins in development. Configure appropriately for production.
