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
            const [userResult, houseResult, categoryResult] = await Promise.all([
                supabase.from('user_profiles').select('id, wizard_name, avatar_url').eq('id', data.user_id).single(),
                data.house_id ? supabase.from('houses').select('id, name').eq('id', data.house_id).single() : { data: null },
                data.category_id ? supabase.from('categories').select('id, name, description, icon').eq('id', data.category_id).single() : { data: null }
            ]);
            
            // Enrich the post data
            const enrichedPost = {
                ...data,
                user: userResult.data || null,
                house: houseResult.data || null,
                category: categoryResult.data || null
            };
            
            return { success: true, data: enrichedPost };
        } catch (error) {
            console.error('Error creating post:', error);
            return { success: false, error: error.message };
        }
    }

    async getPosts(filters = {}) {
        try {
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
                    query = query.order('view_count', { ascending: false });
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
                // Get unique IDs
                const userIds = [...new Set(posts.map(p => p.user_id).filter(Boolean))];
                const houseIds = [...new Set(posts.map(p => p.house_id).filter(Boolean))];
                const categoryIds = [...new Set(posts.map(p => p.category_id).filter(Boolean))];

                // Fetch related data in parallel
                const [usersResult, housesResult, categoriesResult] = await Promise.all([
                    userIds.length > 0 ? supabase.from('user_profiles').select('id, wizard_name, avatar_url').in('id', userIds) : { data: [] },
                    houseIds.length > 0 ? supabase.from('houses').select('id, name').in('id', houseIds) : { data: [] },
                    categoryIds.length > 0 ? supabase.from('categories').select('id, name, description, icon').in('id', categoryIds) : { data: [] }
                ]);

                // Create lookup maps
                const usersMap = new Map((usersResult.data || []).map(u => [u.id, u]));
                const housesMap = new Map((housesResult.data || []).map(h => [h.id, h]));
                const categoriesMap = new Map((categoriesResult.data || []).map(c => [c.id, c]));

                // Enrich posts
                const enrichedPosts = posts.map(post => ({
                    ...post,
                    user: usersMap.get(post.user_id) || null,
                    house: housesMap.get(post.house_id) || null,
                    category: categoriesMap.get(post.category_id) || null,
                    comments: [{ count: 0 }], // We'll implement counts later
                    likes: [{ count: 0 }] // We'll implement counts later
                }));

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

    async getPost(postId) {
        try {
            // Get the post
            const { data: post, error } = await supabase
                .from('posts')
                .select('*')
                .eq('id', postId)
                .single();

            if (error) throw error;

            // Get related data
            const [userResult, houseResult, categoryResult] = await Promise.all([
                post.user_id ? supabase.from('user_profiles').select('id, wizard_name, avatar_url').eq('id', post.user_id).single() : { data: null },
                post.house_id ? supabase.from('houses').select('id, name').eq('id', post.house_id).single() : { data: null },
                post.category_id ? supabase.from('categories').select('id, name, description, icon').eq('id', post.category_id).single() : { data: null }
            ]);

            // Get likes count
            const { count: likesCount } = await supabase
                .from('likes')
                .select('*', { count: 'exact', head: true })
                .eq('post_id', postId);

            // Check if current user liked this post
            const { data: user } = await supabase.auth.getUser();
            let userLiked = false;
            if (user?.user) {
                const { data: userLike } = await supabase
                    .from('likes')
                    .select('id')
                    .eq('post_id', postId)
                    .eq('user_id', user.user.id)
                    .single();
                userLiked = !!userLike;
            }

            // Increment views using SQL function
            try {
                await supabase.rpc('increment_post_views', { post_id: postId });
            } catch(err) {
                console.warn('Error incrementando vistas:', err);
                // Fallback: direct update
                try {
                    await supabase
                        .from('posts')
                        .update({ views: post.views + 1 })
                        .eq('id', postId);
                } catch(fallbackErr) {
                    console.warn('Error en fallback de vistas:', fallbackErr);
                }
            }

            return { 
                success: true, 
                data: {
                    ...post,
                    user: userResult.data,
                    house: houseResult.data,
                    category: categoryResult.data,
                    likes_count: likesCount || 0,
                    user_liked: userLiked
                }
            };
        } catch (error) {
            console.error('Error fetching post:', error);
            return { success: false, error: error.message };
        }
    }

    async updatePost(postId, updates) {
        try {
            const { data, error } = await supabase
                .from('posts')
                .update(updates)
                .eq('id', postId)
                .select()
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

    // Comments CRUD Operations
    async getComments(postId, page = 1) {
        try {
            const from = (page - 1) * this.pageSize;
            const to = from + this.pageSize - 1;

            const { data, error, count } = await supabase
                .from('comments')
                .select('*', { count: 'exact' })
                .eq('post_id', postId)
                .order('created_at', { ascending: true })
                .range(from, to);

            if (error) throw error;

            // Enrich comments with user data if we have comments
            if (data && data.length > 0) {
                const userIds = [...new Set(data.map(c => c.user_id).filter(Boolean))];
                
                // Get users data
                const { data: users } = await supabase
                    .from('user_profiles')
                    .select('id, wizard_name, avatar_url')
                    .in('id', userIds);
                
                const usersMap = new Map((users || []).map(u => [u.id, u]));
                
                // Enrich comments with user data
                data.forEach(comment => {
                    comment.user = usersMap.get(comment.user_id) || null;
                });
            }

            // Check user likes for each comment
            const { data: user } = await supabase.auth.getUser();
            if (user?.user && data && data.length > 0) {
                const commentIds = data.map(c => c.id);
                const { data: userLikes } = await supabase
                    .from('likes')
                    .select('comment_id')
                    .in('comment_id', commentIds)
                    .eq('user_id', user.user.id);

                const likedCommentIds = new Set(userLikes?.map(l => l.comment_id) || []);
                data.forEach(comment => {
                    comment.user_liked = likedCommentIds.has(comment.id);
                    comment.likes = [{ count: 0 }]; // Initialize likes count
                });
            }

            return { 
                success: true, 
                data: data || [],
                totalCount: count || 0,
                hasMore: (count || 0) > to + 1
            };
        } catch (error) {
            console.error('Error fetching comments:', error);
            return { success: false, error: error.message };
        }
    }

    async createComment(postId, content) {
        try {
            const { data: user, error: userError } = await supabase.auth.getUser();
            if (userError) throw userError;

            const { data, error } = await supabase
                .from('comments')
                .insert({
                    post_id: postId,
                    user_id: user.user.id,
                    content
                })
                .select('*')
                .single();

            if (error) throw error;
            return { success: true, data };
        } catch (error) {
            console.error('Error creating comment:', error);
            return { success: false, error: error.message };
        }
    }

    async updateComment(commentId, content) {
        try {
            const { data, error } = await supabase
                .from('comments')
                .update({ content })
                .eq('id', commentId)
                .select()
                .single();

            if (error) throw error;
            return { success: true, data };
        } catch (error) {
            console.error('Error updating comment:', error);
            return { success: false, error: error.message };
        }
    }

    async deleteComment(commentId) {
        try {
            const { error } = await supabase
                .from('comments')
                .delete()
                .eq('id', commentId);

            if (error) throw error;
            return { success: true };
        } catch (error) {
            console.error('Error deleting comment:', error);
            return { success: false, error: error.message };
        }
    }

    // Likes Operations
    async toggleLike(targetId, targetType = 'post') {
        try {
            const { data: user, error: userError } = await supabase.auth.getUser();
            if (userError) throw userError;

            const column = targetType === 'post' ? 'post_id' : 'comment_id';
            
            // Check if already liked
            const { data: existingLike } = await supabase
                .from('likes')
                .select('id')
                .eq(column, targetId)
                .eq('user_id', user.user.id)
                .single();

            if (existingLike) {
                // Unlike
                const { error } = await supabase
                    .from('likes')
                    .delete()
                    .eq('id', existingLike.id);
                
                if (error) throw error;
                return { success: true, liked: false };
            } else {
                // Like
                const { error } = await supabase
                    .from('likes')
                    .insert({
                        [column]: targetId,
                        user_id: user.user.id
                    });
                
                if (error) throw error;
                return { success: true, liked: true };
            }
        } catch (error) {
            console.error('Error toggling like:', error);
            return { success: false, error: error.message };
        }
    }

    // Categories and Houses
    async getCategories() {
        try {
            const { data, error } = await supabase
                .from('categories')
                .select('*')
                .order('order_index');

            if (error) throw error;
            return { success: true, data };
        } catch (error) {
            console.error('Error fetching categories:', error);
            return { success: false, error: error.message };
        }
    }

    async getHouses() {
        try {
            const { data, error } = await supabase
                .from('houses')
                .select('*')
                .order('name');

            if (error) throw error;
            // Ensure house IDs are treated as integers
            const housesWithIntIds = data.map(house => ({
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
    subscribeToPost(postId, callbacks) {
        const channelName = `post-${postId}`;
        
        // Unsubscribe from existing channel if any
        this.unsubscribeFromChannel(channelName);

        const channel = supabase
            .channel(channelName)
            .on('postgres_changes', 
                { 
                    event: 'INSERT', 
                    schema: 'public', 
                    table: 'comments',
                    filter: `post_id=eq.${postId}`
                }, 
                callbacks.onNewComment
            )
            .on('postgres_changes',
                {
                    event: 'UPDATE',
                    schema: 'public',
                    table: 'posts',
                    filter: `id=eq.${postId}`
                },
                callbacks.onPostUpdate
            )
            .subscribe();

        this.realtimeChannels.set(channelName, channel);
        return channel;
    }

    subscribeToForumStats(callback) {
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
}

// Export singleton instance
export const forumAPI = new ForumAPI();
