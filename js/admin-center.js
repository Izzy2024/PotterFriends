(function () {
    'use strict';

    let supabase = null;

    async function ensureSupabaseClient() {
        if (window.supabaseClient) {
            supabase = window.supabaseClient;
            return supabase;
        }

        if (window.HogwartsAuth && typeof window.HogwartsAuth.initDatabase === 'function') {
            supabase = await window.HogwartsAuth.initDatabase();
            return supabase;
        }

        throw new Error('Database client not available. Ensure auth.js is loaded first.');
    }

    function hasAdminAccess(profile) {
        if (!profile) return false;
        const isHouseHead =
            profile.is_house_head === true ||
            profile.is_house_head === 't' ||
            profile.is_house_head === 1 ||
            profile.is_house_head === '1';
        return profile.role === 'admin' || profile.role === 'house_head' || isHouseHead;
    }

    function displayNameFor(profile, user) {
        return profile?.display_name || profile?.wizard_name || user?.user_metadata?.wizard_name || user?.email?.split('@')[0] || 'Administrador';
    }

    function roleLabel(profile) {
        if (profile?.role === 'admin') return 'Administrador Global';
        if (profile?.role === 'house_head' || profile?.is_house_head === true) return 'Jefe de Casa';
        return 'Usuario';
    }

    function houseLabel(house) {
        if (!house) return 'Sin Casa';
        return house.charAt(0).toUpperCase() + house.slice(1);
    }

    function escapeHtml(value) {
        return String(value || '')
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#039;');
    }

    async function getCount(table, extraFilters = null) {
        try {
            let query = supabase.from(table).select('*', { count: 'exact', head: true });
            if (Array.isArray(extraFilters)) {
                for (const filter of extraFilters) {
                    query = query[filter.method](filter.column, filter.value);
                }
            }
            const { count, error } = await query;
            if (error) {
                return 0;
            }
            return Number(count || 0);
        } catch (_err) {
            return 0;
        }
    }

    async function getSortingHatQuestionCount() {
        try {
            const response = await fetch('house_selection_portal_sorting_hat_quiz.html', { cache: 'no-store' });
            if (!response.ok) return 0;

            const html = await response.text();
            const matches = html.match(/question\s*:\s*"/g);
            return matches ? matches.length : 0;
        } catch (_error) {
            return 0;
        }
    }

    function toDateLabel(value) {
        if (!value) return 'Sin fecha';
        const date = new Date(value);
        if (Number.isNaN(date.getTime())) return 'Sin fecha';
        return date.toLocaleString('es-ES', {
            year: 'numeric',
            month: 'short',
            day: '2-digit',
            hour: '2-digit',
            minute: '2-digit'
        });
    }

    class AdminCenter {
        constructor() {
            this.currentUser = null;
            this.currentProfile = null;
        }

        async init() {
            try {
                await ensureSupabaseClient();
                await this.checkAccess();
                this.bindEvents();
                await Promise.all([
                    this.loadSummaryStats(),
                    this.loadHouseRanking(),
                    this.loadRecentPosts()
                ]);
                this.setStatus('Centro de administración listo.');
            } catch (error) {
                console.error('Error initializing admin center:', error);
                this.setStatus(`Error: ${error.message || 'No se pudo cargar el panel.'}`, true);
            }
        }

        async checkAccess() {
            const { data: authData, error: authError } = await supabase.auth.getUser();
            const user = authData?.user;

            if (authError || !user) {
                window.location.href = 'user_login.html';
                return;
            }

            let profile = null;

            const { data: primaryProfile, error: primaryProfileError } = await supabase
                .from('user_profiles')
                .select('*')
                .eq('id', user.id)
                .maybeSingle();

            if (primaryProfile) {
                profile = primaryProfile;
            }

            if (!profile || !hasAdminAccess(profile)) {
                const { data: fallbackProfile, error: fallbackProfileError } = await supabase
                    .from('profiles')
                    .select('*')
                    .eq('id', user.id)
                    .maybeSingle();

                if (fallbackProfile) {
                    profile = { ...(profile || {}), ...fallbackProfile };
                }

                if (primaryProfileError) {
                    console.warn('Admin Center: user_profiles query warning:', primaryProfileError);
                }
                if (fallbackProfileError) {
                    console.warn('Admin Center: profiles query warning:', fallbackProfileError);
                }
            }

            if (!hasAdminAccess(profile)) {
                this.setStatus('No tienes permisos de administración en este momento.', true);
                setTimeout(() => {
                    window.location.href = 'homepage_sorting_hat_experience.html';
                }, 1800);
                throw new Error('access_denied');
            }

            this.currentUser = user;
            this.currentProfile = profile;

            const nameElement = document.getElementById('adminDisplayName');
            const roleElement = document.getElementById('adminRoleBadge');
            const houseElement = document.getElementById('adminHouse');

            if (nameElement) nameElement.textContent = displayNameFor(profile, user);
            if (roleElement) roleElement.textContent = roleLabel(profile);
            if (houseElement) houseElement.textContent = houseLabel(profile?.house);
        }

        bindEvents() {
            const logoutButton = document.getElementById('logoutAdminBtn');
            if (logoutButton) {
                logoutButton.addEventListener('click', async () => {
                    try {
                        await supabase.auth.signOut();
                    } catch (error) {
                        console.error('Logout error:', error);
                    }
                    window.location.href = 'homepage_sorting_hat_experience.html';
                });
            }
        }

        async loadSummaryStats() {
            const [
                usersCount,
                postsCount,
                achievementsAwarded,
                achievementTypes,
                commentsCount,
                sortingQuestionsCount,
                housePointsTotal
            ] = await Promise.all([
                getCount('user_profiles'),
                getCount('posts'),
                getCount('user_achievements'),
                getCount('achievement_types', [{ method: 'eq', column: 'is_active', value: true }]),
                getCount('comments'),
                getSortingHatQuestionCount(),
                this.getTotalHousePoints()
            ]);

            this.setText('usersCount', usersCount);
            this.setText('postsCount', postsCount);
            this.setText('achievementsAwardedCount', achievementsAwarded);
            this.setText('achievementTypesCount', achievementTypes);
            this.setText('commentsCount', commentsCount);
            this.setText('sortingQuestionsCount', sortingQuestionsCount);
            this.setText('housePointsCount', housePointsTotal);
        }

        async getTotalHousePoints() {
            try {
                const { data, error } = await supabase
                    .from('user_profiles')
                    .select('house_points');

                if (error || !Array.isArray(data)) return 0;

                return data.reduce((sum, row) => sum + Number(row.house_points || 0), 0);
            } catch (_error) {
                return 0;
            }
        }

        async loadHouseRanking() {
            const tbody = document.getElementById('houseRankingBody');
            if (!tbody) return;

            try {
                const { data, error } = await supabase
                    .from('user_profiles')
                    .select('house, house_points');

                if (error) throw error;

                const totals = new Map();
                for (const row of data || []) {
                    const house = row.house || 'sin_casa';
                    totals.set(house, (totals.get(house) || 0) + Number(row.house_points || 0));
                }

                const ordered = Array.from(totals.entries())
                    .map(([house, points]) => ({ house, points }))
                    .sort((a, b) => b.points - a.points);

                if (ordered.length === 0) {
                    tbody.innerHTML = '<tr><td colspan="3" class="px-4 py-3 text-text-secondary">Sin datos de casas.</td></tr>';
                    return;
                }

                tbody.innerHTML = ordered.map((item, index) => `
                    <tr class="border-b border-primary/10">
                        <td class="px-4 py-3 text-text-secondary">#${index + 1}</td>
                        <td class="px-4 py-3 font-medium text-text-primary">${escapeHtml(houseLabel(item.house))}</td>
                        <td class="px-4 py-3 text-right font-semibold text-primary">${Number(item.points).toLocaleString('es-ES')}</td>
                    </tr>
                `).join('');
            } catch (error) {
                console.error('Error loading house ranking:', error);
                tbody.innerHTML = '<tr><td colspan="3" class="px-4 py-3 text-error">No se pudo cargar el ranking.</td></tr>';
            }
        }

        async loadRecentPosts() {
            const container = document.getElementById('recentPostsList');
            if (!container) return;

            try {
                const { data: posts, error } = await supabase
                    .from('posts')
                    .select('id, user_id, title, created_at')
                    .order('created_at', { ascending: false })
                    .limit(6);

                if (error) throw error;

                if (!posts || posts.length === 0) {
                    container.innerHTML = '<p class="text-text-secondary">Aún no hay discusiones registradas.</p>';
                    return;
                }

                const userIds = [...new Set(posts.map((post) => post.user_id).filter(Boolean))];
                let usersMap = new Map();

                if (userIds.length > 0) {
                    const { data: users } = await supabase
                        .from('user_profiles')
                        .select('id, display_name, wizard_name')
                        .in('id', userIds);

                    usersMap = new Map((users || []).map((user) => [user.id, user]));
                }

                container.innerHTML = posts.map((post) => {
                    const author = usersMap.get(post.user_id);
                    const authorName = author?.display_name || author?.wizard_name || 'Miembro';
                    return `
                        <a href="post-detail.html?id=${encodeURIComponent(post.id)}" class="block rounded-lg border border-primary/10 p-4 hover:border-primary/40 magical-transition">
                            <p class="font-medium text-text-primary">${escapeHtml(post.title || 'Sin título')}</p>
                            <p class="text-sm text-text-secondary mt-1">${escapeHtml(authorName)} · ${escapeHtml(toDateLabel(post.created_at))}</p>
                        </a>
                    `;
                }).join('');
            } catch (error) {
                console.error('Error loading recent posts:', error);
                container.innerHTML = '<p class="text-error">No se pudieron cargar las discusiones recientes.</p>';
            }
        }

        setText(elementId, value) {
            const element = document.getElementById(elementId);
            if (!element) return;
            element.textContent = Number(value || 0).toLocaleString('es-ES');
        }

        setStatus(message, isError = false) {
            const statusElement = document.getElementById('adminStatus');
            if (!statusElement) return;
            statusElement.textContent = message;
            statusElement.classList.toggle('text-error', isError);
        }
    }

    document.addEventListener('DOMContentLoaded', () => {
        const adminCenter = new AdminCenter();
        adminCenter.init();
        window.adminCenter = adminCenter;
    });
})();
