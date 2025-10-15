/*
 * Deprecated legacy shim for auth module
 * This file now loads the unified module at /src/scripts/auth.js
 * Prefer importing ../src/scripts/auth.js directly from pages.
 */
(function () {
  try {
    if (window.HogwartsAuth) {
      console.warn('[auth.js] Legacy shim: HogwartsAuth already present.');
      return;
    }
    var script = document.createElement('script');
    script.src = '/src/scripts/auth.js';
    script.async = false;
    script.onload = function () {
      console.warn('[auth.js] Loaded deprecated shim -> /src/scripts/auth.js');
    };
    script.onerror = function () {
      console.error('[auth.js] Failed to load /src/scripts/auth.js');
    };
    (document.head || document.documentElement).appendChild(script);
  } catch (e) {
    console.error('[auth.js] Legacy shim error:', e);
  }
})();
