// Script de diagnóstico para el foro
import { supabase as supabaseImport } from './supabase-client.js';
import { forumAPI } from './services/forumApi.js';

// Manejar el caso cuando supabase es una promesa
let supabase = supabaseImport;
if (supabaseImport instanceof Promise) {
    supabaseImport.then(client => {
        supabase = client;
    });
}

async function runDiagnostics() {
    console.log('=== Iniciando diagnóstico del foro ===');
    
    // 1. Verificar conexión con Supabase
    console.log('\n1. Verificando conexión con Supabase...');
    try {
        const { data, error } = await supabase.auth.getSession();
        if (error) {
            console.error('❌ Error al conectar con Supabase:', error);
        } else {
            console.log('✅ Conexión con Supabase exitosa');
            console.log('Sesión actual:', data.session ? 'Autenticado' : 'No autenticado');
        }
    } catch (e) {
        console.error('❌ Error crítico de conexión:', e);
    }

    // 2. Verificar usuario actual
    console.log('\n2. Verificando usuario actual...');
    try {
        const { data: { user }, error } = await supabase.auth.getUser();
        if (error) {
            console.error('❌ Error al obtener usuario:', error);
        } else if (user) {
            console.log('✅ Usuario autenticado:', user.email);
            console.log('ID de usuario:', user.id);
            console.log('Metadata:', user.user_metadata);
        } else {
            console.warn('⚠️ No hay usuario autenticado');
        }
    } catch (e) {
        console.error('❌ Error al verificar usuario:', e);
    }

    // 3. Verificar perfil de usuario
    console.log('\n3. Verificando perfil de usuario...');
    try {
        const { data: { user } } = await supabase.auth.getUser();
        if (user) {
            const { data: profile, error } = await supabase
                .from('user_profiles')
                .select('*')
                .eq('id', user.id)
                .single();
            
            if (error) {
                console.error('❌ Error al obtener perfil:', error);
            } else {
                console.log('✅ Perfil encontrado:', profile);
            }
        }
    } catch (e) {
        console.error('❌ Error al verificar perfil:', e);
    }

    // 4. Verificar tablas
    console.log('\n4. Verificando tablas del foro...');
    const tables = ['houses', 'categories', 'posts', 'comments', 'likes', 'forum_user_stats'];
    
    for (const table of tables) {
        try {
            const { count, error } = await supabase
                .from(table)
                .select('*', { count: 'exact', head: true });
            
            if (error) {
                console.error(`❌ Error en tabla ${table}:`, error);
            } else {
                console.log(`✅ Tabla ${table}: ${count || 0} registros`);
            }
        } catch (e) {
            console.error(`❌ Error crítico en tabla ${table}:`, e);
        }
    }

    // 5. Verificar casas
    console.log('\n5. Verificando casas...');
    try {
        const result = await forumAPI.getHouses();
        if (result.success) {
            console.log('✅ Casas cargadas:', result.data);
        } else {
            console.error('❌ Error al cargar casas:', result.error);
        }
    } catch (e) {
        console.error('❌ Error crítico al cargar casas:', e);
    }

    // 6. Verificar categorías
    console.log('\n6. Verificando categorías...');
    try {
        const result = await forumAPI.getCategories();
        if (result.success) {
            console.log('✅ Categorías cargadas:', result.data);
        } else {
            console.error('❌ Error al cargar categorías:', result.error);
        }
    } catch (e) {
        console.error('❌ Error crítico al cargar categorías:', e);
    }

    // 7. Intentar crear un post de prueba
    console.log('\n7. Intentando crear un post de prueba...');
    try {
        const { data: { user } } = await supabase.auth.getUser();
        if (user) {
            // Primero obtener una categoría válida
            const { data: categories } = await supabase
                .from('categories')
                .select('id')
                .limit(1)
                .single();
            
            if (categories) {
                const testPost = {
                    title: 'Post de prueba - Diagnóstico',
                    content: 'Este es un post de prueba creado por el diagnóstico',
                    categoryId: categories.id,
                    houseId: 1 // Gryffindor
                };
                
                const result = await forumAPI.createPost(testPost);
                if (result.success) {
                    console.log('✅ Post de prueba creado exitosamente:', result.data);
                    // Eliminar el post de prueba
                    await supabase.from('posts').delete().eq('id', result.data.id);
                    console.log('✅ Post de prueba eliminado');
                } else {
                    console.error('❌ Error al crear post de prueba:', result.error);
                }
            } else {
                console.error('❌ No se encontraron categorías');
            }
        } else {
            console.warn('⚠️ No se puede crear post sin usuario autenticado');
        }
    } catch (e) {
        console.error('❌ Error crítico al crear post de prueba:', e);
    }

    // 8. Verificar permisos RLS
    console.log('\n8. Verificando permisos RLS...');
    try {
        const { data: { user } } = await supabase.auth.getUser();
        if (user) {
            // Intentar leer posts
            const { data: posts, error: readError } = await supabase
                .from('posts')
                .select('*')
                .limit(1);
            
            if (readError) {
                console.error('❌ Error al leer posts (posible problema RLS):', readError);
            } else {
                console.log('✅ Lectura de posts permitida');
            }
        }
    } catch (e) {
        console.error('❌ Error al verificar permisos:', e);
    }

    console.log('\n=== Diagnóstico completado ===');
    console.log('Revisa los errores arriba para identificar el problema.');
}

// Ejecutar diagnóstico cuando se cargue la página
if (window.location.pathname.includes('interactive_forum_hub.html')) {
    window.runForumDiagnostics = runDiagnostics;
    console.log('Diagnóstico del foro cargado. Ejecuta runForumDiagnostics() en la consola.');
    
    // Auto-ejecutar si hay parámetro debug
    const urlParams = new URLSearchParams(window.location.search);
    if (urlParams.get('debug') === 'true') {
        runDiagnostics();
    }
}
