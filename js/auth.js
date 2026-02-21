/**
 * Hogwarts Community Hub - Authentication Module
 * 
 * This module handles user authentication functionality including:
 * - Login/logout using local PostgreSQL backend
 * - Token management (JWT)
 * - User session persistence
 * - Authentication state UI updates
 * 
 * Backend: Express.js + PostgreSQL (server/index.js)
 * Database: Local PostgreSQL on localhost:5432
 */

// Application configuration
const APP_CONFIG = window.APP_CONFIG || {
    API_BASE_URL: 'http://localhost:3001'
};

/**
 * Log client events to backend for debugging
 */
async function clientLog(event, data = {}) {
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
    AUTH_TOKEN: 'local_auth_token'
};

// Global database client
let dbClient = null;

/**
 * Create database client that communicates with local Express backend
 * This client provides a query-builder interface similar to Supabase for compatibility
 */
function createDatabaseClient(baseUrl) {
    const getToken = () => localStorage.getItem(STORAGE_KEYS.AUTH_TOKEN);
    const setToken = (token) => localStorage.setItem(STORAGE_KEYS.AUTH_TOKEN, token);
    const clearToken = () => localStorage.removeItem(STORAGE_KEYS.AUTH_TOKEN);

    /**
     * Make HTTP request to backend API
     */
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

    /**
     * Authentication methods
     */
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

    /**
     * Create query builder for database operations
     * Provides chainable interface: client.from('table').select('*').eq('id', 1)
     */
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
            maybeSingle: false,
            or: null
        };

        const builder = {
            select(columns = '*', options = {}) {
                // Supabase compatibility:
                // insert/update/delete().select(...) means RETURNING columns,
                // not switching back to a plain SELECT query.
                if (state.op === 'insert' || state.op === 'update' || state.op === 'delete') {
                    state.returning = columns || '*';
                } else {
                    state.op = 'select';
                    state.columns = columns;
                    state.count = options.count || null;
                    state.head = options.head || false;
                }
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

            /**
             * Execute the built query
             */
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

                let data = result.data.data;
                let error = null;

                // Apply .single()/.maybeSingle() semantics for write operations too
                if (state.single || state.maybeSingle) {
                    const rows = Array.isArray(data) ? data : (data == null ? [] : [data]);
                    if (rows.length === 0) {
                        if (state.maybeSingle) {
                            data = null;
                        } else {
                            error = { message: 'No rows', code: 'PGRST116' };
                            data = null;
                        }
                    } else if (rows.length > 1) {
                        error = { message: 'Multiple rows', code: 'PGRST116' };
                        data = null;
                    } else {
                        data = rows[0];
                    }
                }

                return { data, error };
            },

            // Make the builder thenable so await works directly
            then(resolve, reject) {
                return builder._execute().then(resolve, reject);
            }
        };

        return builder;
    };

    // Return the database client interface
    return {
        auth,
        from: (table) => createQueryBuilder(table),
        
        /**
         * Call a PostgreSQL stored function (RPC)
         */
        rpc: async (fn, args) => {
            const { data, error } = await request('/api/db/rpc', {
                method: 'POST',
                body: JSON.stringify({ fn, args })
            });
            if (error) return { data: null, error };
            const raw = data.data;
            if (Array.isArray(raw) && raw.length === 1 && raw[0] && typeof raw[0] === 'object') {
                const fnName = String(fn || '').split('.').pop();
                if (fnName && Object.prototype.hasOwnProperty.call(raw[0], fnName)) {
                    return { data: raw[0][fnName], error: null };
                }
            }
            return { data: raw, error: null };
        },

        /**
         * Real-time channels (stub - not implemented in local backend)
         */
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
        
        // Base URL for reference
        apiUrl: baseUrl
    };
}

/**
 * Initialize database client
 * @returns {Promise<Object>} Database client
 */
function initDatabase() {
    if (dbClient) {
        return Promise.resolve(dbClient);
    }

    dbClient = createDatabaseClient(APP_CONFIG.API_BASE_URL);
    
    // Make client available globally for compatibility
    // Some scripts still use window.supabaseClient - this provides backward compatibility
    window.supabaseClient = dbClient;
    window.supabase = { createClient: () => dbClient };
    
    return Promise.resolve(dbClient);
}

// Alias for backward compatibility
const initSupabase = initDatabase;

/**
 * Check if user is authenticated
 * @returns {Promise<boolean>} True if user is authenticated
 */
async function isAuthenticated() {
    try {
        const client = await initDatabase();
        const { data: { session } } = await client.auth.getSession();
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
        const client = await initDatabase();
        const { data: { user } } = await client.auth.getUser();
        
        if (user) {
            try {
                // Get additional user data from profiles table
                const { data: profile } = await client
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
        const client = await initDatabase();
        const { data, error } = await client.auth.signInWithPassword({
            email,
            password
        });

        if (error) {
            return { success: false, error: error.message || 'Error en el inicio de sesion' };
        }

        // Get user profile data
        const { data: profile } = await client
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
        return { success: false, error: 'Error de conexion. Verifica que el servidor este ejecutandose.' };
    }
}

/**
 * Register new user
 * @param {Object} userData User registration data
 * @returns {Promise<Object>} Registration response
 */
async function register(userData) {
    try {
        const client = await initDatabase();
        const { data, error } = await client.auth.signUp({
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
            const { error: profileError } = await client.from('user_profiles').insert([
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
        return { success: false, error: 'Error de conexion. Verifica que el servidor este ejecutandose.' };
    }
}

/**
 * Logout user
 * @returns {Promise<void>}
 */
async function logout() {
    try {
        const client = await initDatabase();
        await client.auth.signOut();
    } catch (error) {
        console.error('Logout error:', error);
    } finally {
        // Clear local storage
        localStorage.removeItem(STORAGE_KEYS.USER);
        localStorage.removeItem(STORAGE_KEYS.AUTH_TOKEN);
        
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
        const canAccessAdminCenter = user?.role === 'admin' || user?.role === 'house_head' || user?.is_house_head === true;
        
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
                        ${canAccessAdminCenter ? `<a href="admin_center.html" class="block px-4 py-2 text-sm text-yellow-400 hover:bg-yellow-500/10">Admin Center</a>` : ''}
                        <button id="logoutButton" class="block w-full text-left px-4 py-2 text-sm text-error hover:bg-error/10">Cerrar Sesion</button>
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
                <a href="user_login.html" class="btn-primary text-sm px-4 py-2 rounded-lg">Iniciar Sesion</a>
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
        const client = await initDatabase();
        const { data, error } = await client.auth.resetPasswordForEmail(email, {
            redirectTo: `${window.location.origin}/pages/reset_password.html`
        });

        if (error) {
            return { success: false, error: error.message || 'Error al enviar el correo de recuperacion' };
        }

        return { success: true, resetToken: data?.reset_token || null };
    } catch (error) {
        console.error('Reset password error:', error);
        return { success: false, error: 'Error de conexion. Verifica que el servidor este ejecutandose.' };
    }
}

/**
 * Initialize authentication
 */
async function initAuth() {
    try {
        // Initialize database client
        await initDatabase();
        
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
 * Save user's house selection to database
 * @param {string} house The selected house (gryffindor, hufflepuff, ravenclaw, slytherin)
 * @returns {Promise<Object>} Save response
 */
async function saveUserHouse(house) {
    try {
        const client = await initDatabase();
        const { data: { user } } = await client.auth.getUser();
        
        if (!user) {
            // Fallback local even if not authenticated
            localStorage.setItem('userHouse', house);
            localStorage.setItem('selectedHouse', house);
            localStorage.setItem('sortingDate', new Date().toISOString());
            return { success: false, error: 'Usuario no autenticado (guardado localmente)' };
        }

        // Save to profiles tables
        let error = null;
        const houseSelectedAt = new Date().toISOString();

        const respProfiles = await client
            .from('profiles')
            .update({
                house: house,
                house_selected_at: houseSelectedAt
            })
            .eq('id', user.id);
        if (respProfiles.error) {
            error = respProfiles.error;
        }

        const respUserProfiles = await client
            .from('user_profiles')
            .update({
                house: house
            })
            .eq('id', user.id);
        if (respUserProfiles.error && !error) {
            error = respUserProfiles.error;
        }
            
        if (error) {
            console.error('Error saving house to database:', error);
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
        return { success: false, error: 'Error de conexion, guardado localmente' };
    }
}

/**
 * Get user's house from database or localStorage
 * @returns {Promise<string|null>} User's house or null
 */
async function getUserHouse() {
    try {
        const user = await getCurrentUser();
        
        // First try to get from user profile
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
    initSupabase: initDatabase, // Backward compatibility alias
    initDatabase,
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

// Backward compatibility: several pages/scripts expect these globals
window.initSupabase = initDatabase;
window.getCurrentUser = getCurrentUser;

// Eager init so feature pages can query immediately
try {
    initDatabase().catch(() => {});
} catch (e) {
    // ignore
}
