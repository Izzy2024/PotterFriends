/**
 * SISTEMA DE CONEXIONES SOCIALES - Hogwarts PotterFriends
 * Gestión de amistades, seguidores y estadísticas sociales
 */

class SocialConnections {
    constructor() {
        this.supabase = null;
        this.currentUser = null;
        this.socialStats = {
            friends_count: 0,
            house_members_count: 0,
            followers_count: 0,
            following_count: 0
        };
        this.init();
    }

    async init() {
        try {
            // Inicializar Supabase mediante HogwartsAuth e integrar cliente global
            await (window.HogwartsAuth && window.HogwartsAuth.initSupabase
                ? window.HogwartsAuth.initSupabase()
                : Promise.resolve());
            this.supabase = window.supabaseClient;

            // Obtener usuario actual
            const { data: { user } } = await this.supabase.auth.getUser();
            if (user) {
                this.currentUser = user;
                await this.loadSocialStats();
            }
        } catch (error) {
            console.error('Error inicializando sistema social:', error);
        }
    }

    // ==========================================================
    // GESTIÓN DE AMISTADES
    // ==========================================================

    /**
     * Enviar solicitud de amistad
     * @param {string} friendId - ID del usuario al que enviar solicitud
     */
    async sendFriendRequest(friendId) {
        try {
            const { data, error } = await this.supabase.rpc('send_friend_request', {
                p_friend_id: friendId
            });

            if (error) throw error;

            this.showNotification('Solicitud de amistad enviada ✨', 'success');
            await this.loadSocialStats(); // Actualizar stats
            return { success: true, data };
        } catch (error) {
            console.error('Error enviando solicitud:', error);
            this.showNotification(error.message || 'Error enviando solicitud', 'error');
            return { success: false, error: error.message };
        }
    }

    /**
     * Aceptar solicitud de amistad
     * @param {string} requesterId - ID del usuario que envió la solicitud
     */
    async acceptFriendRequest(requesterId) {
        try {
            const { data, error } = await this.supabase.rpc('accept_friend_request', {
                p_requester_id: requesterId
            });

            if (error) throw error;

            this.showNotification('¡Ahora son amigos! 🤝', 'success');
            await this.loadSocialStats();
            this.updateFriendButtonUI(requesterId, 'friends');
            
            // Disparar logro de primer amigo si aplica
            this.checkFirstFriendAchievement();
            
            return { success: true, data };
        } catch (error) {
            console.error('Error aceptando solicitud:', error);
            this.showNotification(error.message || 'Error aceptando solicitud', 'error');
            return { success: false, error: error.message };
        }
    }

    /**
     * Rechazar solicitud de amistad
     * @param {string} requesterId - ID del usuario que envió la solicitud
     */
    async declineFriendRequest(requesterId) {
        try {
            const { data, error } = await this.supabase.rpc('decline_friend_request', {
                p_requester_id: requesterId
            });

            if (error) throw error;

            this.showNotification('Solicitud rechazada', 'info');
            this.updateFriendButtonUI(requesterId, 'none');
            return { success: true, data };
        } catch (error) {
            console.error('Error rechazando solicitud:', error);
            this.showNotification(error.message || 'Error rechazando solicitud', 'error');
            return { success: false, error: error.message };
        }
    }

    // ==========================================================
    // GESTIÓN DE SEGUIDORES
    // ==========================================================

    /**
     * Seguir a un usuario
     * @param {string} userToFollowId - ID del usuario a seguir
     */
    async followUser(userToFollowId) {
        try {
            const { data, error } = await this.supabase.rpc('follow_user', {
                p_user_to_follow_id: userToFollowId
            });

            if (error) throw error;

            this.showNotification('¡Ahora sigues a este usuario! 👀', 'success');
            await this.loadSocialStats();
            this.updateFollowButtonUI(userToFollowId, true);
            return { success: true, data };
        } catch (error) {
            console.error('Error siguiendo usuario:', error);
            this.showNotification(error.message || 'Error siguiendo usuario', 'error');
            return { success: false, error: error.message };
        }
    }

    /**
     * Dejar de seguir a un usuario
     * @param {string} userToUnfollowId - ID del usuario a dejar de seguir
     */
    async unfollowUser(userToUnfollowId) {
        try {
            const { data, error } = await this.supabase.rpc('unfollow_user', {
                p_user_to_unfollow_id: userToUnfollowId
            });

            if (error) throw error;

            this.showNotification('Has dejado de seguir a este usuario', 'info');
            await this.loadSocialStats();
            this.updateFollowButtonUI(userToUnfollowId, false);
            return { success: true, data };
        } catch (error) {
            console.error('Error dejando de seguir:', error);
            this.showNotification(error.message || 'Error dejando de seguir', 'error');
            return { success: false, error: error.message };
        }
    }

    // ==========================================================
    // ESTADÍSTICAS Y DATOS
    // ==========================================================

    /**
     * Cargar estadísticas sociales del usuario actual
     */
    async loadSocialStats() {
        try {
            const { data, error } = await this.supabase.rpc('get_user_social_stats');
            
            if (error) throw error;

            this.socialStats = data;
            this.renderSocialStats();
            return data;
        } catch (error) {
            console.error('Error cargando estadísticas sociales:', error);
            return null;
        }
    }

    /**
     * Obtener amigos recientes
     * @param {number} limit - Número de amigos a obtener (default: 6)
     */
    async getRecentFriends(limit = 6) {
        try {
            const { data, error } = await this.supabase.rpc('get_recent_friends', {
                p_limit: limit
            });
            
            if (error) throw error;
            return data || [];
        } catch (error) {
            console.error('Error obteniendo amigos recientes:', error);
            return [];
        }
    }

    /**
     * Verificar estado de relación con otro usuario
     * @param {string} userId - ID del usuario a verificar
     */
    async getRelationshipStatus(userId) {
        try {
            // Verificar amistad
            const { data: friendship, error: friendError } = await this.supabase
                .from('friendships')
                .select('status, user_id, friend_id')
                .or(`and(user_id.eq.${this.currentUser.id},friend_id.eq.${userId}),and(user_id.eq.${userId},friend_id.eq.${this.currentUser.id})`)
                .single();

            // Verificar si sigue al usuario
            const { data: following, error: followError } = await this.supabase
                .from('followers')
                .select('*')
                .eq('follower_id', this.currentUser.id)
                .eq('user_id', userId)
                .single();

            return {
                friendship: friendship || null,
                isFollowing: !!following,
                isFriend: friendship?.status === 'accepted',
                isPending: friendship?.status === 'pending',
                isRequester: friendship?.user_id === this.currentUser.id
            };
        } catch (error) {
            console.error('Error verificando relación:', error);
            return {
                friendship: null,
                isFollowing: false,
                isFriend: false,
                isPending: false,
                isRequester: false
            };
        }
    }

    // ==========================================================
    // RENDERIZADO DE UI
    // ==========================================================

    /**
     * Renderizar estadísticas sociales en la interfaz
     */
    renderSocialStats() {
        const statsElements = {
            friends: document.getElementById('friendsCount'),
            houseMembers: document.getElementById('houseMembersCount'),
            followers: document.getElementById('followersCount'),
            following: document.getElementById('followingCount')
        };

        if (statsElements.friends) {
            statsElements.friends.textContent = this.socialStats.friends_count || 0;
        }
        if (statsElements.houseMembers) {
            statsElements.houseMembers.textContent = this.socialStats.house_members_count || 0;
        }
        if (statsElements.followers) {
            statsElements.followers.textContent = this.socialStats.followers_count || 0;
        }
        if (statsElements.following) {
            statsElements.following.textContent = this.socialStats.following_count || 0;
        }

        // Animar los números
        this.animateCounters();
    }

    /**
     * Renderizar lista de amigos recientes
     */
    async renderRecentFriends() {
        const container = document.getElementById('recentFriendsContainer');
        if (!container) return;

        try {
            const friends = await this.getRecentFriends(6);
            
            if (!friends || friends.length === 0) {
                container.innerHTML = `
                    <div class="text-center py-8 text-text-secondary">
                        <p>¡Haz nuevos amigos en Hogwarts!</p>
                        <a href="interactive_forum_hub.html" class="btn-primary mt-4 inline-block">Explorar Comunidad</a>
                    </div>
                `;
                return;
            }

            const friendsHTML = friends.map(friend => {
                const house = ((friend.house || '') + '').toLowerCase();
                const isHouse = house === 'gryffindor' || house === 'hufflepuff' || house === 'ravenclaw' || house === 'slytherin';
                const houseClass = isHouse ? house : 'gray-400';
                return `
                <div class="friend-card bg-surface p-4 rounded-lg border border-gray-200 hover-scale magical-transition">
                    <div class="flex items-center space-x-3">
                        <div class="w-12 h-12 rounded-full bg-${houseClass} flex items-center justify-center text-white font-bold">
                            ${friend.display_name?.charAt(0).toUpperCase() || '?'}
                        </div>
                        <div class="flex-1">
                            <h4 class="font-medium text-text-primary">${friend.display_name || 'Usuario Mágico'}</h4>
                            <p class="text-sm text-text-secondary capitalize">${friend.house || 'Sin casa'}</p>
                        </div>
                        <div class="w-3 h-3 bg-${houseClass} rounded-full"></div>
                    </div>
                </div>
            `;
            }).join('');

            const showMoreButton = friends.length >= 6 ? `
                <div class="text-center mt-4">
                    <button onclick="socialConnections.showAllFriends()" class="text-primary hover:text-primary-700 font-medium">
                        Ver todos los amigos →
                    </button>
                </div>
            ` : '';

            container.innerHTML = friendsHTML + showMoreButton;
        } catch (error) {
            console.error('Error renderizando amigos recientes:', error);
            container.innerHTML = `
                <div class="text-center py-8 text-error">
                    <p>Error cargando amigos</p>
                </div>
            `;
        }
    }

    /**
     * Crear botones de acción social para un usuario
     * @param {string} userId - ID del usuario
     * @param {string} containerId - ID del contenedor donde renderizar
     */
    async renderSocialButtons(userId, containerId) {
        if (!userId || userId === this.currentUser?.id) return;

        const container = document.getElementById(containerId);
        if (!container) return;

        try {
            const relationship = await this.getRelationshipStatus(userId);
            let buttonsHTML = '';

            // Botón de amistad
            if (relationship.isFriend) {
                buttonsHTML += `
                    <button class="btn-secondary" disabled>
                        <span>🤝</span> Amigos
                    </button>
                `;
            } else if (relationship.isPending) {
                if (relationship.isRequester) {
                    buttonsHTML += `
                        <button class="btn-secondary" disabled>
                            <span>⏳</span> Solicitud enviada
                        </button>
                    `;
                } else {
                    buttonsHTML += `
                        <button class="btn-primary mr-2" onclick="socialConnections.acceptFriendRequest('${userId}')">
                            <span>✅</span> Aceptar
                        </button>
                        <button class="btn-secondary" onclick="socialConnections.declineFriendRequest('${userId}')">
                            <span>❌</span> Rechazar
                        </button>
                    `;
                }
            } else {
                buttonsHTML += `
                    <button class="btn-primary mr-2" onclick="socialConnections.sendFriendRequest('${userId}')">
                        <span>👋</span> Agregar amigo
                    </button>
                `;
            }

            // Botón de seguir
            if (relationship.isFollowing) {
                buttonsHTML += `
                    <button class="btn-secondary" onclick="socialConnections.unfollowUser('${userId}')">
                        <span>👁️</span> Siguiendo
                    </button>
                `;
            } else {
                buttonsHTML += `
                    <button class="btn-outline" onclick="socialConnections.followUser('${userId}')">
                        <span>👀</span> Seguir
                    </button>
                `;
            }

            container.innerHTML = buttonsHTML;
        } catch (error) {
            console.error('Error renderizando botones sociales:', error);
        }
    }

    // ==========================================================
    // UTILIDADES Y HELPERS
    // ==========================================================

    /**
     * Actualizar UI de botón de amistad
     * @param {string} userId - ID del usuario
     * @param {string} newStatus - Nuevo estado: 'friends', 'pending', 'none'
     */
    updateFriendButtonUI(userId, newStatus) {
        const button = document.querySelector(`[data-friend-btn="${userId}"]`);
        if (!button) return;

        switch (newStatus) {
            case 'friends':
                button.innerHTML = '<span>🤝</span> Amigos';
                button.className = 'btn-secondary';
                button.disabled = true;
                break;
            case 'pending':
                button.innerHTML = '<span>⏳</span> Solicitud enviada';
                button.className = 'btn-secondary';
                button.disabled = true;
                break;
            case 'none':
                button.innerHTML = '<span>👋</span> Agregar amigo';
                button.className = 'btn-primary';
                button.disabled = false;
                break;
        }
    }

    /**
     * Actualizar UI de botón de seguir
     * @param {string} userId - ID del usuario
     * @param {boolean} isFollowing - Si está siguiendo o no
     */
    updateFollowButtonUI(userId, isFollowing) {
        const button = document.querySelector(`[data-follow-btn="${userId}"]`);
        if (!button) return;

        if (isFollowing) {
            button.innerHTML = '<span>👁️</span> Siguiendo';
            button.className = 'btn-secondary';
        } else {
            button.innerHTML = '<span>👀</span> Seguir';
            button.className = 'btn-outline';
        }
    }

    /**
     * Animar contadores con efecto de incremento
     */
    animateCounters() {
        const counters = ['friendsCount', 'houseMembersCount', 'followersCount', 'followingCount'];
        const values = [
            this.socialStats.friends_count,
            this.socialStats.house_members_count,
            this.socialStats.followers_count,
            this.socialStats.following_count
        ];

        counters.forEach((counterId, index) => {
            const element = document.getElementById(counterId);
            if (!element) return;

            const finalValue = values[index] || 0;
            const duration = 1000; // 1 segundo
            const steps = 30;
            const stepValue = finalValue / steps;
            let currentValue = 0;
            let step = 0;

            const timer = setInterval(() => {
                step++;
                currentValue = Math.min(Math.floor(stepValue * step), finalValue);
                element.textContent = currentValue;

                if (step >= steps) {
                    clearInterval(timer);
                    element.textContent = finalValue;
                }
            }, duration / steps);
        });
    }

    /**
     * Verificar y disparar logro de primer amigo
     */
    async checkFirstFriendAchievement() {
        if (this.socialStats.friends_count === 1) {
            // Disparar logro de primer amigo
            if (window.achievementTracker && typeof window.achievementTracker.triggerAchievement === 'function') {
                window.achievementTracker.triggerAchievement('first_friend');
            }
        }
    }

    /**
     * Mostrar notificación
     * @param {string} message - Mensaje a mostrar
     * @param {string} type - Tipo: 'success', 'error', 'info'
     */
    showNotification(message, type = 'info') {
        // Crear elemento de notificación
        const notification = document.createElement('div');
        notification.className = `fixed top-4 right-4 p-4 rounded-lg shadow-elevated z-50 transform transition-all duration-300 ${
            type === 'success' ? 'bg-success text-white' :
            type === 'error' ? 'bg-error text-white' :
            'bg-accent text-white'
        }`;
        notification.innerHTML = `
            <div class="flex items-center space-x-2">
                <span>${message}</span>
                <button onclick="this.parentElement.parentElement.remove()" class="ml-4 text-white hover:text-gray-200">×</button>
            </div>
        `;

        document.body.appendChild(notification);

        // Auto-eliminar después de 5 segundos
        setTimeout(() => {
            if (notification.parentElement) {
                notification.style.transform = 'translateX(100%)';
                setTimeout(() => notification.remove(), 300);
            }
        }, 5000);
    }

    /**
     * Mostrar modal con todos los amigos
     */
    async showAllFriends() {
        // TODO: Implementar modal con lista completa de amigos
        console.log('Mostrar modal con todos los amigos');
    }
}

// Inicializar el sistema social cuando el DOM esté listo
document.addEventListener('DOMContentLoaded', () => {
    window.socialConnections = new SocialConnections();
});

// Exportar para uso global
if (typeof module !== 'undefined' && module.exports) {
    module.exports = SocialConnections;
}
