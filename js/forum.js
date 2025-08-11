import { forumAPI } from './services/forumApi.js';
import { supabase as supabaseImport } from './supabase-client.js';

// Manejar el caso cuando supabase es una promesa
let supabase = supabaseImport;
if (supabaseImport instanceof Promise) {
    supabaseImport.then(client => {
        supabase = client;
    });
}

class ForumController {
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
        // Get current user
        const { data: { user } } = await supabase.auth.getUser();
        this.currentUser = user;

        // Load initial data
        await this.loadCategories();
        await this.loadHouses();
        await this.loadPosts();
        await this.updateForumStats();

        // Setup event listeners
        this.setupEventListeners();
        
        // Setup real-time subscriptions
        this.setupRealtimeSubscriptions();
    }

    setupEventListeners() {
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

        // Reset filters button - buscar por clase o contenido
        const resetButton = document.querySelector('.btn-secondary');
        if (resetButton && resetButton.textContent.includes('Limpiar Filtros')) {
            resetButton.addEventListener('click', () => {
                this.resetFilters();
            });
        }

        // New discussion button - buscar por texto
        const buttons = document.querySelectorAll('.btn-primary');
        const newPostButton = Array.from(buttons).find(btn => btn.textContent.includes('Nueva Discusión'));
        if (newPostButton) {
            newPostButton.addEventListener('click', () => {
                this.showNewPostModal();
            });
        }

        // Load more button
        const allButtons = document.querySelectorAll('button');
        const loadMoreButton = Array.from(allButtons).find(btn => btn.textContent.includes('Cargar Más'));
        if (loadMoreButton) {
            loadMoreButton.addEventListener('click', () => {
                this.loadMorePosts();
            });
        }

        // Category sections - add click listeners
        document.addEventListener('click', (e) => {
            // Check if clicked on a post item
            const postItem = e.target.closest('.hover\\:bg-surface');
            if (postItem && postItem.querySelector('h4') && postItem.dataset.postId) {
                const postId = postItem.dataset.postId;
                const postTitle = postItem.querySelector('h4').textContent;
                console.log('Navigate to post:', postTitle);
                
                // Navigate to post detail page
                window.location.href = `post-detail.html?id=${postId}`;
            }
        });
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
    }

    resetFilters() {
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
        const result = await forumAPI.getCategories();
        if (result.success) {
            this.categories = result.data;
        }
    }

    async loadHouses() {
        const result = await forumAPI.getHouses();
        if (result.success) {
            this.houses = result.data;
        }
    }

    async loadPosts(reset = false) {
        if (this.isLoading) return;
        
        this.isLoading = true;
        
        if (reset) {
            this.posts = [];
            this.currentFilters.page = 1;
        }
        
        const result = await forumAPI.getPosts(this.currentFilters);
        
        if (result.success) {
            if (reset) {
                this.posts = result.data;
            } else {
                this.posts = [...this.posts, ...result.data];
            }
            this.hasMore = result.hasMore;
            this.renderPosts();
        }
        
        this.isLoading = false;
    }

    async loadMorePosts() {
        if (!this.hasMore || this.isLoading) return;
        
        this.currentFilters.page++;
        await this.loadPosts(false);
    }

    renderPosts() {
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
                     alt="${post.user?.wizard_name}" 
                     class="w-10 h-10 object-cover rounded-full mr-3" />
                <div>
                    <h4 class="font-medium text-sm">${this.escapeHtml(post.title)}</h4>
                    <div class="flex items-center text-xs text-text-secondary">
                        ${post.house ? `
                            <div class="w-2 h-2 bg-${post.house.name.toLowerCase()} rounded-full mr-1"></div>
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

    async updateForumStats() {
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
        }
    }

    setupRealtimeSubscriptions() {
        // Subscribe to forum stats updates
        forumAPI.subscribeToForumStats(() => {
            this.updateForumStats();
        });
    }

    showNewPostModal() {
        if (!this.currentUser) {
            alert('Debes iniciar sesión para crear una discusión');
            return;
        }

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

// Initialize forum when DOM is ready
document.addEventListener('DOMContentLoaded', async () => {
    // Only initialize if we're on the forum page
    if (window.location.pathname.includes('interactive_forum_hub.html')) {
        // Si supabase es una promesa, esperarla
        if (supabaseImport instanceof Promise) {
            console.log('Esperando a que Supabase se cargue...');
            await supabaseImport;
            console.log('Supabase cargado, inicializando foro...');
        }
        window.forumController = new ForumController();
    }
});
