# 📊 Documentación de Base de Datos - Hogwarts Community Hub

## 🏗️ **Estructura de Tablas Principales**

### 📋 **Resumen de Sistemas**
- 🏠 **Sistema de Casas**: `houses`, `profiles`  
- 🎯 **Sistema de Eventos**: `events`, `event_participants`, `challenges`, `challenge_attempts`
- 💬 **Sistema de Foro**: `posts`, `comments`, `categories`, `likes`, `forum_user_stats`
- 🏆 **Sistema de Logros**: `achievement_types`, `user_achievements`, `user_statistics`
- 📊 **Sistema de Puntos**: `house_points_ledger`, `user_points_ledger`
- 🗳️ **Sistema de Votaciones**: `polls`, `poll_options`, `votes`
- 👥 **Sistema Social**: `friendships`, `followers`, `social_notifications`

---

## 🏠 **SISTEMA DE CASAS**

### `houses`
```sql
CREATE TABLE houses (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,     -- 'Gryffindor', 'Slytherin', etc.
    color VARCHAR(7) NOT NULL,            -- Hex color code
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### `profiles` 
```sql
CREATE TABLE public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    username TEXT UNIQUE,
    house_id INTEGER REFERENCES public.houses(id),
    avatar_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## 🎯 **SISTEMA DE EVENTOS Y DESAFÍOS**

### `events`
```sql
CREATE TABLE public.events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug TEXT UNIQUE NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    type TEXT CHECK (type IN ('tournament','contest','celebration')),
    featured BOOLEAN DEFAULT FALSE,
    cover_url TEXT,
    reward_points INT DEFAULT 0,
    start_at TIMESTAMPTZ NOT NULL,
    end_at TIMESTAMPTZ NOT NULL,
    status TEXT DEFAULT 'draft' CHECK (status IN ('draft','active','completed','cancelled')),
    created_by UUID REFERENCES public.profiles(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    metadata JSONB
);
```

### `event_participants`
```sql
CREATE TABLE public.event_participants (
    event_id UUID REFERENCES public.events(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    status TEXT DEFAULT 'joined' CHECK (status IN ('joined','submitted','disqualified','winner')),
    submission_url TEXT,
    points_awarded INT DEFAULT 0,
    joined_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY(event_id, user_id)
);
```

### `challenges`
```sql
CREATE TABLE public.challenges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug TEXT UNIQUE NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    scope TEXT CHECK (scope IN ('individual','house')),
    reward_points INT NOT NULL,
    target_count INT,
    start_at TIMESTAMPTZ NOT NULL,
    end_at TIMESTAMPTZ NOT NULL,
    status TEXT DEFAULT 'draft' CHECK (status IN ('draft','active','completed','cancelled')),
    created_by UUID REFERENCES public.profiles(id),
    metadata JSONB
);
```

### `challenge_attempts`
```sql
CREATE TABLE public.challenge_attempts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    challenge_id UUID REFERENCES public.challenges(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    house_id INTEGER REFERENCES public.houses(id),
    status TEXT DEFAULT 'in_progress' CHECK (status IN ('in_progress','completed','rejected')),
    score INT,
    evidence_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ
);
```

---

## 📊 **SISTEMA DE PUNTOS**

### `house_points_ledger`
```sql
CREATE TABLE public.house_points_ledger (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    house_id INTEGER REFERENCES public.houses(id),
    user_id UUID REFERENCES public.profiles(id),
    source TEXT CHECK (source IN ('event','challenge','vote','manual')),
    source_id UUID,
    points INT NOT NULL,
    note TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### `user_points_ledger`
```sql
CREATE TABLE public.user_points_ledger (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    source TEXT CHECK (source IN ('event','challenge','vote','manual')),
    source_id UUID,
    points INT NOT NULL,
    note TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## 💬 **SISTEMA DE FORO**

### `categories`
```sql
CREATE TABLE IF NOT EXISTS categories (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    icon VARCHAR(50),
    color VARCHAR(7),
    order_index INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### `posts`
```sql
CREATE TABLE IF NOT EXISTS posts (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    house_id INTEGER REFERENCES houses(id),
    category_id UUID NOT NULL REFERENCES categories(id),
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    status post_status DEFAULT 'open',
    views INTEGER DEFAULT 0,
    is_pinned BOOLEAN DEFAULT FALSE,
    is_featured BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### `comments`
```sql
CREATE TABLE IF NOT EXISTS comments (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    is_solution BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### `forum_user_stats`
```sql
CREATE TABLE IF NOT EXISTS forum_user_stats (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
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

## 🏆 **SISTEMA DE LOGROS**

### `achievement_types`
```sql
CREATE TABLE IF NOT EXISTS achievement_types (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    icon TEXT,
    category TEXT,
    points_reward INTEGER DEFAULT 0,
    condition_type TEXT,
    condition_data JSONB,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

### `user_achievements`
```sql
CREATE TABLE IF NOT EXISTS user_achievements (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    achievement_type_id INTEGER REFERENCES achievement_types(id) ON DELETE CASCADE,
    awarded_by UUID REFERENCES auth.users(id),
    reason TEXT,
    awarded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, achievement_type_id)
);
```

---

## 🗳️ **SISTEMA DE VOTACIONES**

### `polls`
```sql
CREATE TABLE public.polls (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug TEXT UNIQUE NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    start_at TIMESTAMPTZ NOT NULL,
    end_at TIMESTAMPTZ NOT NULL,
    status TEXT DEFAULT 'draft' CHECK (status IN ('draft','active','closed')),
    scope TEXT CHECK (scope IN ('everyone','house_heads')),
    multiple_choice BOOLEAN DEFAULT FALSE,
    created_by UUID REFERENCES public.profiles(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### `poll_options`
```sql
CREATE TABLE public.poll_options (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    poll_id UUID REFERENCES public.polls(id) ON DELETE CASCADE,
    option_text TEXT NOT NULL,
    order_index INT DEFAULT 0
);
```

### `votes`
```sql
CREATE TABLE public.votes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    poll_id UUID REFERENCES public.polls(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    poll_option_id UUID REFERENCES public.poll_options(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(poll_id, user_id, poll_option_id)
);
```

---

## 🔧 **FUNCIONES RPC DISPONIBLES**

### Leaderboards
- `leaderboard_houses(in_period TEXT)` - Ranking de casas por período
- `leaderboard_users(in_period TEXT)` - Ranking de usuarios por período

### Eventos y Desafíos
- `get_polls_active()` - Encuestas activas
- `get_poll_options_with_counts(in_poll_id UUID)` - Opciones de encuesta con votos

### Períodos válidos
- `'all'` - Todos los tiempos
- `'month'` - Último mes  
- `'week'` - Última semana
- `'day'` - Último día

---

## ⚙️ **CONFIGURACIÓN DE SEGURIDAD (RLS)**

### Políticas importantes:
- `house_points_ledger`: **Acceso solo vía RPC** (`FOR SELECT USING (false)`)
- `user_points_ledger`: Solo usuarios propios
- `posts`, `comments`: Lectura pública, escritura por dueño
- `achievements`: Solo propios o por house heads

---

## 🚀 **ÍNDICES PRINCIPALES**

### Performance críticos:
- `house_points_ledger(house_id, created_at)`
- `posts(house_id, created_at)`
- `events(status, start_at, end_at)`
- `user_achievements(user_id)`

---

## 📝 **NOTAS IMPORTANTES**

1. **Tablas duplicadas**: Hay confusión entre `profiles` vs `user_profiles` en algunos archivos
2. **Sistema de puntos**: Usa funciones RPC, no acceso directo a `house_points_ledger`
3. **Logros**: Sistema opcional, puede no estar implementado en todas las instancias
4. **Migraciones**: Usar orden secuencial de los archivos en `/supabase/migrations/`

---

## 🔗 **Archivos de Migración**

1. `000_check_existing_structure.sql` - Verificación inicial
2. `003_recreate_houses_and_forum.sql` - Casas y base del foro
3. `004_create_forum_tables_final.sql` - Sistema de foro completo
4. `20250811_community_events_backend.sql` - Sistema de eventos
5. `20250811_community_events_rpcs.sql` - Funciones RPC
6. `complete_achievement_system.sql` - Sistema de logros (opcional)

---

**Última actualización**: Enero 2025  
**Versión**: 1.0