/**
 * SISTEMA DE PERFILES Y LOGROS - Hogwarts Community Hub
 * Funcionalidades completas para gestión de perfiles, logros y compartir
 */

class ProfileSystem {
    constructor() {
        this.supabase = null;
        this.currentUser = null;
        this.currentProfile = null;
        this.isEditMode = false;
        this.init();
    }

    async init() {
        try {
            // Usar el cliente global de auth.js (conecta al backend local)
            if (window.supabaseClient) {
                this.supabase = window.supabaseClient;
            } else {
                throw new Error('Cliente de base de datos no está disponible. Asegúrate de que auth.js esté cargado.');
            }

            // Verificar usuario autenticado
            const { data: { user } } = await this.supabase.auth.getUser();
            if (user) {
                this.currentUser = user;
                await this.loadUserProfile();
                this.setupEventListeners();
                this.renderProfile();
            } else {
                this.redirectToLogin();
            }
        } catch (error) {
            console.error('Error inicializando sistema de perfiles:', error);
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
                // Crear perfil si no existe
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
            const house = localStorage.getItem('userHouse') || localStorage.getItem('selectedHouse') || 'gryffindor';
            
            const profileData = {
                id: this.currentUser.id,
                display_name: this.currentUser.user_metadata?.full_name || this.currentUser.email.split('@')[0],
                bio: 'Nuevo miembro de la comunidad mágica de Hogwarts.',
                house: house.toLowerCase(),
                avatar_url: this.currentUser.user_metadata?.avatar_url || null
            };

            const { data, error } = await this.supabase
                .from('user_profiles')
                .insert([profileData])
                .select()
                .single();

            if (error) throw error;

            this.currentProfile = data;
            
            // Asignar logro de bienvenida
            await this.awardAchievement('Bienvenido', 'Se unió a la comunidad mágica');
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

        // Botón de guardar cambios
        const saveBtn = document.getElementById('saveProfileBtn');
        if (saveBtn) {
            saveBtn.addEventListener('click', () => this.saveProfile());
        }

        // Botón de cancelar edición
        const cancelBtn = document.getElementById('cancelEditBtn');
        if (cancelBtn) {
            cancelBtn.addEventListener('click', () => this.cancelEdit());
        }

        // Botón de enviar mensaje
        const messageBtn = document.getElementById('sendMessageBtn');
        if (messageBtn) {
            messageBtn.addEventListener('click', () => this.sendMessage());
        }

        // Botón de compartir perfil
        const shareBtn = document.getElementById('shareProfileBtn');
        if (shareBtn) {
            shareBtn.addEventListener('click', () => this.shareProfile());
        }

        // Upload de avatar
        const avatarInput = document.getElementById('avatarInput');
        if (avatarInput) {
            avatarInput.addEventListener('change', (e) => this.handleAvatarUpload(e));
        }

        // Toggles de privacidad
        this.setupPrivacyToggles();
    }

    setupPrivacyToggles() {
        const toggles = [
            { id: 'privacyPublicProfile', field: 'privacy_public_profile' },
            { id: 'privacyShowStats', field: 'privacy_show_stats' },
            { id: 'privacyAllowMessages', field: 'privacy_allow_messages' }
        ];

        toggles.forEach(({ id, field }) => {
            const toggle = document.getElementById(id);
            if (toggle) {
                toggle.addEventListener('click', () => this.togglePrivacySetting(field, toggle));
            }
        });
    }

    async togglePrivacySetting(field, toggleElement) {
        try {
            const newValue = !this.currentProfile[field];
            
            const { error } = await this.supabase
                .from('user_profiles')
                .update({ [field]: newValue })
                .eq('id', this.currentUser.id);

            if (error) throw error;

            this.currentProfile[field] = newValue;
            this.updateToggleUI(toggleElement, newValue);
            this.showSuccess('Configuración de privacidad actualizada');
        } catch (error) {
            console.error('Error actualizando privacidad:', error);
            this.showError('Error al actualizar la configuración');
        }
    }

    updateToggleUI(toggle, isActive) {
        const slider = toggle.querySelector('.toggle-slider');
        if (isActive) {
            toggle.classList.add('bg-gryffindor');
            toggle.classList.remove('bg-gray-300');
            slider.classList.add('translate-x-4');
            slider.classList.remove('translate-x-0');
        } else {
            toggle.classList.remove('bg-gryffindor');
            toggle.classList.add('bg-gray-300');
            slider.classList.remove('translate-x-4');
            slider.classList.add('translate-x-0');
        }
    }

    toggleEditMode() {
        this.isEditMode = !this.isEditMode;
        this.renderProfile();
    }

    async saveProfile() {
        try {
            const formData = this.getFormData();
            
            const { error } = await this.supabase
                .from('user_profiles')
                .update(formData)
                .eq('id', this.currentUser.id);

            if (error) throw error;

            // Actualizar perfil local
            Object.assign(this.currentProfile, formData);
            
            this.isEditMode = false;
            this.renderProfile();
            this.showSuccess('Perfil actualizado correctamente');
        } catch (error) {
            console.error('Error guardando perfil:', error);
            this.showError('Error al guardar los cambios');
        }
    }

    getFormData() {
        return {
            display_name: document.getElementById('displayName')?.value || this.currentProfile.display_name,
            bio: document.getElementById('bioText')?.value || this.currentProfile.bio,
            specialization: document.getElementById('specialization')?.value || this.currentProfile.specialization,
            favorite_topics: this.getFavoriteTopics()
        };
    }

    getFavoriteTopics() {
        const checkboxes = document.querySelectorAll('input[name="topics"]:checked');
        return Array.from(checkboxes).map(cb => cb.value);
    }

    cancelEdit() {
        this.isEditMode = false;
        this.renderProfile();
    }

    async handleAvatarUpload(event) {
        const file = event.target.files[0];
        if (!file) return;

        try {
            // Validar archivo
            if (!file.type.startsWith('image/')) {
                throw new Error('Por favor selecciona una imagen válida');
            }

            if (file.size > 2 * 1024 * 1024) { // 2MB
                throw new Error('La imagen debe ser menor a 2MB');
            }

            // Subir a Supabase Storage
            const fileExt = file.name.split('.').pop();
            const fileName = `${this.currentUser.id}-${Date.now()}.${fileExt}`;

            const { data, error } = await this.supabase.storage
                .from('avatars')
                .upload(fileName, file);

            if (error) throw error;

            // Obtener URL pública
            const { data: { publicUrl } } = this.supabase.storage
                .from('avatars')
                .getPublicUrl(fileName);

            // Actualizar perfil
            await this.supabase
                .from('user_profiles')
                .update({ avatar_url: publicUrl })
                .eq('id', this.currentUser.id);

            this.currentProfile.avatar_url = publicUrl;
            this.renderProfile();
            this.showSuccess('Avatar actualizado correctamente');
        } catch (error) {
            console.error('Error subiendo avatar:', error);
            this.showError(error.message || 'Error al subir la imagen');
        }
    }

    async sendMessage() {
        if (!this.currentProfile.privacy_allow_messages) {
            this.showError('Este usuario no permite mensajes directos');
            return;
        }

        const email = this.currentUser.email;
        const subject = `Mensaje desde Hogwarts Community Hub`;
        const body = `Hola ${this.currentProfile.display_name},\n\nTe escribo desde la comunidad de Hogwarts...\n\n`;
        
        const mailtoLink = `mailto:${email}?subject=${encodeURIComponent(subject)}&body=${encodeURIComponent(body)}`;
        window.location.href = mailtoLink;
    }

    async shareProfile() {
        try {
            // Generar token de compartir
            const { data, error } = await this.supabase
                .from('profile_shares')
                .insert([{
                    user_id: this.currentUser.id,
                    share_token: this.generateShareToken(),
                    platform: 'general'
                }])
                .select()
                .single();

            if (error) throw error;

            const shareUrl = `${window.location.origin}/profile-share.html?token=${data.share_token}`;
            
            // Mostrar modal de compartir
            this.showShareModal(shareUrl);
        } catch (error) {
            console.error('Error generando enlace:', error);
            this.showError('Error al generar enlace para compartir');
        }
    }

    generateShareToken() {
        return 'profile_' + Math.random().toString(36).substr(2, 20);
    }

    showShareModal(shareUrl) {
        const modal = document.createElement('div');
        modal.className = 'fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50';
        modal.innerHTML = `
            <div class="bg-white rounded-lg p-6 max-w-md w-full mx-4">
                <h3 class="text-xl font-bold mb-4">Compartir Perfil</h3>
                <p class="text-gray-600 mb-4">Comparte tu perfil mágico con otros:</p>
                <div class="bg-gray-100 p-3 rounded mb-4">
                    <input type="text" value="${shareUrl}" readonly class="w-full bg-transparent" id="shareUrlInput">
                </div>
                <div class="flex gap-2 mb-4">
                    <button onclick="this.copyToClipboard('${shareUrl}')" class="btn-primary flex-1">Copiar</button>
                    <button onclick="this.shareToTwitter('${shareUrl}')" class="bg-blue-500 text-white px-4 py-2 rounded">Twitter</button>
                    <button onclick="this.shareToFacebook('${shareUrl}')" class="bg-blue-600 text-white px-4 py-2 rounded">Facebook</button>
                </div>
                <button class="w-full bg-gray-300 text-gray-700 py-2 rounded close-modal-btn">Cerrar</button>
            </div>
        `;

        // Agregar métodos al modal
        modal.copyToClipboard = (url) => {
            navigator.clipboard.writeText(url);
            this.showSuccess('Enlace copiado al portapapeles');
        };

        modal.shareToTwitter = (url) => {
            const text = `¡Mira mi perfil en Hogwarts Community Hub! 🏰✨`;
            window.open(`https://twitter.com/intent/tweet?text=${encodeURIComponent(text)}&url=${encodeURIComponent(url)}`);
        };

        modal.shareToFacebook = (url) => {
            window.open(`https://www.facebook.com/sharer/sharer.php?u=${encodeURIComponent(url)}`);
        };

        modal.closeModal = () => {
            if (document.body.contains(modal)) {
                document.body.removeChild(modal);
            }
        };
        
        // Cerrar modal al hacer clic fuera
        modal.addEventListener('click', (e) => {
            if (e.target === modal) {
                modal.closeModal();
            }
        });

        document.body.appendChild(modal);
        
        // Agregar event listener para el botón de cerrar
        const closeBtn = modal.querySelector('.close-modal-btn');
        if (closeBtn) {
            closeBtn.addEventListener('click', modal.closeModal);
        }
    }

    async awardAchievement(achievementName, description = '') {
        try {
            // Buscar tipo de logro
            const { data: achievementType } = await this.supabase
                .from('achievement_types')
                .select('*')
                .eq('name', achievementName)
                .single();

            if (!achievementType) return;

            // Verificar si ya tiene el logro
            const { data: existing } = await this.supabase
                .from('user_achievements')
                .select('id')
                .eq('user_id', this.currentUser.id)
                .eq('achievement_type_id', achievementType.id)
                .single();

            if (existing) return; // Ya tiene el logro

            // Asignar logro
            const { error } = await this.supabase
                .from('user_achievements')
                .insert([{
                    user_id: this.currentUser.id,
                    achievement_type_id: achievementType.id,
                    description: description
                }]);

            if (error) throw error;

            // Actualizar puntos
            await this.supabase
                .from('user_profiles')
                .update({ 
                    house_points: this.currentProfile.house_points + achievementType.points_reward 
                })
                .eq('id', this.currentUser.id);

            this.showAchievementNotification(achievementType);
        } catch (error) {
            console.error('Error asignando logro:', error);
        }
    }

    showAchievementNotification(achievement) {
        const notification = document.createElement('div');
        notification.className = 'fixed top-4 right-4 bg-gradient-to-r from-yellow-400 to-yellow-600 text-white p-4 rounded-lg shadow-lg z-50 transform translate-x-full transition-transform duration-300';
        notification.innerHTML = `
            <div class="flex items-center">
                <div class="w-8 h-8 bg-white rounded-full flex items-center justify-center mr-3">
                    <span class="text-yellow-600 text-lg">🏆</span>
                </div>
                <div>
                    <h4 class="font-bold">¡Nuevo Logro!</h4>
                    <p class="text-sm">${achievement.name}</p>
                    <p class="text-xs opacity-90">+${achievement.points_reward} puntos</p>
                </div>
            </div>
        `;

        document.body.appendChild(notification);

        // Animar entrada
        setTimeout(() => {
            notification.classList.remove('translate-x-full');
        }, 100);

        // Remover después de 5 segundos
        setTimeout(() => {
            notification.classList.add('translate-x-full');
            setTimeout(() => {
                document.body.removeChild(notification);
            }, 300);
        }, 5000);
    }

    renderProfile() {
        if (!this.currentProfile) return;

        this.updateProfileHeader();
        this.updateProfileContent();
        this.updatePrivacySettings();
        this.loadAchievements();
        this.loadActivities();
    }

    updateProfileHeader() {
        const profile = this.currentProfile;
        
        // Actualizar nombre
        const nameElement = document.getElementById('profileName');
        if (nameElement) {
            if (this.isEditMode) {
                nameElement.innerHTML = `
                    <input type="text" id="displayName" value="${profile.display_name || ''}" 
                           class="bg-white/20 text-white rounded px-3 py-1 text-3xl font-medium">
                `;
            } else {
                nameElement.textContent = profile.display_name || 'Usuario';
            }
        }

        // Actualizar casa
        const houseElement = document.getElementById('profileHouse');
        if (houseElement) {
            houseElement.textContent = (profile.house || 'gryffindor').toUpperCase();
        }

        // Actualizar especialización
        const specElement = document.getElementById('profileSpecialization');
        if (specElement) {
            if (this.isEditMode) {
                specElement.innerHTML = `
                    <input type="text" id="specialization" value="${profile.specialization || ''}" 
                           class="bg-white/20 text-white rounded px-3 py-1">
                `;
            } else {
                specElement.textContent = profile.specialization || 'Especialista en Teorías Mágicas';
            }
        }

        // Actualizar estadísticas
        document.getElementById('housePoints').textContent = profile.house_points?.toLocaleString() || '0';
        document.getElementById('reputationLevel').textContent = `Nivel ${profile.reputation_level || 1}`;
        document.getElementById('communityTime').textContent = this.calculateCommunityTime(profile.join_date);
        document.getElementById('contributionsCount').textContent = profile.contributions_count || '0';

        // Actualizar avatar
        const avatarElement = document.getElementById('profileAvatar');
        if (avatarElement && profile.avatar_url) {
            avatarElement.src = profile.avatar_url;
        }
    }

    updateProfileContent() {
        const profile = this.currentProfile;

        // Actualizar biografía
        const bioElement = document.getElementById('profileBio');
        if (bioElement) {
            if (this.isEditMode) {
                bioElement.innerHTML = `
                    <textarea id="bioText" rows="4" 
                              class="w-full p-3 border rounded-lg resize-none"
                              placeholder="Cuéntanos tu historia mágica...">${profile.bio || ''}</textarea>
                `;
            } else {
                bioElement.innerHTML = `<p class="text-text-secondary leading-relaxed">${profile.bio || 'Este usuario aún no ha compartido su historia mágica.'}</p>`;
            }
        }

        // Mostrar/ocultar botones de edición
        this.toggleEditButtons();
    }

    toggleEditButtons() {
        const editBtn = document.getElementById('editProfileBtn');
        const saveBtn = document.getElementById('saveProfileBtn');
        const cancelBtn = document.getElementById('cancelEditBtn');

        if (this.isEditMode) {
            editBtn?.classList.add('hidden');
            saveBtn?.classList.remove('hidden');
            cancelBtn?.classList.remove('hidden');
        } else {
            editBtn?.classList.remove('hidden');
            saveBtn?.classList.add('hidden');
            cancelBtn?.classList.add('hidden');
        }
    }

    updatePrivacySettings() {
        const settings = [
            { id: 'privacyPublicProfile', value: this.currentProfile.privacy_public_profile },
            { id: 'privacyShowStats', value: this.currentProfile.privacy_show_stats },
            { id: 'privacyAllowMessages', value: this.currentProfile.privacy_allow_messages }
        ];

        settings.forEach(({ id, value }) => {
            const toggle = document.getElementById(id);
            if (toggle) {
                this.updateToggleUI(toggle, value);
            }
        });

        // Aplicar efectos de privacidad en la interfaz
        this.applyPrivacyEffects();
    }

    applyPrivacyEffects() {
        // Ocultar/mostrar estadísticas según configuración
        const statsElements = document.querySelectorAll('.privacy-stats');
        statsElements.forEach(element => {
            if (this.currentProfile.privacy_show_stats) {
                element.classList.remove('hidden');
            } else {
                element.classList.add('hidden');
            }
        });

        // Actualizar estado del botón de mensaje
        const messageBtn = document.getElementById('sendMessageBtn');
        const messageTooltip = document.getElementById('messageTooltip');
        
        if (messageBtn) {
            if (this.currentProfile.privacy_allow_messages) {
                messageBtn.disabled = false;
                messageBtn.classList.remove('opacity-50', 'cursor-not-allowed');
                messageBtn.classList.add('hover:bg-primary-600');
                if (messageTooltip) {
                    messageTooltip.textContent = 'Enviar mensaje';
                }
            } else {
                messageBtn.disabled = true;
                messageBtn.classList.add('opacity-50', 'cursor-not-allowed');
                messageBtn.classList.remove('hover:bg-primary-600');
                if (messageTooltip) {
                    messageTooltip.textContent = 'Usuario no permite mensajes';
                }
            }
        }

        // Mostrar indicadores de privacidad
        this.updatePrivacyIndicators();
    }

    updatePrivacyIndicators() {
        // Indicador de perfil público/privado
        const publicIndicator = document.getElementById('publicProfileIndicator');
        if (publicIndicator) {
            if (this.currentProfile.privacy_public_profile) {
                publicIndicator.innerHTML = `
                    <div class="flex items-center text-green-600 text-sm">
                        <svg class="w-4 h-4 mr-1" fill="currentColor" viewBox="0 0 20 20">
                            <path d="M10 12a2 2 0 100-4 2 2 0 000 4z"/>
                            <path fill-rule="evenodd" d="M.458 10C1.732 5.943 5.522 3 10 3s8.268 2.943 9.542 7c-1.274 4.057-5.064 7-9.542 7S1.732 14.057.458 10zM14 10a4 4 0 11-8 0 4 4 0 018 0z" clip-rule="evenodd"/>
                        </svg>
                        Perfil Público
                    </div>
                `;
            } else {
                publicIndicator.innerHTML = `
                    <div class="flex items-center text-gray-500 text-sm">
                        <svg class="w-4 h-4 mr-1" fill="currentColor" viewBox="0 0 20 20">
                            <path fill-rule="evenodd" d="M3.707 2.293a1 1 0 00-1.414 1.414l14 14a1 1 0 001.414-1.414l-1.473-1.473A10.014 10.014 0 0019.542 10C18.268 5.943 14.478 3 10 3a9.958 9.958 0 00-4.512 1.074l-1.78-1.781zm4.261 4.26l1.514 1.515a2.003 2.003 0 012.45 2.45l1.514 1.514a4 4 0 00-5.478-5.478z" clip-rule="evenodd"/>
                            <path d="M12.454 16.697L9.75 13.992a4 4 0 01-3.742-3.741L2.335 6.578A9.98 9.98 0 00.458 10c1.274 4.057 5.065 7 9.542 7 .847 0 1.669-.105 2.454-.303z"/>
                        </svg>
                        Perfil Privado
                    </div>
                `;
            }
        }
    }

    async loadAchievements() {
        try {
            await this.ensureBaselineAchievements();

            // Force an automatic check first so newly triggered achievements appear immediately
            await this.supabase.rpc('check_and_award_achievements', {
                p_user_id: this.currentUser.id
            });

            const { data: achievements, error } = await this.supabase
                .from('user_achievements')
                .select('*')
                .eq('user_id', this.currentUser.id)
                .order('awarded_at', { ascending: false });

            if (error) throw error;

            const achievementRows = achievements || [];
            if (achievementRows.length === 0) {
                this.renderAchievements([]);
                return;
            }

            const typeIds = [...new Set(achievementRows.map(a => a.achievement_type_id).filter(Boolean))];
            const { data: types, error: typesError } = await this.supabase
                .from('achievement_types')
                .select('id, name, description, icon, points_reward, category')
                .in('id', typeIds);

            if (typesError) throw typesError;

            const typesMap = new Map((types || []).map(t => [t.id, t]));
            const enrichedAchievements = achievementRows.map(achievement => ({
                ...achievement,
                achievement_types: typesMap.get(achievement.achievement_type_id) || null
            }));

            this.renderAchievements(enrichedAchievements);
        } catch (error) {
            console.error('Error cargando logros:', error);
        }
    }

    async ensureBaselineAchievements() {
        try {
            const { data: existing } = await this.supabase
                .from('user_achievements')
                .select('id')
                .eq('user_id', this.currentUser.id)
                .limit(1);

            if (Array.isArray(existing) && existing.length > 0) {
                return;
            }

            const { data: welcomeType, error: welcomeError } = await this.supabase
                .from('achievement_types')
                .select('id, points_reward, name')
                .eq('trigger_condition', 'user_registration')
                .maybeSingle();

            if (welcomeError || !welcomeType) {
                return;
            }

            const { error: insertError } = await this.supabase
                .from('user_achievements')
                .insert({
                    user_id: this.currentUser.id,
                    achievement_type_id: welcomeType.id,
                    awarded_by: this.currentUser.id,
                    reason: 'Logro base automático de bienvenida'
                });

            if (insertError && insertError.code !== '23505') {
                // Ignore duplicate errors; log only unexpected ones
                console.warn('No se pudo insertar logro base:', insertError);
                return;
            }

            const points = Number(welcomeType.points_reward) || 0;
            if (points > 0) {
                await this.supabase.rpc('update_user_stat', {
                    p_user_id: this.currentUser.id,
                    p_stat_name: 'trigger_user_registration',
                    p_increment: 1
                });
            }
        } catch (error) {
            console.warn('ensureBaselineAchievements falló:', error);
        }
    }

    renderAchievements(achievements) {
        const container = document.getElementById('achievementsContainer');
        const achievementCount = document.getElementById('achievementCount');
        if (!container) return;

        if (achievementCount) {
            achievementCount.textContent = `${achievements.length} desbloqueados`;
        }

        if (!achievements || achievements.length === 0) {
            container.innerHTML = `
                <div class="col-span-full text-center py-12">
                    <div class="inline-flex items-center justify-center w-20 h-20 bg-gray-800 rounded-full mb-4">
                        <span class="text-3xl opacity-50">🏆</span>
                    </div>
                    <p class="text-gray-500 text-sm">Aún no has desbloqueado ningún logro</p>
                    <p class="text-gray-600 text-xs mt-2">¡Explora la comunidad para ganar tus primeros logros!</p>
                </div>
            `;
            return;
        }

        const achievementHTML = achievements.map((achievement, index) => {
            const type = achievement.achievement_types || {};
            const icon = type.icon || '🏆';
            const name = type.name || 'Logro';
            const description = type.description || '';
            const points = type.points_reward || 0;
            const category = type.category || 'general';
            const awardedDate = new Date(achievement.awarded_at).toLocaleDateString('es-ES', {
                day: 'numeric',
                month: 'short'
            });
            
            // Asignar colores según la categoría
            const categoryColors = {
                'primer_ano': { bg: 'from-blue-500 to-blue-700', accent: 'text-blue-400', border: 'border-blue-500' },
                'vida_social_hogwarts': { bg: 'from-purple-500 to-purple-700', accent: 'text-purple-400', border: 'border-purple-500' },
                'lealtad_casa': { bg: 'from-red-500 to-red-700', accent: 'text-red-400', border: 'border-red-500' },
                'maestria_academica': { bg: 'from-green-500 to-green-700', accent: 'text-green-400', border: 'border-green-500' },
                'exploracion_magica': { bg: 'from-yellow-500 to-yellow-700', accent: 'text-yellow-400', border: 'border-yellow-500' },
                'eventos_especiales': { bg: 'from-pink-500 to-pink-700', accent: 'text-pink-400', border: 'border-pink-500' },
                'test': { bg: 'from-gray-500 to-gray-700', accent: 'text-gray-400', border: 'border-gray-500' },
                'general': { bg: 'from-indigo-500 to-indigo-700', accent: 'text-indigo-400', border: 'border-indigo-500' }
            };
            
            const colors = categoryColors[category] || categoryColors['general'];
            
            // Truncar descripción si es muy larga
            const shortDescription = description.length > 80 ? description.substring(0, 80) + '...' : description;
            
            // Añadir animación de entrada escalonada
            const animationDelay = index * 100;
            
            return `
                <div class="achievement-card relative group cursor-pointer" style="animation-delay: ${animationDelay}ms" title="${description}">
                    <!-- Tarjeta principal -->
                    <div class="relative bg-gray-800 hover:bg-gray-750 rounded-xl border-2 ${colors.border} transition-all duration-300 hover:scale-[1.02] hover:shadow-xl overflow-hidden">
                        <!-- Header con icono -->
                        <div class="bg-gradient-to-r ${colors.bg} p-4 text-center">
                            <div class="w-12 h-12 mx-auto bg-white/20 rounded-full flex items-center justify-center mb-2">
                                <span class="text-2xl">${icon}</span>
                            </div>
                            <h3 class="font-bold text-white text-sm leading-tight">${name}</h3>
                        </div>
                        
                        <!-- Contenido -->
                        <div class="p-4 space-y-3">
                            <!-- Descripción -->
                            <p class="text-gray-300 text-xs leading-relaxed h-8 overflow-hidden">${shortDescription}</p>
                            
                            <!-- Puntos y fecha -->
                            <div class="flex items-center justify-between pt-2 border-t border-gray-700">
                                <div class="flex items-center space-x-1">
                                    <span class="text-yellow-400 text-sm font-bold">+${points}</span>
                                    <span class="text-yellow-400 text-xs">pts</span>
                                </div>
                                <span class="text-gray-500 text-xs">${awardedDate}</span>
                            </div>
                        </div>
                        
                        <!-- Indicador de rareza -->
                        ${points >= 50 ? `
                            <div class="absolute top-2 right-2">
                                <div class="w-6 h-6 bg-gradient-to-br from-yellow-400 to-yellow-600 rounded-full flex items-center justify-center shadow-lg">
                                    <span class="text-xs">⭐</span>
                                </div>
                            </div>
                        ` : ''}
                        
                        <!-- Brillo hover -->
                        <div class="absolute inset-0 bg-gradient-to-r ${colors.bg} opacity-0 group-hover:opacity-10 transition-opacity duration-300 pointer-events-none"></div>
                    </div>
                </div>
            `;
        }).join('');

        // Agregar estilos CSS para las animaciones y grid
        const styles = `
            <style>
                @keyframes fadeInUp {
                    from {
                        opacity: 0;
                        transform: translateY(20px);
                    }
                    to {
                        opacity: 1;
                        transform: translateY(0);
                    }
                }
                
                .achievement-card {
                    animation: fadeInUp 0.6s ease-out forwards;
                    opacity: 0;
                }
                
                /* Asegurar grid responsive para las cartas */
                #achievementsContainer {
                    display: grid;
                    grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
                    gap: 1rem;
                }
                
                @media (max-width: 640px) {
                    #achievementsContainer {
                        grid-template-columns: 1fr;
                    }
                }
            </style>
        `;

        container.innerHTML = styles + achievementHTML;
    }

    getAchievementIcon(iconName) {
        const icons = {
            star: '<svg class="w-full h-full" fill="currentColor" viewBox="0 0 20 20"><path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"/></svg>',
            heart: '<svg class="w-full h-full" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clip-rule="evenodd"/></svg>',
            chat: '<svg class="w-full h-full" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M18 10c0 3.866-3.582 7-8 7a8.841 8.841 0 01-4.083-.98L2 17l1.338-3.123C2.493 12.767 2 11.434 2 10c0-3.866 3.582-7 8-7s8 3.134 8 7z" clip-rule="evenodd"/></svg>'
        };
        return icons[iconName] || icons.star;
    }

    async loadActivities() {
        try {
            const { data: activities, error } = await this.supabase
                .from('user_activities')
                .select('*')
                .eq('user_id', this.currentUser.id)
                .order('created_at', { ascending: false })
                .limit(10);

            if (error) throw error;

            this.renderActivities(activities || []);
        } catch (error) {
            console.error('Error cargando actividades:', error);
        }
    }

    renderActivities(activities) {
        const container = document.getElementById('activitiesContainer');
        if (!container) return;

        if (activities.length === 0) {
            container.innerHTML = '<p class="text-text-secondary text-center py-8">Aún no hay actividades registradas.</p>';
            return;
        }

        const activitiesHTML = activities.map(activity => `
            <div class="flex items-start space-x-4">
                <div class="flex-shrink-0 w-10 h-10 bg-primary rounded-full flex items-center justify-center">
                    ${this.getActivityIcon(activity.activity_type)}
                </div>
                <div class="flex-1">
                    <div class="flex items-center justify-between mb-1">
                        <h3 class="font-cta font-semibold text-text-primary">${activity.title}</h3>
                        <span class="text-text-secondary text-sm">${this.formatTimeAgo(activity.created_at)}</span>
                    </div>
                    <p class="text-text-secondary text-sm">${activity.description}</p>
                    ${activity.points_earned > 0 ? `<span class="text-success text-xs">+${activity.points_earned} puntos</span>` : ''}
                </div>
            </div>
        `).join('');

        container.innerHTML = activitiesHTML;
    }

    getActivityIcon(activityType) {
        return '<svg class="w-5 h-5 text-white" fill="currentColor" viewBox="0 0 20 20"><path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"/></svg>';
    }

    calculateCommunityTime(joinDate) {
        if (!joinDate) return '0 días';
        
        const now = new Date();
        const joined = new Date(joinDate);
        const diffTime = Math.abs(now - joined);
        const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
        
        if (diffDays < 30) return `${diffDays} días`;
        if (diffDays < 365) return `${Math.floor(diffDays / 30)} meses`;
        return `${Math.floor(diffDays / 365)} años`;
    }

    formatTimeAgo(dateString) {
        const now = new Date();
        const date = new Date(dateString);
        const diffTime = Math.abs(now - date);
        const diffHours = Math.floor(diffTime / (1000 * 60 * 60));
        const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));
        
        if (diffHours < 1) return 'Hace unos minutos';
        if (diffHours < 24) return `Hace ${diffHours} horas`;
        if (diffDays < 7) return `Hace ${diffDays} días`;
        return date.toLocaleDateString('es-ES');
    }

    redirectToLogin() {
        window.location.href = 'user_login.html';
    }

    showSuccess(message) {
        this.showNotification(message, 'success');
    }

    showError(message) {
        this.showNotification(message, 'error');
    }

    showNotification(message, type = 'info') {
        const notification = document.createElement('div');
        const bgColor = type === 'success' ? 'bg-green-500' : type === 'error' ? 'bg-red-500' : 'bg-blue-500';
        
        notification.className = `fixed top-4 right-4 ${bgColor} text-white p-4 rounded-lg shadow-lg z-50 transform translate-x-full transition-transform duration-300`;
        notification.textContent = message;

        document.body.appendChild(notification);

        setTimeout(() => {
            notification.classList.remove('translate-x-full');
        }, 100);

        setTimeout(() => {
            notification.classList.add('translate-x-full');
            setTimeout(() => {
                if (document.body.contains(notification)) {
                    document.body.removeChild(notification);
                }
            }, 300);
        }, 3000);
    }
}

// Inicializar sistema cuando se carga la página
document.addEventListener('DOMContentLoaded', () => {
    window.profileSystem = new ProfileSystem();
});
