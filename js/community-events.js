// Share event function
function shareEvent(slug, title) {
  const url = `${window.location.origin}${window.location.pathname.replace('community_events_challenges_center.html', '')}event-detail.html?event=${slug}`;
  const text = `¡Mira este evento mágico! "${title}" - ${url}`;

  if (navigator.share) {
    navigator.share({
      title: title,
      text: `¡Mira este evento mágico! "${title}"`,
      url: url
    }).catch(err => {
      console.log('Error sharing:', err);
      fallbackShare(text);
    });
  } else {
    fallbackShare(text);
  }
}

function fallbackShare(text) {
  if (navigator.clipboard) {
    navigator.clipboard.writeText(text).then(() => {
      // Show a temporary success message
      showToast('¡Enlace copiado al portapapeles!', 'success');
    }).catch(err => {
      console.error('Error copying to clipboard:', err);
      showToast('Error al copiar el enlace', 'error');
    });
  } else {
    // Fallback for older browsers
    const textArea = document.createElement('textarea');
    textArea.value = text;
    document.body.appendChild(textArea);
    textArea.select();
    try {
      document.execCommand('copy');
      showToast('¡Enlace copiado al portapapeles!', 'success');
    } catch (err) {
      showToast('Error al copiar el enlace', 'error');
    }
    document.body.removeChild(textArea);
  }
}

function showToast(message, type = 'info') {
  // Create toast notification
  const toast = document.createElement('div');
  toast.className = `fixed top-4 right-4 z-50 p-4 rounded-lg shadow-lg max-w-sm ${
    type === 'success' ? 'bg-success text-white' :
    type === 'error' ? 'bg-error text-white' :
    'bg-primary text-white'
  }`;
  toast.innerHTML = `
    <div class="flex items-center">
      <span>${message}</span>
      <button onclick="this.parentElement.parentElement.remove()" class="ml-4 text-white hover:text-gray-200">
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
        </svg>
      </button>
    </div>
  `;
  document.body.appendChild(toast);

  // Auto remove after 3 seconds
  setTimeout(() => {
    if (toast.parentElement) {
      toast.remove();
    }
  }, 3000);
}

function safeNumber(n) {
  if (typeof n === 'number' && isFinite(n)) return n;
  if (typeof n === 'string') {
    const parsed = parseInt(n.replace(/[^0-9-]/g, ''), 10);
    if (!isNaN(parsed)) return parsed;
  }
  return 0;
}

function unwrapRpcObject(data, key) {
  if (Array.isArray(data)) {
    if (data.length === 1 && data[0] && typeof data[0] === 'object' && key in data[0]) {
      return data[0][key];
    }
    return data;
  }
  return data;
}

async function ensureClient() {
  if (window.supabaseClient) return window.supabaseClient;

  // Kick auth init if available (some pages load this module before auth finishes).
  try {
    if (window.HogwartsAuth?.initSupabase) {
      await window.HogwartsAuth.initSupabase();
      if (window.supabaseClient) return window.supabaseClient;
    }
  } catch (e) {
    // ignore; we'll keep waiting below
  }

  // Wait for auth.js to initialize Supabase (up to ~8s)
  for (let i = 0; i < 40; i++) {
    if (window.supabaseClient) return window.supabaseClient;
    await new Promise(r => setTimeout(r, 200));
  }

  console.warn('[community-events] Supabase client no disponible después de 8 segundos');
  return null;
}

async function fetchQuickStatsFallback(client) {
  const nowIso = new Date().toISOString();
  const { data: activeEvents, error: activeError } = await client
    .from('events')
    .select('id,reward_points,end_at,start_at,status')
    .eq('status', 'active')
    .lte('start_at', nowIso)
    .gte('end_at', nowIso);

  if (activeError) throw activeError;

  const events = Array.isArray(activeEvents) ? activeEvents : [];
  const eventIds = events.map(e => e.id).filter(Boolean);

  // Use the new RPC to get participant count (bypasses RLS)
  let uniqueParticipants = 0;
  try {
    const { data: countData, error: countError } = await client.rpc('get_active_event_participants_count');
    if (!countError && countData !== null) {
      uniqueParticipants = safeNumber(countData);
    }
  } catch (e) {
    // Fallback to direct query if RPC doesn't exist yet
    console.warn('[community-events] get_active_event_participants_count RPC not available, using fallback');
    if (eventIds.length > 0) {
      const { data: participantsData, error: participantsError } = await client
        .from('event_participants')
        .select('event_id,user_id')
        .in('event_id', eventIds);
      if (!participantsError && Array.isArray(participantsData)) {
        uniqueParticipants = new Set(participantsData.map(p => p.user_id)).size;
      }
    }
  }

  const pointsInPlay = events.reduce((sum, event) => sum + safeNumber(event.reward_points), 0);

  // Calculate days remaining for the most recently started event (not the minimum)
  // Sort by start_at descending and take the first one
  let minDaysRemaining = 0;
  if (events.length > 0) {
    const sortedEvents = [...events].sort((a, b) => 
      new Date(b.start_at).getTime() - new Date(a.start_at).getTime()
    );
    const mostRecentEvent = sortedEvents[0];
    const daysRemaining = Math.ceil((new Date(mostRecentEvent.end_at) - new Date()) / (1000 * 60 * 60 * 24));
    minDaysRemaining = Number.isFinite(daysRemaining) && daysRemaining >= 0 ? daysRemaining : 0;
  }

  return {
    active_events_count: events.length,
    active_participants_count: uniqueParticipants,
    points_in_play: pointsInPlay,
    min_days_remaining: minDaysRemaining
  };
}

async function fetchQuickStats() {
  const client = await ensureClient();
  if (!client) return null;
  try {
    const { data, error } = await client.rpc('get_quick_stats');
    if (error) throw error;
    const normalized = unwrapRpcObject(data, 'get_quick_stats');
    if (normalized && !Array.isArray(normalized)) return normalized;
    return await fetchQuickStatsFallback(client);
  } catch (e) {
    console.error('[community-events] get_quick_stats error', e);
    try {
      return await fetchQuickStatsFallback(client);
    } catch (fallbackError) {
      console.error('[community-events] quick stats fallback error', fallbackError);
      return null;
    }
  }
}

function renderQuickStats(stats) {
  if (!stats) return;
  const activeEventsEl = document.getElementById('stat-active-events');
  const participantsEl = document.getElementById('stat-active-participants');
  const pointsEl = document.getElementById('stat-points-in-play');
  const daysEl = document.getElementById('stat-days-remaining');

  if (activeEventsEl) activeEventsEl.textContent = `${safeNumber(stats.active_events_count)}`;
  if (participantsEl) participantsEl.textContent = `${safeNumber(stats.active_participants_count)}`;
  if (pointsEl) pointsEl.textContent = `${safeNumber(stats.points_in_play).toLocaleString()}`;
  if (daysEl) daysEl.textContent = `${safeNumber(stats.min_days_remaining)}`;
}

async function fetchFeaturedEvents(limit = 6) {
  const client = await ensureClient();
  if (!client) return [];
  try {
    const { data, error } = await client.rpc('list_featured_events', { in_limit: limit });
    if (error) throw error;
    return Array.isArray(data) ? data : [];
  } catch (e) {
    console.error('[community-events] list_featured_events error', e);
    return [];
  }
}

function renderFeaturedEvents(items) {
  const grid = document.getElementById('featured-events-grid');
  if (!grid) return;

  if (!items || items.length === 0) {
    // Show empty state
    grid.innerHTML = `
      <div class="col-span-full text-center py-12">
        <svg class="w-16 h-16 text-text-secondary mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3a2 2 0 012-2h4a2 2 0 012 2v4m-6 4v10a2 2 0 002 2h4a2 2 0 002-2V11M9 11h6"/>
        </svg>
        <h3 class="font-headline text-xl font-medium text-text-primary mb-2">No hay eventos destacados</h3>
        <p class="text-text-secondary">Los eventos destacados aparecerán aquí cuando sean creados.</p>
      </div>
    `;
    return;
  }

  const html = items.map(ev => {
    const days = typeof ev.ends_in_days === 'number' ? `${ev.ends_in_days} días restantes` : '';
    const participants = typeof ev.participants_count === 'number' ? `${ev.participants_count} participantes` : '';

    // Get the right button text and URL based on event type
    let buttonText = 'Ver Detalles';
    let buttonClass = 'btn-secondary';
    if (ev.type === 'tournament') {
      buttonText = 'Participar Ahora';
      buttonClass = 'btn-primary';
    } else if (ev.type === 'contest') {
      buttonText = 'Ver Detalles';
      buttonClass = 'btn-secondary';
    } else if (ev.type === 'celebration') {
      buttonText = 'Comenzar Historia';
      buttonClass = 'btn-secondary';
    }

    return `
    <div class="card overflow-hidden hover-scale group">
      <div class="relative h-48 overflow-hidden">
        <img src="${ev.cover_url || ''}" alt="${ev.title || ''}" class="w-full h-full object-cover group-hover:scale-105 magical-transition" onerror="this.src='https://images.pexels.com/photos/159711/books-bookstore-book-reading-159711.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2'; this.onerror=null;" />
        <div class="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent"></div>
        <div class="absolute top-4 left-4">
          <span class="bg-warning text-text-primary px-3 py-1 rounded-full text-sm font-cta font-semibold">
            DESTACADO
          </span>
        </div>
        <div class="absolute top-4 right-4">
          <button onclick="shareEvent('${ev.slug}', '${ev.title}')" class="bg-white/20 backdrop-blur-sm text-white p-2 rounded-full hover:bg-white/30 transition-colors" title="Compartir evento">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8.684 13.342C8.886 12.938 9 12.482 9 12c0-.482-.114-.938-.316-1.342m0 2.684a3 3 0 110-2.684m0 2.684l6.632 3.316m-6.632-6l6.632-3.316m0 0a3 3 0 105.367-2.684 3 3 0 00-5.367 2.684zm0 9.316a3 3 0 105.367 2.684 3 3 0 00-5.367-2.684z"/>
            </svg>
          </button>
        </div>
        ${days ? `<div class="absolute bottom-4 right-4"><span class="bg-primary text-white px-3 py-1 rounded-full text-sm font-cta font-semibold">${days}</span></div>` : ''}
      </div>
      <div class="p-6">
        <div class="flex items-center mb-3">
          <svg class="w-5 h-5 text-secondary mr-2" fill="currentColor" viewBox="0 0 20 20"><path d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
          <span class="text-sm font-cta font-semibold text-text-secondary">${ev.type?.toUpperCase() || ''}</span>
        </div>
        <h3 class="font-headline text-xl font-medium text-text-primary mb-3">${ev.title || ''}</h3>
        <div class="flex items-center justify-between mb-4">
          <div class="flex items-center text-sm text-text-secondary">
            <svg class="w-4 h-4 mr-1" fill="currentColor" viewBox="0 0 20 20"><path d="M13 6a3 3 0 11-6 0 3 3 0 016 0zM18 8a2 2 0 11-4 0 2 2 0 014 0zM14 15a4 4 0 00-8 0v3h8v-3z"/></svg>
            <span>${participants}</span>
          </div>
          <div class="flex items-center text-sm text-secondary">
            <svg class="w-4 h-4 mr-1" fill="currentColor" viewBox="0 0 20 20"><path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"/></svg>
            <span>${ev.reward_points || 0} puntos</span>
          </div>
        </div>
        <a href="event-detail.html?event=${ev.slug}" class="${buttonClass} w-full hover-scale magical-transition text-center block">${buttonText}</a>
      </div>
    </div>`;
  }).join('');
  grid.innerHTML = html;
}

async function fetchUpcoming(limit = 5) {
  const client = await ensureClient();
  if (!client) return [];
  try {
    const { data, error } = await client.rpc('list_upcoming_events', { in_limit: limit });
    if (error) throw error;
    return Array.isArray(data) ? data : [];
  } catch (e) {
    console.error('[community-events] list_upcoming_events error', e);
    return [];
  }
}

function renderUpcoming(items) {
  const list = document.getElementById('upcoming-events-list');
  if (!list) return;

  if (!items || items.length === 0) {
    list.innerHTML = `
      <div class="text-center py-8">
        <p class="text-text-secondary">No hay eventos próximos</p>
        <p class="text-sm text-text-secondary mt-2">Los próximos eventos aparecerán aquí.</p>
      </div>
    `;
    return;
  }

  const html = items.map(ev => `
    <div class="flex items-start space-x-3 p-3 rounded-lg hover:bg-primary/5 magical-transition cursor-pointer" onclick="window.location.href='event-detail.html?event=${ev.slug}'">
      <div class="flex-shrink-0 w-12 h-12 bg-primary/10 rounded-lg flex items-center justify-center">
        <svg class="w-6 h-6 text-primary" fill="currentColor" viewBox="0 0 20 20"><path d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
      </div>
      <div class="flex-1 min-w-0">
        <p class="font-cta font-semibold text-text-primary text-sm">${ev.title || ''}</p>
        <p class="text-text-secondary text-xs">${new Date(ev.start_at).toLocaleString()}</p>
        <div class="flex items-center justify-between mt-2">
          <span class="text-xs text-text-secondary">${ev.type?.toUpperCase() || ''}</span>
          <button onclick="event.stopPropagation(); shareEvent('${ev.slug}', '${ev.title}')" class="text-primary hover:text-primary-700 text-xs" title="Compartir">
            <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8.684 13.342C8.886 12.938 9 12.482 9 12c0-.482-.114-.938-.316-1.342m0 2.684a3 3 0 110-2.684m0 2.684l6.632 3.316m-6.632-6l6.632-3.316m0 0a3 3 0 105.367-2.684 3 3 0 00-5.367 2.684zm0 9.316a3 3 0 105.367 2.684 3 3 0 00-5.367-2.684z"/>
            </svg>
          </button>
        </div>
      </div>
    </div>`).join('');
  list.innerHTML = html;
}

async function fetchIndividualChallenges() {
  const client = await ensureClient();
  if (!client) return [];
  try {
    const { data, error } = await client.rpc('list_individual_challenges');
    if (error) throw error;
    return Array.isArray(data) ? data : [];
  } catch (e) {
    console.error('[community-events] list_individual_challenges error', e);
    return [];
  }
}

function renderIndividualChallenges(items) {
  const list = document.getElementById('individual-challenges-list');
  if (!list || !items || items.length === 0) return;
  const html = items.map(ch => `
    <div class="border border-gray-200 rounded-lg p-4 hover:border-accent/30 magical-transition">
      <div class="flex items-center justify-between mb-2">
        <h4 class="font-cta font-semibold text-text-primary">${ch.title}</h4>
        <span class="text-sm text-accent font-semibold">+${ch.reward_points} pts</span>
      </div>
      <p class="text-text-secondary text-sm mb-3">${ch.description || ''}</p>
      <div class="flex items-center justify-between">
        <div class="flex items-center text-sm text-text-secondary">
          <svg class="w-4 h-4 mr-1" fill="currentColor" viewBox="0 0 20 20"><path d="M13 6a3 3 0 11-6 0 3 3 0 016 0zM18 8a2 2 0 11-4 0 2 2 0 014 0zM14 15a4 4 0 00-8 0v3h8v-3z"/></svg>
          <span>${ch.completed_count} completados</span>
        </div>
        <button data-slug="${ch.slug}" class="text-accent hover:text-accent-700 font-cta font-semibold text-sm js-submit-attempt">Intentar</button>
      </div>
    </div>`).join('');
  list.insertAdjacentHTML('afterbegin', html);
}

async function fetchHouseChallenges() {
  const client = await ensureClient();
  if (!client) return [];
  try {
    const { data, error } = await client.rpc('list_house_challenges');
    if (error) throw error;
    return Array.isArray(data) ? data : [];
  } catch (e) {
    console.error('[community-events] list_house_challenges error', e);
    return [];
  }
}

function renderHouseChallenges(items) {
  const list = document.getElementById('house-challenges-list');
  if (!list || !items || items.length === 0) return;
  const html = items.map(ch => {
    const total = ch.target_count || 0;
    const gry = Math.min(100, Math.round(((ch.gryffindor || 0) / (total || 1)) * 100));
    return `
    <div class="border border-primary/30 rounded-lg p-4 hover:border-primary/50 magical-transition">
      <div class="flex items-center justify-between mb-2">
        <div class="flex items-center"><div class="w-3 h-3 bg-primary rounded-full mr-2"></div>
          <h4 class="font-cta font-semibold text-text-primary">${ch.title}</h4></div>
        <span class="text-sm text-primary font-semibold">+${ch.reward_points} pts</span>
      </div>
      <p class="text-text-secondary text-sm mb-3">Meta: ${ch.target_count || 0}</p>
      <div class="flex items-center justify-between">
        <div class="w-full bg-gray-200 rounded-full h-2 mr-3">
          <div class="bg-primary h-2 rounded-full" style="width: ${gry}%"></div>
        </div>
        <span class="text-sm text-text-secondary">${ch.gryffindor || 0}/${ch.target_count || 0}</span>
      </div>
    </div>`;
  }).join('');
  list.insertAdjacentHTML('afterbegin', html);
}

async function fetchActivePoll() {
  const client = await ensureClient();
  if (!client) return null;
  try {
    const { data, error } = await client.rpc('get_polls_active');
    if (error) throw error;
    return Array.isArray(data) && data.length ? data[0] : null;
  } catch (e) {
    console.error('[community-events] get_polls_active error', e);
    return null;
  }
}

async function fetchPollOptions(pollId) {
  const client = await ensureClient();
  if (!client) return [];
  try {
    const { data, error } = await client.rpc('get_poll_options_with_counts', { in_poll_id: pollId });
    if (error) throw error;
    return Array.isArray(data) ? data : [];
  } catch (e) {
    console.error('[community-events] get_poll_options_with_counts error', e);
    return [];
  }
}

function renderActivePoll(poll, options) {
  const list = document.getElementById('active-poll-options');
  if (!list || !poll || !options || options.length === 0) return;
  const html = options.map(opt => `
    <div class="border border-gray-200 rounded-lg p-4 hover:border-primary/30 magical-transition cursor-pointer js-vote-option" data-poll-slug="${poll.slug}" data-option-id="${opt.option_id}">
      <div class="flex items-center justify-between mb-2">
        <h4 class="font-cta font-semibold text-text-primary">${opt.label}</h4>
        <span class="text-sm text-primary font-semibold">${opt.percent || 0}%</span>
      </div>
      <div class="w-full bg-gray-200 rounded-full h-2">
        <div class="bg-primary h-2 rounded-full" style="width: ${opt.percent || 0}%"></div>
      </div>
    </div>`).join('');
  list.insertAdjacentHTML('afterbegin', html);
}

async function fetchRecentPollResults(limit = 1) {
  const client = await ensureClient();
  if (!client) return [];
  try {
    const { data, error } = await client.rpc('get_recent_poll_results', { in_limit: limit });
    if (error) throw error;
    return Array.isArray(data) ? data : [];
  } catch (e) {
    console.error('[community-events] get_recent_poll_results error', e);
    return [];
  }
}

function renderRecentPollResults(items) {
  const list = document.getElementById('recent-poll-results-list');
  if (!list || !items || items.length === 0) return;
  const html = items.map(pr => `
    <div class="border border-gray-200 rounded-lg p-4">
      <div class="flex items-center justify-between mb-2">
        <h4 class="font-cta font-semibold text-text-primary">${pr.title}</h4>
        <span class="text-sm text-text-secondary font-semibold">${(pr.total_votes || 0)} votos</span>
      </div>
      <p class="text-text-secondary text-sm">Finalizado: ${new Date(pr.ended_at).toLocaleString()}</p>
    </div>`).join('');
  list.insertAdjacentHTML('afterbegin', html);
}

async function refreshQuickStatsUI() {
  const stats = await fetchQuickStats();
  renderQuickStats(stats);
}

async function handleClicks(e) {
  const t = e.target;
  const client = await ensureClient();
  if (!client) return;
  try {
    if (t.closest('.js-join-event')) {
      const btn = t.closest('.js-join-event');
      const slug = btn?.getAttribute('data-slug');
      if (slug) {
        await client.rpc('join_event', { in_slug: slug });
        btn.textContent = '¡Participando!';
        btn.disabled = true;
        await refreshQuickStatsUI();
        // If this page shows featured events, refresh to update counts.
        const featured = await fetchFeaturedEvents(6);
        renderFeaturedEvents(featured);
      }
    }
    if (t.closest('.js-submit-attempt')) {
      const btn = t.closest('.js-submit-attempt');
      const slug = btn?.getAttribute('data-slug');
      if (slug) {
        await client.rpc('submit_challenge_attempt', { in_slug: slug, in_evidence_url: null });
        btn.textContent = 'Intento creado';
        btn.disabled = true;
        await refreshQuickStatsUI();
      }
    }
    if (t.closest('.js-vote-option')) {
      const opt = t.closest('.js-vote-option');
      const pollSlug = opt?.getAttribute('data-poll-slug');
      const optionId = opt?.getAttribute('data-option-id');
      if (pollSlug && optionId) {
        await client.rpc('vote_poll', { in_slug: pollSlug, in_option: optionId });
        opt.classList.add('border-primary','bg-primary/5');
        await refreshQuickStatsUI();
      }
    }
  } catch (err) {
    console.error('[community-events] action error', err);
  }
}

async function fetchPastEvents(limit = 9) {
  const client = await ensureClient();
  if (!client) return [];
  try {
    const { data, error } = await client
      .from('events')
      .select('slug,title,description,cover_url,end_at')
      .eq('status','completed')
      .order('end_at', { ascending: false })
      .limit(limit);
    if (error) throw error;
    return Array.isArray(data) ? data : [];
  } catch (e) {
    console.error('[community-events] fetchPastEvents error', e);
    return [];
  }
}

function renderPastEvents(items) {
  const grid = document.getElementById('past-events-grid');
  if (!grid || !items || items.length === 0) return;
  const html = items.map(ev => `
    <div class="card overflow-hidden hover-scale group">
      <div class="relative h-48 overflow-hidden">
        <img src="${ev.cover_url || ''}" alt="${ev.title || ''}" class="w-full h-full object-cover group-hover:scale-105 magical-transition" />
        <div class="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent"></div>
        <div class="absolute top-4 left-4">
          <span class="bg-success text-white px-3 py-1 rounded-full text-sm font-cta font-semibold">COMPLETADO</span>
        </div>
      </div>
      <div class="p-6">
        <h3 class="font-headline text-xl font-medium text-text-primary mb-3">${ev.title}</h3>
        <p class="text-text-secondary mb-4 text-sm">Finalizado: ${new Date(ev.end_at).toLocaleDateString()}</p>
        <button class="btn-secondary w-full hover-scale magical-transition">Ver Detalles</button>
      </div>
    </div>`).join('');
  grid.insertAdjacentHTML('afterbegin', html);
}

async function fetchCalendar(month, year) {
  const client = await ensureClient();
  if (!client) return [];
  try {
    const { data, error } = await client.rpc('list_calendar_events_detailed', { in_month: month, in_year: year });
    if (error) throw error;
    return Array.isArray(data) ? data : [];
  } catch (e) {
    console.error('[community-events] list_calendar_events_detailed error', e);
    return [];
  }
}

function setCalendarMonthLabel(month, year) {
  const label = document.getElementById('calendar-month-label');
  if (!label) return;
  const dt = new Date(year, month - 1, 1);
  const formatter = new Intl.DateTimeFormat('es-ES', { month: 'long', year: 'numeric' });
  label.textContent = formatter.format(dt).replace(/^\w/, c => c.toUpperCase());
}

function markCalendarDays(events) {
  // Clear previous markings
  const dayCells = document.querySelectorAll('.grid.grid-cols-7 > div');
  dayCells.forEach(cell => {
    cell.classList.remove('bg-secondary/20', 'bg-warning/20', 'bg-success/20');
    const existingDot = cell.querySelector('.absolute.bottom-0');
    if (existingDot) existingDot.remove();
  });
  
  // Group events by date
  const eventsByDate = {};
  events.forEach(event => {
    const date = new Date(event.event_date).getDate();
    if (!eventsByDate[date]) {
      eventsByDate[date] = [];
    }
    eventsByDate[date].push(event);
  });
  
  // Mark days with events
  dayCells.forEach(cell => {
    const dayText = cell.textContent.trim();
    const dayNumber = parseInt(dayText, 10);
    
    if (!isNaN(dayNumber) && eventsByDate[dayNumber]) {
      const dayEvents = eventsByDate[dayNumber];
      
      // Get predominant event type for coloring
      const typeCount = {};
      dayEvents.forEach(event => {
        typeCount[event.type] = (typeCount[event.type] || 0) + 1;
      });
      
      const predominantType = Object.keys(typeCount).reduce((a, b) => 
        typeCount[a] > typeCount[b] ? a : b
      );
      
      // Apply styling based on event type
      let bgClass = 'bg-secondary/20';
      let dotColor = 'bg-secondary';
      
      if (predominantType === 'tournament') {
        bgClass = 'bg-secondary/20';
        dotColor = 'bg-secondary';
      } else if (predominantType === 'contest') {
        bgClass = 'bg-warning/20';
        dotColor = 'bg-warning';
      } else if (predominantType === 'celebration') {
        bgClass = 'bg-success/20';
        dotColor = 'bg-success';
      }
      
      cell.classList.add(bgClass);
      cell.style.position = 'relative';
      cell.style.cursor = 'pointer';
      
      // Add dot indicator
      const dot = document.createElement('div');
      dot.className = `absolute bottom-0 left-1/2 transform -translate-x-1/2 w-1 h-1 ${dotColor} rounded-full`;
      cell.appendChild(dot);
      
      // Add click handler to show events for this day
      cell.addEventListener('click', () => showDayEvents(dayNumber, dayEvents));
    }
  });
}

function showDayEvents(day, events) {
  // Create or update modal to show events for the selected day
  let modal = document.getElementById('day-events-modal');
  if (!modal) {
    modal = document.createElement('div');
    modal.id = 'day-events-modal';
    modal.className = 'fixed inset-0 bg-black/50 backdrop-blur-sm z-50 hidden';
    modal.innerHTML = `
      <div class="flex items-center justify-center min-h-screen p-4">
        <div class="bg-surface rounded-xl max-w-md w-full p-6">
          <div class="flex justify-between items-center mb-4">
            <h3 id="day-events-title" class="font-headline text-xl font-medium text-text-primary"></h3>
            <button id="close-day-events" class="text-text-secondary hover:text-text-primary">
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
              </svg>
            </button>
          </div>
          <div id="day-events-list"></div>
        </div>
      </div>
    `;
    document.body.appendChild(modal);
    
    // Add close handler
    modal.querySelector('#close-day-events').addEventListener('click', () => {
      modal.classList.add('hidden');
    });
  }
  
  // Update modal content
  const title = modal.querySelector('#day-events-title');
  const list = modal.querySelector('#day-events-list');
  
  title.textContent = `Eventos del día ${day}`;
  
  list.innerHTML = events.map(event => {
    const typeConfig = {
      'tournament': { name: 'Torneo', color: 'text-ravenclaw', bg: 'bg-ravenclaw/10' },
      'contest': { name: 'Concurso', color: 'text-hufflepuff', bg: 'bg-hufflepuff/10' },
      'celebration': { name: 'Celebración', color: 'text-success', bg: 'bg-success/10' }
    };
    
    const config = typeConfig[event.type] || typeConfig['contest'];
    
    return `
      <div class="border rounded-lg p-3 mb-3 hover:bg-gray-50 cursor-pointer" onclick="window.location.href='event-detail.html?event=${event.slug}'">
        <div class="flex items-center mb-2">
          <span class="${config.bg} ${config.color} px-2 py-1 rounded text-xs font-semibold">
            ${config.name}
          </span>
        </div>
        <h4 class="font-medium text-text-primary">${event.title}</h4>
      </div>
    `;
  }).join('');
  
  // Show modal
  modal.classList.remove('hidden');
}

async function init() {
  const stats = await fetchQuickStats();
  renderQuickStats(stats);

  const now = new Date();
  let currentMonth = now.getMonth() + 1;
  let currentYear = now.getFullYear();
  setCalendarMonthLabel(currentMonth, currentYear);

  const [featured, upcoming, indCh, houseCh, activePoll, recentResults, pastEvents, cal] = await Promise.all([
    fetchFeaturedEvents(6),
    fetchUpcoming(5),
    fetchIndividualChallenges(),
    fetchHouseChallenges(),
    fetchActivePoll(),
    fetchRecentPollResults(1),
    fetchPastEvents(9),
    fetchCalendar(currentMonth, currentYear)
  ]);
  renderFeaturedEvents(featured);
  renderUpcoming(upcoming);
  renderIndividualChallenges(indCh);
  renderHouseChallenges(houseCh);
  if (activePoll) {
    const options = await fetchPollOptions(activePoll.poll_id);
    renderActivePoll(activePoll, options);
  }
  renderRecentPollResults(recentResults);
  renderPastEvents(pastEvents);
  markCalendarDays(cal);

  document.addEventListener('click', handleClicks);

  const prev = document.getElementById('calendar-prev');
  const next = document.getElementById('calendar-next');
  if (prev && next) {
    prev.addEventListener('click', async () => {
      currentMonth -= 1;
      if (currentMonth < 1) { currentMonth = 12; currentYear -= 1; }
      setCalendarMonthLabel(currentMonth, currentYear);
      const data = await fetchCalendar(currentMonth, currentYear);
      markCalendarDays(data);
    });
    next.addEventListener('click', async () => {
      currentMonth += 1;
      if (currentMonth > 12) { currentMonth = 1; currentYear += 1; }
      setCalendarMonthLabel(currentMonth, currentYear);
      const data = await fetchCalendar(currentMonth, currentYear);
      markCalendarDays(data);
    });
  }
  
  // Make functions available globally for button clicks
  window.showMyParticipations = showMyParticipations;
  window.showLeaderboard = showLeaderboard;
}

// Show user's participations modal
async function showMyParticipations() {
  const client = await ensureClient();
  if (!client) {
    alert('Por favor, inicia sesión para ver tus participaciones');
    return;
  }
  
  try {
    const { data: participations, error } = await client.rpc('my_participations');
    if (error) throw error;
    
    // Create or update modal
    let modal = document.getElementById('participations-modal');
    if (!modal) {
      modal = document.createElement('div');
      modal.id = 'participations-modal';
      modal.className = 'fixed inset-0 bg-black/50 backdrop-blur-sm z-50 hidden';
      modal.innerHTML = `
        <div class="flex items-center justify-center min-h-screen p-4">
          <div class="bg-surface rounded-xl max-w-2xl w-full max-h-[80vh] overflow-y-auto p-6">
            <div class="flex justify-between items-center mb-6">
              <h3 class="font-headline text-xl font-medium text-text-primary">Mis Participaciones</h3>
              <button id="close-participations" class="text-text-secondary hover:text-text-primary">
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
                </svg>
              </button>
            </div>
            <div id="participations-list"></div>
          </div>
        </div>
      `;
      document.body.appendChild(modal);
      
      modal.querySelector('#close-participations').addEventListener('click', () => {
        modal.classList.add('hidden');
      });
    }
    
    const list = modal.querySelector('#participations-list');
    
    if (!participations || participations.length === 0) {
      list.innerHTML = `
        <div class="text-center py-8">
          <p class="text-text-secondary">No tienes participaciones aún</p>
          <p class="text-sm text-text-secondary mt-2">¡Únete a algunos eventos para comenzar!</p>
        </div>
      `;
    } else {
      list.innerHTML = participations.map(p => {
        const statusConfig = {
          'joined': { name: 'Participando', color: 'text-blue-600', bg: 'bg-blue-50' },
          'submitted': { name: 'Enviado', color: 'text-success', bg: 'bg-success/10' },
          'winner': { name: 'Ganador', color: 'text-secondary', bg: 'bg-secondary/10' },
          'disqualified': { name: 'Descalificado', color: 'text-error', bg: 'bg-error/10' }
        };
        
        const config = statusConfig[p.status] || statusConfig['joined'];
        const endDate = new Date(p.end_at);
        const isActive = endDate > new Date();
        
        return `
          <div class="border rounded-lg p-4 mb-3 hover:bg-gray-50">
            <div class="flex items-center justify-between mb-2">
              <h4 class="font-medium text-text-primary">${p.title}</h4>
              <span class="${config.bg} ${config.color} px-2 py-1 rounded text-xs font-semibold">
                ${config.name}
              </span>
            </div>
            <div class="flex items-center justify-between text-sm text-text-secondary">
              <span>${new Date(p.start_at).toLocaleDateString()} - ${endDate.toLocaleDateString()}</span>
              <a href="event-detail.html?event=${p.slug}" class="text-primary hover:underline">Ver Evento</a>
            </div>
          </div>
        `;
      }).join('');
    }
    
    modal.classList.remove('hidden');
    
  } catch (error) {
    console.error('Error fetching participations:', error);
    alert('Error al cargar tus participaciones');
  }
}

// Show leaderboard modal
async function showLeaderboard() {
  const client = await ensureClient();
  if (!client) return;
  
  try {
    const [housesData, usersData] = await Promise.all([
      client.rpc('leaderboard_houses', { in_period: 'month' }),
      client.rpc('leaderboard_users', { in_period: 'month' })
    ]);
    
    if (housesData.error) throw housesData.error;
    if (usersData.error) throw usersData.error;
    
    // Create or update modal
    let modal = document.getElementById('leaderboard-modal');
    if (!modal) {
      modal = document.createElement('div');
      modal.id = 'leaderboard-modal';
      modal.className = 'fixed inset-0 bg-black/50 backdrop-blur-sm z-50 hidden';
      modal.innerHTML = `
        <div class="flex items-center justify-center min-h-screen p-4">
          <div class="bg-surface rounded-xl max-w-4xl w-full max-h-[80vh] overflow-y-auto p-6">
            <div class="flex justify-between items-center mb-6">
              <h3 class="font-headline text-xl font-medium text-text-primary">Tabla de Posiciones</h3>
              <button id="close-leaderboard" class="text-text-secondary hover:text-text-primary">
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
                </svg>
              </button>
            </div>
            <div class="grid md:grid-cols-2 gap-6">
              <div>
                <h4 class="font-semibold text-text-primary mb-4">Ranking por Casas</h4>
                <div id="houses-leaderboard"></div>
              </div>
              <div>
                <h4 class="font-semibold text-text-primary mb-4">Top Usuarios</h4>
                <div id="users-leaderboard"></div>
              </div>
            </div>
          </div>
        </div>
      `;
      document.body.appendChild(modal);
      
      modal.querySelector('#close-leaderboard').addEventListener('click', () => {
        modal.classList.add('hidden');
      });
    }
    
    const housesContainer = modal.querySelector('#houses-leaderboard');
    const usersContainer = modal.querySelector('#users-leaderboard');
    
    // Render houses leaderboard
    const houseColors = {
      'Gryffindor': 'text-gryffindor',
      'Ravenclaw': 'text-ravenclaw',
      'Hufflepuff': 'text-hufflepuff',
      'Slytherin': 'text-slytherin'
    };
    
    housesContainer.innerHTML = (housesData.data || []).map((house, index) => `
      <div class="flex items-center justify-between p-3 rounded-lg ${index === 0 ? 'bg-secondary/10' : 'hover:bg-gray-50'}">
        <div class="flex items-center">
          <span class="font-bold text-lg ${houseColors[house.house_name] || 'text-text-primary'} mr-3">
            ${index + 1}
          </span>
          <span class="font-medium ${houseColors[house.house_name] || 'text-text-primary'}">
            ${house.house_name}
          </span>
        </div>
        <span class="font-semibold text-secondary">${house.points} pts</span>
      </div>
    `).join('');
    
    // Render users leaderboard
    usersContainer.innerHTML = (usersData.data || []).slice(0, 10).map((user, index) => `
      <div class="flex items-center justify-between p-3 rounded-lg ${index === 0 ? 'bg-secondary/10' : 'hover:bg-gray-50'}">
        <div class="flex items-center">
          <span class="font-bold text-lg text-text-primary mr-3">${index + 1}</span>
          <span class="font-medium text-text-primary">${user.username || 'Usuario'}</span>
        </div>
        <span class="font-semibold text-secondary">${user.points} pts</span>
      </div>
    `).join('');
    
    modal.classList.remove('hidden');
    
  } catch (error) {
    console.error('Error fetching leaderboard:', error);
    alert('Error al cargar la tabla de posiciones');
  }
}

document.addEventListener('DOMContentLoaded', () => { init().catch(e => console.error(e)); });
