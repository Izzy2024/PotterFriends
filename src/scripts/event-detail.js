/**
 * Event Detail Page JavaScript
 * Handles individual event pages with participation, submissions, and interaction
 */

(function() {
    'use strict';
    
    let currentEvent = null;
    let currentUser = null;
    let userParticipation = null;

    function ensureToastHost() {
        let host = document.getElementById('app-toast-host');
        if (!host) {
            host = document.createElement('div');
            host.id = 'app-toast-host';
            host.className = 'fixed top-4 right-4 z-[100] space-y-2 pointer-events-none';
            document.body.appendChild(host);
        }
        return host;
    }

    function showToast(message, type = 'success') {
        const host = ensureToastHost();
        const toast = document.createElement('div');
        const palette = {
            success: 'bg-success text-white border-success/70',
            error: 'bg-error text-white border-error/70',
            info: 'bg-primary text-white border-primary/70'
        };
        const style = palette[type] || palette.info;
        toast.className = `pointer-events-auto border ${style} shadow-xl rounded-lg px-4 py-3 transform transition-all duration-300 ease-out opacity-0 translate-x-8`;
        toast.innerHTML = `<p class="text-sm font-medium">${message}</p>`;
        host.appendChild(toast);

        requestAnimationFrame(() => {
            toast.classList.remove('opacity-0', 'translate-x-8');
        });

        setTimeout(() => {
            toast.classList.add('opacity-0', 'translate-x-8');
            setTimeout(() => toast.remove(), 280);
        }, 2800);
    }
    
    // Get event slug from URL
    function getEventSlug() {
        const urlParams = new URLSearchParams(window.location.search);
        return urlParams.get('event') || urlParams.get('slug');
    }
    
    // Wait for Supabase client
    async function waitForSupabase() {
        // Kick auth init if available
        try {
            if (window.HogwartsAuth?.initSupabase) {
                await window.HogwartsAuth.initSupabase();
            }
        } catch (e) {
            // ignore and keep waiting
        }

        for (let i = 0; i < 40; i++) {
            if (window.supabaseClient) return window.supabaseClient;
            await new Promise(resolve => setTimeout(resolve, 200));
        }
        throw new Error('Supabase client not available');
    }
    
    // Fetch event details
    async function fetchEventDetails(slug) {
        const client = await waitForSupabase();

        // Prefer RPCs (they provide counts + usernames/houses).
        try {
            const [{ data: eventRows, error: eventError }, { data: participantsRows, error: participantsError }] = await Promise.all([
                client.rpc('get_event_by_slug', { in_slug: slug }),
                client.rpc('get_event_participants', { in_event_slug: slug })
            ]);
            if (eventError) throw eventError;
            if (participantsError) throw participantsError;

            const event = Array.isArray(eventRows) ? eventRows[0] : eventRows;
            if (!event) throw new Error('Event not found');

            return {
                ...event,
                event_participants: Array.isArray(participantsRows) ? participantsRows : []
            };
        } catch (e) {
            // Fallback to direct table reads if RPCs are not available
            const { data: event, error } = await client
                .from('events')
                .select('*')
                .eq('slug', slug)
                .single();
            if (error) throw error;

            const { data: participants, error: participantsError } = await client
                .from('event_participants')
                .select('user_id,status,submission_url,points_awarded,joined_at')
                .eq('event_id', event.id);
            if (participantsError) throw participantsError;

            return {
                ...event,
                event_participants: Array.isArray(participants) ? participants : []
            };
        }
    }
    
    // Fetch user participation status
    async function fetchUserParticipation(eventId, userId, eventSlug) {
        const client = await waitForSupabase();

        // Prefer auth-aware RPC (does not require a userId on the client).
        if (eventSlug) {
            try {
                const { data, error } = await client.rpc('get_user_participation', { in_event_slug: eventSlug });
                if (error) throw error;
                return Array.isArray(data) ? (data[0] || null) : data;
            } catch (e) {
                // fall through
            }
        }

        if (!userId) return null;
        const { data, error } = await client
            .from('event_participants')
            .select('*')
            .eq('event_id', eventId)
            .eq('user_id', userId)
            .single();
        if (error && error.code !== 'PGRST116') throw error;
        return data;
    }
    
    // Format date for display
    function formatDate(dateString) {
        const date = new Date(dateString);
        return date.toLocaleDateString('es-ES', {
            year: 'numeric',
            month: 'long',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        });
    }
    
    // Calculate days remaining
    function getDaysRemaining(endDate) {
        const now = new Date();
        const end = new Date(endDate);
        const diffTime = end - now;
        const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
        return Math.max(0, diffDays);
    }

    function toInt(value, fallback = 0) {
        const n = typeof value === 'number' ? value : parseInt(String(value ?? '').replace(/[^0-9-]/g, ''), 10);
        return Number.isFinite(n) ? n : fallback;
    }
    
    // Get event type configuration
    function getEventTypeConfig(type) {
        const configs = {
            'tournament': {
                badge: 'TORNEO INTELECTUAL',
                bgClass: 'bg-ravenclaw',
                color: 'text-ravenclaw',
                icon: 'M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z'
            },
            'contest': {
                badge: 'CONCURSO ARTÍSTICO',
                bgClass: 'bg-hufflepuff',
                color: 'text-hufflepuff',
                icon: 'M4 3a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V5a2 2 0 00-2-2H4zm12 12H4l4-8 3 6 2-4 3 6z'
            },
            'celebration': {
                badge: 'CELEBRACIÓN',
                bgClass: 'bg-success',
                color: 'text-success',
                icon: 'M6 2a1 1 0 00-1 1v1H4a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2h-1V3a1 1 0 10-2 0v1H7V3a1 1 0 00-1-1zm0 5a1 1 0 000 2h8a1 1 0 100-2H6z'
            }
        };
        return configs[type] || configs['contest'];
    }
    
    // Render event details
    function renderEventDetails(event) {
        const config = getEventTypeConfig(event.type);
        const daysRemaining = getDaysRemaining(event.end_at);
        const participantsCount = event.participants_count != null
            ? toInt(event.participants_count, 0)
            : (event.event_participants?.length || 0);
        const submissionsCount = event.submissions_count != null
            ? toInt(event.submissions_count, 0)
            : (event.event_participants?.filter(p => p.submission_url).length || 0);
        
        // Update page title and breadcrumb
        document.title = `${event.title} - Hogwarts Community Hub`;
        document.getElementById('breadcrumb-event-title').textContent = event.title;
        
        // Update hero section
        if (event.cover_url) {
            document.getElementById('event-bg-image').style.backgroundImage = `url('${event.cover_url}')`;
        }
        
        document.getElementById('event-type-badge').textContent = config.badge;
        document.getElementById('event-type-badge').className = `${config.bgClass} text-white px-4 py-2 rounded-full text-sm font-cta font-semibold mr-4`;
        
        document.getElementById('event-title').textContent = event.title;
        document.getElementById('event-description').textContent = event.description || '';
        
        // Update stats
        document.getElementById('event-participants').textContent = participantsCount;
        document.getElementById('event-reward-points').textContent = event.reward_points || 0;
        document.getElementById('event-days-remaining').textContent = daysRemaining;
        document.getElementById('event-submissions').textContent = submissionsCount;
        
        // Update dates
        document.getElementById('event-start-date').textContent = formatDate(event.start_at);
        document.getElementById('event-end-date').textContent = formatDate(event.end_at);
        
        // Update status
        const statusEl = document.getElementById('event-status');
        if (event.status === 'active') {
            statusEl.textContent = 'ACTIVO';
            statusEl.className = 'bg-success text-white px-3 py-1 rounded-full text-xs font-semibold';
        } else if (event.status === 'completed') {
            statusEl.textContent = 'COMPLETADO';
            statusEl.className = 'bg-gray-500 text-white px-3 py-1 rounded-full text-xs font-semibold';
        }
    }
    
    // Render participation status and actions
    function renderParticipationPanel(event, participation) {
        const statusContainer = document.getElementById('participation-status');
        const actionsContainer = document.getElementById('action-buttons');
        
        if (!currentUser) {
            statusContainer.innerHTML = `
                <div class="bg-warning/20 border border-warning/30 rounded-lg p-4 text-center">
                    <p class="text-warning font-medium">Inicia sesión para participar</p>
                </div>
            `;
            actionsContainer.innerHTML = `
                <a href="user_login.html" class="btn-primary w-full text-center">Iniciar Sesión</a>
            `;
            return;
        }
        
        if (!participation) {
            statusContainer.innerHTML = `
                <div class="bg-blue-500/20 border border-blue-500/30 rounded-lg p-4 text-center">
                    <p class="text-blue-400 font-medium">¡Únete a este evento!</p>
                </div>
            `;
            actionsContainer.innerHTML = `
                <button id="join-event-btn" class="btn-primary w-full">Participar Ahora</button>
            `;
        } else {
            const statusText = {
                'joined': 'Participando',
                'submitted': 'Enviado',
                'winner': 'Ganador',
                'disqualified': 'Descalificado'
            };
            
            const statusColor = {
                'joined': 'bg-blue-500/20 border-blue-500/30 text-blue-400',
                'submitted': 'bg-success/20 border-success/30 text-success',
                'winner': 'bg-secondary/20 border-secondary/30 text-secondary',
                'disqualified': 'bg-error/20 border-error/30 text-error'
            };
            
            statusContainer.innerHTML = `
                <div class="${statusColor[participation.status]} border rounded-lg p-4 text-center">
                    <p class="font-medium">${statusText[participation.status]}</p>
                    <p class="text-xs mt-1">Desde: ${formatDate(participation.joined_at)}</p>
                </div>
            `;
            
            let buttons = '';
            if (participation.status === 'joined' && event.status === 'active') {
                buttons += `<button id="submit-work-btn" class="btn-secondary w-full">Enviar Trabajo</button>`;
            }
            if (participation.submission_url) {
                buttons += `<a href="${participation.submission_url}" target="_blank" class="btn-secondary w-full text-center">Ver mi Envío</a>`;
            }
            
            actionsContainer.innerHTML = buttons;
        }
    }
    
    // Render event details content
    function renderEventDetailsTab(event) {
        const detailsContent = document.getElementById('event-details-content');
        const rulesContent = document.getElementById('event-rules-content');
        
        // Basic event information
        detailsContent.innerHTML = `
            <div class="space-y-4">
                <div>
                    <h4 class="font-semibold text-text-primary mb-2">Tipo de Evento</h4>
                    <p class="text-text-secondary">${getEventTypeConfig(event.type).badge}</p>
                </div>
                <div>
                    <h4 class="font-semibold text-text-primary mb-2">Duración</h4>
                    <p class="text-text-secondary">
                        Del ${formatDate(event.start_at)} al ${formatDate(event.end_at)}
                    </p>
                </div>
                <div>
                    <h4 class="font-semibold text-text-primary mb-2">Recompensa</h4>
                    <p class="text-text-secondary">${event.reward_points || 0} puntos para tu casa</p>
                </div>
                ${event.metadata?.requirements ? `
                <div>
                    <h4 class="font-semibold text-text-primary mb-2">Requisitos</h4>
                    <p class="text-text-secondary">${event.metadata.requirements}</p>
                </div>
                ` : ''}
            </div>
        `;
        
        // Rules and guidelines
        rulesContent.innerHTML = `
            <div class="space-y-4">
                <div>
                    <h4 class="font-semibold text-text-primary mb-2">Reglas Generales</h4>
                    <ul class="list-disc list-inside text-text-secondary space-y-1">
                        <li>Respeta las normas de la comunidad</li>
                        <li>El contenido debe ser original y apropiado</li>
                        <li>Solo se permite una participación por usuario</li>
                        <li>Los envíos deben realizarse antes del cierre</li>
                    </ul>
                </div>
                ${event.metadata?.rules ? `
                <div>
                    <h4 class="font-semibold text-text-primary mb-2">Reglas Específicas</h4>
                    <div class="text-text-secondary">${event.metadata.rules}</div>
                </div>
                ` : ''}
                <div>
                    <h4 class="font-semibold text-text-primary mb-2">Evaluación</h4>
                    <p class="text-text-secondary">
                        Los ganadores serán seleccionados por votación de la comunidad y/o jueces especializados.
                    </p>
                </div>
            </div>
        `;
    }
    
    // Render participants
    function renderParticipants(participants) {
        const grid = document.getElementById('participants-grid');
        
        if (!participants || participants.length === 0) {
            grid.innerHTML = `
                <div class="col-span-full text-center py-8">
                    <p class="text-text-secondary">Aún no hay participantes registrados.</p>
                </div>
            `;
            return;
        }
        
        grid.innerHTML = participants.map(participant => `
            <div class="card p-4">
                <div class="flex items-center space-x-3">
                    <div class="w-10 h-10 bg-primary/10 rounded-full flex items-center justify-center">
                        <svg class="w-5 h-5 text-primary" fill="currentColor" viewBox="0 0 20 20">
                            <path d="M13 6a3 3 0 11-6 0 3 3 0 016 0zM18 8a2 2 0 11-4 0 2 2 0 014 0zM14 15a4 4 0 00-8 0v3h8v-3z"/>
                        </svg>
                    </div>
                    <div class="flex-1 min-w-0">
                        <p class="font-medium text-text-primary">${participant.username || `Participante ${String(participant.user_id || '').slice(-4)}`}</p>
                        <p class="text-sm text-text-secondary">
                            ${participant.house_name ? `${participant.house_name} · ` : ''}${participant.status === 'submitted' ? 'Ha enviado su trabajo' : 'Participando'}
                        </p>
                    </div>
                    ${participant.status === 'winner' ? `
                        <div class="flex-shrink-0">
                            <svg class="w-5 h-5 text-secondary" fill="currentColor" viewBox="0 0 20 20">
                                <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"/>
                            </svg>
                        </div>
                    ` : ''}
                </div>
            </div>
        `).join('');
    }
    
    // Handle tab switching
    function initializeTabs() {
        const tabButtons = document.querySelectorAll('.tab-button');
        const tabContents = document.querySelectorAll('.tab-content');
        
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
                
                // Load tab-specific content
                if (tabId === 'participants') {
                    renderParticipants(currentEvent?.event_participants);
                }
            });
        });
    }
    
    // Handle event actions
    async function handleJoinEvent() {
        try {
            const client = await waitForSupabase();
            await client.rpc('join_event', { in_slug: currentEvent.slug });
            
            // Refresh event and counters immediately after joining
            currentEvent = await fetchEventDetails(currentEvent.slug);

            // Refresh participation status
            userParticipation = await fetchUserParticipation(currentEvent.id, currentUser?.id, currentEvent.slug);
            renderEventDetails(currentEvent);
            renderParticipationPanel(currentEvent, userParticipation);
            renderEventDetailsTab(currentEvent);
            renderParticipants(currentEvent?.event_participants);
            
            // Show success message
            showToast('¡Te has unido al evento exitosamente!', 'success');
        } catch (error) {
            console.error('Error joining event:', error);
            showToast('Error al unirse al evento. Inténtalo de nuevo.', 'error');
        }
    }
    
    // Handle submission modal
    function showSubmissionModal() {
        const modal = document.getElementById('submission-modal');
        const content = document.getElementById('submission-modal-content');
        
        content.innerHTML = `
            <form id="submission-form" class="space-y-4">
                <div>
                    <label class="block text-sm font-medium text-text-primary mb-2">
                        Enlace a tu trabajo
                    </label>
                    <input 
                        type="url" 
                        id="submission-url" 
                        class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent"
                        placeholder="https://..."
                        required
                    >
                    <p class="text-sm text-text-secondary mt-1">
                        Enlace a tu trabajo (Google Drive, Dropbox, etc.)
                    </p>
                </div>
                <div>
                    <label class="block text-sm font-medium text-text-primary mb-2">
                        Descripción (opcional)
                    </label>
                    <textarea 
                        id="submission-description" 
                        class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent"
                        rows="3"
                        placeholder="Describe tu trabajo..."
                    ></textarea>
                </div>
                <div class="flex space-x-3">
                    <button type="submit" class="btn-primary flex-1">Enviar</button>
                    <button type="button" id="cancel-submission" class="btn-secondary flex-1">Cancelar</button>
                </div>
            </form>
        `;
        
        modal.classList.remove('hidden');
        
        // Handle form submission
        document.getElementById('submission-form').addEventListener('submit', handleSubmission);
        document.getElementById('cancel-submission').addEventListener('click', () => {
            modal.classList.add('hidden');
        });
    }
    
    // Handle work submission
    async function handleSubmission(e) {
        e.preventDefault();
        
        const url = document.getElementById('submission-url').value;
        const description = document.getElementById('submission-description').value;
        
        try {
            const client = await waitForSupabase();
            
            // Update participation with submission
            await client
                .from('event_participants')
                .update({
                    status: 'submitted',
                    submission_url: url,
                    metadata: description ? { description } : null
                })
                .eq('event_id', currentEvent.id)
                .eq('user_id', currentUser.id);
            
            // Refresh participation status
            userParticipation = await fetchUserParticipation(currentEvent.id, currentUser.id);
            renderParticipationPanel(currentEvent, userParticipation);
            
            // Close modal and show success
            document.getElementById('submission-modal').classList.add('hidden');
            showToast('¡Trabajo enviado exitosamente!', 'success');
            
        } catch (error) {
            console.error('Error submitting work:', error);
            showToast('Error al enviar el trabajo. Inténtalo de nuevo.', 'error');
        }
    }
    
    // Initialize page
    async function initialize() {
        try {
            const slug = getEventSlug();
            if (!slug) {
                window.location.href = 'community_events_challenges_center.html';
                return;
            }
            
            // Get current user
            try {
                if (window.getCurrentUser) {
                    currentUser = await window.getCurrentUser();
                } else if (window.HogwartsAuth?.getCurrentUser) {
                    currentUser = await window.HogwartsAuth.getCurrentUser();
                }
            } catch (e) {
                currentUser = null;
            }
            
            // Fetch event details
            currentEvent = await fetchEventDetails(slug);
            
            // Fetch user participation if logged in
            userParticipation = await fetchUserParticipation(currentEvent.id, currentUser?.id, currentEvent.slug);
            
            // Render everything
            renderEventDetails(currentEvent);
            renderParticipationPanel(currentEvent, userParticipation);
            renderEventDetailsTab(currentEvent);
            
            // Initialize tabs
            initializeTabs();
            
            // Add event listeners
            document.addEventListener('click', (e) => {
                if (e.target.id === 'join-event-btn') {
                    handleJoinEvent();
                } else if (e.target.id === 'submit-work-btn') {
                    showSubmissionModal();
                } else if (e.target.id === 'close-modal' || e.target.id === 'close-submission-modal') {
                    e.target.closest('.fixed').classList.add('hidden');
                }
            });
            
        } catch (error) {
            console.error('Error initializing event page:', error);
            document.getElementById('event-title').textContent = 'Error al cargar el evento';
            document.getElementById('event-description').textContent = 'No se pudo cargar la información del evento.';
        }
    }
    
    // Auto-initialize when DOM is ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initialize);
    } else {
        initialize();
    }
    
})();
