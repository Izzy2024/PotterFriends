/**
 * Universal Navigation - Sistema de navegación dinámica para todas las páginas
 * Se integra con Supabase Auth para mostrar el estado correcto del usuario
 */

// Función para actualizar la navegación en cualquier página
async function updateUniversalNavigation() {
    // Buscar el botón "Mi Casa" en la navegación
    const navLinks = document.querySelectorAll('nav a[href*="house_common_rooms"]');
    
    if (navLinks.length === 0) return; // No hay navegación en esta página
    
    try {
        // Verificar si el usuario está autenticado
        const authenticated = window.HogwartsAuth ? await window.HogwartsAuth.isAuthenticated() : false;
        
        navLinks.forEach(link => {
            if (authenticated) {
                // Usuario logueado - mostrar "Mi Casa" o nombre de casa
                window.HogwartsAuth.getUserHouse().then(house => {
                    if (house) {
                        const houseName = house.charAt(0).toUpperCase() + house.slice(1);
                        link.textContent = houseName;
                        link.href = 'house_common_rooms_personalized_dashboards.html';
                    } else {
                        link.textContent = 'Seleccionar Casa';
                        link.href = 'house_selection_portal_sorting_hat_quiz.html';
                    }
                }).catch(() => {
                    // Fallback - verificar localStorage
                    const localHouse = localStorage.getItem('userHouse') || localStorage.getItem('selectedHouse');
                    if (localHouse) {
                        const houseName = localHouse.charAt(0).toUpperCase() + localHouse.slice(1);
                        link.textContent = houseName;
                        link.href = 'house_common_rooms_personalized_dashboards.html';
                    } else {
                        link.textContent = 'Seleccionar Casa';
                        link.href = 'house_selection_portal_sorting_hat_quiz.html';
                    }
                });
            } else {
                // Usuario NO logueado - mostrar "Iniciar Sesión"
                link.textContent = 'Iniciar Sesión';
                link.href = 'user_login.html';
                link.className = link.className.replace('btn-primary', 'btn-secondary');
            }
        });
        
    } catch (error) {
        console.log('Auth not available, showing login button');
        // Si hay error con auth, mostrar login
        navLinks.forEach(link => {
            link.textContent = 'Iniciar Sesión';
            link.href = 'user_login.html';
            link.className = link.className.replace('btn-primary', 'btn-secondary');
        });
    }
}

// Función para inicializar la navegación universal
function initUniversalNavigation() {
    // Esperar a que se cargue el auth
    if (window.HogwartsAuth) {
        updateUniversalNavigation();
    } else {
        // Intentar cada 100ms hasta que esté disponible
        let attempts = 0;
        const checkAuth = setInterval(() => {
            attempts++;
            if (window.HogwartsAuth || attempts > 50) { // Max 5 segundos
                clearInterval(checkAuth);
                updateUniversalNavigation();
            }
        }, 100);
    }
}

// Auto-inicializar cuando el DOM esté listo
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initUniversalNavigation);
} else {
    initUniversalNavigation();
}

// Exportar para uso manual si es necesario
window.updateUniversalNavigation = updateUniversalNavigation;