/**
 * Script de diagnóstico para problemas de autenticación
 * Úsalo en la consola del navegador para diagnosticar problemas de login
 */

async function diagnosticarProblemasAuth() {
    console.log('🔍 Iniciando diagnóstico de autenticación...');
    
    try {
        // 1. Verificar configuración de Supabase
        console.log('1️⃣ Verificando configuración de Supabase...');
        
        if (!window.supabase) {
            console.error('❌ Supabase no está disponible');
            return;
        }
        
        const SUPABASE_URL = 'https://vdcclritlgnwwdxloayt.supabase.co';
        const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZkY2Nscml0bGdud3dkeGxvYXl0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMwOTQxMDQsImV4cCI6MjA2ODY3MDEwNH0.BaBIrCS9fgkLEkC_KLZg9gR_jNgFIPC7bMvuwfCnb6E';
        
        const supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
        console.log('✅ Cliente Supabase inicializado');
        
        // 2. Verificar conexión a la base de datos
        console.log('2️⃣ Verificando conexión a la base de datos...');
        
        try {
            const { data, error } = await supabaseClient
                .from('user_profiles')
                .select('count(*)', { count: 'exact', head: true });
            
            if (error) {
                console.error('❌ Error conectando a user_profiles:', error);
            } else {
                console.log('✅ Conexión a user_profiles exitosa');
            }
        } catch (e) {
            console.error('❌ Error al conectar con la tabla user_profiles:', e);
        }
        
        // 3. Probar autenticación con credenciales de prueba
        console.log('3️⃣ Probando funcionalidad de autenticación...');
        
        // Obtener sesión actual
        const { data: session } = await supabaseClient.auth.getSession();
        if (session.session) {
            console.log('✅ Usuario ya autenticado:', session.session.user.email);
            
            // Probar acceso al perfil
            try {
                const { data: profile, error: profileError } = await supabaseClient
                    .from('user_profiles')
                    .select('*')
                    .eq('id', session.session.user.id)
                    .single();
                
                if (profileError) {
                    console.error('❌ Error accediendo al perfil:', profileError);
                } else {
                    console.log('✅ Perfil de usuario accesible:', profile);
                }
            } catch (e) {
                console.error('❌ Error al obtener perfil:', e);
            }
        } else {
            console.log('ℹ️ No hay usuario autenticado actualmente');
        }
        
        // 4. Verificar políticas RLS
        console.log('4️⃣ Verificando políticas de seguridad...');
        
        try {
            const { data: policies, error: policiesError } = await supabaseClient
                .rpc('get_policies', { table_name: 'user_profiles' });
            
            if (policiesError) {
                console.warn('⚠️ No se pudieron obtener las políticas RLS');
            } else {
                console.log('✅ Políticas RLS obtenidas:', policies);
            }
        } catch (e) {
            console.warn('⚠️ No se pudo verificar las políticas RLS');
        }
        
        console.log('🎉 Diagnóstico completado!');
        return supabaseClient;
        
    } catch (error) {
        console.error('💥 Error durante el diagnóstico:', error);
        return null;
    }
}

// Función para probar login específico
async function probarLogin(email, password) {
    console.log(`🧪 Probando login con: ${email}`);
    
    try {
        const supabaseClient = window.supabase.createClient(
            'https://vdcclritlgnwwdxloayt.supabase.co',
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZkY2Nscml0bGdud3dkeGxvYXl0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMwOTQxMDQsImV4cCI6MjA2ODY3MDEwNH0.BaBIrCS9fgkLEkC_KLZg9gR_jNgFIPC7bMvuwfCnb6E'
        );
        
        const { data, error } = await supabaseClient.auth.signInWithPassword({
            email: email,
            password: password
        });
        
        if (error) {
            console.error('❌ Error de login:', error);
            return { success: false, error: error.message };
        }
        
        console.log('✅ Login exitoso:', data);
        
        // Intentar obtener el perfil
        try {
            const { data: profile, error: profileError } = await supabaseClient
                .from('user_profiles')
                .select('*')
                .eq('id', data.user.id)
                .single();
            
            if (profileError) {
                console.error('❌ Error obteniendo perfil después del login:', profileError);
                return { success: true, data: data, profile: null, profileError: profileError.message };
            }
            
            console.log('✅ Perfil obtenido exitosamente:', profile);
            return { success: true, data: data, profile: profile };
            
        } catch (profileError) {
            console.error('❌ Error en la consulta del perfil:', profileError);
            return { success: true, data: data, profile: null, profileError: profileError.message };
        }
        
    } catch (error) {
        console.error('💥 Error inesperado durante el login:', error);
        return { success: false, error: error.message };
    }
}

// Función para crear un usuario de prueba
async function crearUsuarioPrueba() {
    const testEmail = 'test@hogwarts.com';
    const testPassword = 'Test123456!';
    
    console.log(`🧪 Creando usuario de prueba: ${testEmail}`);
    
    try {
        const supabaseClient = window.supabase.createClient(
            'https://vdcclritlgnwwdxloayt.supabase.co',
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZkY2Nscml0bGdud3dkeGxvYXl0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMwOTQxMDQsImV4cCI6MjA2ODY3MDEwNH0.BaBIrCS9fgkLEkC_KLZg9gR_jNgFIPC7bMvuwfCnb6E'
        );
        
        const { data, error } = await supabaseClient.auth.signUp({
            email: testEmail,
            password: testPassword,
            options: {
                data: {
                    first_name: 'Test',
                    last_name: 'User',
                    wizard_name: 'Test Wizard'
                }
            }
        });
        
        if (error) {
            console.error('❌ Error creando usuario de prueba:', error);
            return { success: false, error: error.message };
        }
        
        console.log('✅ Usuario de prueba creado:', data);
        return { success: true, data: data, email: testEmail, password: testPassword };
        
    } catch (error) {
        console.error('💥 Error inesperado creando usuario:', error);
        return { success: false, error: error.message };
    }
}

// Ejecutar diagnóstico automáticamente
console.log('📋 Script de diagnóstico de autenticación cargado');
console.log('📝 Comandos disponibles:');
console.log('  - diagnosticarProblemasAuth(): Ejecuta diagnóstico completo');
console.log('  - probarLogin(email, password): Prueba login con credenciales específicas');
console.log('  - crearUsuarioPrueba(): Crea un usuario de prueba');

// Ejecutar diagnóstico automáticamente si no hay parámetros
if (typeof window !== 'undefined' && window.location && window.location.search.includes('autodiag')) {
    diagnosticarProblemasAuth();
}