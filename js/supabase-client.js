// Usar el cliente Supabase global ya cargado desde el CDN
const supabaseUrl = 'https://vdcclritlgnwwdxloayt.supabase.co'
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZkY2Nscml0bGdud3dkeGxvYXl0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMwOTQxMDQsImV4cCI6MjA2ODY3MDEwNH0.BaBIrCS9fgkLEkC_KLZg9gR_jNgFIPC7bMvuwfCnb6E'

// Esperar a que Supabase esté cargado desde el CDN
let supabase;

if (window.supabaseClient) {
    // Si ya existe el cliente global, usarlo
    supabase = window.supabaseClient;
} else if (window.supabase) {
    // Si existe la librería, crear el cliente
    supabase = window.supabase.createClient(supabaseUrl, supabaseAnonKey);
    window.supabaseClient = supabase;
} else {
    // Si no está cargado aún, esperar y crearlo
    console.warn('Supabase no está cargado aún, esperando...');
    
    // Crear una promesa que se resuelve cuando Supabase esté disponible
    const waitForSupabase = new Promise((resolve) => {
        const checkInterval = setInterval(() => {
            if (window.supabase) {
                clearInterval(checkInterval);
                supabase = window.supabase.createClient(supabaseUrl, supabaseAnonKey);
                window.supabaseClient = supabase;
                resolve(supabase);
            }
        }, 100);
    });
    
    // Exportar la promesa temporalmente
    supabase = waitForSupabase;
}

export { supabase }
