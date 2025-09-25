// Stagewise Toolbar Initialization
// This file initializes the stagewise toolbar for AI-powered editing capabilities

// Check if we're in development mode
const isDevelopment = window.location.hostname === 'localhost' || 
                     window.location.hostname === '127.0.0.1' || 
                     window.location.hostname === '';

if (isDevelopment) {
    // Import and initialize stagewise toolbar
    import('@stagewise/toolbar').then(({ initToolbar }) => {
        initToolbar();
    }).catch(error => {
        console.warn('Stagewise toolbar could not be loaded:', error);
    });
} 