// Profile Activity Tracker
class ProfileActivityTracker {
    constructor() {
        this.activities = [];
        this.stats = {
            totalPosts: 0,
            totalLikes: 0,
            totalComments: 0,
            totalViews: 0
        };
        this.supabase = null;
        this.init();
    }

    async init() {
        try {
            if (window.supabaseClient) {
                this.supabase = window.supabaseClient;
            } else if (window.HogwartsAuth?.initDatabase) {
                this.supabase = await window.HogwartsAuth.initDatabase();
            }
        } catch (e) {
            console.error('Database client not ready:', e);
            return;
        }

        if (!this.supabase) {
            console.error('Database client unavailable for ProfileActivityTracker');
            return;
        }

        await this.loadUserStats();
        await this.loadRecentActivities();
        this.updateDisplay();
        this.setupRealTimeListeners();
    }

    async loadUserStats() {
        if (!this.supabase) return;
        try {
            const { data } = await this.supabase.auth.getUser();
            const authUser = data?.user?.user || data?.user || null;
            if (!authUser) return;

            const userId = authUser.id;

            // Get posts count and total views
            const { data: posts, count: postsCount } = await this.supabase
                .from('posts')
                .select('id, views', { count: 'exact' })
                .eq('user_id', userId);

            this.stats.totalPosts = postsCount || 0;
            this.stats.totalViews = posts?.reduce((total, post) => total + (post.views || 0), 0) || 0;

            // Get likes received on posts
            const postIds = posts?.map(p => p.id) || [];
            const { count: likesCount } = await this.supabase
                .from('likes')
                .select('*', { count: 'exact', head: true })
                .in('post_id', postIds);

            this.stats.totalLikes = likesCount || 0;

            // Get comments count
            const { count: commentsCount } = await this.supabase
                .from('comments')
                .select('*', { count: 'exact', head: true })
                .eq('user_id', userId);

            this.stats.totalComments = commentsCount || 0;

        } catch (error) {
            console.error('Error loading user stats:', error);
        }
    }

    async loadRecentActivities() {
        if (!this.supabase) return;
        try {
            const { data } = await this.supabase.auth.getUser();
            const authUser = data?.user?.user || data?.user || null;
            if (!authUser) return;

            const userId = authUser.id;
            const activities = [];

            // Get recent posts
            const { data: recentPosts } = await this.supabase
                .from('posts')
                .select(`
                    id,
                    title,
                    created_at,
                    views,
                    categories(name)
                `)
                .eq('user_id', userId)
                .order('created_at', { ascending: false })
                .limit(5);

            recentPosts?.forEach(post => {
                activities.push({
                    type: 'post_created',
                    title: 'Creó un nuevo post',
                    description: post.title,
                    date: new Date(post.created_at),
                    icon: 'edit',
                    color: 'blue'
                });
            });

            // Get recent likes received
            const { data: recentLikes } = await this.supabase
                .from('likes')
                .select(`
                    created_at,
                    posts(title)
                `)
                .in('post_id', recentPosts?.map(p => p.id) || [])
                .order('created_at', { ascending: false })
                .limit(10);

            recentLikes?.forEach(like => {
                activities.push({
                    type: 'like_received',
                    title: 'Recibió un me gusta',
                    description: `En: ${like.posts?.title}`,
                    date: new Date(like.created_at),
                    icon: 'heart',
                    color: 'red'
                });
            });

            // Get recent comments
            const { data: recentComments } = await this.supabase
                .from('comments')
                .select(`
                    created_at,
                    content,
                    posts(title)
                `)
                .eq('user_id', userId)
                .order('created_at', { ascending: false })
                .limit(5);

            recentComments?.forEach(comment => {
                activities.push({
                    type: 'comment_created',
                    title: 'Comentó en un post',
                    description: `En: ${comment.posts?.title}`,
                    date: new Date(comment.created_at),
                    icon: 'chat',
                    color: 'green'
                });
            });

            // Sort all activities by date
            this.activities = activities.sort((a, b) => b.date - a.date).slice(0, 10);

        } catch (error) {
            console.error('Error loading recent activities:', error);
        }
    }

    updateDisplay() {
        this.updateStatsDisplay();
        this.updateActivitiesDisplay();
    }

    updateStatsDisplay() {
        // Update posts count
        const postsElements = document.querySelectorAll('[data-stat="posts"]');
        postsElements.forEach(el => {
            el.textContent = this.formatNumber(this.stats.totalPosts);
        });

        // Update likes count
        const likesElements = document.querySelectorAll('[data-stat="likes"]');
        likesElements.forEach(el => {
            el.textContent = this.formatNumber(this.stats.totalLikes);
        });

        // Update comments count
        const commentsElements = document.querySelectorAll('[data-stat="comments"]');
        commentsElements.forEach(el => {
            el.textContent = this.formatNumber(this.stats.totalComments);  
        });

        // Update views count
        const viewsElements = document.querySelectorAll('[data-stat="views"]');
        viewsElements.forEach(el => {
            el.textContent = this.formatNumber(this.stats.totalViews);
        });
    }

    updateActivitiesDisplay() {
        const container = document.getElementById('activitiesContainer');
        if (!container) return;

        if (this.activities.length === 0) {
            container.innerHTML = `
                <div class="text-center py-8">
                    <p class="text-gray-500">No hay actividades recientes</p>
                </div>
            `;
            return;
        }

        container.innerHTML = this.activities.map(activity => `
            <div class="flex items-start gap-3">
                <div class="flex-shrink-0 w-8 h-8 bg-${activity.color}-100 rounded-full flex items-center justify-center">
                    ${this.getActivityIcon(activity.icon)}
                </div>
                <div class="flex-1 min-w-0">
                    <div class="flex items-start justify-between">
                        <p class="text-sm text-gray-900 font-medium">${activity.title}</p>
                        <span class="text-xs text-gray-500 ml-2">${this.formatDate(activity.date)}</span>
                    </div>
                    <p class="text-xs text-gray-600 truncate">${activity.description}</p>
                </div>
            </div>
        `).join('');
    }

    getActivityIcon(iconType) {
        const icons = {
            edit: `<svg class="w-4 h-4 text-blue-600" fill="currentColor" viewBox="0 0 20 20">
                <path d="M13.586 3.586a2 2 0 112.828 2.828l-.793.793-2.828-2.828.793-.793zM11.379 5.793L3 14.172V17h2.828l8.38-8.379-2.83-2.828z"/>
            </svg>`,
            heart: `<svg class="w-4 h-4 text-red-600" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clip-rule="evenodd"/>
            </svg>`,
            chat: `<svg class="w-4 h-4 text-green-600" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M18 10c0 3.866-3.582 7-8 7a8.841 8.841 0 01-4.083-.98L2 17l1.338-3.123C2.493 12.767 2 11.434 2 10c0-3.866 3.582-7 8-7s8 3.134 8 7zM7 9H5v2h2V9zm8 0h-2v2h2V9zM9 9h2v2H9V9z" clip-rule="evenodd"/>
            </svg>`
        };
        return icons[iconType] || icons.edit;
    }

    formatDate(date) {
        const now = new Date();
        const diff = now - date;
        const minutes = Math.floor(diff / (1000 * 60));
        const hours = Math.floor(diff / (1000 * 60 * 60));
        const days = Math.floor(diff / (1000 * 60 * 60 * 24));

        if (minutes < 60) {
            return `${minutes}m`;
        } else if (hours < 24) {
            return `${hours}h`;
        } else {
            return `${days}d`;
        }
    }

    formatNumber(num) {
        if (num >= 1000000) {
            return (num / 1000000).toFixed(1) + 'M';
        } else if (num >= 1000) {
            return (num / 1000).toFixed(1) + 'K';
        }
        return num.toString();
    }

    setupRealTimeListeners() {
        if (!this.supabase) return;
        // Listen for new posts
        this.supabase
            .channel('profile-posts')
            .on('postgres_changes', 
                { event: 'INSERT', schema: 'public', table: 'posts' },
                (payload) => this.handleNewPost(payload)
            )
            .subscribe();

        // Listen for new likes
        this.supabase
            .channel('profile-likes')
            .on('postgres_changes',
                { event: 'INSERT', schema: 'public', table: 'likes' },
                (payload) => this.handleNewLike(payload)
            )
            .subscribe();

        // Listen for new comments
        this.supabase
            .channel('profile-comments')
            .on('postgres_changes',
                { event: 'INSERT', schema: 'public', table: 'comments' },
                (payload) => this.handleNewComment(payload)
            )
            .subscribe();
    }

    async handleNewPost(payload) {
        if (!this.supabase) return;
        const { data: user } = await this.supabase.auth.getUser();
        if (payload.new.user_id === user?.user?.id) {
            this.stats.totalPosts++;
            this.activities.unshift({
                type: 'post_created',
                title: 'Creó un nuevo post',
                description: payload.new.title,
                date: new Date(payload.new.created_at),
                icon: 'edit',
                color: 'blue'
            });
            this.activities = this.activities.slice(0, 10);
            this.updateDisplay();
        }
    }

    async handleNewLike(payload) {
        if (!this.supabase) return;
        const { data: user } = await this.supabase.auth.getUser();
        
        // Check if the like is on user's post
        if (payload.new.post_id) {
            const { data: post } = await this.supabase
                .from('posts')
                .select('user_id, title')
                .eq('id', payload.new.post_id)
                .single();

            if (post && post.user_id === user?.user?.id) {
                this.stats.totalLikes++;
                this.activities.unshift({
                    type: 'like_received',
                    title: 'Recibió un me gusta',
                    description: `En: ${post.title}`,
                    date: new Date(payload.new.created_at),
                    icon: 'heart',
                    color: 'red'
                });
                this.activities = this.activities.slice(0, 10);
                this.updateDisplay();
            }
        }
    }

    async handleNewComment(payload) {
        if (!this.supabase) return;
        const { data: user } = await this.supabase.auth.getUser();
        if (payload.new.user_id === user?.user?.id) {
            this.stats.totalComments++;
            
            const { data: post } = await this.supabase
                .from('posts')
                .select('title')
                .eq('id', payload.new.post_id)
                .single();

            this.activities.unshift({
                type: 'comment_created',
                title: 'Comentó en un post',
                description: `En: ${post?.title || 'Post desconocido'}`,
                date: new Date(payload.new.created_at),
                icon: 'chat',
                color: 'green'
            });
            this.activities = this.activities.slice(0, 10);
            this.updateDisplay();
        }
    }

    // Public method to refresh data
    async refresh() {
        await this.loadUserStats();
        await this.loadRecentActivities();
        this.updateDisplay();
    }
}

// Initialize and export
const profileActivityTracker = new ProfileActivityTracker();
window.profileActivityTracker = profileActivityTracker;

export default profileActivityTracker;
