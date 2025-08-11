/**
 * SISTEMA DE PERFIL REDISEÑADO - Hogwarts Community Hub
 * Versión compacta y minimalista con funcionalidades mejoradas
 */

class ProfileRedesigned {
    constructor() {
        this.supabase = null;
        this.currentUser = null;
        this.currentProfile = null;
        this.isEditMode = false;
        this.achievements = [];
        this.activities = [];
        this.init();
    }

    async init() {
        try {
            // Inicializar Supabase
            this.supabase = window.supabase.createClient(
                'https://vdcclritlgnwwdxloayt.supabase.co',
                'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZkY2Nscml0bGdud3dkeGxvYXl0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMwOTQxMDQsImV4cCI6MjA2ODY3MDEwNH0.BaBIrCS9fgkLEkC_KLZg9gR_jNgFIPC7bMvuwfCnb6E'
            );

            // Verificar usuario autenticado
            const { data: { user } } = await this.supabase.auth.getUser();
            if (user) {
                this.currentUser = user;
                await this.loadUserProfile();
                this.setupEventListeners();
                this.renderProfile();
                this.loadAchievements();
                this.loadActivities();
            } else {
                this.redirectToLogin();
            }
        } catch (error) {
            console.error('Error inicializando perfil:', error);
            this.showError('Error al cargar el perfil');
        }
    }

    async loadUserProfile() {
        try {
            const { data: profile, error } = await this.supabase
                .from('user_profiles')
                .select('*')
                .eq('id', this.currentUser.id)
                .single();

            if (error && error.code !== 'PGRST116') {
                throw error;
            }

            if (!profile) {
                await this.createUserProfile();
            } else {
                this.currentProfile = profile;
            }
        } catch (error) {
            console.error('Error cargando perfil:', error);
            this.showError('Error al cargar los datos del perfil');
        }
    }

    async createUserProfile() {
        try {
            const house = localStorage.getItem('userHouse') || 'gryffindor';
            
            const profileData = {
                id: this.currentUser.id,
                display_name: this.currentUser.user_metadata?.full_name || this.currentUser.email.split('@')[0],
                bio: 'Nuevo miembro de la comunidad mágica de Hogwarts.',
                house: house.toLowerCase(),
                avatar_url: this.currentUser.user_metadata?.avatar_url || null,
                house_points: 0,
                reputation_level: 1,
                community_days: 0,
                contributions_count: 0
            };

            const { data, error } = await this.supabase
                .from('user_profiles')
                .insert([profileData])
                .select()
                .single();

            if (error) throw error;

            this.currentProfile = data;
        } catch (error) {
            console.error('Error creando perfil:', error);
            this.showError('Error al crear el perfil');
        }
    }

    setupEventListeners() {
        // Botón de editar perfil
        const editBtn = document.getElementById('editProfileBtn');
        if (editBtn) {
            editBtn.addEventListener('click', () => this.toggleEditMode());
        }

        // Botón de compartir perfil
        const shareBtn = document.getElementById('shareProfileBtn');
        if (shareBtn) {
            shareBtn.addEventListener('click', () => this.shareProfile());
        }

        // Editor de biografía
        this.setupBioEditor();

        // Toggles de privacidad
        this.setupPrivacyToggles();

        // Animaciones de entrada
        this.setupAnimations();
    }

    setupBioEditor() {
        const editBioBtn = document.getElementById('editBioBtn');
        const bioEditor = document.getElementById('bioEditor');
        const profileBio = document.getElementById('profileBio');
        const saveBioBtn = document.getElementById('saveBioBtn');
        const cancelBioBtn = document.getElementById('cancelBioBtn');
        const bioTextarea = document.getElementById('bioTextarea');

        if (editBioBtn) {
            editBioBtn.addEventListener('click', () => {
                bioEditor.classList.remove('hidden');
                profileBio.classList.add('hidden');
                bioTextarea.value = profileBio.textContent.trim();
                bioTextarea.focus();
            });
        }

        if (cancelBioBtn) {
            cancelBioBtn.addEventListener('click', () => {
                bioEditor.classList.add('hidden');
                profileBio.classList.remove('hidden');
            });
        }

        if (saveBioBtn) {
            saveBioBtn.addEventListener('click', async () => {
                await this.saveBio(bioTextarea.value);
                bioEditor.classList.add('hidden');
                profileBio.classList.remove('hidden');
            });
        }
    }

    setupPrivacyToggles() {
        const toggles = document.querySelectorAll('input[type="checkbox"]');
        toggles.forEach(toggle => {
            toggle.addEventListener('change', (e) => {
                this.updatePrivacySetting(e.target);
            });
        });
    }

    setupAnimations() {
        // Animaciones de entrada para las cards
        const cards = document.querySelectorAll('.card');
        const observer = new IntersectionObserver((entries) => {
            entries.forEach((entry, index) => {
                if (entry.isIntersecting) {
                    setTimeout(() => {
                        entry.target.classList.add('fade-in');
                    }, index * 100);
                }
            });
        }, { threshold: 0.1 });

        cards.forEach(card => {
            observer.observe(card);
        });
    }

    renderProfile() {
        if (!this.currentProfile) return;

        // Información básica
        this.updateElement('profileName', this.currentProfile.display_name);
        this.updateElement('profileHouse', this.currentProfile.house.toUpperCase());
        this.updateElement('profileRole', this.currentProfile.role || 'Miembro');
        this.updateElement('profileSpecialization', this.currentProfile.specialization || 'Especialista en Teorías');
        
        // Estadísticas
        this.updateElement('housePoints', this.currentProfile.house_points || 0);
        this.updateElement('reputationLevel', `Nivel ${this.currentProfile.reputation_level || 1}`);
        this.updateElement('communityTime', `${this.currentProfile.community_days || 0} días`);

        // Biografía
        const bioElement = document.getElementById('profileBio');
        if (bioElement) {
            bioElement.innerHTML = `<p>${this.currentProfile.bio || 'Sin biografía disponible.'}</p>`;
        }

        // Avatar
        const avatarElement = document.getElementById('profileAvatar');
        if (avatarElement && this.currentProfile.avatar_url) {
            avatarElement.src = this.currentProfile.avatar_url;
        }

        // Aplicar colores de casa
        this.applyHouseColors();
    }

    applyHouseColors() {
        const house = this.currentProfile.house;
        const houseColors = {
            gryffindor: '#740001',
            slytherin: '#1a472a',
            ravenclaw: '#0e1a40',
            hufflepuff: '#ecb939'
        };

        const color = houseColors[house] || houseColors.gryffindor;
        document.documentElement.style.setProperty('--house-color', color);
    }

    loadAchievements() {
        const achievements = [
            { id: 1, name: 'Primer Año', icon: '⭐', color: 'bg-secondary', unlocked: true, description: 'Se unió a la comunidad' },
            { id: 2, name: 'Campeón', icon: '🏆', color: 'bg-gryffindor', unlocked: true, description: 'Ganó puntos para su casa' },
            { id: 3, name: 'Maestro', icon: '✅', color: 'bg-accent', unlocked: true, description: 'Demostró conocimiento experto' },
            { id: 4, name: 'Ayudante', icon: '👥', color: 'bg-success', unlocked: true, description: 'Ayudó a otros miembros' },
            { id: 5, name: 'Escritor', icon: '🔥', color: 'bg-warning', unlocked: true, description: 'Publicó contenido popular' },
            { id: 6, name: 'Mentor', icon: '❤️', color: 'bg-primary', unlocked: true, description: 'Guió a nuevos miembros' },
            { id: 7, name: 'Explorador', icon: '🔒', color: 'bg-gray-300', unlocked: false, description: 'Descubre nuevas áreas' },
            { id: 8, name: 'Sabio', icon: '🔒', color: 'bg-gray-300', unlocked: false, description: 'Alcanza sabiduría suprema' },
            { id: 9, name: 'Leyenda', icon: '🔒', color: 'bg-gray-300', unlocked: false, description: 'Conviértete en leyenda' },
            { id: 10, name: 'Guardián', icon: '🔒', color: 'bg-gray-300', unlocked: false, description: 'Protege la comunidad' },
            { id: 11, name: 'Místico', icon: '🔒', color: 'bg-gray-300', unlocked: false, description: 'Domina artes místicas' },
            { id: 12, name: 'Eterno', icon: '🔒', color: 'bg-gray-300', unlocked: false, description: 'Logro supremo' }
        ];

        this.achievements = achievements;
        this.renderAchievements();
    }

    renderAchievements() {
        const container = document.getElementById('achievementsContainer');
        if (!container) return;

        const unlockedCount = this.achievements.filter(a => a.unlocked).length;
        this.updateElement('achievementCount', `${unlockedCount} de ${this.achievements.length}`);

        container.innerHTML = this.achievements.map(achievement => `
            <div class="achievement-badge group relative ${achievement.unlocked ? 'unlocked' : ''}" data-tooltip="${achievement.description}">
                <div class="${achievement.color} ${achievement.unlocked ? '' : 'opacity-50'} p-3 rounded-lg text-center hover-scale magical-transition cursor-pointer">
                    <div class="text-lg mb-1">${achievement.icon}</div>
                    <h3 class="font-cta text-xs font-semibold ${achievement.unlocked ? 'text-white' : 'text-gray-500'}">${achievement.name}</h3>
                </div>
                <div class="achievement-tooltip">${achievement.description}</div>
            </div>
        `).join('');

        // Agregar eventos de hover para tooltips
        this.setupAchievementTooltips();
    }

    setupAchievementTooltips() {
        const badges = document.querySelectorAll('.achievement-badge');
        badges.forEach(badge => {
            badge.addEventListener('mouseenter', () => {
                const tooltip = badge.querySelector('.achievement-tooltip');
                if (tooltip) {
                    tooltip.style.opacity = '1';
                }
            });

            badge.addEventListener('mouseleave', () => {
                const tooltip = badge.querySelector('.achievement-tooltip');
                if (tooltip) {
                    tooltip.style.opacity = '0';
                }
            });
        });
    }

    loadActivities() {
        const activities = [
            { 
                type: 'points', 
                text: 'Ganó 50 puntos para Gryffindor', 
                detail: 'Completó el desafío "Coraje en la Adversidad"',
                time: 'Hace 2h', 
                color: 'bg-gryffindor',
                icon: '⭐'
            },
            { 
                type: 'discussion', 
                text: 'Inició discusión popular', 
                detail: '"Teorías sobre Patronus" - 47 respuestas',
                time: 'Hace 1d', 
                color: 'bg-accent',
                icon: '💬'
            },
            { 
                type: 'achievement', 
                text: 'Desbloqueó nuevo logro', 
                detail: 'Logro "Mentor Querido" obtenido',
                time: 'Hace 3d', 
                color: 'bg-success',
                icon: '🏆'
            },
            { 
                type: 'event', 
                text: 'Participó en evento', 
                detail: 'Torneo de Conocimiento Mágico - Top 10',
                time: 'Hace 1 semana', 
                color: 'bg-warning',
                icon: '🎯'
            }
        ];

        this.activities = activities;
        this.renderActivities();
    }

    renderActivities() {
        const container = document.getElementById('activitiesContainer');
        if (!container) return;

        container.innerHTML = this.activities.map(activity => `
            <div class="activity-item flex items-center space-x-3 p-3 rounded-lg hover:bg-gray-50 magical-transition">
                <div class="flex-shrink-0 w-8 h-8 ${activity.color} rounded-full flex items-center justify-center">
                    <span class="text-white text-sm">${activity.icon}</span>
                </div>
                <div class="flex-1 min-w-0">
                    <div class="flex items-center justify-between">
                        <p class="text-sm font-medium text-text-primary truncate">${activity.text}</p>
                        <span class="text-xs text-text-secondary flex-shrink-0 ml-2">${activity.time}</span>
                    </div>
                    <p class="text-xs text-text-secondary mt-1">${activity.detail}</p>
                </div>
            </div>
        `).join('');
    }

    async saveBio(newBio) {
        try {
            const { error } = await this.supabase
                .from('user_profiles')
                .update({ bio: newBio })
                .eq('id', this.currentUser.id);

            if (error) throw error;

            this.currentProfile.bio = newBio;
            document.getElementById('profileBio').innerHTML = `<p>${newBio}</p>`;
            this.showSuccess('Biografía actualizada correctamente');
        } catch (error) {
            console.error('Error guardando biografía:', error);
            this.showError('Error al guardar la biografía');
        }
    }

    async shareProfile() {
        const profileUrl = `${window.location.origin}/pages/user_profile_redesigned.html?user=${this.currentUser.id}`;
        
        if (navigator.share) {
            try {
                await navigator.share({
                    title: `Perfil de ${this.currentProfile.display_name}`,
                    text: `Mira mi perfil en Hogwarts Community Hub`,
                    url: profileUrl
                });
            } catch (error) {
                console.log('Error sharing:', error);
                this.copyToClipboard(profileUrl);
            }
        } else {
            this.copyToClipboard(profileUrl);
        }
    }

    copyToClipboard(text) {
        navigator.clipboard.writeText(text).then(() => {
            this.showSuccess('Enlace del perfil copiado al portapapeles');
        }).catch(() => {
            this.showError('Error al copiar el enlace');
        });
    }

    toggleEditMode() {
        this.isEditMode = !this.isEditMode;
        const editBtn = document.getElementById('editProfileBtn');
        
        if (this.isEditMode) {
            editBtn.innerHTML = `
                <svg class="w-4 h-4 mr-1" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>
                </svg>
                Guardar
            `;
            editBtn.classList.add('bg-green-500', 'hover:bg-green-600');
            editBtn.classList.remove('bg-white/20', 'hover:bg-white/30');
        } else {
            editBtn.innerHTML = `
                <svg class="w-4 h-4 mr-1" fill="currentColor" viewBox="0 0 20 20">
                    <path d="M13.586 3.586a2 2 0 112.828 2.828l-.793.793-2.828-2.828.793-.793zM11.379 5.793L3 14.172V17h2.828l8.38-8.379-2.83-2.828z"/>
                </svg>
                Editar
            `;
            editBtn.classList.remove('bg-green-500', 'hover:bg-green-600');
            editBtn.classList.add('bg-white/20', 'hover:bg-white/30');
        }
    }

    updatePrivacySetting(toggle) {
        const setting = toggle.closest('.flex').querySelector('span').textContent;
        const isEnabled = toggle.checked;
        
        console.log(`Privacy setting "${setting}" ${isEnabled ? 'enabled' : 'disabled'}`);
        // Aquí iría la lógica para actualizar la configuración en la base de datos
    }

    updateElement(id, value) {
        const element = document.getElementById(id);
        if (element) {
            element.textContent = value;
        }
    }

    showSuccess(message) {
        this.showNotification(message, 'success');
    }

    showError(message) {
        this.showNotification(message, 'error');
    }

    showNotification(message, type) {
        // Crear notificación temporal
        const notification = document.createElement('div');
        notification.className = `fixed top-4 right-4 p-4 rounded-lg text-white z-50 ${
            type === 'success' ? 'bg-green-500' : 'bg-red-500'
        }`;
        notification.textContent = message;
        
        document.body.appendChild(notification);
        
        setTimeout(() => {
            notification.remove();
        }, 3000);
    }

    redirectToLogin() {
        window.location.href = 'user_login.html';
    }
}

// Inicializar cuando el DOM esté listo
document.addEventListener('DOMContentLoaded', () => {
    new ProfileRedesigned();
});

// Exportar para uso global
window.ProfileRedesigned = ProfileRedesigned;
