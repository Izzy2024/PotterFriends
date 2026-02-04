/**
 * Hogwarts Community Hub - Authentication Module
 * 
 * This module handles user authentication functionality including:
 * - Login/logout using Supabase
 * - Token management
 * - User session persistence
 * - Authentication state UI updates
 */

// Supabase configuration (production fallback)
const SUPABASE_URL = 'https://vdcclritlgnwwdxloayt.supabase.co';
// Using the correct anon key from your Supabase project
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZkY2Nscml0bGdud3dkeGxvYXl0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMwOTQxMDQsImV4cCI6MjA2ODY3MDEwNH0.BaBIrCS9fgkLEkC_KLZg9gR_jNgFIPC7bMvuwfCnb6E';

const APP_CONFIG = window.APP_CONFIG || {
    USE_LOCAL_BACKEND: true,
    API_BASE_URL: 'http://localhost:3001'
};

async function clientLog(event, data = {}) {
    if (!APP_CONFIG.USE_LOCAL_BACKEND) return;
    try {
        await fetch(`${APP_CONFIG.API_BASE_URL}/client-log`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                event,
                data,
                path: window.location.pathname,
                ts: new Date().toISOString()
            })
        });
    } catch (error) {
        // ignore logging errors
    }
}

// Storage keys
const STORAGE_KEYS = {
    USER: 'hogwarts_user',
    REGISTERED_EMAIL: 'registeredEmail',
};

// Global Supabase client
let supabaseClient = null;

// Promise to prevent duplicate initialization
let supabaseInitPromise = null;

function createLocalSupabaseClient(baseUrl) {
    const TOKEN_KEY = 'local_auth_token';

    const getToken = () => localStorage.getItem(TOKEN_KEY);
    const setToken = (token) => localStorage.setItem(TOKEN_KEY, token);
    const clearToken = () => localStorage.removeItem(TOKEN_KEY);

    const request = async (path, options = {}) => {
        const token = getToken();
        const headers = {
            'Content-Type': 'application/json',
            ...(options.headers || {})
        };
        if (token) headers.Authorization = `Bearer ${token}`;

        const res = await fetch(`${baseUrl}${path}`, {
            ...options,
            headers
        });
        const data = await res.json().catch(() => ({}));
        if (!res.ok) {
            const error = new Error(data.error || 'request_failed');
            error.details = data.detail || null;
            return { data: null, error };
        }
        return { data, error: null };
    };

    const auth = {
        async signUp({ email, password, options }) {
            const meta = options?.data || {};
            const { data, error } = await request('/auth/signup', {
                method: 'POST',
                body: JSON.stringify({
                    email,
                    password,
                    wizard_name: meta.wizard_name,
                    first_name: meta.first_name,
                    last_name: meta.last_name,
                    house: meta.house
                })
            });

            if (error) return { data: null, error };
            if (data?.session?.access_token) setToken(data.session.access_token);
            clientLog('auth_signup', { ok: true, email });

            return {
                data: { user: data.user, session: data.session },
                error: null
            };
        },
        async signInWithPassword({ email, password }) {
            const { data, error } = await request('/auth/login', {
                method: 'POST',
                body: JSON.stringify({ email, password })
            });

            if (error) return { data: null, error };
            if (data?.session?.access_token) setToken(data.session.access_token);
            clientLog('auth_login', { ok: true, email });

            return {
                data: { user: data.user, session: data.session },
                error: null
            };
        },
        async signOut() {
            await request('/auth/logout', { method: 'POST' });
            clearToken();
            clientLog('auth_logout', { ok: true });
            return { error: null };
        },
        async getSession() {
            const token = getToken();
            clientLog('auth_get_session', { hasToken: !!token });
            if (!token) return { data: { session: null }, error: null };
            return { data: { session: { access_token: token, token_type: 'bearer' } }, error: null };
        },
        async getUser() {
            const token = getToken();
            clientLog('auth_get_user', { hasToken: !!token });
            if (!token) return { data: { user: null }, error: null };
            const { data, error } = await request('/auth/user', { method: 'GET' });
            if (error) return { data: { user: null }, error };
            return { data: { user: data.user }, error: null };
        },
        async resetPasswordForEmail(email) {
            const { data, error } = await request('/auth/request-reset', {
                method: 'POST',
                body: JSON.stringify({ email })
            });
            if (error) return { data: null, error };
            return { data, error: null };
        },
        async updateUser({ password }) {
            const { data, error } = await request('/auth/update', {
                method: 'POST',
                body: JSON.stringify({ password })
            });
            if (error) return { data: null, error };
            return { data, error: null };
        }
    };

    const createQueryBuilder = (table) => {
        const state = {
            table,
            op: 'select',
            columns: '*',
            filters: [],
            order: null,
            limit: null,
            offset: null,
            count: null,
            head: false,
            values: null,
            returning: null,
            single: false,
            maybeSingle: false
        };

        const builder = {
            select(columns = '*', options = {}) {
                state.op = 'select';
                state.columns = columns;
                state.count = options.count || null;
                state.head = options.head || false;
                return builder;
            },
            insert(values, options = {}) {
                state.op = 'insert';
                state.values = values;
                state.returning = options.returning || null;
                return builder;
            },
            update(values, options = {}) {
                state.op = 'update';
                state.values = values;
                state.returning = options.returning || null;
                return builder;
            },
            delete(options = {}) {
                state.op = 'delete';
                state.returning = options.returning || null;
                return builder;
            },
            eq(column, value) {
                state.filters.push({ column, op: 'eq', value });
                return builder;
            },
            or(filterString) {
                state.or = filterString;
                return builder;
            },
            in(column, value) {
                state.filters.push({ column, op: 'in', value });
                return builder;
            },
            neq(column, value) {
                state.filters.push({ column, op: 'neq', value });
                return builder;
            },
            gt(column, value) {
                state.filters.push({ column, op: 'gt', value });
                return builder;
            },
            gte(column, value) {
                state.filters.push({ column, op: 'gte', value });
                return builder;
            },
            lt(column, value) {
                state.filters.push({ column, op: 'lt', value });
                return builder;
            },
            lte(column, value) {
                state.filters.push({ column, op: 'lte', value });
                return builder;
            },
            like(column, value) {
                state.filters.push({ column, op: 'like', value });
                return builder;
            },
            ilike(column, value) {
                state.filters.push({ column, op: 'ilike', value });
                return builder;
            },
            is(column, value) {
                state.filters.push({ column, op: 'is', value });
                return builder;
            },
            order(column, options = {}) {
                if (!column) return builder;
                const columns = column
                    .split(',')
                    .map((c) => c.trim())
                    .filter(Boolean);
                state.order = columns.map((col) => ({
                    column: col,
                    ascending: options.ascending !== false
                }));
                return builder;
            },
            range(from, to) {
                if (Number.isInteger(from) && Number.isInteger(to) && to >= from) {
                    state.offset = from;
                    state.limit = to - from + 1;
                }
                return builder;
            },
            limit(count) {
                if (Number.isInteger(count)) {
                    state.limit = count;
                }
                return builder;
            },
            single() {
                state.single = true;
                return builder;
            },
            maybeSingle() {
                state.maybeSingle = true;
                return builder;
            },
            async rpc(fn, args) {
                const { data, error } = await request('/api/db/rpc', {
                    method: 'POST',
                    body: JSON.stringify({ fn, args })
                });
                if (error) return { data: null, error };
                return { data: data.data, error: null };
            },
            async _execute() {
                let result;
                if (state.op === 'select') {
                    result = await request('/api/db/select', {
                        method: 'POST',
                        body: JSON.stringify({
                            table: state.table,
                            columns: state.columns,
                            filters: state.filters,
                            or: state.or || null,
                            order: state.order,
                            limit: state.limit,
                            offset: state.offset,
                            count: state.count,
                            head: state.head
                        })
                    });
                    if (result.error) return { data: null, error: result.error, count: null };
                    let data = result.data.data || [];
                    let error = null;

                    if (state.single || state.maybeSingle) {
                        if (data.length === 0) {
                            if (state.maybeSingle) {
                                data = null;
                            } else {
                                error = { message: 'No rows', code: 'PGRST116' };
                                data = null;
                            }
                        } else if (data.length > 1) {
                            error = { message: 'Multiple rows', code: 'PGRST116' };
                            data = null;
                        } else {
                            data = data[0];
                        }
                    }

                    return { data, error, count: result.data.count ?? null };
                }

                if (state.op === 'insert') {
                    result = await request('/api/db/insert', {
                        method: 'POST',
                        body: JSON.stringify({
                            table: state.table,
                            values: state.values,
                            returning: state.returning
                        })
                    });
                }

                if (state.op === 'update') {
                    result = await request('/api/db/update', {
                        method: 'POST',
                        body: JSON.stringify({
                            table: state.table,
                            values: state.values,
                            filters: state.filters,
                            returning: state.returning
                        })
                    });
                }

                if (state.op === 'delete') {
                    result = await request('/api/db/delete', {
                        method: 'POST',
                        body: JSON.stringify({
                            table: state.table,
                            filters: state.filters,
                            returning: state.returning
                        })
                    });
                }

                if (result.error) return { data: null, error: result.error };
                return { data: result.data.data, error: null };
            },
            then(resolve, reject) {
                return builder._execute().then(resolve, reject);
            }
        };

        return builder;
    };

    return {
        auth,
        from: (table) => createQueryBuilder(table),
        rpc: async (fn, args) => createQueryBuilder(null).rpc(fn, args),
        channel: () => {
            const channel = {
                on: () => channel,
                subscribe: () => ({}),
                presenceState: () => ({}),
                track: async () => ({})
            };
            return channel;
        },
        removeChannel: () => {},
        supabaseUrl: baseUrl
    };
}

/**
 * Initialize Supabase client
 * @returns {Object} Supabase client
 */
function initSupabase() {
    if (supabaseClient) {
        return Promise.resolve(supabaseClient);
    }
    if (supabaseInitPromise) {
        return supabaseInitPromise;
    }

    if (APP_CONFIG.USE_LOCAL_BACKEND) {
        supabaseClient = createLocalSupabaseClient(APP_CONFIG.API_BASE_URL);
        window.supabaseClient = supabaseClient;
        window.supabase = window.supabase || { createClient: () => supabaseClient };
        return Promise.resolve(supabaseClient);
    }

    const createClient = () => {
        supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
        // Hacer el cliente disponible globalmente
        window.supabaseClient = supabaseClient;
        return supabaseClient;
    };

    if (window.supabase) {
        supabaseInitPromise = Promise.resolve(createClient());
    } else {
        console.warn('Supabase client not available. Loading from CDN...');
        let script = document.querySelector('script[data-supabase-cdn]');
        if (!script) {
            script = document.createElement('script');
            script.src = 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2';
            script.async = true;
            script.setAttribute('data-supabase-cdn', 'true');
            document.head.appendChild(script);
        }
        supabaseInitPromise = new Promise((resolve, reject) => {
            script.onload = () => resolve(createClient());
            script.onerror = () => reject(new Error('Failed to load Supabase client from CDN'));
        });
    }

    return supabaseInitPromise;
}

/**
 * Check if user is authenticated
 * @returns {Promise<boolean>} True if user is authenticated
 */
async function isAuthenticated() {
    try {
        const supabase = await initSupabase();
        const { data: { session } } = await supabase.auth.getSession();
        return !!session;
    } catch (error) {
        console.error('Authentication check error:', error);
        return false;
    }
}

/**
 * Get current user data
 * @returns {Promise<Object|null>} User data or null if not authenticated
 */
async function getCurrentUser() {
    try {
        const supabase = await initSupabase();
        const { data: { user } } = await supabase.auth.getUser();
        
        if (user) {
            try {
                // Get additional user data from profiles table
                const { data: profile } = await supabase
                    .from('user_profiles')
                    .select('*')
                    .eq('id', user.id)
                    .single();
                    
                return { ...user, ...profile };
            } catch (profileError) {
                console.warn('Could not fetch profile data, returning user data only:', profileError);
                return user;
            }
        }
        return null;
    } catch (error) {
        console.error('Get user error:', error);
        return null;
    }
}

/**
 * Login user
 * @param {string} email User email
 * @param {string} password User password
 * @returns {Promise<Object>} Login response
 */
async function login(email, password) {
    try {
        const supabase = await initSupabase();
        const { data, error } = await supabase.auth.signInWithPassword({
            email,
            password
        });

        if (error) {
            return { success: false, error: error.message || 'Error en el inicio de sesión' };
        }

        // Get user profile data
        const { data: profile } = await supabase
            .from('user_profiles')
            .select('*')
            .eq('id', data.user.id)
            .single();
            
        // Store user data
        const userData = { ...data.user, ...profile };
        localStorage.setItem(STORAGE_KEYS.USER, JSON.stringify(userData));
        
        // Update UI
        await updateAuthUI();
        
        return { success: true, data: { user: userData } };
    } catch (error) {
        console.error('Login error:', error);
        return { success: false, error: 'Error de conexión. Por favor verifica tu conexión a internet.' };
    }
}

/**
 * Register new user
 * @param {Object} userData User registration data
 * @returns {Promise<Object>} Registration response
 */
async function register(userData) {
    try {
        const supabase = await initSupabase();
        const { data, error } = await supabase.auth.signUp({
            email: userData.email,
            password: userData.password,
            options: {
                data: {
                    first_name: userData.firstName,
                    last_name: userData.lastName,
                    wizard_name: userData.wizardName
                }
            }
        });

        if (error) {
            return { success: false, error: error.message || 'Error en el registro' };
        }

        // Store email for verification page
        localStorage.setItem(STORAGE_KEYS.REGISTERED_EMAIL, userData.email);
        
        try {
            // Create profile record
            const { error: profileError } = await supabase.from('user_profiles').insert([
                {
                    id: data.user.id,
                    first_name: userData.firstName,
                    last_name: userData.lastName,
                    wizard_name: userData.wizardName,
                    email: userData.email
                }
            ]);
            
            if (profileError) {
                console.warn('Could not create profile record:', profileError);
            }
        } catch (profileError) {
            console.warn('Error creating profile record:', profileError);
        }
        
        return { success: true, data };
    } catch (error) {
        console.error('Registration error:', error);
        return { success: false, error: 'Error de conexión. Por favor verifica tu conexión a internet.' };
    }
}

/**
 * Logout user
 * @returns {Promise<void>}
 */
async function logout() {
    try {
        const supabase = await initSupabase();
        await supabase.auth.signOut();
    } catch (error) {
        console.error('Logout error:', error);
    } finally {
        // Clear local storage
        localStorage.removeItem(STORAGE_KEYS.USER);
        
        // Update UI
        await updateAuthUI();
        
        // Redirect to home page
        window.location.href = 'homepage_sorting_hat_experience.html';
    }
}

/**
 * Update UI based on authentication state
 */
async function updateAuthUI() {
    const authButton = document.getElementById('authButton');
    if (!authButton) return;
    
    const authenticated = await isAuthenticated();
    
    if (authenticated) {
        const user = await getCurrentUser();
        const displayName = user?.wizard_name || user?.user_metadata?.wizard_name || 'Usuario';
        
        // Create dropdown menu
        authButton.innerHTML = `
            <div class="relative">
                <button id="userMenuButton" class="flex items-center space-x-2 btn-primary text-sm px-4 py-2 rounded-lg">
                    <span>${displayName}</span>
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
                    </svg>
                </button>
                <div id="userMenu" class="hidden absolute right-0 mt-2 w-48 bg-surface rounded-lg shadow-elevated z-50">
                    <div class="py-1">
                        <a href="user_profile_achievement_system.html" class="block px-4 py-2 text-sm text-text-primary hover:bg-primary/10">Mi Perfil</a>
                        ${user?.house ? `<a href="house_common_rooms_personalized_dashboards.html" class="block px-4 py-2 text-sm text-text-primary hover:bg-primary/10">Mi Casa</a>` : ''}
                        <button id="logoutButton" class="block w-full text-left px-4 py-2 text-sm text-error hover:bg-error/10">Cerrar Sesión</button>
                    </div>
                </div>
            </div>
        `;
        
        // Add event listeners
        document.getElementById('userMenuButton').addEventListener('click', function() {
            document.getElementById('userMenu').classList.toggle('hidden');
        });
        
        document.getElementById('logoutButton').addEventListener('click', logout);
        
        // Close menu when clicking outside
        document.addEventListener('click', function(event) {
            const userMenu = document.getElementById('userMenu');
            const userMenuButton = document.getElementById('userMenuButton');
            
            if (userMenu && !userMenu.contains(event.target) && !userMenuButton.contains(event.target)) {
                userMenu.classList.add('hidden');
            }
        });
    } else {
        // Show login/register buttons
        authButton.innerHTML = `
            <div class="flex space-x-2">
                <a href="user_login.html" class="btn-primary text-sm px-4 py-2 rounded-lg">Iniciar Sesión</a>
                <a href="user_registration.html" class="btn-secondary text-sm px-4 py-2 rounded-lg">Registrarse</a>
            </div>
        `;
    }
}

/**
 * Reset password for email
 * @param {string} email User email
 * @returns {Promise<Object>} Reset password response
 */
async function resetPassword(email) {
    try {
        const supabase = await initSupabase();
        const { data, error } = await supabase.auth.resetPasswordForEmail(email, {
            redirectTo: `${window.location.origin}/pages/reset_password.html`
        });

        if (error) {
            return { success: false, error: error.message || 'Error al enviar el correo de recuperación' };
        }

        return { success: true, resetToken: data?.reset_token || null };
    } catch (error) {
        console.error('Reset password error:', error);
        return { success: false, error: 'Error de conexión. Por favor verifica tu conexión a internet.' };
    }
}

/**
 * Initialize authentication
 */
async function initAuth() {
    try {
        // Initialize Supabase client
        await initSupabase();
        
        // Update UI based on auth state
        await updateAuthUI();
        
        // Check if user is authenticated
        const authenticated = await isAuthenticated();
        if (authenticated) {
            const user = await getCurrentUser();
            
        // If user has no house assigned, redirect to sorting hat quiz
        if (user && window.location.pathname.includes('house_common_rooms_personalized_dashboards.html')) {
            const house = await getUserHouse();
            if (!house) {
                window.location.href = 'house_selection_portal_sorting_hat_quiz.html';
            }
        }
        }
    } catch (error) {
        console.error('Auth initialization error:', error);
    }
}

// Initialize auth when DOM is loaded
document.addEventListener('DOMContentLoaded', initAuth);

/**
 * Save user's house selection to Supabase
 * @param {string} house The selected house (gryffindor, hufflepuff, ravenclaw, slytherin)
 * @returns {Promise<Object>} Save response
 */
async function saveUserHouse(house) {
    try {
        const supabase = await initSupabase();
        const { data: { user } } = await supabase.auth.getUser();
        
        if (!user) {
            // Fallback local even if not authenticated
            localStorage.setItem('userHouse', house);
            localStorage.setItem('selectedHouse', house);
            localStorage.setItem('sortingDate', new Date().toISOString());
            return { success: false, error: 'Usuario no autenticado (guardado localmente)' };
        }

        // Save to Supabase profiles tables (compatibilidad con ambas)
        let error = null;
        const houseSelectedAt = new Date().toISOString();

        const respProfiles = await supabase
            .from('profiles')
            .update({
                house: house,
                house_selected_at: houseSelectedAt
            })
            .eq('id', user.id);
        if (respProfiles.error) {
            error = respProfiles.error;
        }

        const respUserProfiles = await supabase
            .from('user_profiles')
            .update({
                house: house
            })
            .eq('id', user.id);
        if (respUserProfiles.error && !error) {
            error = respUserProfiles.error;
        }
            
        if (error) {
            console.error('Error saving house to Supabase:', error);
            // Fallback to localStorage only
            localStorage.setItem('userHouse', house);
            localStorage.setItem('selectedHouse', house);
            return { success: false, error: 'Error guardando en la base de datos, guardado localmente' };
        }

        // Update localStorage as cache
        localStorage.setItem('userHouse', house);
        localStorage.setItem('selectedHouse', house);
        localStorage.setItem('sortingDate', new Date().toISOString());
        
        return { success: true };
    } catch (error) {
        console.error('Error in saveUserHouse:', error);
        // Fallback to localStorage
        localStorage.setItem('userHouse', house);
        localStorage.setItem('selectedHouse', house);
        return { success: false, error: 'Error de conexión, guardado localmente' };
    }
}

/**
 * Get user's house from Supabase or localStorage
 * @returns {Promise<string|null>} User's house or null
 */
async function getUserHouse() {
    try {
        const user = await getCurrentUser();
        
        // First try to get from Supabase user profile
        if (user?.house) {
            // Update localStorage cache
            localStorage.setItem('userHouse', user.house);
            localStorage.setItem('selectedHouse', user.house);
            return user.house;
        }
        
        // Fallback to localStorage
        return localStorage.getItem('userHouse') || localStorage.getItem('selectedHouse');
    } catch (error) {
        console.error('Error getting user house:', error);
        // Fallback to localStorage
        return localStorage.getItem('userHouse') || localStorage.getItem('selectedHouse');
    }
}

// Export auth functions
window.HogwartsAuth = {
    initSupabase,
    login,
    register,
    logout,
    isAuthenticated,
    getCurrentUser,
    updateAuthUI,
    resetPassword,
    saveUserHouse,
    getUserHouse
};
