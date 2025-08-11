/**
 * Hogwarts Community Hub - Authentication Module
 * 
 * This module handles user authentication functionality including:
 * - Login/logout using Supabase
 * - Token management
 * - User session persistence
 * - Authentication state UI updates
 */

// Supabase configuration
const SUPABASE_URL = 'https://vdcclritlgnwwdxloayt.supabase.co';
// Using the correct anon key from your Supabase project
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZkY2Nscml0bGdud3dkeGxvYXl0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMwOTQxMDQsImV4cCI6MjA2ODY3MDEwNH0.BaBIrCS9fgkLEkC_KLZg9gR_jNgFIPC7bMvuwfCnb6E';

// Storage keys
const STORAGE_KEYS = {
    USER: 'hogwarts_user',
    REGISTERED_EMAIL: 'registeredEmail',
};

// Global Supabase client
let supabaseClient = null;

/**
 * Initialize Supabase client
 * @returns {Object} Supabase client
 */
function initSupabase() {
    if (!supabaseClient) {
        // Load Supabase from CDN if not available
        if (!window.supabase) {
            console.error('Supabase client not available. Loading from CDN...');
            const script = document.createElement('script');
            script.src = 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2';
            script.async = true;
            document.head.appendChild(script);
            
            return new Promise((resolve, reject) => {
                script.onload = () => {
                    supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
                    // Hacer el cliente disponible globalmente
                    window.supabaseClient = supabaseClient;
                    resolve(supabaseClient);
                };
                script.onerror = () => {
                    reject(new Error('Failed to load Supabase client from CDN'));
                };
            });
        } else {
            supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
            // Hacer el cliente disponible globalmente
            window.supabaseClient = supabaseClient;
        }
    }
    
    return supabaseClient;
}

/**
 * Check if user is authenticated
 * @returns {Promise<boolean>} True if user is authenticated
 */
async function isAuthenticated() {
    try {
        const supabase = initSupabase();
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
        const supabase = initSupabase();
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
        const supabase = initSupabase();
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
        const supabase = initSupabase();
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
        const supabase = initSupabase();
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
        const supabase = initSupabase();
        const { error } = await supabase.auth.resetPasswordForEmail(email, {
            redirectTo: `${window.location.origin}/pages/reset_password.html`
        });

        if (error) {
            return { success: false, error: error.message || 'Error al enviar el correo de recuperación' };
        }

        return { success: true };
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
            if (user && !user.house && window.location.pathname.includes('house_common_rooms_personalized_dashboards.html')) {
                window.location.href = 'house_selection_portal_sorting_hat_quiz.html';
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
        const supabase = initSupabase();
        const { data: { user } } = await supabase.auth.getUser();
        
        if (!user) {
            return { success: false, error: 'Usuario no autenticado' };
        }

        // Save to Supabase profiles table
        const { error } = await supabase
            .from('user_profiles')
            .update({ 
                house: house, 
                house_selected_at: new Date().toISOString() 
            })
            .eq('id', user.id);
            
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