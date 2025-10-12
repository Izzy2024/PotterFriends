-- SISTEMA DE CONEXIONES SOCIALES - Hogwarts PotterFriends
-- Script SQL para configurar el sistema de amistades y seguidores
-- Ejecuta este código en el SQL Editor de Supabase

-- ==========================================================
-- TABLAS PRINCIPALES
-- ==========================================================

-- Tabla para gestionar amistades
CREATE TABLE IF NOT EXISTS friendships (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    friend_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'declined', 'blocked')),
    requested_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    responded_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, friend_id),
    CHECK (user_id != friend_id) -- No puedes ser amigo de ti mismo
);

-- Tabla para gestionar seguidores
CREATE TABLE IF NOT EXISTS followers (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE, -- Usuario que es seguido
    follower_id UUID REFERENCES auth.users(id) ON DELETE CASCADE, -- Usuario que sigue
    followed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, follower_id),
    CHECK (user_id != follower_id) -- No puedes seguirte a ti mismo
);

-- Tabla para notificaciones sociales
CREATE TABLE IF NOT EXISTS social_notifications (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE, -- Usuario que recibe la notificación
    from_user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE, -- Usuario que genera la notificación
    type TEXT NOT NULL CHECK (type IN ('friend_request', 'friend_accepted', 'new_follower', 'house_mention')),
    message TEXT,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP WITH TIME ZONE DEFAULT (CURRENT_TIMESTAMP + INTERVAL '30 days')
);

-- ==========================================================
-- ÍNDICES PARA OPTIMIZACIÓN
-- ==========================================================

CREATE INDEX IF NOT EXISTS idx_friendships_user_id ON friendships(user_id);
CREATE INDEX IF NOT EXISTS idx_friendships_friend_id ON friendships(friend_id);
CREATE INDEX IF NOT EXISTS idx_friendships_status ON friendships(status);

CREATE INDEX IF NOT EXISTS idx_followers_user_id ON followers(user_id);
CREATE INDEX IF NOT EXISTS idx_followers_follower_id ON followers(follower_id);

CREATE INDEX IF NOT EXISTS idx_social_notifications_user_id ON social_notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_social_notifications_is_read ON social_notifications(is_read);

-- ==========================================================
-- ROW LEVEL SECURITY (RLS)
-- ==========================================================

ALTER TABLE friendships ENABLE ROW LEVEL SECURITY;
ALTER TABLE followers ENABLE ROW LEVEL SECURITY;
ALTER TABLE social_notifications ENABLE ROW LEVEL SECURITY;

-- Políticas para friendships
DROP POLICY IF EXISTS "Users can view their own friendships" ON friendships;
CREATE POLICY "Users can view their own friendships" 
    ON friendships FOR SELECT 
    USING (auth.uid() = user_id OR auth.uid() = friend_id);

DROP POLICY IF EXISTS "Users can create friend requests" ON friendships;
CREATE POLICY "Users can create friend requests" 
    ON friendships FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their friend requests" ON friendships;
CREATE POLICY "Users can update their friend requests" 
    ON friendships FOR UPDATE 
    USING (auth.uid() = friend_id OR auth.uid() = user_id);

-- Políticas para followers
DROP POLICY IF EXISTS "Users can view followers" ON followers;
CREATE POLICY "Users can view followers" 
    ON followers FOR SELECT 
    USING (auth.uid() = user_id OR auth.uid() = follower_id);

DROP POLICY IF EXISTS "Users can follow others" ON followers;
CREATE POLICY "Users can follow others" 
    ON followers FOR INSERT 
    WITH CHECK (auth.uid() = follower_id);

DROP POLICY IF EXISTS "Users can unfollow others" ON followers;
CREATE POLICY "Users can unfollow others" 
    ON followers FOR DELETE 
    USING (auth.uid() = follower_id);

-- Políticas para social_notifications
DROP POLICY IF EXISTS "Users can view their own notifications" ON social_notifications;
CREATE POLICY "Users can view their own notifications" 
    ON social_notifications FOR SELECT 
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own notifications" ON social_notifications;
CREATE POLICY "Users can update their own notifications" 
    ON social_notifications FOR UPDATE 
    USING (auth.uid() = user_id);

-- ==========================================================
-- FUNCIONES PARA GESTIÓN DE AMISTADES
-- ==========================================================

-- Función para enviar solicitud de amistad
CREATE OR REPLACE FUNCTION send_friend_request(p_friend_id UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
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

-- Función para aceptar solicitud de amistad
CREATE OR REPLACE FUNCTION accept_friend_request(p_requester_id UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
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

-- Función para rechazar solicitud de amistad
CREATE OR REPLACE FUNCTION decline_friend_request(p_requester_id UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
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

-- ==========================================================
-- FUNCIONES PARA GESTIÓN DE SEGUIDORES
-- ==========================================================

-- Función para seguir a un usuario
CREATE OR REPLACE FUNCTION follow_user(p_user_to_follow_id UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
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

-- Función para dejar de seguir a un usuario
CREATE OR REPLACE FUNCTION unfollow_user(p_user_to_unfollow_id UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
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

-- ==========================================================
-- FUNCIONES PARA OBTENER ESTADÍSTICAS SOCIALES
-- ==========================================================

-- Función para obtener estadísticas sociales de un usuario
CREATE OR REPLACE FUNCTION get_user_social_stats(p_user_id UUID DEFAULT NULL)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
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

-- Función para obtener lista de amigos recientes
CREATE OR REPLACE FUNCTION get_recent_friends(p_limit INTEGER DEFAULT 6)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
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

-- ==========================================================
-- TRIGGERS PARA ACTUALIZACIÓN AUTOMÁTICA
-- ==========================================================

-- Función para actualizar updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger para friendships
DROP TRIGGER IF EXISTS update_friendships_updated_at ON friendships;
CREATE TRIGGER update_friendships_updated_at 
    BEFORE UPDATE ON friendships 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ==========================================================
-- DATOS DE PRUEBA (OPCIONAL)
-- ==========================================================

-- Insertar algunos logros relacionados con conexiones sociales
INSERT INTO achievement_types (name, description, icon, points_reward, category, trigger_condition) VALUES
('Primer Amigo Mágico', 'Hiciste tu primer amigo en Hogwarts', '🤝', 20, 'vida_social_hogwarts', 'first_friend'),
('Popular en el Castillo', 'Tienes 10 o más amigos', '👥', 50, 'vida_social_hogwarts', 'friends_count_10'),
('Influencer de Casa', 'Tienes 50 o más seguidores', '⭐', 75, 'vida_social_hogwarts', 'followers_count_50'),
('Espíritu Social', 'Sigues a 25 o más compañeros', '👀', 30, 'vida_social_hogwarts', 'following_count_25'),
('Unión de Casa', 'Eres amigo de 5 compañeros de tu casa', '🏠', 40, 'lealtad_casa', 'house_friends_5')
ON CONFLICT (name) DO NOTHING;

-- Mensaje de confirmación
SELECT 'Sistema de conexiones sociales configurado exitosamente! 🎉' as message,
       'Tablas: friendships, followers, social_notifications' as tables_created,
       'Funciones: send_friend_request, accept_friend_request, follow_user, etc.' as functions_created;
