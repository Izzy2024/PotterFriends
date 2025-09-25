/**
 * Community Events Configuration and Initialization
 * This file ensures proper initialization and debugging for the community events system
 */

(function() {
    'use strict';
    
    // Configuration
    const CONFIG = {
        DEBUG_MODE: true,
        RETRY_ATTEMPTS: 10,
        RETRY_DELAY: 200
    };
    
    // Utility functions
    function log(message, data = null) {
        if (CONFIG.DEBUG_MODE) {
            console.log(`[Community Events] ${message}`, data || '');
        }
    }
    
    function error(message, err = null) {
        console.error(`[Community Events] ❌ ${message}`, err || '');
    }
    
    function success(message, data = null) {
        if (CONFIG.DEBUG_MODE) {
            console.log(`[Community Events] ✅ ${message}`, data || '');
        }
    }
    
    // Wait for Supabase client to be available
    async function waitForSupabase() {
        for (let i = 0; i < CONFIG.RETRY_ATTEMPTS; i++) {
            if (window.supabaseClient) {
                success('Supabase client found');
                return window.supabaseClient;
            }
            
            log(`Waiting for Supabase client... attempt ${i + 1}/${CONFIG.RETRY_ATTEMPTS}`);
            await new Promise(resolve => setTimeout(resolve, CONFIG.RETRY_DELAY));
        }
        
        error('Supabase client not available after maximum retries');
        return null;
    }
    
    // Test database connection
    async function testConnection() {
        const client = await waitForSupabase();
        if (!client) return false;
        
        try {
            // Simple test query
            const { data, error } = await client.from('events').select('count').limit(1).single();
            if (error && error.code !== 'PGRST116') { // PGRST116 = no rows, which is ok
                throw error;
            }
            success('Database connection successful');
            return true;
        } catch (err) {
            error('Database connection failed', err);
            return false;
        }
    }
    
    // Test RPC functions
    async function testRPCFunctions() {
        const client = await waitForSupabase();
        if (!client) return;
        
        const rpcs = [
            'get_quick_stats',
            'list_featured_events',
            'list_individual_challenges',
            'list_house_challenges',
            'get_polls_active'
        ];
        
        for (const rpcName of rpcs) {
            try {
                const { data, error } = await client.rpc(rpcName, 
                    rpcName.includes('list_') ? { in_limit: 1 } : {}
                );
                
                if (error) {
                    error(`RPC ${rpcName} failed`, error);
                } else {
                    success(`RPC ${rpcName} working`, data);
                }
            } catch (err) {
                error(`RPC ${rpcName} exception`, err);
            }
        }
    }
    
    // Show helpful debugging info
    function showDebugInfo() {
        if (!CONFIG.DEBUG_MODE) return;
        
        log('=== Community Events Debug Info ===');
        log('Page URL:', window.location.href);
        log('Supabase client available:', !!window.supabaseClient);
        log('Auth module loaded:', !!window.getCurrentUser);
        log('Community Events module loaded:', !!window.testCommunityEventsAPI);
        
        if (window.supabaseClient) {
            log('Supabase URL:', window.supabaseClient.supabaseUrl);
        }
        
        // Check if required DOM elements exist (only for community events page)
        if (window.location.pathname.includes('community_events_challenges_center.html')) {
            const requiredElements = [
                'stat-active-events',
                'stat-active-participants', 
                'stat-points-in-play',
                'stat-days-remaining',
                'featured-events-grid',
                'upcoming-events-list',
                'individual-challenges-list',
                'house-challenges-list'
            ];
            
            const missingElements = requiredElements.filter(id => !document.getElementById(id));
            if (missingElements.length > 0) {
                error('Missing DOM elements:', missingElements);
            } else {
                success('All required DOM elements found');
            }
        }
    }
    
    // Initialize everything
    async function initialize() {
        log('Initializing Community Events system...');
        
        showDebugInfo();
        
        const connectionOk = await testConnection();
        if (connectionOk) {
            await testRPCFunctions();
        }
        
        // Add global helpers for debugging
        window.communityEventsDebug = {
            testConnection,
            testRPCFunctions,
            showDebugInfo,
            waitForSupabase,
            config: CONFIG
        };
        
        success('Community Events system initialized');
    }
    
    // Auto-initialize when DOM is ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initialize);
    } else {
        initialize();
    }
    
})();