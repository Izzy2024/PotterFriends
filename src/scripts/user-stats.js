// User Statistics Manager
class UserStatsManager {
    constructor() {
        this.supabase = null;
        this.currentUser = null;
        this.statsCache = null;
        this.cacheExpiry = 5 * 60 * 1000; // 5 minutes
        this.lastCacheTime = null;
        
        this.init();
    }

    async init() {
        try {
            await (window.HogwartsAuth && window.HogwartsAuth.initSupabase
                ? window.HogwartsAuth.initSupabase()
                : Promise.resolve());
            this.supabase = window.supabaseClient;
            if (!this.supabase) {
                console.error('Supabase no está disponible para User Stats');
                return;
            }
        } catch (e) {
            console.error('Error inicializando Supabase para User Stats:', e);
            return;
        }

        try {
            // Get current user
            const { data: { user } } = await this.supabase.auth.getUser();
            this.currentUser = user;
        } catch (error) {
            console.error('Error getting user:', error);
            this.currentUser = null;
        }

        if (this.currentUser) {
            await this.loadUserStats();
        }
    }

    async loadUserStats() {
        try {
            // Check cache first
            if (this.isStatsCacheValid()) {
                this.updateStatsDisplay(this.statsCache);
                return;
            }

            // Calculate statistics from different tables
            const stats = await this.calculateUserStats();
            
            // Cache the results
            this.statsCache = stats;
            this.lastCacheTime = Date.now();
            
            // Update display
            this.updateStatsDisplay(stats);
            
        } catch (error) {
            console.error('Error loading user stats:', error);
            this.showErrorState();
        }
    }

    isStatsCacheValid() {
        return this.statsCache && 
               this.lastCacheTime && 
               (Date.now() - this.lastCacheTime) < this.cacheExpiry;
    }

    async calculateUserStats() {
        const userId = this.currentUser.id;
        const stats = {
            posts: 0,
            likes: 0,
            comments: 0,
            helpfulAnswers: 0
        };

        try {
            // Try to get stats from user_statistics table first (if exists)
            const { data: userStats, error: statsError } = await this.supabase
                .from('user_statistics')
                .select('*')
                .eq('user_id', userId);

            if (!statsError && userStats) {
                // Use stats from user_statistics table
                userStats.forEach(stat => {
                    switch(stat.stat_name) {
                        case 'forum_posts':
                            stats.posts = stat.stat_value || 0;
                            break;
                        case 'likes_received':
                            stats.likes = stat.stat_value || 0;
                            break;
                        case 'comments_made':
                            stats.comments = stat.stat_value || 0;
                            break;
                        case 'helpful_answers':
                            stats.helpfulAnswers = stat.stat_value || 0;
                            break;
                    }
                });
            }

            // Try to get some stats from user_achievements count
            const { data: achievements, error: achError } = await this.supabase
                .from('user_achievements')
                .select('id', { count: 'exact' })
                .eq('user_id', userId);

            if (!achError && achievements) {
                // Could use achievement count as a proxy for activity
                // For now, just log it
                console.log('User has', achievements.length || 0, 'achievements');
            }

            // Get post count from user_profiles if available
            const { data: profile, error: profileError } = await this.supabase
                .from('user_profiles')
                .select('contributions_count')
                .eq('id', userId)
                .single();

            if (!profileError && profile && profile.contributions_count) {
                stats.posts = profile.contributions_count;
            }

        } catch (error) {
            console.error('Error calculating user stats:', error);
        }

        return stats;
    }

    updateStatsDisplay(stats) {
        // Update posts count
        const postsElement = document.getElementById('postsCount');
        if (postsElement) {
            postsElement.textContent = this.formatNumber(stats.posts);
        }

        // Update likes received
        const likesElement = document.getElementById('likesReceived');
        if (likesElement) {
            likesElement.textContent = this.formatNumber(stats.likes);
        }

        // Update comments count
        const commentsElement = document.getElementById('commentsCount');
        if (commentsElement) {
            commentsElement.textContent = this.formatNumber(stats.comments);
        }

        // Update helpful answers
        const helpfulElement = document.getElementById('helpfulAnswers');
        if (helpfulElement) {
            helpfulElement.textContent = this.formatNumber(stats.helpfulAnswers);
        }

        // Add smooth animation
        this.animateStatsUpdate();
    }

    formatNumber(num) {
        if (num >= 1000000) {
            return (num / 1000000).toFixed(1) + 'M';
        } else if (num >= 1000) {
            return (num / 1000).toFixed(1) + 'K';
        }
        return num.toString();
    }

    animateStatsUpdate() {
        const statElements = [
            'postsCount',
            'likesReceived', 
            'commentsCount',
            'helpfulAnswers'
        ];

        statElements.forEach(elementId => {
            const element = document.getElementById(elementId);
            if (element && element.textContent !== 'Cargando...') {
                // Add animation class
                element.style.transform = 'scale(1.1)';
                element.style.transition = 'transform 0.3s ease';
                
                setTimeout(() => {
                    element.style.transform = 'scale(1)';
                }, 300);
            }
        });
    }

    showErrorState() {
        const statElements = [
            'postsCount',
            'likesReceived', 
            'commentsCount',
            'helpfulAnswers'
        ];

        statElements.forEach(elementId => {
            const element = document.getElementById(elementId);
            if (element) {
                element.textContent = '--';
                element.style.opacity = '0.5';
            }
        });
    }

    // Method to refresh stats (can be called from external sources)
    async refreshStats() {
        this.statsCache = null;
        this.lastCacheTime = null;
        await this.loadUserStats();
    }

    // Method to increment stats in real-time (for immediate feedback)
    incrementStat(statType, increment = 1) {
        if (!this.statsCache) return;

        switch (statType) {
            case 'posts':
                this.statsCache.posts += increment;
                break;
            case 'likes':
                this.statsCache.likes += increment;
                break;
            case 'comments':
                this.statsCache.comments += increment;
                break;
            case 'helpfulAnswers':
                this.statsCache.helpfulAnswers += increment;
                break;
        }

        this.updateStatsDisplay(this.statsCache);
    }
}

// Initialize User Stats Manager
window.userStatsManager = new UserStatsManager();

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = UserStatsManager;
}
