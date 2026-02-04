# 📊 DOCUMENTACIÓN DE LA BASE DE DATOS - HOGWARTS POTTER FRIENDS

## 🎯 ESTRUCTURA ACTUAL CONFIRMADA

### ✅ **TABLAS DE USUARIOS - CONFIGURACIÓN DUAL**

#### 1. **Tabla `profiles` (Básica - Auth Principal)**
```sql
CREATE TABLE public.profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id),
  first_name text,
  last_name text,
  wizard_name text NOT NULL,
  email text NOT NULL UNIQUE,
  house text,
  avatar_url text,
  role character varying DEFAULT 'student',
  house_selected_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);
```

**Propósito**: Tabla principal de autenticación y datos básicos del usuario.
**Usado por**: Sistema de autenticación, challenges, events, votes, house_points_ledger
**Campos clave**: `wizard_name`, `email`, `house`, `role`

#### 2. **Tabla `user_profiles` (Completa - Features Avanzadas)**
```sql
CREATE TABLE public.user_profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id),
  display_name character varying,
  bio text,
  avatar_url text,
  house character varying CHECK (house IN ('gryffindor','hufflepuff','ravenclaw','slytherin')),
  house_points integer DEFAULT 0,
  reputation_level integer DEFAULT 1,
  join_date timestamp with time zone DEFAULT now(),
  contributions_count integer DEFAULT 0,
  is_house_head boolean DEFAULT false,
  is_prefect boolean DEFAULT false,
  specialization character varying,
  favorite_topics ARRAY,
  privacy_public_profile boolean DEFAULT true,
  privacy_show_stats boolean DEFAULT true,
  privacy_allow_messages boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  role character varying DEFAULT 'student' CHECK (role IN ('student','prefect','house_head','admin')),
  wizard_name text,
  username text,
  house_id integer REFERENCES houses(id)
);
```

**Propósito**: Tabla completa con todas las características sociales y de gamificación.
**Usado por**: Achievements, activities, moderation, social features, house management
**Campos clave**: `display_name`, `bio`, `house_points`, `is_house_head`, `reputation_level`

### 🔄 **ESTRATEGIA DE SINCRONIZACIÓN**

#### **Datos del Usuario Actual Confirmados:**
```json
// Tabla profiles:
{
  "id": "3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0",
  "first_name": "Isaac",
  "last_name": "Castillo",
  "wizard_name": "Isaac",
  "email": "akileskenobi@gmail.com",
  "house": "slytherin",
  "role": "house_head"
}

// Tabla user_profiles:
{
  "id": "3a3fd303-ccb9-4aad-acc7-cb3eb89d6aa0",
  "display_name": "akileskenobi",
  "wizard_name": "Isaac",
  "house": "slytherin",
  "role": "student",           // ⚠️ INCONSISTENCIA DETECTADA
  "is_house_head": true,
  "house_points": 0,
  "reputation_level": 1
}
```

#### **🚨 INCONSISTENCIA DETECTADA:**
- `profiles.role` = "house_head"
- `user_profiles.role` = "student" 
- `user_profiles.is_house_head` = true

**Recomendación**: Sincronizar el campo `role` entre ambas tablas.

### 📋 **SISTEMA DE AUTENTICACIÓN IMPLEMENTADO**

#### **Estrategia Fallback (auth.js):**
1. **Prioridad 1**: Intentar `user_profiles` (datos completos)
2. **Prioridad 2**: Fallback a `profiles` (datos básicos)
3. **Creación**: Crear perfil en tabla apropiada si no existe
4. **Actualización**: Sincronizar cambios en ambas tablas

#### **Funciones Principales:**
- `getCurrentUser()` - Obtiene datos unificados de ambas tablas
- `login()` - Estrategia dual con fallback automático
- `register()` - Crea perfiles en ambas tablas
- `saveHouse()` - Actualiza house en ambas tablas

### 🏠 **RELACIONES CON OTRAS TABLAS**

#### **Tablas que usan `profiles`:**
- `challenge_attempts` ➜ `profiles.id`
- `events` ➜ `profiles.id`
- `event_participants` ➜ `profiles.id`
- `votes` ➜ `profiles.id`
- `house_points_ledger` ➜ `profiles.id`
- `user_points_ledger` ➜ `profiles.id`

#### **Tablas que usan `user_profiles`:**
- `achievement_assignments` ➜ `user_profiles.id`
- `activity_participations` ➜ `user_profiles.id`
- `house_activities` ➜ `user_profiles.id`
- `moderation_reports` ➜ `user_profiles.id`
- `profile_shares` ➜ `user_profiles.id`
- `system_notifications` ➜ `user_profiles.id`
- `user_achievements` ➜ `user_profiles.id`
- `user_activities` ➜ `user_profiles.id`
- `user_connections` ➜ `user_profiles.id`

### 🛠️ **POLÍTICAS RLS CONFIGURADAS**

#### **Tabla `profiles`:**
- ✅ SELECT: Público (todos pueden leer)
- ✅ INSERT: Solo propietario (`auth.uid() = id`)
- ✅ UPDATE: Solo propietario (`auth.uid() = id`)

#### **Tabla `user_profiles`:**
- ✅ SELECT: Público (todos pueden leer)
- ✅ INSERT: Solo propietario (`auth.uid() = id`)
- ✅ UPDATE: Solo propietario (`auth.uid() = id`)

### 🎮 **FUNCIONALIDADES ESPECÍFICAS**

#### **Sistema de Casas:**
- **Tabla principal**: `houses` (id, name, description, color)
- **Asignación**: `profiles.house` (texto) y `user_profiles.house_id` (referencia)
- **Puntos**: `user_profiles.house_points` y `house_points_ledger`

#### **Sistema de Logros:**
- **Tipos**: `achievement_types`
- **Asignaciones**: `user_achievements` ➜ `user_profiles.id`
- **Progreso**: Tracked en `user_profiles.reputation_level`

#### **Sistema Social:**
- **Seguidores**: `followers` ➜ `auth.users.id`
- **Amistades**: `friendships` ➜ `auth.users.id` 
- **Conexiones**: `user_connections` ➜ `user_profiles.id`
- **Notificaciones**: `social_notifications` ➜ `auth.users.id`

### 📝 **RECOMENDACIONES FUTURAS**

#### **Inmediatas:**
1. **Sincronizar rol inconsistente** entre tablas
2. **Ejecutar script de migración** `fix_dual_tables_strategy.sql`
3. **Implementar triggers** para sincronización automática

#### **A largo plazo:**
1. **Unificar en una sola tabla** `user_profiles` (más completa)
2. **Migrar relaciones** de `profiles` a `user_profiles`
3. **Mantener `profiles`** solo como vista o alias

### 🚀 **ESTADO ACTUAL: FUNCIONANDO**
- ✅ Login/Logout: Funcional
- ✅ Creación de usuarios: Funcional  
- ✅ Acceso a ambas tablas: Funcional
- ✅ Políticas RLS: Configuradas
- ⚠️ Sincronización: Necesita mejoras

---
**Última actualización**: 15 de octubre de 2025
**Sistema probado**: test-dual-tables.html - ✅ Exitoso
**Usuario de prueba**: Isaac (akileskenobi@gmail.com) - Casa Slytherin