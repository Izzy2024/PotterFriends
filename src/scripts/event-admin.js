/**
 * Event Administration JavaScript
 * Handles the admin panel for creating and managing events
 */

(function() {
    'use strict';
    
    let currentUser = null;
    let events = [];
    let editingEvent = null;
    
    // Wait for Supabase client
    async function waitForSupabase() {
        for (let i = 0; i < 20; i++) {
            if (window.supabaseClient) return window.supabaseClient;
            await new Promise(resolve => setTimeout(resolve, 100));
        }
        throw new Error('Supabase client not available');
    }
    
    // Check if user has admin privileges
    async function checkAdminAccess() {
        if (!currentUser) {
            window.location.href = 'user_login.html';
            return false;
        }
        
        // For now, allow all authenticated users to create events
        // In production, you'd check for admin roles here
        return true;
    }
    
    // Fetch all events for admin view
    async function fetchAllEvents() {
        const client = await waitForSupabase();
        
        const { data, error } = await client
            .from('events')
            .select(`
                *,
                event_participants(count)
            `)
            .order('created_at', { ascending: false });
            
        if (error) throw error;
        return data || [];
    }
    
    // Create or update event
    async function saveEvent(eventData) {
        const client = await waitForSupabase();
        
        if (editingEvent) {
            // Update existing event
            const { data, error } = await client.rpc('update_event', {
                in_event_id: editingEvent.id,
                in_title: eventData.title,
                in_slug: eventData.slug,
                in_description: eventData.description,
                in_type: eventData.type,
                in_reward_points: eventData.reward_points,
                in_status: eventData.status,
                in_start_at: eventData.start_at,
                in_end_at: eventData.end_at,
                in_cover_url: eventData.cover_url,
                in_featured: eventData.featured
            });
            
            if (error) throw error;
            return { id: editingEvent.id, ...eventData };
        } else {
            // Create new event
            const { data, error } = await client.rpc('create_event', {
                in_title: eventData.title,
                in_slug: eventData.slug,
                in_description: eventData.description,
                in_type: eventData.type,
                in_reward_points: eventData.reward_points,
                in_status: eventData.status,
                in_start_at: eventData.start_at,
                in_end_at: eventData.end_at,
                in_cover_url: eventData.cover_url,
                in_featured: eventData.featured
            });
            
            if (error) throw error;
            return { id: data, ...eventData };
        }
    }
    
    // Delete event
    async function deleteEvent(eventId) {
        const client = await waitForSupabase();
        
        const { error } = await client.rpc('delete_event', {
            in_event_id: eventId
        });
            
        if (error) throw error;
    }
    
    // Format date for datetime-local input
    function formatDateForInput(dateString) {
        const date = new Date(dateString);
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        const hours = String(date.getHours()).padStart(2, '0');
        const minutes = String(date.getMinutes()).padStart(2, '0');
        return `${year}-${month}-${day}T${hours}:${minutes}`;
    }
    
    // Generate slug from title
    function generateSlug(title) {
        return title
            .toLowerCase()
            .replace(/[^a-z0-9\s-]/g, '')
            .replace(/\s+/g, '-')
            .replace(/-+/g, '-')
            .trim();
    }
    
    // Get event type configuration
    function getEventTypeConfig(type) {
        const configs = {
            'tournament': {
                name: 'Torneo',
                color: 'text-ravenclaw',
                bgColor: 'bg-ravenclaw/10',
                borderColor: 'border-ravenclaw/30'
            },
            'contest': {
                name: 'Concurso',
                color: 'text-hufflepuff',
                bgColor: 'bg-hufflepuff/10',
                borderColor: 'border-hufflepuff/30'
            },
            'celebration': {
                name: 'Celebración',
                color: 'text-success',
                bgColor: 'bg-success/10',
                borderColor: 'border-success/30'
            }
        };
        return configs[type] || configs['contest'];
    }
    
    // Get status configuration
    function getStatusConfig(status) {
        const configs = {
            'draft': {
                name: 'Borrador',
                color: 'text-gray-500',
                bgColor: 'bg-gray-100',
                borderColor: 'border-gray-300'
            },
            'active': {
                name: 'Activo',
                color: 'text-success',
                bgColor: 'bg-success/10',
                borderColor: 'border-success/30'
            },
            'completed': {
                name: 'Completado',
                color: 'text-blue-600',
                bgColor: 'bg-blue-50',
                borderColor: 'border-blue-200'
            },
            'cancelled': {
                name: 'Cancelado',
                color: 'text-error',
                bgColor: 'bg-error/10',
                borderColor: 'border-error/30'
            }
        };
        return configs[status] || configs['draft'];
    }
    
    // Render events list
    function renderEventsList(filteredEvents = null) {
        const eventsToRender = filteredEvents || events;
        const container = document.getElementById('events-list');
        
        if (!eventsToRender || eventsToRender.length === 0) {
            container.innerHTML = `
                <div class="text-center py-8">
                    <svg class="w-12 h-12 text-gray-400 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3a4 4 0 118 0v4m-4 6l-2 2m0 0l-2-2m2 2V9"/>
                    </svg>
                    <p class="text-text-secondary">No hay eventos para mostrar</p>
                    <button class="btn-primary mt-4" onclick="showEventModal()">Crear Primer Evento</button>
                </div>
            `;
            return;
        }
        
        container.innerHTML = eventsToRender.map(event => {
            const typeConfig = getEventTypeConfig(event.type);
            const statusConfig = getStatusConfig(event.status);
            const participantsCount = Array.isArray(event.event_participants) ? event.event_participants.length : 0;
            const startDate = new Date(event.start_at).toLocaleDateString('es-ES');
            const endDate = new Date(event.end_at).toLocaleDateString('es-ES');
            
            return `
                <div class="card p-6 hover:shadow-lg transition-shadow">
                    <div class="flex items-start justify-between mb-4">
                        <div class="flex-1">
                            <div class="flex items-center mb-2">
                                <span class="${typeConfig.bgColor} ${typeConfig.color} px-2 py-1 rounded text-xs font-semibold mr-2">
                                    ${typeConfig.name}
                                </span>
                                <span class="${statusConfig.bgColor} ${statusConfig.color} px-2 py-1 rounded text-xs font-semibold">
                                    ${statusConfig.name}
                                </span>
                                ${event.featured ? `
                                    <span class="bg-secondary/20 text-secondary px-2 py-1 rounded text-xs font-semibold ml-2">
                                        DESTACADO
                                    </span>
                                ` : ''}
                            </div>
                            <h3 class="font-headline text-lg font-medium text-text-primary mb-2">
                                ${event.title}
                            </h3>
                            <p class="text-text-secondary text-sm mb-3 line-clamp-2">
                                ${event.description || 'Sin descripción'}
                            </p>
                            <div class="flex items-center text-sm text-text-secondary space-x-4">
                                <div class="flex items-center">
                                    <svg class="w-4 h-4 mr-1" fill="currentColor" viewBox="0 0 20 20">
                                        <path d="M13 6a3 3 0 11-6 0 3 3 0 016 0zM18 8a2 2 0 11-4 0 2 2 0 014 0zM14 15a4 4 0 00-8 0v3h8v-3z"/>
                                    </svg>
                                    ${participantsCount} participantes
                                </div>
                                <div class="flex items-center">
                                    <svg class="w-4 h-4 mr-1" fill="currentColor" viewBox="0 0 20 20">
                                        <path d="M8 7V3a4 4 0 118 0v4m-4 6l-2 2m0 0l-2-2m2 2V9"/>
                                    </svg>
                                    ${startDate} - ${endDate}
                                </div>
                                <div class="flex items-center">
                                    <svg class="w-4 h-4 mr-1" fill="currentColor" viewBox="0 0 20 20">
                                        <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"/>
                                    </svg>
                                    ${event.reward_points || 0} puntos
                                </div>
                            </div>
                        </div>
                        <div class="flex items-center space-x-2 ml-4">
                            <a href="event-detail.html?event=${event.slug}" target="_blank" class="p-2 text-text-secondary hover:text-primary rounded-lg hover:bg-gray-100" title="Ver evento">
                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"/>
                                </svg>
                            </a>
                            <button class="p-2 text-text-secondary hover:text-primary rounded-lg hover:bg-gray-100" onclick="editEvent('${event.id}')" title="Editar">
                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/>
                                </svg>
                            </button>
                            <button class="p-2 text-error hover:text-error-700 rounded-lg hover:bg-error/10" onclick="confirmDeleteEvent('${event.id}')" title="Eliminar">
                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/>
                                </svg>
                            </button>
                        </div>
                    </div>
                </div>
            `;
        }).join('');
    }
    
    // Show event creation/edit modal
    function showEventModal(eventData = null) {
        const modal = document.getElementById('event-modal');
        const modalTitle = document.getElementById('modal-title');
        const submitBtnText = document.getElementById('submit-btn-text');
        const form = document.getElementById('event-form');
        
        editingEvent = eventData;
        
        if (eventData) {
            modalTitle.textContent = 'Editar Evento';
            submitBtnText.textContent = 'Actualizar Evento';
            
            // Fill form with existing data
            document.getElementById('event-title-input').value = eventData.title || '';
            document.getElementById('event-slug-input').value = eventData.slug || '';
            document.getElementById('event-description-input').value = eventData.description || '';
            document.getElementById('event-type-input').value = eventData.type || 'contest';
            document.getElementById('event-points-input').value = eventData.reward_points || 0;
            document.getElementById('event-status-input').value = eventData.status || 'draft';
            document.getElementById('event-start-input').value = formatDateForInput(eventData.start_at);
            document.getElementById('event-end-input').value = formatDateForInput(eventData.end_at);
            document.getElementById('event-cover-input').value = eventData.cover_url || '';
            document.getElementById('event-featured-input').checked = eventData.featured || false;
        } else {
            modalTitle.textContent = 'Crear Nuevo Evento';
            submitBtnText.textContent = 'Crear Evento';
            form.reset();
            
            // Set default dates (start now, end in 7 days)
            const now = new Date();
            const weekLater = new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000);
            document.getElementById('event-start-input').value = formatDateForInput(now);
            document.getElementById('event-end-input').value = formatDateForInput(weekLater);
        }
        
        modal.classList.remove('hidden');
    }
    
    // Handle form submission
    async function handleEventSubmit(e) {
        e.preventDefault();
        
        const formData = new FormData(e.target);
        const eventData = {
            title: document.getElementById('event-title-input').value,
            slug: document.getElementById('event-slug-input').value,
            description: document.getElementById('event-description-input').value,
            type: document.getElementById('event-type-input').value,
            reward_points: parseInt(document.getElementById('event-points-input').value) || 0,
            status: document.getElementById('event-status-input').value,
            start_at: document.getElementById('event-start-input').value,
            end_at: document.getElementById('event-end-input').value,
            cover_url: document.getElementById('event-cover-input').value || null,
            featured: document.getElementById('event-featured-input').checked
        };
        
        try {
            await saveEvent(eventData);
            
            // Close modal and refresh list
            document.getElementById('event-modal').classList.add('hidden');
            await loadEvents();
            
            alert(editingEvent ? 'Evento actualizado exitosamente' : 'Evento creado exitosamente');
        } catch (error) {
            console.error('Error saving event:', error);
            alert('Error al guardar el evento: ' + (error.message || 'Error desconocido'));
        }
    }
    
    // Edit event
    function editEvent(eventId) {
        const event = events.find(e => e.id === eventId);
        if (event) {
            showEventModal(event);
        }
    }
    
    // Confirm delete event
    function confirmDeleteEvent(eventId) {
        const event = events.find(e => e.id === eventId);
        if (event && confirm(`¿Estás seguro de que quieres eliminar el evento "${event.title}"?`)) {
            handleDeleteEvent(eventId);
        }
    }
    
    // Handle event deletion
    async function handleDeleteEvent(eventId) {
        try {
            await deleteEvent(eventId);
            await loadEvents();
            alert('Evento eliminado exitosamente');
        } catch (error) {
            console.error('Error deleting event:', error);
            alert('Error al eliminar el evento: ' + (error.message || 'Error desconocido'));
        }
    }
    
    // Load events and update stats
    async function loadEvents() {
        try {
            events = await fetchAllEvents();
            renderEventsList();
            updateStats();
        } catch (error) {
            console.error('Error loading events:', error);
            document.getElementById('events-list').innerHTML = `
                <div class="text-center py-8">
                    <p class="text-error">Error al cargar los eventos</p>
                </div>
            `;
        }
    }
    
    // Update statistics
    function updateStats() {
        const activeEvents = events.filter(e => e.status === 'active').length;
        const totalParticipants = events.reduce((sum, event) => {
            return sum + (Array.isArray(event.event_participants) ? event.event_participants.length : 0);
        }, 0);
        
        const thisMonth = new Date();
        const monthStart = new Date(thisMonth.getFullYear(), thisMonth.getMonth(), 1);
        const monthlyEvents = events.filter(e => new Date(e.created_at) >= monthStart).length;
        
        document.getElementById('stat-active-events').textContent = activeEvents;
        document.getElementById('stat-total-participants').textContent = totalParticipants;
        document.getElementById('stat-monthly-events').textContent = monthlyEvents;
    }
    
    // Initialize tabs
    function initializeTabs() {
        const tabButtons = document.querySelectorAll('.admin-tab-button');
        const tabContents = document.querySelectorAll('.admin-tab-content');
        
        tabButtons.forEach(button => {
            button.addEventListener('click', () => {
                const tabId = button.dataset.tab;
                
                // Update button states
                tabButtons.forEach(btn => {
                    btn.classList.remove('active', 'border-primary', 'text-primary');
                    btn.classList.add('border-transparent', 'text-text-secondary');
                });
                button.classList.add('active', 'border-primary', 'text-primary');
                button.classList.remove('border-transparent', 'text-text-secondary');
                
                // Update content visibility
                tabContents.forEach(content => {
                    content.classList.add('hidden');
                });
                document.getElementById(`${tabId}-tab`).classList.remove('hidden');
            });
        });
    }
    
    // Initialize page
    async function initialize() {
        try {
            // Check authentication
            if (window.getCurrentUser) {
                currentUser = await window.getCurrentUser();
            }
            
            // Check admin access
            const hasAccess = await checkAdminAccess();
            if (!hasAccess) return;
            
            // Load events
            await loadEvents();
            
            // Initialize tabs
            initializeTabs();
            
            // Add event listeners
            document.getElementById('create-event-btn').addEventListener('click', () => showEventModal());
            document.getElementById('event-form').addEventListener('submit', handleEventSubmit);
            
            // Auto-generate slug from title
            document.getElementById('event-title-input').addEventListener('input', (e) => {
                const slugInput = document.getElementById('event-slug-input');
                if (!slugInput.value || !editingEvent) {
                    slugInput.value = generateSlug(e.target.value);
                }
            });
            
            // Quick create buttons
            document.getElementById('quick-tournament').addEventListener('click', () => {
                showEventModal();
                document.getElementById('event-type-input').value = 'tournament';
            });
            
            document.getElementById('quick-contest').addEventListener('click', () => {
                showEventModal();
                document.getElementById('event-type-input').value = 'contest';
            });
            
            document.getElementById('quick-celebration').addEventListener('click', () => {
                showEventModal();
                document.getElementById('event-type-input').value = 'celebration';
            });
            
            // Modal close handlers
            document.getElementById('close-event-modal').addEventListener('click', () => {
                document.getElementById('event-modal').classList.add('hidden');
            });
            
            document.getElementById('cancel-event-form').addEventListener('click', () => {
                document.getElementById('event-modal').classList.add('hidden');
            });
            
            // Filter events
            document.getElementById('events-filter').addEventListener('change', (e) => {
                const filter = e.target.value;
                if (filter === 'all') {
                    renderEventsList();
                } else {
                    const filtered = events.filter(event => event.status === filter);
                    renderEventsList(filtered);
                }
            });
            
            // Make functions global for inline event handlers
            window.showEventModal = showEventModal;
            window.editEvent = editEvent;
            window.confirmDeleteEvent = confirmDeleteEvent;
            
        } catch (error) {
            console.error('Error initializing admin page:', error);
        }
    }
    
    // Auto-initialize when DOM is ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initialize);
    } else {
        initialize();
    }
    
})();