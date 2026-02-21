import { forumAPI } from './services/forumApi.js';

let supabase = window.supabaseClient || null;

async function ensureSupabaseClient() {
    if (window.supabaseClient) {
        supabase = window.supabaseClient;
        return supabase;
    }
    if (window.HogwartsAuth?.initDatabase) {
        supabase = await window.HogwartsAuth.initDatabase();
        return supabase;
    }
    throw new Error('Database client not available. Ensure auth.js is loaded first.');
}

export class ForumController {
    constructor() {
        this.currentFilters = {
            houseIds: [],
            categoryId: null,
            sortBy: 'recent',
            search: '',
            page: 1
        };
        
        this.posts = [];
        this.categories = [];
        this.houses = [];
        this.hasMore = true;
        this.isLoading = false;
        this.currentUser = null;
        
        this.init();
    }

    async init() {
        try {
            await ensureSupabaseClient();
            console.log('✅ Cliente de base de datos cargado correctamente');

            // Get current user
            const { data: { user } } = await supabase.auth.getUser();
            this.currentUser = user;
            console.log('👤 Usuario actual:', user ? user.email : 'No autenticado');

            // Load initial data
            await this.loadCategories();
            await this.loadHouses();
            await this.loadPosts();
            await this.updateForumStats();
            await this.loadFeaturedPosts();

            // Setup event listeners
            this.setupEventListeners();
            
            // Setup real-time subscriptions
            this.setupRealtimeSubscriptions();
            
            console.log('🎉 Foro inicializado completamente');
        } catch (error) {
            console.error('❌ Error en la inicialización:', error);
            this.showNotification('Error inicializando el foro', 'error');
        }
    }

    setupEventListeners() {
        console.log('🎧 Configurando event listeners...');
        
        // Search functionality
        const searchInput = document.querySelector('input[placeholder="Buscar discusiones..."]');
        if (searchInput) {
            let searchTimeout;
            searchInput.addEventListener('input', (e) => {
                clearTimeout(searchTimeout);
                searchTimeout = setTimeout(() => {
                    this.currentFilters.search = e.target.value;
                    this.currentFilters.page = 1;
                    this.loadPosts(true);
                }, 300);
            });
            console.log('✅ Buscador configurado');
        }

        // Sort dropdown
        const sortSelect = document.querySelector('select');
        if (sortSelect) {
            sortSelect.addEventListener('change', (e) => {
                const sortMap = {
                    'Más Reciente': 'recent',
                    'Más Popular': 'popular',
                    'Más Comentado': 'most-commented',
                    'Mejor Valorado': 'top-rated'
                };
                this.currentFilters.sortBy = sortMap[e.target.value] || 'recent';
                this.currentFilters.page = 1;
                this.loadPosts(true);
            });
            console.log('✅ Ordenamiento configurado');
        }

        // House filters
        const houseCheckboxes = document.querySelectorAll('input[type="checkbox"]');
        houseCheckboxes.forEach(checkbox => {
            checkbox.addEventListener('change', () => {
                this.updateHouseFilters();
                this.currentFilters.page = 1;
                this.loadPosts(true);
            });
        });
        console.log('✅ Filtros de casa configurados');

        // Reset filters button
        const resetButton = document.querySelector('.btn-secondary');
        if (resetButton && resetButton.textContent.includes('Limpiar Filtros')) {
            resetButton.addEventListener('click', () => {
                this.resetFilters();
            });
            console.log('✅ Botón reset configurado');
        }

        // New discussion button
        const buttons = document.querySelectorAll('.btn-primary');
        const newPostButton = Array.from(buttons).find(btn => btn.textContent.includes('Nueva Discusión'));
        if (newPostButton) {
            newPostButton.addEventListener('click', () => {
                this.showNewPostModal();
            });
            console.log('✅ Botón nueva discusión configurado');
        }

        // Load more button
        const allButtons = document.querySelectorAll('button');
        const loadMoreButton = Array.from(allButtons).find(btn => btn.textContent.includes('Cargar Más'));
        if (loadMoreButton) {
            loadMoreButton.addEventListener('click', () => {
                this.loadMorePosts();
            });
            console.log('✅ Botón cargar más configurado');
        }

        // Event delegation for navigating to post detail
        document.addEventListener('click', (e) => {
            const item = e.target.closest('[data-post-id]');
            if (item) {
                const id = item.dataset.postId;
                if (id) {
                    window.location.href = `post-detail.html?id=${encodeURIComponent(id)}`;
                }
            }
        });
        console.log('✅ Navegación por click configurada');
    }

    updateHouseFilters() {
        const checkedHouses = [];
        const houseCheckboxes = document.querySelectorAll('input[type="checkbox"]:checked');
        
        houseCheckboxes.forEach(checkbox => {
            const houseName = checkbox.parentElement.textContent.trim().toLowerCase();
            const house = this.houses.find(h => h.name.toLowerCase() === houseName);
            if (house) {
                checkedHouses.push(house.id);
            }
        });
        
        this.currentFilters.houseIds = checkedHouses;
        console.log('🏠 Filtros de casa actualizados:', checkedHouses);
    }

    resetFilters() {
        console.log('🔄 Reseteando filtros...');
        
        // Reset checkboxes
        document.querySelectorAll('input[type="checkbox"]').forEach(cb => cb.checked = false);
        
        // Reset sort
        const sortSelect = document.querySelector('select');
        if (sortSelect) sortSelect.selectedIndex = 0;
        
        // Reset search
        const searchInput = document.querySelector('input[placeholder="Buscar discusiones..."]');
        if (searchInput) searchInput.value = '';
        
        // Reset filters
        this.currentFilters = {
            houseIds: [],
            categoryId: null,
            sortBy: 'recent',
            search: '',
            page: 1
        };
        
        this.loadPosts(true);
    }

    async loadCategories() {
        console.log('📂 Cargando categorías...');
        try {
            const result = await forumAPI.getCategories();
            if (result.success) {
                this.categories = result.data;
                console.log('✅ Categorías cargadas:', this.categories.length);
            } else {
                console.error('❌ Error cargando categorías:', result.error);
                // Crear categorías por defecto si no existen
                this.categories = [
                    { id: 1, name: 'Teorías y Análisis' },
                    { id: 2, name: 'Fanfiction' },
                    { id: 3, name: 'Arte y Creatividad' },
                    { id: 4, name: 'Debates Mágicos' },
                    { id: 5, name: 'Ayuda y Preguntas' }
                ];
            }
        } catch (error) {
            console.error('❌ Error cargando categorías:', error);
            this.showNotification('Error cargando categorías', 'error');
        }
    }

    async loadHouses() {
        console.log('🏠 Cargando casas...');
        try {
            const result = await forumAPI.getHouses();
            if (result.success) {
                this.houses = result.data;
                console.log('✅ Casas cargadas:', this.houses.length);
            } else {
                console.error('❌ Error cargando casas:', result.error);
                // Crear casas por defecto si no existen
                this.houses = [
                    { id: 1, name: 'Gryffindor' },
                    { id: 2, name: 'Slytherin' },
                    { id: 3, name: 'Ravenclaw' },
                    { id: 4, name: 'Hufflepuff' }
                ];
            }
        } catch (error) {
            console.error('❌ Error cargando casas:', error);
            this.showNotification('Error cargando casas', 'error');
        }
    }

    async loadPosts(reset = false) {
        if (this.isLoading) return;
        
        console.log('📝 Cargando posts...', { reset, filters: this.currentFilters });
        this.isLoading = true;
        
        if (reset) {
            this.posts = [];
            this.currentFilters.page = 1;
        }
        
        try {
            const result = await forumAPI.getPosts(this.currentFilters);
            
            if (result.success) {
                if (reset) {
                    this.posts = result.data;
                } else {
                    this.posts = [...this.posts, ...result.data];
                }
                this.hasMore = result.hasMore;
                this.renderPosts();
                console.log('✅ Posts cargados:', result.data.length, 'total:', this.posts.length);
            } else {
                console.error('❌ Error cargando posts:', result.error);
                this.showNotification('Error cargando discusiones: ' + result.error, 'error');
            }
        } catch (error) {
            console.error('❌ Error cargando posts:', error);
            this.showNotification('Error cargando discusiones', 'error');
        }
        
        this.isLoading = false;
    }

    renderPosts() {
        console.log('🎨 Renderizando posts...');
        
        // Si no hay categorías aún, no renderizar
        if (this.categories.length === 0) {
            console.log('⏳ Esperando categorías...');
            return;
        }
        
        // Si no hay posts, mostrar estado vacío
        if (this.posts.length === 0) {
            this.renderEmptyState();
            return;
        }
        
        // Group posts by category
        const postsByCategory = {};
        this.categories.forEach(cat => {
            postsByCategory[cat.id] = this.posts.filter(p => p.category_id === cat.id);
        });

        // Update each category section
        this.categories.forEach(category => {
            const categoryPosts = postsByCategory[category.id] || [];
            const categorySection = this.findCategorySection(category.name);
            
            if (categorySection) {
                this.updateCategorySection(categorySection, category, categoryPosts);
            }
        });

        // Update load more button visibility
        const allButtons = document.querySelectorAll('button');
        const loadMoreButton = Array.from(allButtons).find(btn => btn.textContent.includes('Cargar Más'));
        if (loadMoreButton) {
            loadMoreButton.style.display = this.hasMore ? 'block' : 'none';
        }
        
        console.log('✅ Posts renderizados correctamente');
    }

    renderEmptyState() {
        // Encontrar todas las secciones de categorías y mostrar estado vacío
        this.categories.forEach(category => {
            const categorySection = this.findCategorySection(category.name);
            if (categorySection) {
                const postsContainer = categorySection.querySelector('.space-y-3');
                if (postsContainer) {
                    postsContainer.innerHTML = `
                        <div class="text-center py-8 text-text-secondary">
                            <p>No hay discusiones en esta categoría aún.</p>
                            <button class="btn-primary mt-2" onclick="window.forumController.showNewPostModal()">
                                Crear primera discusión
                            </button>
                        </div>
                    `;
                }
            }
        });
    }

    findCategorySection(categoryName) {
        const sections = document.querySelectorAll('.card');
        for (const section of sections) {
            const title = section.querySelector('h3');
            if (title && title.textContent.includes(categoryName)) {
                return section;
            }
        }
        return null;
    }

    updateCategorySection(section, category, posts) {
        // Update stats
        const statsDiv = section.querySelector('.text-right.text-sm');
        if (statsDiv) {
            const postCount = posts.length;
            const commentCount = posts.reduce((sum, p) => sum + (p.comments?.[0]?.count || 0), 0);
            statsDiv.innerHTML = `
                <div>${postCount} temas</div>
                <div>${commentCount} mensajes</div>
            `;
        }

        // Find posts container
        const postsContainer = section.querySelector('.space-y-3');
        if (!postsContainer) return;

        // Clear existing posts
        postsContainer.innerHTML = '';

        // Add posts
        posts.slice(0, 5).forEach(post => {
            const postElement = this.createPostElement(post, category);
            postsContainer.appendChild(postElement);
        });

        // If no posts, show empty state
        if (posts.length === 0) {
            postsContainer.innerHTML = `
                <div class="text-center py-8 text-text-secondary">
                    <p>No hay discusiones en esta categoría aún.</p>
                    <button class="btn-primary mt-2" onclick="window.forumController.showNewPostModal()">
                        Crear primera discusión
                    </button>
                </div>
            `;
        }
    }

    createPostElement(post, category) {
        const div = document.createElement('div');
        div.className = 'flex items-center justify-between p-3 bg-surface/50 rounded-lg hover:bg-surface magical-transition cursor-pointer';
        div.dataset.postId = post.id;
        
        const timeAgo = this.getTimeAgo(post.created_at);
        const likesCount = post.likes?.[0]?.count || 0;
        const commentsCount = post.comments?.[0]?.count || 0;
        
        div.innerHTML = `
            <div class="flex items-center">
                <img src="${post.user?.avatar_url || 'https://ui-avatars.com/api/?name=' + encodeURIComponent(post.user?.wizard_name || 'U')}" 
                     alt="${post.user?.wizard_name || 'Usuario'}" 
                     class="w-10 h-10 object-cover rounded-full mr-3" />
                <div>
                    <h4 class="font-medium text-sm">${this.escapeHtml(post.title)}</h4>
                    <div class="flex items-center text-xs text-text-secondary">
                        ${post.house ? `
                            <div class="w-2 h-2 bg-${(post.house.name || '').toLowerCase()} rounded-full mr-1"></div>
                        ` : ''}
                        <span class="mr-2">${post.user?.wizard_name || 'Usuario'}</span>
                        <span>•</span>
                        <span class="ml-2">${commentsCount} respuestas</span>
                    </div>
                </div>
            </div>
            <div class="text-xs text-text-secondary">
                <div>${timeAgo}</div>
                ${likesCount > 0 ? `
                    <div class="flex items-center">
                        <svg class="w-3 h-3 mr-1 text-secondary" fill="currentColor" viewBox="0 0 20 20">
                            <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"/>
                        </svg>
                        <span>+${likesCount} pts</span>
                    </div>
                ` : ''}
            </div>
        `;
        
        return div;
    }

    async loadFeaturedPosts() {
        try {
            const grid = document.getElementById('featuredPostsGrid');
            if (!grid) {
                console.warn('⚠️ No se encontró el contenedor de destacados');
                return;
            }
            grid.innerHTML = '<div class="text-sm text-text-secondary">Cargando discusiones destacadas...</div>';
            const result = await forumAPI.getFeaturedPosts(2);
            if (!result.success) {
                grid.innerHTML = '<div class="text-sm text-error">Error cargando discusiones destacadas</div>';
                return;
            }
            const posts = result.data || [];
            if (!posts.length) {
                grid.innerHTML = '<div class="text-sm text-text-secondary">No hay discusiones destacadas por ahora.</div>';
                return;
            }
            grid.innerHTML = '';
            posts.forEach(post => {
                grid.appendChild(this.createFeaturedCard(post));
            });
        } catch (error) {
            const grid = document.getElementById('featuredPostsGrid');
            if (grid) grid.innerHTML = '<div class="text-sm text-error">Error cargando discusiones destacadas</div>';
            console.error('Error en loadFeaturedPosts:', error);
        }
    }

    createFeaturedCard(post) {
        const houseName = (post.house?.name || '').toLowerCase();
        const validHouses = ['gryffindor','slytherin','ravenclaw','hufflepuff'];
        const theme = validHouses.includes(houseName) ? houseName : 'secondary';
        const commentsCount = post.comments?.[0]?.count || 0;
        const views = post.views || post.view_count || 0;
        const timeAgo = this.getTimeAgo(post.created_at);
        const div = document.createElement('div');
        div.className = `bg-gradient-to-r from-${theme}/10 to-${theme}/5 p-4 rounded-lg border-l-4 border-${theme} hover-scale magical-transition cursor-pointer`;
        div.dataset.postId = post.id;
        const avatar = post.user?.avatar_url || `https://ui-avatars.com/api/?name=${encodeURIComponent(post.user?.wizard_name || 'U')}`;
        div.innerHTML = `
            <div class="flex items-center mb-2">
                <img src="${avatar}" alt="${post.user?.wizard_name || 'Usuario'}" class="w-8 h-8 object-cover rounded-full mr-3" onerror="this.src='https://ui-avatars.com/api/?name=${encodeURIComponent(post.user?.wizard_name || 'U')}'; this.onerror=null;" />
                <div>
                    <div class="font-cta font-semibold text-sm">${this.escapeHtml(post.user?.wizard_name || 'Usuario')}</div>
                    <div class="flex items-center">
                        ${houseName ? `<div class="w-2 h-2 bg-${theme} rounded-full mr-1"></div>` : ''}
                        <span class="text-xs ${houseName ? `text-${theme}` : 'text-text-secondary'}">${houseName ? post.house.name : 'Miembro'}</span>
                    </div>
                </div>
            </div>
            <h4 class="font-headline font-medium mb-2">${this.escapeHtml(post.title)}</h4>
            <p class="text-sm text-text-secondary mb-3 line-clamp-2">${this.escapeHtml(post.content || '')}</p>
            <div class="flex items-center justify-between text-xs text-text-secondary">
                <span>${commentsCount} respuestas • ${views.toLocaleString()} vistas</span>
                <span>${timeAgo}</span>
            </div>
        `;
        return div;
    }

    async updateForumStats() {
        console.log('📊 Actualizando estadísticas...');
        try {
            const result = await forumAPI.getForumStats();
            if (result.success) {
                const stats = result.data;
                
                // Update stats in the UI
                const statsElements = document.querySelectorAll('.font-headline.text-2xl');
                if (statsElements.length >= 4) {
                    statsElements[0].textContent = stats.activeDiscussions.toLocaleString();
                    statsElements[1].textContent = stats.todayMessages.toLocaleString();
                    // Keep online members count as is (would need presence system)
                    statsElements[3].textContent = stats.newToday.toLocaleString();
                }
                console.log('✅ Estadísticas actualizadas:', stats);
            } else {
                console.error('❌ Error actualizando estadísticas:', result.error);
            }
        } catch (error) {
            console.error('❌ Error actualizando estadísticas:', error);
        }
    }

    setupRealtimeSubscriptions() {
        console.log('📡 Configurando subscripciones en tiempo real...');
        
        try {
            // Subscribe to forum stats updates
            forumAPI.subscribeToForumStats(() => {
                this.updateForumStats();
            });
            
            console.log('✅ Subscripciones configuradas');
        } catch (error) {
            console.error('❌ Error configurando realtime:', error);
        }
    }

    async loadMorePosts() {
        if (!this.hasMore || this.isLoading) return;
        
        this.currentFilters.page++;
        await this.loadPosts(false);
    }

    showNewPostModal() {
        if (!this.currentUser) {
            alert('Debes iniciar sesión para crear una discusión');
            return;
        }

        console.log('📝 Mostrando modal de nueva discusión...');

        // Create modal HTML
        const modal = document.createElement('div');
        modal.className = 'fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4';
        modal.innerHTML = `
            <div class="bg-surface rounded-lg max-w-2xl w-full max-h-[90vh] overflow-y-auto">
                <div class="p-6">
                    <h2 class="font-headline text-2xl font-medium mb-4">Nueva Discusión</h2>
                    <form id="newPostForm">
                        <div class="mb-4">
                            <label class="block text-sm font-medium mb-2">Título</label>
                            <input type="text" name="title" required 
                                   class="input-field w-full" 
                                   placeholder="¿De qué quieres hablar?">
                        </div>
                        
                        <div class="mb-4">
                            <label class="block text-sm font-medium mb-2">Categoría</label>
                            <select name="category" required class="input-field w-full">
                                <option value="">Selecciona una categoría</option>
                                ${this.categories.map(cat => `
                                    <option value="${cat.id}">${cat.name}</option>
                                `).join('')}
                            </select>
                        </div>
                        
                        <div class="mb-4">
                            <label class="block text-sm font-medium mb-2">Contenido</label>
                            <textarea name="content" required 
                                      class="input-field w-full" 
                                      rows="6"
                                      placeholder="Escribe tu mensaje aquí..."></textarea>
                        </div>
                        
                        <div class="flex justify-end gap-4">
                            <button type="button" class="btn-secondary" onclick="this.closest('.fixed').remove()">
                                Cancelar
                            </button>
                            <button type="submit" class="btn-primary">
                                Publicar
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        `;
        
        document.body.appendChild(modal);
        
        // Handle form submission
        const form = modal.querySelector('#newPostForm');
        form.addEventListener('submit', async (e) => {
            e.preventDefault();
            
            const formData = new FormData(form);
            const postData = {
                title: formData.get('title'),
                content: formData.get('content'),
                categoryId: formData.get('category'),
                houseId: this.currentUser.user_metadata?.house_id || null
            };
            
            const submitButton = form.querySelector('button[type="submit"]');
            submitButton.disabled = true;
            submitButton.textContent = 'Publicando...';
            
            try {
                const result = await forumAPI.createPost(postData);
                
                if (result.success) {
                    modal.remove();
                    this.loadPosts(true);
                    this.showNotification('¡Discusión creada exitosamente!', 'success');
                } else {
                    submitButton.disabled = false;
                    submitButton.textContent = 'Publicar';
                    this.showNotification('Error al crear la discusión: ' + result.error, 'error');
                }
            } catch (error) {
                submitButton.disabled = false;
                submitButton.textContent = 'Publicar';
                this.showNotification('Error al crear la discusión', 'error');
            }
        });
    }

    showNotification(message, type = 'info') {
        const notification = document.createElement('div');
        notification.className = `fixed top-4 right-4 z-50 p-4 rounded-lg shadow-lg ${
            type === 'success' ? 'bg-success text-white' : 
            type === 'error' ? 'bg-error text-white' : 
            'bg-primary text-white'
        }`;
        notification.textContent = message;
        
        document.body.appendChild(notification);
        
        setTimeout(() => {
            notification.remove();
        }, 3000);
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

    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
}
