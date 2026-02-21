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

class PostDetailController {
    constructor() {
        this.postId = null;
        this.post = null;
        this.comments = [];
        this.currentUser = null;
        this.commentsPage = 1;
        this.hasMoreComments = true;
        
        this.init();
    }

    async init() {
        await ensureSupabaseClient();

        // Get current user
        const { data: { user } } = await supabase.auth.getUser();
        this.currentUser = user;

        // Get post ID from URL parameters
        const urlParams = new URLSearchParams(window.location.search);
        this.postId = urlParams.get('id');

        if (!this.postId) {
            this.showError('No se encontró el ID del post');
            return;
        }

        // Load post and comments
        await this.loadPost();
        await this.loadComments();
        
        // Setup event listeners
        this.setupEventListeners();
        
        // Setup real-time subscriptions
        this.setupRealtimeSubscriptions();
    }

    async loadPost() {
        try {
            const result = await forumAPI.getPost(this.postId);
            
            if (result.success) {
                this.post = result.data;
                this.renderPost();
                document.title = `${this.post.title} - Hogwarts Community Hub`;
            } else {
                this.showError('Error al cargar el post: ' + result.error);
            }
        } catch (error) {
            console.error('Error loading post:', error);
            this.showError('Error al cargar el post');
        }
    }

    async loadComments(reset = false) {
        try {
            if (reset) {
                this.comments = [];
                this.commentsPage = 1;
            }

            // When resetting, load all comments to ensure we see the latest
            const pageToLoad = reset ? null : this.commentsPage; // null means load all
            const result = await forumAPI.getComments(this.postId, pageToLoad);
            
            if (result.success) {
                if (reset) {
                    this.comments = result.data;
                } else {
                    this.comments = [...this.comments, ...result.data];
                }
                
                this.hasMoreComments = result.hasMore;
                this.renderComments();
                this.updateCommentsCount();
            } else {
                console.error('Error loading comments:', result.error);
            }
        } catch (error) {
            console.error('Error loading comments:', error);
        }
    }

    renderPost() {
        const postContent = document.getElementById('postContent');
        
        if (!this.post) {
            postContent.innerHTML = '<p class="text-center text-text-secondary">Post no encontrado</p>';
            return;
        }

        const timeAgo = this.getTimeAgo(this.post.created_at);
        const likesCount = this.post.likes_count || 0;

        postContent.innerHTML = `
            <div class="mb-6">
                <div class="flex items-center justify-between mb-4">
                    <div class="flex items-center">
                        ${this.post.category ? `
                            <span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-primary/10 text-primary mr-3">
                                ${this.post.category.name}
                            </span>
                        ` : ''}
                        ${this.post.house ? `
                            <div class="flex items-center text-sm text-text-secondary">
                                <div class="w-3 h-3 bg-${this.post.house.name.toLowerCase()} rounded-full mr-2"></div>
                                <span>${this.post.house.name}</span>
                            </div>
                        ` : ''}
                    </div>
                    <div class="flex items-center space-x-4">
                        <button id="likeBtn" class="flex items-center space-x-2 text-text-secondary hover:text-warning magical-transition ${this.post.user_liked ? 'text-warning' : ''}">
                            <svg class="w-5 h-5" fill="${this.post.user_liked ? 'currentColor' : 'none'}" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"/>
                            </svg>
                            <span id="likesCount">${likesCount}</span>
                        </button>
                        <div class="text-sm text-text-secondary">
                            ${this.post.view_count || 0} vistas
                        </div>
                    </div>
                </div>
                
                <h1 class="font-headline text-3xl font-medium text-text-primary mb-4">
                    ${this.escapeHtml(this.post.title)}
                </h1>
                
                <div class="flex items-center text-text-secondary mb-6">
                    <img src="${this.post.user?.avatar_url || 'https://ui-avatars.com/api/?name=' + encodeURIComponent(this.post.user?.wizard_name || 'U')}" 
                         alt="${this.post.user?.wizard_name}" 
                         class="w-10 h-10 object-cover rounded-full mr-3" />
                    <div>
                        <div class="font-medium text-text-primary">${this.post.user?.wizard_name || 'Usuario'}</div>
                        <div class="text-sm">${timeAgo}</div>
                    </div>
                </div>
            </div>
            
            <div class="prose prose-invert max-w-none">
                <p class="text-text-primary leading-relaxed whitespace-pre-wrap">${this.escapeHtml(this.post.content)}</p>
            </div>
        `;
    }

    renderComments() {
        const commentsList = document.getElementById('commentsList');
        const loadMoreBtn = document.getElementById('loadMoreComments');

        // Render all comments
        commentsList.innerHTML = this.comments.map(comment => this.createCommentHTML(comment)).join('');

        // Show/hide load more button
        loadMoreBtn.style.display = this.hasMoreComments ? 'block' : 'none';

        // Render new comment form
        this.renderNewCommentForm();
    }

    createCommentHTML(comment) {
        const timeAgo = this.getTimeAgo(comment.created_at);
        const likesCount = comment.likes?.[0]?.count || 0;
        const isOwner = this.currentUser && comment.user_id === this.currentUser.id;

        return `
            <div class="comment bg-surface/30 p-4 rounded-lg" data-comment-id="${comment.id}">
                <div class="flex items-start space-x-3">
                    <img src="${comment.user?.avatar_url || 'https://ui-avatars.com/api/?name=' + encodeURIComponent(comment.user?.wizard_name || 'U')}" 
                         alt="${comment.user?.wizard_name}" 
                         class="w-8 h-8 object-cover rounded-full" />
                    <div class="flex-1">
                        <div class="flex items-center justify-between mb-2">
                            <div class="flex items-center space-x-2">
                                <span class="font-medium text-sm">${comment.user?.wizard_name || 'Usuario'}</span>
                                <span class="text-xs text-text-secondary">${timeAgo}</span>
                            </div>
                            ${isOwner ? `
                                <div class="flex items-center space-x-2">
                                    <button class="edit-comment text-xs text-text-secondary hover:text-primary" data-comment-id="${comment.id}">
                                        Editar
                                    </button>
                                    <button class="delete-comment text-xs text-text-secondary hover:text-error" data-comment-id="${comment.id}">
                                        Eliminar
                                    </button>
                                </div>
                            ` : ''}
                        </div>
                        <div class="comment-content text-sm text-text-primary leading-relaxed whitespace-pre-wrap">
                            ${this.escapeHtml(comment.content)}
                        </div>
                        <div class="flex items-center justify-between mt-3">
                            <button class="like-comment flex items-center space-x-1 text-xs text-text-secondary hover:text-warning magical-transition ${comment.user_liked ? 'text-warning' : ''}" data-comment-id="${comment.id}">
                                <svg class="w-4 h-4" fill="${comment.user_liked ? 'currentColor' : 'none'}" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"/>
                                </svg>
                                <span>${likesCount}</span>
                            </button>
                            <button class="reply-comment text-xs text-text-secondary hover:text-primary" data-comment-id="${comment.id}">
                                Responder
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        `;
    }

    renderNewCommentForm() {
        const newCommentForm = document.getElementById('newCommentForm');

        if (!this.currentUser) {
            newCommentForm.innerHTML = `
                <div class="bg-surface/50 p-4 rounded-lg">
                    <p class="text-center text-text-secondary">
                        <a href="#" class="text-primary hover:underline">Inicia sesión</a> para comentar
                    </p>
                </div>
            `;
            return;
        }

        newCommentForm.innerHTML = `
            <form id="commentForm" class="space-y-4">
                <div class="flex items-start space-x-3">
                    <img src="${this.currentUser.user_metadata?.avatar_url || 'https://ui-avatars.com/api/?name=' + encodeURIComponent(this.currentUser.user_metadata?.wizard_name || 'U')}" 
                         alt="Tu avatar" 
                         class="w-8 h-8 object-cover rounded-full" />
                    <div class="flex-1">
                        <textarea 
                            id="commentContent" 
                            placeholder="Escribe tu comentario..." 
                            rows="3" 
                            class="input-field w-full resize-none"
                            required
                        ></textarea>
                        <div class="flex justify-end mt-2">
                            <button type="submit" class="btn-primary px-4 py-2 text-sm">
                                Comentar
                            </button>
                        </div>
                    </div>
                </div>
            </form>
        `;
    }

    updateCommentsCount() {
        const commentsCount = document.getElementById('commentsCount');
        commentsCount.textContent = `(${this.comments.length})`;
    }

    setupEventListeners() {
        // Like post button
        document.addEventListener('click', async (e) => {
            if (e.target.closest('#likeBtn')) {
                await this.togglePostLike();
            }

            // Like comment button
            if (e.target.closest('.like-comment')) {
                const commentId = e.target.closest('.like-comment').dataset.commentId;
                await this.toggleCommentLike(commentId);
            }

            // Load more comments
            if (e.target.closest('#loadMoreComments button')) {
                this.commentsPage++;
                await this.loadComments();
            }
        });

        // Comment form submission
        document.addEventListener('submit', async (e) => {
            if (e.target.id === 'commentForm') {
                e.preventDefault();
                await this.submitComment();
            }
        });
    }

    async togglePostLike() {
        if (!this.currentUser) {
            alert('Debes iniciar sesión para dar like');
            return;
        }

        try {
            const result = await forumAPI.toggleLike(this.postId, 'post');
            
            if (result.success) {
                this.post.user_liked = result.liked;
                this.post.likes_count = (this.post.likes_count || 0) + (result.liked ? 1 : -1);
                
                // Update UI
                const likeBtn = document.getElementById('likeBtn');
                const likesCount = document.getElementById('likesCount');
                const svg = likeBtn.querySelector('svg');
                
                if (result.liked) {
                    likeBtn.classList.add('text-warning');
                    svg.setAttribute('fill', 'currentColor');
                } else {
                    likeBtn.classList.remove('text-warning');
                    svg.setAttribute('fill', 'none');
                }
                
                likesCount.textContent = this.post.likes_count;
            }
        } catch (error) {
            console.error('Error toggling like:', error);
        }
    }

    async toggleCommentLike(commentId) {
        if (!this.currentUser) {
            alert('Debes iniciar sesión para dar like');
            return;
        }

        try {
            const result = await forumAPI.toggleLike(commentId, 'comment');
            
            if (result.success) {
                // Find and update the comment in our array
                const comment = this.comments.find(c => c.id === commentId);
                if (comment) {
                    comment.user_liked = result.liked;
                    comment.likes = comment.likes || [{ count: 0 }];
                    comment.likes[0].count = (comment.likes[0].count || 0) + (result.liked ? 1 : -1);
                }
                
                // Update UI for this specific comment
                const commentElement = document.querySelector(`[data-comment-id="${commentId}"]`);
                const likeBtn = commentElement.querySelector('.like-comment');
                const svg = likeBtn.querySelector('svg');
                const count = likeBtn.querySelector('span');
                
                if (result.liked) {
                    likeBtn.classList.add('text-warning');
                    svg.setAttribute('fill', 'currentColor');
                } else {
                    likeBtn.classList.remove('text-warning');
                    svg.setAttribute('fill', 'none');
                }
                
                count.textContent = comment.likes[0].count;
            }
        } catch (error) {
            console.error('Error toggling comment like:', error);
        }
    }

    async submitComment() {
        const content = document.getElementById('commentContent').value.trim();
        
        if (!content) return;

        try {
            const result = await forumAPI.createComment(this.postId, content);
            
            if (result.success) {
                // Clear form
                document.getElementById('commentContent').value = '';
                
                // Reload comments to show the new one
                await this.loadComments(true);
                
                this.showNotification('Comentario publicado exitosamente', 'success');
            } else {
                this.showNotification('Error al publicar comentario: ' + result.error, 'error');
            }
        } catch (error) {
            console.error('Error submitting comment:', error);
            this.showNotification('Error al publicar comentario', 'error');
        }
    }

    setupRealtimeSubscriptions() {
        // Subscribe to new comments on this post
        forumAPI.subscribeToPost(this.postId, {
            onNewComment: () => {
                // Reload comments when new comment is added
                this.loadComments(true);
            },
            onPostUpdate: () => {
                // Reload post if it's updated
                this.loadPost();
            }
        });
    }

    showError(message) {
        const postContent = document.getElementById('postContent');
        postContent.innerHTML = `
            <div class="text-center py-8">
                <svg class="mx-auto h-12 w-12 text-error mb-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L4.082 16.5c-.77.833.192 2.5 1.732 2.5z"/>
                </svg>
                <p class="text-error">${message}</p>
                <button onclick="history.back()" class="btn-secondary mt-4">
                    Volver al Foro
                </button>
            </div>
        `;
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

// Initialize when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
    window.postDetailController = new PostDetailController();
});
