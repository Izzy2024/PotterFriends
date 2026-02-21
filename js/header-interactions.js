/**
 * header-interactions.js
 * Implements Wonder Games style magnetic hover, scroll transitions, and dynamic effects
 */
document.addEventListener('DOMContentLoaded', () => {
    const nav = document.getElementById('mainNav');
    
    // --- 1. Scroll Effect (Glassmorphism intensity) ---
    const handleScroll = () => {
        if (window.scrollY > 50) {
            nav.classList.add('scrolled');
        } else {
            nav.classList.remove('scrolled');
        }
    };
    // Initialize on load just in case page starts scrolled
    handleScroll();
    window.addEventListener('scroll', handleScroll, { passive: true });

    // --- 2. Magnetic Hover Effect ---
    const magneticElements = document.querySelectorAll('.wm-link, .wm-cta');

    magneticElements.forEach((el) => {
        // Only apply on non-touch devices
        if (window.matchMedia("(hover: hover)").matches) {
            el.addEventListener('mousemove', (e) => {
                const position = el.getBoundingClientRect();
                const x = e.clientX - position.left - position.width / 2;
                const y = e.clientY - position.top - position.height / 2;

                // Strength of the pull (lower = more subtle)
                const strength = el.classList.contains('wm-cta') ? 0.3 : 0.15;

                requestAnimationFrame(() => {
                    el.style.transform = `translate(${x * strength}px, ${y * strength}px)`;
                });
            });

            el.addEventListener('mouseleave', () => {
                requestAnimationFrame(() => {
                    el.style.transform = 'translate(0px, 0px)';
                });
            });
        }
    });

    // --- 3. Hide on Scroll Down (Optional/Optionalized feature, removed if we just want it sticky) ---
    // If the style dictates sticky, we keep it sticky. Currently, sticking with just the .scrolled class.

    // --- 4. Mobile Menu toggle enhancements ---
    const mobileMenuBtn = nav.querySelector('button.md\\:hidden');
    // If a mobile menu is implemented somewhere else in the code, this can broadcast an event
    if(mobileMenuBtn) {
        mobileMenuBtn.addEventListener('click', () => {
            // Add any specific magical mobile effects here
        });
    }
});
