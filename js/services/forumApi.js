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

    // Placeholder methods for future implementation
    async getPost(postId) {
        // TODO: Implement
        return { success: false, error: 'Not implemented yet' };
    }

    async updatePost(postId, updates) {
        // TODO: Implement
        return { success: false, error: 'Not implemented yet' };
    }

    async deletePost(postId) {
        // TODO: Implement
        return { success: false, error: 'Not implemented yet' };
    }

    async getComments(postId, page = 1) {
        // TODO: Implement
        return { success: false, error: 'Not implemented yet' };
    }

    async createComment(postId, content) {
        // TODO: Implement
        return { success: false, error: 'Not implemented yet' };
    }

    async toggleLike(targetId, targetType = 'post') {
        // TODO: Implement
        return { success: false, error: 'Not implemented yet' };
    }
}

// Export singleton instance
export const forumAPI = new ForumAPI();
