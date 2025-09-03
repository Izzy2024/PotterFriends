// Centraliza el uso del cliente Supabase evitando múltiples instancias.
// Este módulo SIEMPRE reutiliza window.supabaseClient (creado en auth.js).

let supabase;

function waitForClient(timeoutMs = 4000) {
  return new Promise((resolve, reject) => {
    const start = Date.now();
    const timer = setInterval(() => {
      if (window.supabaseClient) {
        clearInterval(timer);
        supabase = window.supabaseClient;
        resolve(supabase);
      } else if (Date.now() - start > timeoutMs) {
        clearInterval(timer);
        reject(new Error('Supabase client not initialized by auth.js'));
      }
    }, 50);
  });
}

const ready = (async () => {
  // Si ya existe el cliente global, úsalo
  if (window.supabaseClient) {
    supabase = window.supabaseClient;
    return supabase;
  }
  // Espera a que cargue la librería del CDN si hiciera falta
  if (!window.supabase) {
    await new Promise(resolve => {
      const check = setInterval(() => {
        if (window.supabase) { clearInterval(check); resolve(); }
      }, 50);
    });
  }
  // Espera a que auth.js cree el cliente global
  return waitForClient();
})();

export { ready as supabase }
