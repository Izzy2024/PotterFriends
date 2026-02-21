/**
 * PANEL DE ADMINISTRACIÓN PARA JEFES DE CASA
 * Hogwarts Community Hub - Sistema de gestión de logros y casa
 */

class HouseHeadAdmin {
    constructor() {
        // Usar el cliente global de auth.js (conecta al backend local)
        this.supabase = window.supabaseClient;
        
        if (!this.supabase) {
            console.error('❌ Cliente de base de datos no disponible. Asegúrate de que auth.js esté cargado.');
        }
        
        this.currentUser = null;
        this.currentHouse = null;
        this.houseMembers = [];
        this.achievementTypes = [];
        
        // No llamar a init() aquí, esperar a que el DOM esté listo
    }
    
    // Método para inicializar después de que el DOM esté cargado
    async initialize() {
        this.init();
    }

    async init() {
        try {
            await this.checkAuth();
            await this.loadHouseData();
            await this.loadAchievementTypes();
            this.setupEventListeners();
            await this.loadDashboardData();
            
            // Ocultar overlay de carga cuando todo esté listo
            this.hideLoadingOverlay();
        } catch (error) {
            console.error('Error inicializando panel de administración:', error);
            this.showError('Error al cargar el panel de administración');
            this.hideLoadingOverlay();
        }
    }

    hideLoadingOverlay() {
        // Buscar el overlay de carga por ID
        let overlay = document.getElementById('loadingOverlay');
        
        if (overlay) {
            console.log('🔄 Hiding loading overlay...', overlay);
            overlay.style.opacity = '0';
            overlay.style.visibility = 'hidden';
            overlay.style.display = 'none';
            overlay.remove();
            console.log('✅ Loading overlay hidden and removed');
        } else {
            console.log('❌ Loading overlay element not found');
        }
    }

    async checkAuth() {
        const { data: { user } } = await this.supabase.auth.getUser();
        if (!user) {
            window.location.href = 'user_login.html';
            return;
        }

        // Verificar que es jefe de casa - revisar ambas tablas
        let profile = null;
        let profileSource = '';

        // Intentar user_profiles primero
        const { data: userProfile, error: userProfileError } = await this.supabase
            .from('user_profiles')
            .select('*')
            .eq('id', user.id)
            .single();

        if (!userProfileError && userProfile) {
            profile = userProfile;
            profileSource = 'user_profiles';
            console.log('🔍 Profile from user_profiles:', profile);
        }

        // Si no tiene rol válido en user_profiles, intentar profiles
        if (!profile || !profile.role || profile.role === 'student') {
            const { data: profilesData, error: profilesError } = await this.supabase
                .from('profiles')
                .select('*')
                .eq('id', user.id)
                .single();

            if (!profilesError && profilesData && profilesData.role) {
                profile = profilesData;
                profileSource = 'profiles';
                console.log('🔍 Profile from profiles table:', profile);
            }
        }

        // Verificar permisos - revisar role y is_house_head
        const isHouseHead = profile && (
            profile.role === 'house_head' ||
            profile.role === 'admin' ||
            profile.is_house_head === true
        );

        if (!isHouseHead) {
            console.log('❌ Access denied. Profile:', profile);
            this.showError('No tienes permisos para acceder a este panel');
            setTimeout(() => {
                window.location.href = 'homepage_sorting_hat_experience.html';
            }, 3000);
            return;
        }

        console.log(`✅ Access granted! Source: ${profileSource}, Role: ${profile.role}, is_house_head: ${profile.is_house_head}`);

        this.currentUser = profile;
        this.currentHouse = profile.house || 'slytherin'; // Fallback a slytherin si no hay casa
        
        console.log('🏠 Current house set to:', this.currentHouse);
        
        // Actualizar UI con información del usuario
        this.updateUserInfo();
    }

    updateUserInfo() {
        // Verificar que los elementos existen antes de actualizarlos
        const adminName = document.getElementById('adminName');
        const houseName = document.getElementById('houseName');
        const houseTitle = document.getElementById('houseTitle');
        const adminRole = document.getElementById('adminRole');
        
        console.log('🔍 Updating user info:', this.currentUser);
        console.log('🔍 Elements found:', { adminName: !!adminName, houseName: !!houseName, houseTitle: !!houseTitle, adminRole: !!adminRole });
        
        if (adminName) {
            const name = this.currentUser.display_name || this.currentUser.wizard_name || this.currentUser.first_name || 'Jefe de Casa';
            adminName.textContent = name;
            console.log('✅ Admin name set to:', name);
        }
        
        if (houseName) {
            const house = this.currentUser.house ? this.currentUser.house.charAt(0).toUpperCase() + this.currentUser.house.slice(1) : 'Casa';
            houseName.textContent = house;
            console.log('✅ House name set to:', house);
        }
        
        if (houseTitle) {
            const house = this.currentUser.house ? this.currentUser.house.toUpperCase() : 'CASA';
            houseTitle.textContent = `Casa ${house}`;
            console.log('✅ House title set to:', `Casa ${house}`);
        }
        
        if (adminRole) {
            const role = this.currentUser.role === 'admin' ? 'ADMINISTRADOR' : 'JEFE DE CASA';
            adminRole.textContent = role;
            console.log('✅ Admin role set to:', role);
        }
        
        // Aplicar colores de casa
        this.applyHouseColors();
        
        // Aplicar colores con delay adicional para asegurar que se vean
        setTimeout(() => {
            this.applyHouseColors();
        }, 500);
    }

    applyHouseColors() {
        if (!this.currentHouse) return;
        
        const houseHeader = document.getElementById('houseHeader');
        const houseColors = {
            gryffindor: 'linear-gradient(135deg, #b91c1c, #991b1b, #7f1d1d)',
            hufflepuff: 'linear-gradient(135deg, #d97706, #b45309, #92400e)',
            ravenclaw: 'linear-gradient(135deg, #1d4ed8, #1e40af, #1e3a8a)',
            slytherin: 'linear-gradient(135deg, #15803d, #166534, #14532d)'
        };
        
        if (houseHeader && houseColors[this.currentHouse]) {
            // Aplicar el gradiente directamente como estilo CSS
            houseHeader.style.background = houseColors[this.currentHouse];
            console.log(`🎨 Applied ${this.currentHouse} colors to header`);
        }
    }

    async loadHouseData() {
        try {
            // Cargar miembros de la casa
            const { data: members } = await this.supabase
                .from('user_profiles')
                .select('*')
                .eq('house', this.currentHouse)
                .order('house_points', { ascending: false });

            this.houseMembers = members || [];
            this.renderHouseMembers();
            console.log('✅ House members loaded:', this.houseMembers.length);
        } catch (error) {
            console.error('Error cargando datos de la casa:', error);
        }
    }

    async loadAchievementTypes() {
        try {
            const { data: types } = await this.supabase
                .from('achievement_types')
                .select('*')
                .order('category, points_reward', { ascending: false });

            this.achievementTypes = types || [];
            console.log('✅ Achievement types loaded:', this.achievementTypes.length);
            
            // Si no hay logros, mostrar mensaje para configurar la base de datos
            if (this.achievementTypes.length === 0) {
                console.warn('⚠️ No achievement types found. Please run the SQL setup script.');
                this.showError('No se encontraron tipos de logros. Ejecuta el script SQL de configuración.');
            }
        } catch (error) {
            console.error('Error cargando tipos de logros:', error);
            this.showError('Error al cargar los tipos de logros. Verifica que las tablas estén creadas.');
        }
    }

    renderHouseMembers() {
        const container = document.getElementById('houseMembersContainer');
        if (!container) return;

        const membersHTML = this.houseMembers.map(member => `
            <div class="flex items-center justify-between p-3 bg-background rounded-lg hover:bg-primary/5 transition-colors">
                <div class="flex items-center space-x-3">
                    <img src="${member.avatar_url || 'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?auto=compress&cs=tinysrgb&w=100'}" 
                         alt="${member.display_name}" 
                         class="w-8 h-8 rounded-full object-cover">
                    <div>
                        <div class="font-medium text-text-primary">${member.display_name}</div>
                        <div class="text-sm text-text-secondary">${member.house_points} puntos</div>
                    </div>
                </div>
                <div class="flex items-center space-x-2">
                    <button onclick="houseAdmin.openAssignAchievementModal('${member.id}')" 
                            class="admin-action-btn assign text-xs">
                        Asignar Logro
                    </button>
                    <button onclick="houseAdmin.viewMemberProfile('${member.id}')" 
                            class="admin-action-btn view text-xs">
                        Ver Perfil
                    </button>
                </div>
            </div>
        `).join('');

        container.innerHTML = membersHTML;
    }

    async loadDashboardData() {
        try {
            // Cargar estadísticas básicas primero
            const { data: members } = await this.supabase
                .from('user_profiles')
                .select('house_points')
                .eq('house', this.currentHouse);

            const totalMembers = members ? members.length : 0;
            const totalPoints = members ? members.reduce((sum, member) => sum + (member.house_points || 0), 0) : 0;

            // Actualizar elementos si existen
            const totalMembersEl = document.getElementById('totalMembers');
            const totalPointsEl = document.getElementById('totalPoints');
            const activeMembersEl = document.getElementById('activeMembers');
            const monthlyAchievementsEl = document.getElementById('monthlyAchievements');

            if (totalMembersEl) totalMembersEl.textContent = totalMembers;
            if (totalPointsEl) totalPointsEl.textContent = totalPoints;
            if (activeMembersEl) activeMembersEl.textContent = Math.floor(totalMembers * 0.7); // Estimación
            if (monthlyAchievementsEl) monthlyAchievementsEl.textContent = 0;

            console.log('✅ Dashboard data loaded:', { totalMembers, totalPoints });

            // Cargar actividad reciente
            await this.loadRecentActivity();
        } catch (error) {
            console.error('Error cargando estadísticas:', error);
        }
    }

    async loadRecentActivity() {
        try {
            // Por ahora mostrar mensaje simple hasta que tengamos datos de logros
            const container = document.getElementById('recentActivityContainer');
            if (container && this.currentHouse) {
                container.innerHTML = `
                    <div class="text-center text-text-secondary py-8">
                        <p>📊 Panel de administración cargado correctamente</p>
                        <p class="text-sm mt-2">Casa: ${this.currentHouse.toUpperCase()}</p>
                        <p class="text-sm">Miembros: ${this.houseMembers.length}</p>
                    </div>
                `;
            } else if (container) {
                container.innerHTML = `
                    <div class="text-center text-text-secondary py-8">
                        <p>📊 Panel de administración cargado</p>
                        <p class="text-sm mt-2">Casa: No definida</p>
                        <p class="text-sm">Miembros: ${this.houseMembers.length}</p>
                    </div>
                `;
            }
            console.log('✅ Recent activity placeholder loaded');
        
        // Forzar ocultar overlay después de cargar todo
        setTimeout(() => {
            console.log('🔄 Attempting to hide overlay...');
            this.hideLoadingOverlay();
        }, 100);
        
        // Backup: ocultar overlay directamente
        setTimeout(() => {
            const overlay = document.getElementById('loadingOverlay');
            if (overlay && overlay.style.display !== 'none') {
                console.log('🔄 Force hiding overlay with backup method...');
                overlay.remove();
                console.log('✅ Overlay removed completely');
            }
        }, 1000);
        } catch (error) {
            console.error('Error cargando actividad reciente:', error);
        }
    }

    renderRecentActivity(activities) {
        const container = document.getElementById('recentActivityContainer');
        if (!container) return;

        const activitiesHTML = activities.map(activity => `
            <div class="flex items-start space-x-4">
                <div class="w-10 h-10 bg-gradient-to-br from-yellow-400 to-yellow-600 rounded-full flex items-center justify-center">
                    <span class="text-white text-lg">${activity.achievement_types?.icon || '🏆'}</span>
                </div>
                <div class="flex-1">
                    <p class="text-sm font-medium text-text-primary">
                        ${activity.user_profiles.display_name} obtuvo "${activity.achievement_types?.name}"
                    </p>
                    <p class="text-xs text-text-secondary">
                        ${new Date(activity.awarded_at).toLocaleDateString('es-ES')}
                    </p>
                </div>
            </div>
        `).join('');

        container.innerHTML = activitiesHTML || '<p class="text-text-secondary text-center">No hay actividad reciente</p>';
    }

    setupEventListeners() {
        // Acciones rápidas
        document.getElementById('quickAssignAchievement')?.addEventListener('click', () => {
            this.openAssignAchievementModal();
        });

        // Búsqueda de miembros
        document.getElementById('memberSearch')?.addEventListener('input', (e) => {
            this.filterMembers(e.target.value);
        });

        // Cerrar modales al hacer clic fuera
        document.addEventListener('click', (e) => {
            if (e.target.classList.contains('admin-modal')) {
                this.closeModal(e.target.id);
            }
        });
    }

    filterMembers(searchTerm) {
        const filteredMembers = this.houseMembers.filter(member =>
            member.display_name.toLowerCase().includes(searchTerm.toLowerCase())
        );
        
        // Temporalmente actualizar la lista renderizada
        const container = document.getElementById('houseMembersContainer');
        if (!container) return;

        const membersHTML = filteredMembers.map(member => `
            <div class="flex items-center justify-between p-3 bg-background rounded-lg hover:bg-primary/5 transition-colors">
                <div class="flex items-center space-x-3">
                    <img src="${member.avatar_url || 'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?auto=compress&cs=tinysrgb&w=100'}" 
                         alt="${member.display_name}" 
                         class="w-8 h-8 rounded-full object-cover">
                    <div>
                        <div class="font-medium text-text-primary">${member.display_name}</div>
                        <div class="text-sm text-text-secondary">${member.house_points} puntos</div>
                    </div>
                </div>
                <div class="flex items-center space-x-2">
                    <button onclick="houseAdmin.openAssignAchievementModal('${member.id}')" 
                            class="admin-action-btn assign text-xs">
                        Asignar Logro
                    </button>
                    <button onclick="houseAdmin.viewMemberProfile('${member.id}')" 
                            class="admin-action-btn view text-xs">
                        Ver Perfil
                    </button>
                </div>
            </div>
        `).join('');

        container.innerHTML = membersHTML;
    }

    openAssignAchievementModal(userId = null) {
        const modal = this.createAssignAchievementModal(userId);
        document.body.appendChild(modal);
        
        // Animar entrada
        setTimeout(() => {
            modal.classList.add('opacity-100');
            modal.querySelector('.admin-modal-content').classList.add('scale-100');
        }, 10);
    }

    createAssignAchievementModal(userId) {
        const modal = document.createElement('div');
        modal.id = 'assignAchievementModal';
        modal.className = 'admin-modal fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 opacity-0 transition-opacity duration-300';

        const selectedMember = userId ? this.houseMembers.find(m => m.id === userId) : null;

        modal.innerHTML = `
            <div class="admin-modal-content transform scale-95 transition-transform duration-300 max-w-2xl w-full mx-4">
                <div class="admin-modal-header">
                    <h2 class="text-xl font-bold">Asignar Logro</h2>
                    <button onclick="houseAdmin.closeModal('assignAchievementModal')" 
                            class="text-white hover:text-gray-300">
                        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
                        </svg>
                    </button>
                </div>
                <div class="admin-modal-body">
                    <form id="assignAchievementForm">
                        <div class="admin-form-group">
                            <label class="admin-form-label">Estudiante</label>
                            <select id="selectedStudent" class="admin-form-select" ${userId ? 'disabled' : ''}>
                                ${userId ? 
                                    `<option value="${userId}">${selectedMember?.display_name}</option>` :
                                    `<option value="">Seleccionar estudiante...</option>
                                     ${this.houseMembers.map(member => 
                                        `<option value="${member.id}">${member.display_name} (${member.house_points} pts)</option>`
                                     ).join('')}`
                                }
                            </select>
                        </div>

                        <div class="admin-form-group">
                            <label class="admin-form-label">Logro</label>
                            ${this.achievementTypes.length > 0 ? `
                                <div class="admin-achievement-selector">
                                    ${this.groupAchievementsByCategory().map(categoryGroup => `
                                        <div class="achievement-category mb-4">
                                            <h4 class="text-sm font-semibold text-gray-600 mb-2 capitalize">${this.getCategoryDisplayName(categoryGroup.category)}</h4>
                                            <div class="grid grid-cols-1 md:grid-cols-2 gap-2">
                                                ${categoryGroup.achievements.map(achievement => `
                                                    <div class="admin-achievement-option" data-achievement-id="${achievement.id}">
                                                        <div class="admin-achievement-icon">${achievement.icon || '🏆'}</div>
                                                        <div class="admin-achievement-name">${achievement.name}</div>
                                                        <div class="admin-achievement-points">+${achievement.points_reward} pts</div>
                                                        ${achievement.description ? `<div class="text-xs text-gray-500 mt-1">${achievement.description}</div>` : ''}
                                                    </div>
                                                `).join('')}
                                            </div>
                                        </div>
                                    `).join('')}
                                </div>
                            ` : `
                                <div class="text-center p-8 bg-gray-50 rounded-lg">
                                    <p class="text-gray-600 mb-4">⚠️ No hay logros configurados</p>
                                    <p class="text-sm text-gray-500">Ejecuta el script SQL para crear los logros temáticos de Harry Potter</p>
                                </div>
                            `}
                        </div>

                        <div class="admin-form-group">
                            <label class="admin-form-label">Razón (opcional)</label>
                            <textarea id="achievementReason" class="admin-form-textarea" 
                                      placeholder="Describe por qué merece este logro..."></textarea>
                        </div>

                        <div class="flex justify-end space-x-4 mt-6">
                            <button type="button" onclick="houseAdmin.closeModal('assignAchievementModal')" 
                                    class="px-4 py-2 text-gray-600 hover:text-gray-800">
                                Cancelar
                            </button>
                            <button type="submit" class="btn-primary">
                                Asignar Logro
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        `;

        // Configurar eventos del modal
        this.setupModalEvents(modal);
        
        return modal;
    }

    setupModalEvents(modal) {
        // Selección de logros
        modal.querySelectorAll('.admin-achievement-option').forEach(option => {
            option.addEventListener('click', () => {
                modal.querySelectorAll('.admin-achievement-option').forEach(opt => 
                    opt.classList.remove('selected'));
                option.classList.add('selected');
            });
        });

        // Envío del formulario
        modal.querySelector('#assignAchievementForm').addEventListener('submit', (e) => {
            e.preventDefault();
            this.handleAssignAchievement(modal);
        });
    }

    async handleAssignAchievement(modal) {
        const studentId = modal.querySelector('#selectedStudent').value;
        const selectedAchievement = modal.querySelector('.admin-achievement-option.selected');
        const reason = modal.querySelector('#achievementReason').value;

        if (!studentId || !selectedAchievement) {
            this.showError('Por favor selecciona un estudiante y un logro');
            return;
        }

        const achievementTypeId = selectedAchievement.dataset.achievementId;
        
        const submitBtn = modal.querySelector('button[type="submit"]');
        const originalText = submitBtn.textContent;
        
        try {
            // Mostrar loading
            submitBtn.innerHTML = '<div class="admin-loading"><div class="admin-spinner"></div> Asignando...</div>';
            submitBtn.disabled = true;

            // Intentar usar la función RPC primero
            let success = false;
            try {
                const { data, error } = await this.supabase
                    .rpc('assign_achievement_to_user', {
                        p_user_id: studentId,
                        p_achievement_type_id: parseInt(achievementTypeId),
                        p_reason: reason
                    });

                if (!error) {
                    success = true;
                    console.log('✅ Logro asignado usando RPC:', data);
                }
            } catch (rpcError) {
                console.log('⚠️ RPC no disponible, usando método directo:', rpcError.message);
            }

            // Si RPC falla, usar método directo
            if (!success) {
                // Insertar directamente en la tabla user_achievements
                const { data: insertData, error: insertError } = await this.supabase
                    .from('user_achievements')
                    .insert({
                        user_id: studentId,
                        achievement_type_id: parseInt(achievementTypeId),
                        awarded_by: this.currentUser.id,
                        reason: reason || null,
                        awarded_at: new Date().toISOString()
                    });

                if (insertError) throw insertError;

                // Obtener los puntos del logro para actualizar el usuario
                const achievementType = this.achievementTypes.find(a => a.id == achievementTypeId);
                const pointsToAdd = achievementType ? achievementType.points_reward : 0;

                if (pointsToAdd > 0) {
                    // Actualizar puntos del usuario
                    const { error: updateError } = await this.supabase
                        .from('user_profiles')
                        .update({
                            house_points: this.supabase.raw(`house_points + ${pointsToAdd}`)
                        })
                        .eq('id', studentId);

                    if (updateError) {
                        console.warn('Error actualizando puntos:', updateError);
                    }
                }
            }

            this.showSuccess('¡Logro asignado exitosamente!');
            this.closeModal('assignAchievementModal');
            
            // Recargar datos
            await this.loadHouseData();
            await this.loadDashboardData();

        } catch (error) {
            console.error('Error asignando logro:', error);
            this.showError(error.message || 'Error al asignar el logro');
            
            // Restaurar botón
            submitBtn.textContent = originalText;
            submitBtn.disabled = false;
        }
    }

    viewMemberProfile(userId) {
        // Abrir perfil del miembro en nueva pestaña
        window.open(`user_profile_achievement_system.html?user=${userId}`, '_blank');
    }

    closeModal(modalId) {
        const modal = document.getElementById(modalId);
        if (modal) {
            modal.classList.remove('opacity-100');
            modal.querySelector('.admin-modal-content').classList.remove('scale-100');
            
            setTimeout(() => {
                modal.remove();
            }, 300);
        }
    }

    showSuccess(message) {
        this.showNotification(message, 'success');
    }

    showError(message) {
        this.showNotification(message, 'error');
    }

    showNotification(message, type = 'info') {
        const notification = document.createElement('div');
        notification.className = `admin-notification ${type} fixed top-4 right-4 z-50`;
        notification.innerHTML = `
            <div class="flex items-center">
                <span class="mr-2">
                    ${type === 'success' ? '✅' : type === 'error' ? '❌' : 'ℹ️'}
                </span>
                <span>${message}</span>
                <button onclick="this.parentElement.parentElement.remove()" class="ml-4 text-lg">&times;</button>
            </div>
        `;

        document.body.appendChild(notification);

        // Auto-remove después de 5 segundos
        setTimeout(() => {
            if (notification.parentElement) {
                notification.remove();
            }
        }, 5000);
    }

    // Funciones auxiliares para organizar logros por categoría
    groupAchievementsByCategory() {
        const categories = {};
        this.achievementTypes.forEach(achievement => {
            const category = achievement.category || 'otros';
            if (!categories[category]) {
                categories[category] = [];
            }
            categories[category].push(achievement);
        });

        return Object.keys(categories).map(category => ({
            category,
            achievements: categories[category]
        }));
    }

    getCategoryDisplayName(category) {
        const categoryNames = {
            'primer_ano': '🎓 Primer Año',
            'vida_social_hogwarts': '👥 Vida Social en Hogwarts',
            'lealtad_casa': '🏠 Lealtad de Casa',
            'maestria_academica': '📚 Maestría Académica',
            'exploracion_magica': '🗺️ Exploración Mágica',
            'eventos_especiales': '🎉 Eventos Especiales',
            'otros': '✨ Otros Logros'
        };
        return categoryNames[category] || category.charAt(0).toUpperCase() + category.slice(1);
    }
}

// Inicializar cuando el DOM esté listo
document.addEventListener('DOMContentLoaded', () => {
    window.houseAdmin = new HouseHeadAdmin();
    // Usar setTimeout para asegurar que el DOM esté completamente renderizado
    setTimeout(() => {
        window.houseAdmin.initialize();
    }, 100);
});
