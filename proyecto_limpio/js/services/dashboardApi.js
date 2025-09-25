import { supabase as supabaseImport } from '../supabase-client.js';

// Manejar el caso cuando supabase es una promesa
let supabase = supabaseImport;
if (supabaseImport instanceof Promise) {
    supabaseImport.then(client => {
        supabase = client;
    });
}

class DashboardAPI {
    constructor() {
        this.realtimeChannels = new Map();
    }

    // ESTADÍSTICAS DE CASA
    async getHouseStandings() {
        try {
            // Esperar a que supabase esté disponible si es una promesa
            if (supabaseImport instanceof Promise) {
                supabase = await supabaseImport;
            }

            // Usar RPC function para obtener leaderboard de casas (período total)
            const { data: allTimeData, error: allTimeError } = await supabase
                .rpc('leaderboard_houses', { in_period: 'all' });

            // Obtener también actividad reciente (última semana) 
            const { data: weekData, error: weekError } = await supabase
                .rpc('leaderboard_houses', { in_period: 'week' });

            if (allTimeError) {
                console.error('Error fetching all-time standings:', allTimeError);
                throw allTimeError;
            }

            if (weekError) {
                console.warn('Error fetching week standings:', weekError);
            }

            // Obtener información adicional de las casas (colores)
            const { data: housesInfo } = await supabase
                .from('houses')
                .select('id, name, color')
                .order('name');

            // Crear un mapa de colores por casa
            const houseColors = {};
            housesInfo?.forEach(house => {
                houseColors[house.id] = house.color;
            });

            // Crear mapa de actividad reciente
            const recentActivity = {};
            weekData?.forEach(entry => {
                recentActivity[entry.house_id] = entry.points;
            });

            // Combinar datos con colores y actividad reciente
            const standings = allTimeData?.map(house => ({
                id: house.house_id,
                name: house.house_name,
                color: houseColors[house.house_id] || '#666666',
                total_points: house.points,
                recent_activity: recentActivity[house.house_id] || 0
            })) || [];

            return { success: true, data: standings };
        } catch (error) {
            console.error('Error fetching house standings:', error);
            return { success: false, error: error.message };
        }
    }

    async getHousePointsBreakdown(houseId) {
        try {
            if (supabaseImport instanceof Promise) {
                supabase = await supabaseImport;
            }

            // Usar la función RPC get_house_points_breakdown
            const { data, error } = await supabase
                .rpc('get_house_points_breakdown', { target_house_id: houseId });

            if (error) {
                console.error('Error in get_house_points_breakdown RPC:', error);
                throw error;
            }

            // Convertir array a objeto para compatibilidad con el frontend
            const breakdown = {};
            data?.forEach(item => {
                breakdown[item.source] = item.points;
            });

            // Asegurar que todas las categorías estén presentes
            const defaultCategories = {
                'Eventos Especiales': 0,
                'Desafíos Completados': 0,
                'Contribuciones': 0,
                'Foro y Discusiones': 0
            };

            const finalBreakdown = { ...defaultCategories, ...breakdown };

            return { success: true, data: finalBreakdown };
        } catch (error) {
            console.error('Error fetching house points breakdown:', error);
            return { success: false, error: error.message };
        }
    }

    async getUserHouseRank(userId, houseId) {
        try {
            if (supabaseImport instanceof Promise) {
                supabase = await supabaseImport;
            }

            // Usar función leaderboard_users para obtener ranking de usuarios
            const { data: userLeaderboard, error } = await supabase
                .rpc('leaderboard_users', { in_period: 'all' });

            if (error) throw error;

            const userPoints = userLeaderboard?.find(u => u.user_id === userId)?.points || 0;
            
            // Filtrar solo usuarios de la misma casa usando user_profiles
            const { data: houseMembers } = await supabase
                .from('user_profiles')
                .select('id')
                .eq('house', getHouseName(houseId));

            const houseMemberIds = houseMembers?.map(m => m.id) || [];
            const houseLeaderboard = userLeaderboard?.filter(u => houseMemberIds.includes(u.user_id));

            let rank = 1;
            houseLeaderboard?.forEach((member, index) => {
                if (member.user_id === userId) {
                    rank = index + 1;
                }
            });

            return { 
                success: true, 
                data: { 
                    rank, 
                    total_members: houseLeaderboard?.length || 0,
                    user_points: userPoints
                } 
            };
        } catch (error) {
            console.error('Error fetching user house rank:', error);
            return { success: false, error: error.message };
        }
    }

    // ACTIVIDAD DE LA CASA
    async getHouseActivity(houseId, limit = 10) {
        try {
            if (supabaseImport instanceof Promise) {
                supabase = await supabaseImport;
            }

            // Obtener actividad del foro
            const { data: forumActivity } = await supabase
                .from('posts')
                .select(`
                    id,
                    title,
                    created_at,
                    user_id
                `)
                .eq('house_id', houseId)
                .order('created_at', { ascending: false })
                .limit(limit);

            // Obtener información de usuarios para el foro
            const userIds = forumActivity?.map(post => post.user_id) || [];
            let usersData = [];
            
            if (userIds.length > 0) {
                const { data: users } = await supabase
                    .from('user_profiles')
                    .select('id, wizard_name, avatar_url')
                    .in('id', userIds);
                usersData = users?.map(u => ({
                    id: u.id,
                    username: u.wizard_name,
                    avatar_url: u.avatar_url
                })) || [];
            }

            // Obtener logros recientes (si existen en user_achievements)
            let achievementActivity = [];
            try {
                const { data: achievements } = await supabase
                    .from('user_achievements')
                    .select(`
                        id,
                        awarded_at,
                        achievement_types!inner(name, icon, points_reward),
                        user_profiles!inner(id, wizard_name, avatar_url, house)
                    `)
                    .eq('user_profiles.house', getHouseName(houseId))
                    .order('awarded_at', { ascending: false })
                    .limit(5);
                achievementActivity = achievements || [];
            } catch (error) {
                console.warn('Achievement data not available:', error.message);
            }

            // Obtener nuevos miembros de la casa (intenta profiles -> public_profiles -> user_profiles)
            let newMembers = [];
            try {
                // 1) profiles
                let resp = await supabase
                    .from('profiles')
                    .select('id, wizard_name, avatar_url, house')
                    .eq('house', getHouseName(houseId))
                    .limit(3);
                if (resp.error) {
                    // 2) public_profiles (vista)
                    resp = await supabase
                        .from('public_profiles')
                        .select('id, wizard_name, avatar_url, house')
                        .eq('house', getHouseName(houseId))
                        .limit(3);
                }
                if (resp.error) {
                    // 3) user_profiles
                    resp = await supabase
                        .from('user_profiles')
                        .select('id, wizard_name, avatar_url, house')
                        .eq('house', getHouseName(houseId))
                        .limit(3);
                }
                if (!resp.error) newMembers = resp.data || [];
            } catch (e) {
                console.warn('profiles (new members) not available:', e.message);
            }

            // Combinar y ordenar por fecha
            const allActivity = [];

            // Agregar posts del foro
            forumActivity?.forEach(post => {
                const user = usersData.find(u => u.id === post.user_id);
                allActivity.push({
                    type: 'forum_post',
                    id: post.id,
                    title: post.title,
                    user: user || { id: post.user_id, username: 'Usuario', avatar_url: null },
                    created_at: post.created_at,
                    icon: '💬'
                });
            });

            // Agregar logros
            achievementActivity?.forEach(achievement => {
                allActivity.push({
                    type: 'achievement',
                    id: achievement.id,
                    title: `Logró: ${achievement.achievement_types.name}`,
                    user: achievement.user_profiles,
                    created_at: achievement.awarded_at,
                    icon: achievement.achievement_types.icon,
                    points: achievement.achievement_types.points_reward
                });
            });

            // Agregar nuevos miembros
            newMembers?.forEach(member => {
                allActivity.push({
                    type: 'new_member',
                    id: member.id,
                    title: 'Se unió a la casa',
                    user: { id: member.id, username: member.wizard_name, avatar_url: member.avatar_url },
                    created_at: member.created_at || new Date().toISOString(),
                    icon: '🎉'
                });
            });

            // Ordenar por fecha más reciente
            allActivity.sort((a, b) => new Date(b.created_at) - new Date(a.created_at));

            return { success: true, data: allActivity.slice(0, limit) };
        } catch (error) {
            console.error('Error fetching house activity:', error);
            return { success: false, error: error.message };
        }
    }

    // LOGROS Y ACHIEVEMENTS
    async getUserAchievements(userId) {
        try {
            if (supabaseImport instanceof Promise) {
                supabase = await supabaseImport;
            }

            // Obtener todos los tipos de logros
            const { data: allAchievements, error: achievementError } = await supabase
                .from('achievement_types')
                .select('*')
                .eq('is_active', true)
                .order('points_reward', { ascending: false });

            if (achievementError) throw achievementError;

            // Obtener logros del usuario
            const { data: userAchievements, error: userError } = await supabase
                .from('user_achievements')
                .select('achievement_type_id, awarded_at, id')
                .eq('user_id', userId);

            if (userError) throw userError;

            // Crear mapa de logros obtenidos
            const earnedMap = {};
            userAchievements?.forEach(achievement => {
                earnedMap[achievement.achievement_type_id] = achievement;
            });

            // Separar logros obtenidos y no obtenidos
            const earned = [];
            const available = [];

            allAchievements?.forEach(achievement => {
                const userAchievement = earnedMap[achievement.id];
                if (userAchievement) {
                    earned.push({
                        ...achievement,
                        earned: true,
                        awarded_at: userAchievement.awarded_at
                    });
                } else {
                    available.push({
                        ...achievement,
                        earned: false
                    });
                }
            });

            return { 
                success: true, 
                data: { 
                    earned: earned.slice(0, 4), // Mostrar solo 4 en el dashboard
                    available: available.slice(0, 2), // Próximos 2 disponibles
                    total_earned: earned.length,
                    total_points: earned.reduce((sum, a) => sum + a.points_reward, 0)
                } 
            };
        } catch (error) {
            console.error('Error fetching user achievements:', error);
            return { success: false, error: error.message };
        }
    }

    async getHouseAchievements(houseId, limit = 5) {
        try {
            if (supabaseImport instanceof Promise) {
                supabase = await supabaseImport;
            }

            const houseName = getHouseName(houseId);

            // 1) Obtener IDs de usuarios de la casa (profiles -> public_profiles -> user_profiles)
            let memberIds = [];
            try {
                let resp = await supabase
                    .from('profiles')
                    .select('id')
                    .eq('house', houseName);
                if (resp.error) {
                    resp = await supabase
                        .from('public_profiles')
                        .select('id')
                        .eq('house', houseName);
                }
                if (resp.error) {
                    resp = await supabase
                        .from('user_profiles')
                        .select('id')
                        .eq('house', houseName);
                }
                if (!resp.error) memberIds = (resp.data || []).map(r => r.id);
            } catch (e) {
                console.warn('No se pudieron obtener IDs de miembros para logros:', e.message);
            }

            if (!memberIds || memberIds.length === 0) {
                return { success: true, data: [] };
            }

            // 2) Obtener logros de esos usuarios (sin join a user_profiles para evitar 400)
            const { data: achievements, error: achError } = await supabase
                .from('user_achievements')
                .select(`id, user_id, awarded_at, achievement_types (name, icon, points_reward, description)`) 
                .in('user_id', memberIds)
                .order('awarded_at', { ascending: false })
                .limit(limit);
            if (achError) throw achError;

            // 3) Obtener nombres/avatares para esos user_ids
            const uniqueIds = [...new Set(achievements.map(a => a.user_id))];
            let profilesMap = new Map();
            try {
                let resp = await supabase
                    .from('profiles')
                    .select('id, wizard_name, avatar_url')
                    .in('id', uniqueIds);
                if (resp.error) {
                    resp = await supabase
                        .from('public_profiles')
                        .select('id, wizard_name, avatar_url')
                        .in('id', uniqueIds);
                }
                if (resp.error) {
                    resp = await supabase
                        .from('user_profiles')
                        .select('id, wizard_name, avatar_url')
                        .in('id', uniqueIds);
                }
                if (!resp.error) {
                    (resp.data || []).forEach(p => profilesMap.set(p.id, p));
                }
            } catch (e) {
                console.warn('No se pudieron obtener nombres para logros:', e.message);
            }

            // 4) Combinar
            const merged = (achievements || []).map(a => ({
                id: a.id,
                awarded_at: a.awarded_at,
                achievement_types: a.achievement_types,
                user_profiles: profilesMap.get(a.user_id) || null
            }));

            return { success: true, data: merged };
        } catch (error) {
            console.error('Error fetching house achievements:', error);
            return { success: false, error: error.message };
        }
    }

    // MIEMBROS DE LA CASA
    async getHouseMembers(houseId, limit = 10) {
        try {
            if (supabaseImport instanceof Promise) {
                supabase = await supabaseImport;
            }

            // Obtener miembros de la casa (profiles -> public_profiles -> user_profiles)
            let members = [];
            let baseError = null;
            try {
                // 1) profiles
                let resp = await supabase
                    .from('profiles')
                    .select('id, wizard_name, avatar_url, house')
                    .eq('house', getHouseName(houseId))
                    .limit(limit);
                if (!resp.error) {
                    members = resp.data || [];
                } else {
                    baseError = resp.error;
                    // 2) public_profiles
                    resp = await supabase
                        .from('public_profiles')
                        .select('id, wizard_name, avatar_url, house')
                        .eq('house', getHouseName(houseId))
                        .limit(limit);
                    if (!resp.error) {
                        members = resp.data || [];
                    } else {
                        // 3) user_profiles
                        const fallback = await supabase
                            .from('user_profiles')
                            .select('id, wizard_name, avatar_url, house')
                            .eq('house', getHouseName(houseId))
                            .limit(limit);
                        if (!fallback.error) {
                            members = fallback.data || [];
                        } else {
                            throw fallback.error;
                        }
                    }
                }
            } catch (e) {
                throw (baseError || e);
            }

            // Obtener puntos de usuarios usando la función leaderboard_users
            const { data: userLeaderboard } = await supabase
                .rpc('leaderboard_users', { in_period: 'all' });

            // Crear mapa de puntos por usuario
            const userPointsMap = {};
            userLeaderboard?.forEach(user => {
                userPointsMap[user.user_id] = user.points || 0;
            });

            // Combinar datos de miembros con puntos
            const membersWithStats = members?.map(member => ({
                id: member.id,
                wizard_name: member.wizard_name || 'Mago Anónimo',
                avatar_url: member.avatar_url,
                house_points: userPointsMap[member.id] || 0,
                created_at: member.created_at,
                last_login: null, // No disponible en tabla user_profiles
                online_status: this.getOnlineStatus(null),
                specialty: this.getMemberSpecialty(userPointsMap[member.id] || 0)
            })) || [];

            // Ordenar por puntos de casa
            membersWithStats.sort((a, b) => b.house_points - a.house_points);

            return { success: true, data: membersWithStats };
        } catch (error) {
            console.error('Error fetching house members:', error);
            return { success: false, error: error.message };
        }
    }

    // EVENTOS Y CALENDARIO
    async getUpcomingEvents(limit = 5) {
        try {
            if (supabaseImport instanceof Promise) {
                supabase = await supabaseImport;
            }

            const now = new Date().toISOString();

            const { data, error } = await supabase
                .from('events')
                .select('*')
                .eq('status', 'active')
                .gte('start_at', now)
                .order('start_at', { ascending: true })
                .limit(limit);

            if (error) throw error;

            return { success: true, data: data || [] };
        } catch (error) {
            console.error('Error fetching upcoming events:', error);
            return { success: false, error: error.message };
        }
    }

    // ESTADÍSTICAS PERSONALES
    async getUserStats(userId) {
        try {
            if (supabaseImport instanceof Promise) {
                supabase = await supabaseImport;
            }

            // Perfil básico desde user_profiles (tolerante a errores)
            let profile = null;
            try {
                const { data, error } = await supabase
                    .from('user_profiles')
                    .select('*')
                    .eq('id', userId)
                    .maybeSingle();
                if (!error) profile = data;
            } catch (e) {
                console.warn('user_profiles not available:', e.message);
            }

            // Puntos del usuario usando leaderboard (tolerante a ausencia de RPC)
            let userPoints = 0;
            try {
                const { data: userLeaderboard } = await supabase
                    .rpc('leaderboard_users', { in_period: 'all' });
                userPoints = userLeaderboard?.find(u => u.user_id === userId)?.points || 0;
            } catch (e) {
                console.warn('leaderboard_users RPC not available:', e.message);
            }

            // Estadísticas del foro (tabla opcional)
            let forumStats = null;
            try {
                const { data, error } = await supabase
                    .from('forum_user_stats')
                    .select('*')
                    .eq('user_id', userId)
                    .maybeSingle();
                if (!error) forumStats = data;
            } catch (e) {
                console.warn('forum_user_stats not available:', e.message);
            }

            // Total de logros (tabla opcional)
            let achievementsCount = 0;
            try {
                const { count } = await supabase
                    .from('user_achievements')
                    .select('*', { count: 'exact', head: true })
                    .eq('user_id', userId);
                achievementsCount = count || 0;
            } catch (error) {
                console.warn('Achievement data not available:', error.message);
            }

            return {
                success: true,
                data: {
                    house_points: userPoints,
                    total_posts: forumStats?.total_posts || 0,
                    total_comments: forumStats?.total_comments || 0,
                    achievements_count: achievementsCount,
                    reputation_points: forumStats?.reputation_points || 0,
                    member_since: profile?.created_at
                }
            };
        } catch (error) {
            console.error('Error fetching user stats:', error);
            return { success: false, error: error.message };
        }
    }

    // UTILIDADES AUXILIARES
    getOnlineStatus(lastLogin) {
        if (!lastLogin) return 'offline';
        
        const now = new Date();
        const loginTime = new Date(lastLogin);
        const diffMinutes = (now - loginTime) / (1000 * 60);
        
        if (diffMinutes < 5) return 'online';
        if (diffMinutes < 60) return 'away';
        return 'offline';
    }

    getMemberSpecialty(points) {
        if (points >= 1000) return 'Especialista en Defensa Contra las Artes Oscuras';
        if (points >= 500) return 'Experto en Historia de la Magia';
        if (points >= 200) return 'Maestra en Transformaciones';
        return 'Estudiante de primer año';
    }

    getTimeAgo(dateString) {
        const date = new Date(dateString);
        const now = new Date();
        const seconds = Math.floor((now - date) / 1000);
        
        if (seconds < 60) return 'Hace un momento';
        if (seconds < 3600) return `Hace ${Math.floor(seconds / 60)} minutos`;
        if (seconds < 86400) return `Hace ${Math.floor(seconds / 3600)} horas`;
        if (seconds < 604800) return `Hace ${Math.floor(seconds / 86400)} días`;
        
        return date.toLocaleDateString();
    }

    // SUBSCRIPCIONES EN TIEMPO REAL
    subscribeToDashboardUpdates(houseId, callback) {
        try {
            const channelName = `dashboard-${houseId}`;
            
            // Unsubscribe from existing channel if any
            this.unsubscribeFromChannel(channelName);

            const channel = supabase
                .channel(channelName)
                .on('postgres_changes', 
                    { event: '*', schema: 'public', table: 'house_points_ledger' }, 
                    () => callback('points_updated')
                )
                .on('postgres_changes',
                    { event: '*', schema: 'public', table: 'user_achievements' },
                    () => callback('achievements_updated')
                )
                .on('postgres_changes',
                    { event: '*', schema: 'public', table: 'posts' },
                    () => callback('posts_updated')
                )
                .subscribe();

            this.realtimeChannels.set(channelName, channel);
            return channel;
        } catch (error) {
            console.error('Error setting up dashboard subscription:', error);
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
}

// Utility functions
function getHouseId(houseName) {
    const houseIds = {
        'gryffindor': 1,
        'slytherin': 4, // Basado en tus datos reales
        'ravenclaw': 3,
        'hufflepuff': 2
    };
    return houseIds[houseName?.toLowerCase()];
}

function getHouseName(houseId) {
    const houseNames = {
        1: 'gryffindor',
        4: 'slytherin', // Basado en tus datos reales
        3: 'ravenclaw',
        2: 'hufflepuff'
    };
    return houseNames[houseId];
}

// Export singleton instance
export const dashboardAPI = new DashboardAPI();