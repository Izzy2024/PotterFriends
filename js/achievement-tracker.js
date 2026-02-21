/**
 * SISTEMA DE SEGUIMIENTO AUTOMÁTICO DE LOGROS
 * Hogwarts Community Hub - Detección automática de logros temáticos
 */

class AchievementTracker {
    constructor(supabaseClient) {
        // Require a single, unified Supabase client (provided by auth.js)
        this.supabase = supabaseClient || (typeof window !== 'undefined' ? window.supabaseClient : null);
        if (!this.supabase) {
            console.warn('AchievementTracker: Supabase client not available yet.');
            return;
        }

        this.currentUser = null;
        this.sessionStats = {
            pagesVisited: new Set(),
            timeSpent: 0,
            interactions: 0
        };
        this.startTime = Date.now();

        this.init();
    }

    async init() {
        try {
            if (!this.supabase) return; // sin supabase no podemos continuar aún
            const { data: { user } } = await this.supabase.auth.getUser();
            if (user) {
                this.currentUser = user;
                this.setupTracking();
                this.checkForNewAchievements();
            }
        } catch (error) {
            console.warn('AchievementTracker init error:', error);
        }
    }

    setupTracking() {
        // Rastrear visitas a páginas
        this.trackPageVisit();
        this.trackDailyVisit();

        // Rastrear tiempo en la página
        this.trackTimeSpent();

        // Rastrear interacciones
        this.trackInteractions();

        // Rastrear eventos específicos
        this.trackSpecificEvents();

        // Verificar logros cada 30 segundos
        setInterval(() => {
            this.checkForNewAchievements();
        }, 30000);
    }

    trackPageVisit() {
        const currentPage = window.location.pathname;
        this.sessionStats.pagesVisited.add(currentPage);

        // Actualizar estadística de páginas visitadas
        this.updateUserStat('pages_visited', 1);

        // Verificar logros específicos de páginas
        this.checkPageSpecificAchievements(currentPage);
    }

    trackTimeSpent() {
        // Actualizar tiempo cada minuto
        setInterval(() => {
            const timeSpent = Math.floor((Date.now() - this.startTime) / 60000); // minutos
            this.sessionStats.timeSpent = timeSpent;

            if (timeSpent > 0) {
                this.updateUserStat('time_spent_minutes', 1);
            }
        }, 60000);
    }

    trackInteractions() {
        // Rastrear clics en elementos importantes
        document.addEventListener('click', (e) => {
            const target = e.target;

            // Botones importantes
            if (target.matches('.btn-primary, .btn-secondary, .magical-button')) {
                this.sessionStats.interactions++;
                this.updateUserStat('button_clicks', 1);
            }

            // Enlaces de navegación
            if (target.matches('nav a, .nav-link')) {
                this.updateUserStat('navigation_clicks', 1);
            }

            // Elementos de casa
            if (target.matches('.house-element, [class*="house-"]')) {
                this.updateUserStat('house_interactions', 1);
            }
        });

        // Rastrear envío de formularios
        document.addEventListener('submit', (e) => {
            const form = e.target;

            if (form.matches('#forumPostForm, .forum-form')) {
                this.updateUserStat('forum_posts', 1);
                this.triggerAchievement('first_forum_post');
            }

            if (form.matches('#profileForm, .profile-form')) {
                this.triggerAchievement('profile_completion');
            }
        });
    }

    trackSpecificEvents() {
        // Rastrear selección de casa
        if (window.location.pathname.includes('house_selection')) {
            document.addEventListener('click', (e) => {
                if (e.target.matches('.house-selection-btn, .house-option')) {
                    this.triggerAchievement('house_selection');
                }
            });
        }

        // Rastrear visitas a salas comunes
        if (window.location.pathname.includes('house_common_rooms')) {
            this.triggerAchievement('house_room_visit');
        }

        // Rastrear participación en quizzes
        if (window.location.pathname.includes('quiz') || window.location.pathname.includes('sorting_hat')) {
            document.addEventListener('submit', () => {
                this.updateUserStat('quizzes_completed', 1);
                this.triggerAchievement('quiz_completion');
            });
        }

        // Rastrear easter eggs
        this.setupEasterEggTracking();
    }

    setupEasterEggTracking() {
        let clickCount = 0;

        // Easter egg: hacer clic en el logo muchas veces
        document.addEventListener('click', (e) => {
            if (e.target.matches('.logo, .site-logo, [alt*="logo"]')) {
                clickCount++;
                if (clickCount >= 10) {
                    this.triggerAchievement('easter_egg_discovery');
                    clickCount = 0; // Reset
                }
            }
        });

        // Easter egg: secuencia de teclas mágica (Konami code adaptado)
        let sequence = [];
        const magicSequence = ['ArrowUp', 'ArrowUp', 'ArrowDown', 'ArrowDown', 'ArrowLeft', 'ArrowRight', 'ArrowLeft', 'ArrowRight'];

        document.addEventListener('keydown', (e) => {
            sequence.push(e.code);
            if (sequence.length > magicSequence.length) {
                sequence.shift();
            }

            if (JSON.stringify(sequence) === JSON.stringify(magicSequence)) {
                this.triggerAchievement('easter_egg_discovery');
                sequence = []; // Reset
            }
        });
    }

    checkPageSpecificAchievements(currentPage) {
        const pageAchievements = {
            '/pages/user_profile_achievement_system.html': 'profile_visit',
            '/pages/house_common_rooms_personalized_dashboards.html': 'house_room_visit',
            '/pages/interactive_forum_hub.html': 'forum_visit',
            '/pages/community_events_challenges_center.html': 'events_visit'
        };

        const achievement = pageAchievements[currentPage];
        if (achievement) {
            this.triggerAchievement(achievement);
        }

        // Verificar si visitó todas las secciones principales
        const mainSections = Object.keys(pageAchievements);
        const visitedSections = Array.from(this.sessionStats.pagesVisited);
        const visitedMainSections = visitedSections.filter(page => mainSections.includes(page));

        if (visitedMainSections.length >= mainSections.length) {
            this.triggerAchievement('all_sections_visited');
        }
    }

    async updateUserStat(statName, increment = 1) {
        if (!this.currentUser) return;

        try {
            await this.supabase.rpc('update_user_stat', {
                p_user_id: this.currentUser.id,
                p_stat_name: statName,
                p_increment: increment
            });
        } catch (error) {
            console.log('Error updating user stat:', error);
        }
    }

    async triggerAchievement(triggerCondition) {
        if (!this.currentUser) return;

        try {
            // Marcar que se activó esta condición
            await this.updateUserStat(`trigger_${triggerCondition}`, 1);

            // Verificar logros
            this.checkForNewAchievements();
        } catch (error) {
            console.log('Error triggering achievement:', error);
        }
    }

    async checkForNewAchievements() {
        if (!this.currentUser) return;

        try {
            const { data, error } = await this.supabase
                .rpc('check_and_award_achievements', {
                    p_user_id: this.currentUser.id
                });

            const result = Array.isArray(data) ? data[0] : data;
            if (!error && result && result.achievements_awarded > 0) {
                this.showAchievementNotification(result);
            }
        } catch (error) {
            console.log('Error checking achievements:', error);
        }
    }

    showAchievementNotification(data) {
        // Crear notificación mágica de logro
        const notification = document.createElement('div');
        notification.className = 'achievement-notification fixed top-4 right-4 z-50 transform translate-x-full transition-transform duration-500';
        notification.innerHTML = `
            <div class="bg-gradient-to-r from-yellow-400 to-yellow-600 text-white p-4 rounded-lg shadow-lg border-2 border-yellow-300">
                <div class="flex items-center space-x-3">
                    <div class="text-2xl">🏆</div>
                    <div>
                        <div class="font-bold">¡Nuevo Logro Desbloqueado!</div>
                        <div class="text-sm opacity-90">${data.message}</div>
                    </div>
                    <button onclick="this.parentElement.parentElement.parentElement.remove()" class="text-white hover:text-yellow-200">
                        ×
                    </button>
                </div>
            </div>
        `;

        document.body.appendChild(notification);

        // Animar entrada
        setTimeout(() => {
            notification.classList.remove('translate-x-full');
        }, 100);

        // Auto-remove después de 5 segundos
        setTimeout(() => {
            if (notification.parentElement) {
                notification.classList.add('translate-x-full');
                setTimeout(() => notification.remove(), 500);
            }
        }, 5000);

        // Reproducir sonido mágico (opcional)
        this.playAchievementSound();
    }

    playAchievementSound() {
        // Crear un sonido simple usando Web Audio API
        try {
            const audioContext = new (window.AudioContext || window.webkitAudioContext)();
            const oscillator = audioContext.createOscillator();
            const gainNode = audioContext.createGain();

            oscillator.connect(gainNode);
            gainNode.connect(audioContext.destination);

            oscillator.frequency.setValueAtTime(523.25, audioContext.currentTime); // C5
            oscillator.frequency.setValueAtTime(659.25, audioContext.currentTime + 0.1); // E5
            oscillator.frequency.setValueAtTime(783.99, audioContext.currentTime + 0.2); // G5

            gainNode.gain.setValueAtTime(0.3, audioContext.currentTime);
            gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + 0.5);

            oscillator.start(audioContext.currentTime);
            oscillator.stop(audioContext.currentTime + 0.5);
        } catch (error) {
            console.log('Could not play achievement sound:', error);
        }
    }

    // Método para rastrear visitas diarias consecutivas
    trackDailyVisit() {
        const today = new Date().toDateString();
        const lastVisit = localStorage.getItem('lastVisitDate');
        const consecutiveDays = parseInt(localStorage.getItem('consecutiveDays') || '0');

        if (lastVisit !== today) {
            const yesterday = new Date();
            yesterday.setDate(yesterday.getDate() - 1);

            if (lastVisit === yesterday.toDateString()) {
                // Visita consecutiva
                const newConsecutiveDays = consecutiveDays + 1;
                localStorage.setItem('consecutiveDays', newConsecutiveDays.toString());
                this.updateUserStat('consecutive_days', 1);
            } else {
                // Se rompió la racha
                localStorage.setItem('consecutiveDays', '1');
                this.updateUserStat('consecutive_days', 1 - consecutiveDays);
            }

            localStorage.setItem('lastVisitDate', today);
        }
    }
}

// Exponer la clase globalmente para que la página pueda instanciarla
if (typeof window !== 'undefined') {
    window.AchievementTracker = AchievementTracker;
}

// Inicializar el tracker cuando el DOM esté listo y el cliente unificado exista
if (typeof window !== 'undefined') {
    document.addEventListener('DOMContentLoaded', async () => {
        try {
            // Espera a que auth.js cree el cliente global
            await new Promise((resolve, reject) => {
                const start = Date.now();
                const timer = setInterval(() => {
                    if (window.supabaseClient) {
                        clearInterval(timer);
                        resolve();
                    } else if (Date.now() - start > 5000) {
                        clearInterval(timer);
                        reject(new Error('Supabase client not initialized by auth.js'));
                    }
                }, 50);
            });

            if (!window.achievementTracker) {
                window.achievementTracker = new AchievementTracker(window.supabaseClient);
            }
        } catch (e) {
            console.warn('AchievementTracker could not start:', e);
        }
    });
}
