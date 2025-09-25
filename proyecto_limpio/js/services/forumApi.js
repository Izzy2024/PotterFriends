import { supabase as supabaseImport } from '../supabase-client.js';

// Manejar el caso cuando supabase es una promesa
let supabase = supabaseImport;
if (supabaseImport instanceof Promise) {
    supabaseImport.then(client => {
        supabase = client;
    });
}

class ForumAPI {
    constructor() {
        this.pageSize = 20;
        this.realtimeChannels = new Map();
    }

    // Posts CRUD Operations
    async createPost(postData) {
        try {
            // Esperar a que supabase esté disponible si es una promesa
            if (supabaseImport instanceof Promise) {
                supabase = await supabaseImport;
            }

            const { data: user, error: userError } = await supabase.auth.getUser();
            if (userError) throw userError;

            const { data, error } = await supabase
                .from('posts')
                .insert({
                    user_id: user.user.id,
                    title: postData.title,
                    content: postData.content,
                    category_id: postData.categoryId,
                    house_id: postData.houseId
                })
                .select('*')
                .single();

            if (error) throw error;
            
            // Fetch related data
            const enrichedPost = await this.enrichPostWithRelations(data);
            
            return { success: true, data: enrichedPost };
        } catch (error) {
            console.error('Error creating post:', error);
            return { success: false, error: error.message };
        }
    }

    async getPosts(filters = {}) {
        try {
            // Esperar a que supabase esté disponible si es una promesa
            if (supabaseImport instanceof Promise) {
                supabase = await supabaseImport;
            }

            // First get the posts
            let query = supabase
                .from('posts')
                .select('*', { count: 'exact' });

            // Apply filters
            if (filters.categoryId) {
                query = query.eq('category_id', filters.categoryId);
            }
            if (filters.houseIds && filters.houseIds.length > 0) {
                query = query.in('house_id', filters.houseIds);
            }
            if (filters.search) {
                query = query.or(`title.ilike.%${filters.search}%,content.ilike.%${filters.search}%`);
            }

            // Apply sorting
            switch (filters.sortBy) {
                case 'popular':
                    query = query.order('views', { ascending: false });
                    break;
                default:
                    query = query.order('created_at', { ascending: false });
            }

            // Apply pagination
            const page = filters.page || 1;
            const from = (page - 1) * this.pageSize;
            const to = from + this.pageSize - 1;
            query = query.range(from, to);

            const { data: posts, error, count } = await query;

            if (error) throw error;

            // If we have posts, enrich them with related data
            if (posts && posts.length > 0) {
                const enrichedPosts = await this.enrichPostsWithRelations(posts);

                return { 
                    success: true, 
                    data: enrichedPosts,
                    totalCount: count,
                    hasMore: count > to + 1
                };
            }

            return { 
                success: true, 
                data: [],
                totalCount: 0,
                hasMore: false
            };
        } catch (error) {
            console.error('Error fetching posts:', error);
            return { success: false, error: error.message };
        }
    }

    async enrichPostWithRelations(post) {
        try {
            const [userResult, houseResult, categoryResult, likesResult, commentsResult] = await Promise.all([
                post.user_id ? supabase.from('user_profiles').select('id, wizard_name, avatar_url').eq('id', post.user_id).single() : { data: null },
                post.house_id ? supabase.from('houses').select('id, name').eq('id', post.house_id).single() : { data: null },
                post.category_id ? supabase.from('categories').select('id, name, description, icon').eq('id', post.category_id).single() : { data: null },
                supabase.from('likes').select('*', { count: 'exact', head: true }).eq('post_id', post.id),
                supabase.from('comments').select('*', { count: 'exact', head: true }).eq('post_id', post.id)
            ]);
            
            return {
                ...post,
                user: userResult.data || { wizard_name: 'Usuario Anónimo' },
                house: houseResult.data || null,
                category: categoryResult.data || null,
                likes: [{ count: likesResult.count || 0 }],
                comments: [{ count: commentsResult.count || 0 }]
            };
        } catch (error) {
            console.error('Error enriching post:', error);
            return {
                ...post,
                user: { wizard_name: 'Usuario Anónimo' },
                house: null,
                category: null,
                likes: [{ count: 0 }],
                comments: [{ count: 0 }]
            };
        }
    }

    async enrichPostsWithRelations(posts) {
        try {
            // Get unique IDs
            const userIds = [...new Set(posts.map(p => p.user_id).filter(Boolean))];
            const houseIds = [...new Set(posts.map(p => p.house_id).filter(Boolean))];
            const categoryIds = [...new Set(posts.map(p => p.category_id).filter(Boolean))];
            const postIds = posts.map(p => p.id);

            // Fetch related data in parallel
            const [usersResult, housesResult, categoriesResult, likesResult, commentsResult] = await Promise.all([
                userIds.length > 0 ? supabase.from('user_profiles').select('id, wizard_name, avatar_url').in('id', userIds) : { data: [] },
                houseIds.length > 0 ? supabase.from('houses').select('id, name').in('id', houseIds) : { data: [] },
                categoryIds.length > 0 ? supabase.from('categories').select('id, name, description, icon').in('id', categoryIds) : { data: [] },
                supabase.from('likes').select('post_id').in('post_id', postIds),
                supabase.from('comments').select('post_id').in('post_id', postIds)
            ]);

            // Create lookup maps
            const usersMap = new Map((usersResult.data || []).map(u => [u.id, u]));
            const housesMap = new Map((housesResult.data || []).map(h => [h.id, h]));
            const categoriesMap = new Map((categoriesResult.data || []).map(c => [c.id, c]));
            
            // Count likes and comments per post
            const likeCounts = {};
            const commentCounts = {};
            
            (likesResult.data || []).forEach(like => {
                likeCounts[like.post_id] = (likeCounts[like.post_id] || 0) + 1;
            });
            
            (commentsResult.data || []).forEach(comment => {
                commentCounts[comment.post_id] = (commentCounts[comment.post_id] || 0) + 1;
            });

            // Enrich posts
            const enrichedPosts = posts.map(post => ({
                ...post,
                user: usersMap.get(post.user_id) || { wizard_name: 'Usuario Anónimo' },
                house: housesMap.get(post.house_id) || null,
                category: categoriesMap.get(post.category_id) || null,
                likes: [{ count: likeCounts[post.id] || 0 }],
                comments: [{ count: commentCounts[post.id] || 0 }]
            }));

            return enrichedPosts;
        } catch (error) {
            console.error('Error enriching posts:', error);
            // Return posts with basic data if enrichment fails
            return posts.map(post => ({
                ...post,
                user: { wizard_name: 'Usuario Anónimo' },
                house: null,
                category: null,
                likes: [{ count: 0 }],
                comments: [{ count: 0 }]
            }));
        }
    }

    // Categories and Houses
    async getCategories() {
        try {
            // Esperar a que supabase esté disponible si es una promesa
            if (supabaseImport instanceof Promise) {
                supabase = await supabaseImport;
            }

            const { data, error } = await supabase
                .from('categories')
                .select('*')
                .order('order_index');

            if (error) throw error;
            return { success: true, data: data || [] };
        } catch (error) {
            console.error('Error fetching categories:', error);
            return { success: false, error: error.message };
        }
    }

    async getHouses() {
        try {
            // Esperar a que supabase esté disponible si es una promesa
            if (supabaseImport instanceof Promise) {
                supabase = await supabaseImport;
            }

            const { data, error } = await supabase
                .from('houses')
                .select('*')
                .order('name');

            if (error) throw error;
            // Ensure house IDs are treated as integers
            const housesWithIntIds = (data || []).map(house => ({
                ...house,
                id: parseInt(house.id)
            }));
            return { success: true, data: housesWithIntIds };
        } catch (error) {
            console.error('Error fetching houses:', error);
            return { success: false, error: error.message };
        }
    }

    // Forum Stats
    async getForumStats() {
        try {
            // Esperar a que supabase esté disponible si es una promesa
            if (supabaseImport instanceof Promise) {
                supabase = await supabaseImport;
            }

            const today = new Date();
            today.setHours(0, 0, 0, 0);

            // Get total posts
            const { count: totalPosts } = await supabase
                .from('posts')
                .select('*', { count: 'exact', head: true });

            // Get today's posts
            const { count: todayPosts } = await supabase
                .from('posts')
                .select('*', { count: 'exact', head: true })
                .gte('created_at', today.toISOString());

            // Get active discussions (open status)
            const { count: activeDiscussions } = await supabase
                .from('posts')
                .select('*', { count: 'exact', head: true })
                .eq('status', 'open');

            // Get today's comments
            const { count: todayComments } = await supabase
                .from('comments')
                .select('*', { count: 'exact', head: true })
                .gte('created_at', today.toISOString());

            return {
                success: true,
                data: {
                    activeDiscussions: activeDiscussions || 0,
                    todayMessages: (todayPosts || 0) + (todayComments || 0),
                    totalPosts: totalPosts || 0,
                    newToday: todayPosts || 0
                }
            };
        } catch (error) {
            console.error('Error fetching forum stats:', error);
            return { success: false, error: error.message };
        }
    }

    // Real-time subscriptions
    subscribeToForumStats(callback) {
        try {
            const channelName = 'forum-stats';
            
            // Unsubscribe from existing channel if any
            this.unsubscribeFromChannel(channelName);

            const channel = supabase
                .channel(channelName)
                .on('postgres_changes', 
                    { event: '*', schema: 'public', table: 'posts' }, 
                    () => callback()
                )
                .on('postgres_changes',
                    { event: '*', schema: 'public', table: 'comments' },
                    () => callback()
                )
                .subscribe();

            this.realtimeChannels.set(channelName, channel);
            return channel;
        } catch (error) {
            console.error('Error setting up realtime subscription:', error);
        }
    }

    unsubscribeFromChannel(channelName) {
        const channel = this.realtimeChannels.get(channelName);
        if (channel) {
            supabase.removeChannel(channel);
            this.realtimeChannels.delete(channelName);
        }
    }

    unsubscribeAll() {
        this.realtimeChannels.forEach((channel, name) => {
            supabase.removeChannel(channel);
        });
        this.realtimeChannels.clear();
    }

    // Post detail and interactions
    async getPost(postId) {
        try {
            if (supabaseImport instanceof Promise) {
                supabase = await supabaseImport;
            }

            const { data: post, error } = await supabase
                .from('posts')
                .select('*')
                .eq('id', postId)
                .single();

            if (error) throw error;

            // Try to increment views optimistically (ignore failures due to RLS)
            try {
                await supabase.rpc('increment_post_views', { post_id: postId });
            } catch (e) {
                // noop
            }

            // Get current user first
            const { data: { user: currentUser } = { user: null } } = await supabase.auth.getUser();

            const [userResult, houseResult, categoryResult, likesHead, userLike] = await Promise.all([
                post.user_id ? supabase.from('user_profiles').select('id, wizard_name, avatar_url').eq('id', post.user_id).single() : Promise.resolve({ data: null }),
                post.house_id ? supabase.from('houses').select('id, name').eq('id', post.house_id).single() : Promise.resolve({ data: null }),
                post.category_id ? supabase.from('categories').select('id, name, description, icon').eq('id', post.category_id).single() : Promise.resolve({ data: null }),
                supabase.from('likes').select('*', { count: 'exact', head: true }).eq('post_id', postId),
                // Check if current user liked this post
                currentUser ? supabase.from('likes').select('id').eq('post_id', postId).eq('user_id', currentUser.id).maybeSingle() : Promise.resolve({ data: null })
            ]);

            const likesCount = likesHead?.count || 0;
            const userLiked = !!(userLike && userLike.data);

            const enrichedPost = {
                ...post,
                user: userResult?.data || { wizard_name: 'Usuario Anónimo' },
                house: houseResult?.data || null,
                category: categoryResult?.data || null,
                likes_count: likesCount,
                user_liked: userLiked,
                view_count: (post.views || 0) + 1 // optimistic for UI
            };

            return { success: true, data: enrichedPost };
        } catch (error) {
            console.error('Error fetching post:', error);
            return { success: false, error: error.message };
        }
    }

    async updatePost(postId, updates) {
        try {
            if (supabaseImport instanceof Promise) {
                supabase = await supabaseImport;
            }

            const { data, error } = await supabase
                .from('posts')
                .update(updates)
                .eq('id', postId)
                .select('*')
                .single();
            if (error) throw error;
            return { success: true, data };
        } catch (error) {
            console.error('Error updating post:', error);
            return { success: false, error: error.message };
        }
    }

    async deletePost(postId) {
        try {
            if (supabaseImport instanceof Promise) {
                supabase = await supabaseImport;
            }

            const { error } = await supabase
                .from('posts')
                .delete()
                .eq('id', postId);
            if (error) throw error;
            return { success: true };
        } catch (error) {
            console.error('Error deleting post:', error);
            return { success: false, error: error.message };
        }
    }

    async getComments(postId, page = 1) {
        try {
            if (supabaseImport instanceof Promise) {
                supabase = await supabaseImport;
            }

            let query = supabase
                .from('comments')
                .select('*', { count: 'exact' })
                .eq('post_id', postId)
                .order('created_at', { ascending: true });

            // If page is null, load all comments
            if (page === null) {
                // Load all comments without pagination
            } else {
                const from = (page - 1) * this.pageSize;
                const to = from + this.pageSize - 1;
                query = query.range(from, to);
            }

            const { data: comments, error, count } = await query;

            if (error) throw error;

            if (!comments || comments.length === 0) {
                return { success: true, data: [], hasMore: false, totalCount: count || 0 };
            }

            const userIds = [...new Set(comments.map(c => c.user_id).filter(Boolean))];
            const commentIds = comments.map(c => c.id);

            const [{ data: usersResult }, { data: likesResult }, { data: { user: currentUser } = { user: null } }] = await Promise.all([
                userIds.length > 0
                    ? supabase.from('user_profiles').select('id, wizard_name, avatar_url').in('id', userIds)
                    : Promise.resolve({ data: [] }),
                supabase.from('likes').select('comment_id, user_id').in('comment_id', commentIds),
                supabase.auth.getUser()
            ]);

            const usersMap = new Map((usersResult || []).map(u => [u.id, u]));
            const likeCounts = {};
            const userLikedSet = new Set();

            (likesResult || []).forEach(like => {
                likeCounts[like.comment_id] = (likeCounts[like.comment_id] || 0) + 1;
                if (currentUser && like.user_id === currentUser.id) {
                    userLikedSet.add(like.comment_id);
                }
            });

            const enriched = comments.map(c => ({
                ...c,
                user: usersMap.get(c.user_id) || { wizard_name: 'Usuario' },
                likes: [{ count: likeCounts[c.id] || 0 }],
                user_liked: userLikedSet.has(c.id)
            }));

            // When loading all comments, hasMore is always false
            const hasMore = page === null ? false : (count || 0) > ((page - 1) * this.pageSize + comments.length);

            return {
                success: true,
                data: enriched,
                hasMore: hasMore,
                totalCount: count || enriched.length
            };
        } catch (error) {
            console.error('Error fetching comments:', error);
            return { success: false, error: error.message };
        }
    }

    async createComment(postId, content) {
        try {
            if (supabaseImport instanceof Promise) {
                supabase = await supabaseImport;
            }

            const { data: { user } } = await supabase.auth.getUser();
            if (!user) throw new Error('Usuario no autenticado');

            const { data, error } = await supabase
                .from('comments')
                .insert({ post_id: postId, user_id: user.id, content })
                .select('*')
                .single();

            if (error) throw error;
            return { success: true, data };
        } catch (error) {
            console.error('Error creating comment:', error);
            return { success: false, error: error.message };
        }
    }

    async toggleLike(targetId, targetType = 'post') {
        try {
            if (supabaseImport instanceof Promise) {
                supabase = await supabaseImport;
            }

            const { data: { user } } = await supabase.auth.getUser();
            if (!user) throw new Error('Usuario no autenticado');

            const column = targetType === 'comment' ? 'comment_id' : 'post_id';

            // Check if like exists
            const { data: existing, error: selError } = await supabase
                .from('likes')
                .select('id')
                .eq(column, targetId)
                .eq('user_id', user.id)
                .maybeSingle();
            if (selError && selError.code !== 'PGRST116') throw selError; // ignore no rows error

            if (existing && existing.id) {
                // Unlike
                const { error: delError } = await supabase
                    .from('likes')
                    .delete()
                    .eq('id', existing.id);
                if (delError) throw delError;
                return { success: true, liked: false };
            } else {
                // Like
                const payload = { user_id: user.id };
                payload[column] = targetId;
                const { error: insError } = await supabase
                    .from('likes')
                    .insert(payload);
                if (insError) throw insError;
                return { success: true, liked: true };
            }
        } catch (error) {
            console.error('Error toggling like:', error);
            return { success: false, error: error.message };
        }
    }

    subscribeToPost(postId, { onNewComment, onPostUpdate } = {}) {
        try {
            const channelName = `post-${postId}`;
            this.unsubscribeFromChannel(channelName);

            const channel = supabase
                .channel(channelName)
                .on('postgres_changes', { event: 'INSERT', schema: 'public', table: 'comments', filter: `post_id=eq.${postId}` }, (payload) => {
                    console.log('New comment detected:', payload);
                    if (typeof onNewComment === 'function') onNewComment();
                })
                .on('postgres_changes', { event: 'UPDATE', schema: 'public', table: 'posts', filter: `id=eq.${postId}` }, (payload) => {
                    console.log('Post update detected:', payload);
                    if (typeof onPostUpdate === 'function') onPostUpdate();
                })
                .subscribe((status) => {
                    console.log('Subscription status:', status);
                });

            this.realtimeChannels.set(channelName, channel);
            return channel;
        } catch (error) {
            console.error('Error setting up post subscription:', error);
        }
    }

    async getFeaturedPosts(limit = 2) {
        try {
            if (supabaseImport instanceof Promise) {
                supabase = await supabaseImport;
            }

            // First try featured flag
            let { data: posts, error } = await supabase
                .from('posts')
                .select('*')
                .eq('is_featured', true)
                .order('created_at', { ascending: false })
                .limit(limit);

            if (error) throw error;

            // Fallback: most viewed
            if (!posts || posts.length === 0) {
                const res = await supabase
                    .from('posts')
                    .select('*')
                    .order('views', { ascending: false })
                    .limit(limit);
                posts = res.data || [];
            }

            const enriched = posts.length ? await this.enrichPostsWithRelations(posts) : [];
            return { success: true, data: enriched };
        } catch (error) {
            console.error('Error fetching featured posts:', error);
            return { success: false, error: error.message };
        }
    }
}

// Export singleton instance
export const forumAPI = new ForumAPI();
