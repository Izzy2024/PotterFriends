// Minimal data wiring for Community Events page.
// It expects window.supabaseClient to be available (from auth.js). If not, it will no-op with console warnings.
// Replace {{SUPABASE_URL}} and {{SUPABASE_ANON_KEY}} in your global initializer; do not hardcode secrets here.

function safeNumber(n) {
  if (typeof n === 'number' && isFinite(n)) return n;
  if (typeof n === 'string') {
    const parsed = parseInt(n.replace(/[^0-9-]/g, ''), 10);
    if (!isNaN(parsed)) return parsed;
  }
  return 0;
}

async function ensureClient() {
  if (window.supabaseClient) return window.supabaseClient;
  if (window.supabase && window.SUPABASE_URL && window.SUPABASE_ANON_KEY) {
    window.supabaseClient = window.supabase.createClient(window.SUPABASE_URL, window.SUPABASE_ANON_KEY);
    return window.supabaseClient;
  }
  console.warn('[community-events] Supabase client no disponible aún');
  // small wait-retry once
  await new Promise(r => setTimeout(r, 300));
  return window.supabaseClient || null;
}

async function fetchQuickStats() {
  const client = await ensureClient();
  if (!client) return null;
  try {
    const { data, error } = await client.rpc('get_quick_stats');
    if (error) throw error;
    return data || null;
  } catch (e) {
    console.error('[community-events] get_quick_stats error', e);
    return null;
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
  if (!grid || !items || items.length === 0) return;
  // Keep existing markup as fallback; we will prepend rendered items
  const html = items.map(ev => {
    const days = typeof ev.ends_in_days === 'number' ? `${ev.ends_in_days} días restantes` : '';
    const participants = typeof ev.participants_count === 'number' ? `${ev.participants_count} participantes` : '';
    return `
    <div class="card overflow-hidden hover-scale group">
      <div class="relative h-48 overflow-hidden">
        <img src="${ev.cover_url || ''}" alt="${ev.title || ''}" class="w-full h-full object-cover group-hover:scale-105 magical-transition" />
        <div class="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent"></div>
        <div class="absolute bottom-4 right-4">
          ${days ? `<span class="bg-primary text-white px-3 py-1 rounded-full text-sm font-cta font-semibold">${days}</span>` : ''}
        </div>
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
        <button data-slug="${ev.slug}" class="btn-primary w-full hover-scale magical-transition js-join-event">Participar Ahora</button>
      </div>
    </div>`;
  }).join('');
  grid.insertAdjacentHTML('afterbegin', html);
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
  if (!list || !items || items.length === 0) return;
  const html = items.map(ev => `
    <div class="flex items-start space-x-3 p-3 rounded-lg hover:bg-primary/5 magical-transition">
      <div class="flex-shrink-0 w-12 h-12 bg-primary/10 rounded-lg flex items-center justify-center">
        <svg class="w-6 h-6 text-primary" fill="currentColor" viewBox="0 0 20 20"><path d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
      </div>
      <div class="flex-1 min-w-0">
        <p class="font-cta font-semibold text-text-primary text-sm">${ev.title || ''}</p>
        <p class="text-text-secondary text-xs">${new Date(ev.start_at).toLocaleString()}</p>
      </div>
    </div>`).join('');
  list.insertAdjacentHTML('afterbegin', html);
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
      }
    }
    if (t.closest('.js-submit-attempt')) {
      const btn = t.closest('.js-submit-attempt');
      const slug = btn?.getAttribute('data-slug');
      if (slug) {
        await client.rpc('submit_challenge_attempt', { in_slug: slug, in_evidence_url: null });
        btn.textContent = 'Intento creado';
        btn.disabled = true;
      }
    }
    if (t.closest('.js-vote-option')) {
      const opt = t.closest('.js-vote-option');
      const pollSlug = opt?.getAttribute('data-poll-slug');
      const optionId = opt?.getAttribute('data-option-id');
      if (pollSlug && optionId) {
        await client.rpc('vote_poll', { in_slug: pollSlug, in_option: optionId });
        opt.classList.add('border-primary','bg-primary/5');
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
  const html = items.map(ev = 3e `
     3cdiv class="card overflow-hidden hover-scale group" 3e
       3cdiv class="relative h-48 overflow-hidden" 3e
         3cimg src="${ev.cover_url || ''}" alt="${ev.title || ''}" class="w-full h-full object-cover group-hover:scale-105 magical-transition" / 3e
         3cdiv class="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent" 3e 3c/div 3e
         3cdiv class="absolute top-4 left-4" 3e
           3cspan class="bg-success text-white px-3 py-1 rounded-full text-sm font-cta font-semibold" 3eCOMPLETADO 3c/span 3e
         3c/div 3e
       3c/div 3e
       3cdiv class="p-6" 3e
         3ch3 class="font-headline text-xl font-medium text-text-primary mb-3" 3e${ev.title} 3c/h3 3e
         3cp class="text-text-secondary mb-4 text-sm" 3eFinalizado: ${new Date(ev.end_at).toLocaleDateString()} 3c/p 3e
         3cbutton class="btn-secondary w-full hover-scale magical-transition" 3eVer Detalles 3c/button 3e
       3c/div 3e
     3c/div 3e`).join('');
  grid.insertAdjacentHTML('afterbegin', html);
}

async function fetchCalendar(month, year) {
  const client = await ensureClient();
  if (!client) return [];
  try {
    const { data, error } = await client.rpc('list_calendar_events', { in_month: month, in_year: year });
    if (error) throw error;
    return Array.isArray(data) ? data : [];
  } catch (e) {
    console.error('[community-events] list_calendar_events error', e);
    return [];
  }
}

function setCalendarMonthLabel(month, year) {
  const label = document.getElementById('calendar-month-label');
  if (!label) return;
  const dt = new Date(year, month - 1, 1);
  const formatter = new Intl.DateTimeFormat('es-ES', { month: 'long', year: 'numeric' });
  label.textContent = formatter.format(dt).replace(/^\w/, c = 3e c.toUpperCase());
}

function markCalendarDays(events) {
  // Very lightweight: add a small dot to days that have events.
  const dayCells = document.querySelectorAll('.grid.grid-cols-7  3e div');
  const daysWithEvents = new Set(events.map(e = 3e new Date(e.event_date).getDate()));
  dayCells.forEach(cell = 3e {
    const d = parseInt(cell.textContent.trim(), 10);
    if (!isNaN(d)  26 26 daysWithEvents.has(d)) {
      cell.classList.add('bg-secondary/20');
    } else {
      // keep existing styling for non-event days
    }
  });
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
  if (prev  26 26 next) {
    prev.addEventListener('click', async () = 3e {
      currentMonth -= 1;
      if (currentMonth  3c 1) { currentMonth = 12; currentYear -= 1; }
      setCalendarMonthLabel(currentMonth, currentYear);
      const data = await fetchCalendar(currentMonth, currentYear);
      markCalendarDays(data);
    });
    next.addEventListener('click', async () = 3e {
      currentMonth += 1;
      if (currentMonth  3e 12) { currentMonth = 1; currentYear += 1; }
      setCalendarMonthLabel(currentMonth, currentYear);
      const data = await fetchCalendar(currentMonth, currentYear);
      markCalendarDays(data);
    });
  }
}

document.addEventListener('DOMContentLoaded', () => { init().catch(e => console.error(e)); });

