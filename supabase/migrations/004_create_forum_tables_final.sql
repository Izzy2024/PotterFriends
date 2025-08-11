-- Script definitivo para crear las tablas del foro
-- Respeta la estructura existente de la tabla houses

-- Enable UUID extension if not exists
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create enum for post status if not exists
DO $$ BEGIN
    CREATE TYPE post_status AS ENUM ('open', 'closed', 'resolved', 'live');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- La tabla houses ya existe, no la tocamos

-- Create categories table
CREATE TABLE IF NOT EXISTS categories (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    icon VARCHAR(50),
    color VARCHAR(7),
    order_index INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert default categories
INSERT INTO categories (name, description, icon, color, order_index) VALUES 
    ('Teorías y Análisis', 'Discusiones profundas sobre el mundo mágico', 'lightbulb', '#9C27B0', 1),
    ('Fanfiction', 'Historias originales del mundo mágico', 'edit', '#FF5722', 2),
    ('Arte y Creatividad', 'Fanart, ilustraciones y creaciones visuales', 'image', '#FF9800', 3),
    ('Debates Mágicos', 'Discusiones acaloradas sobre temas controvertidos', 'chat', '#F44336', 4),
    ('Ayuda y Preguntas', 'Soporte de la comunidad y preguntas generales', 'help', '#4CAF50', 5)
ON CONFLICT (name) DO NOTHING;

-- Create posts table with integer house_id matching your existing houses table
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

-- Create comments table
CREATE TABLE IF NOT EXISTS comments (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    is_solution BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create likes table (for posts and comments)
CREATE TABLE IF NOT EXISTS likes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
    comment_id UUID REFERENCES comments(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    -- Ensure user can only like once per item
    CONSTRAINT unique_post_like UNIQUE(user_id, post_id),
    CONSTRAINT unique_comment_like UNIQUE(user_id, comment_id),
    -- Ensure like is for either post or comment, not both
    CONSTRAINT like_target CHECK (
        (post_id IS NOT NULL AND comment_id IS NULL) OR 
        (post_id IS NULL AND comment_id IS NOT NULL)
    )
);

-- Create user_profiles extension for forum
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

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_posts_user_id ON posts(user_id);
CREATE INDEX IF NOT EXISTS idx_posts_category_id ON posts(category_id);
CREATE INDEX IF NOT EXISTS idx_posts_house_id ON posts(house_id);
CREATE INDEX IF NOT EXISTS idx_posts_status ON posts(status);
CREATE INDEX IF NOT EXISTS idx_posts_created_at ON posts(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_comments_post_id ON comments(post_id);
CREATE INDEX IF NOT EXISTS idx_comments_user_id ON comments(user_id);
CREATE INDEX IF NOT EXISTS idx_likes_user_id ON likes(user_id);
CREATE INDEX IF NOT EXISTS idx_likes_post_id ON likes(post_id);
CREATE INDEX IF NOT EXISTS idx_likes_comment_id ON likes(comment_id);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
DROP TRIGGER IF EXISTS update_posts_updated_at ON posts;
CREATE TRIGGER update_posts_updated_at BEFORE UPDATE ON posts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_comments_updated_at ON comments;
CREATE TRIGGER update_comments_updated_at BEFORE UPDATE ON comments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_forum_user_stats_updated_at ON forum_user_stats;
CREATE TRIGGER update_forum_user_stats_updated_at BEFORE UPDATE ON forum_user_stats
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create function to increment views
CREATE OR REPLACE FUNCTION increment_post_views(post_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE posts SET views = views + 1 WHERE id = post_id;
END;
$$ LANGUAGE plpgsql;

-- Create function to update user stats
CREATE OR REPLACE FUNCTION update_user_forum_stats()
RETURNS TRIGGER AS $$
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
$$ LANGUAGE plpgsql;

-- Create triggers for user stats
DROP TRIGGER IF EXISTS update_user_posts_stats ON posts;
CREATE TRIGGER update_user_posts_stats
AFTER INSERT OR DELETE ON posts
FOR EACH ROW EXECUTE FUNCTION update_user_forum_stats();

DROP TRIGGER IF EXISTS update_user_comments_stats ON comments;
CREATE TRIGGER update_user_comments_stats
AFTER INSERT OR DELETE ON comments
FOR EACH ROW EXECUTE FUNCTION update_user_forum_stats();

-- Enable Row Level Security
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE forum_user_stats ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist to avoid conflicts
DROP POLICY IF EXISTS "Posts are viewable by everyone" ON posts;
DROP POLICY IF EXISTS "Users can create their own posts" ON posts;
DROP POLICY IF EXISTS "Users can update their own posts" ON posts;
DROP POLICY IF EXISTS "Users can delete their own posts" ON posts;

DROP POLICY IF EXISTS "Comments are viewable by everyone" ON comments;
DROP POLICY IF EXISTS "Users can create their own comments" ON comments;
DROP POLICY IF EXISTS "Users can update their own comments" ON comments;
DROP POLICY IF EXISTS "Users can delete their own comments" ON comments;

DROP POLICY IF EXISTS "Likes are viewable by everyone" ON likes;
DROP POLICY IF EXISTS "Users can create their own likes" ON likes;
DROP POLICY IF EXISTS "Users can delete their own likes" ON likes;

DROP POLICY IF EXISTS "Forum stats are viewable by everyone" ON forum_user_stats;
DROP POLICY IF EXISTS "System can update forum stats" ON forum_user_stats;

-- RLS Policies for posts
CREATE POLICY "Posts are viewable by everyone" ON posts
    FOR SELECT USING (true);

CREATE POLICY "Users can create their own posts" ON posts
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own posts" ON posts
    FOR UPDATE USING (auth.uid() = user_id OR 
        EXISTS (SELECT 1 FROM forum_user_stats WHERE user_id = auth.uid() AND is_moderator = true));

CREATE POLICY "Users can delete their own posts" ON posts
    FOR DELETE USING (auth.uid() = user_id OR 
        EXISTS (SELECT 1 FROM forum_user_stats WHERE user_id = auth.uid() AND is_moderator = true));

-- RLS Policies for comments
CREATE POLICY "Comments are viewable by everyone" ON comments
    FOR SELECT USING (true);

CREATE POLICY "Users can create their own comments" ON comments
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own comments" ON comments
    FOR UPDATE USING (auth.uid() = user_id OR 
        EXISTS (SELECT 1 FROM forum_user_stats WHERE user_id = auth.uid() AND is_moderator = true));

CREATE POLICY "Users can delete their own comments" ON comments
    FOR DELETE USING (auth.uid() = user_id OR 
        EXISTS (SELECT 1 FROM forum_user_stats WHERE user_id = auth.uid() AND is_moderator = true));

-- RLS Policies for likes
CREATE POLICY "Likes are viewable by everyone" ON likes
    FOR SELECT USING (true);

CREATE POLICY "Users can create their own likes" ON likes
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own likes" ON likes
    FOR DELETE USING (auth.uid() = user_id);

-- RLS Policies for forum_user_stats
CREATE POLICY "Forum stats are viewable by everyone" ON forum_user_stats
    FOR SELECT USING (true);

CREATE POLICY "System can update forum stats" ON forum_user_stats
    FOR ALL USING (true);

-- Mensaje de confirmación
DO $$
BEGIN
    RAISE NOTICE 'Tablas del foro creadas exitosamente!';
END $$;
