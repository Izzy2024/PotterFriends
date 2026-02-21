/**
 * Script de diagnóstico para problemas de autenticación
 * Úsalo en la consola del navegador para diagnosticar problemas de login
 * 
 * Este script usa el cliente de base de datos local (window.supabaseClient)
 * que se conecta al backend en http://localhost:3001
 */

async function diagnosticarProblemasAuth() {
    console.log('🔍 Iniciando diagnóstico de autenticación...');
    
    try {
        // 1. Verificar configuración del cliente de base de datos
        console.log('1️⃣ Verificando configuración del cliente de base de datos...');
        
        if (!window.supabaseClient) {
            console.error('❌ Cliente de base de datos no está disponible');
            console.log('ℹ️ Asegúrate de que auth.js esté cargado y el backend local esté corriendo');
            return;
        }
        
        const dbClient = window.supabaseClient;
        console.log('✅ Cliente de base de datos inicializado');
        
        // 2. Verificar conexión a la base de datos
        console.log('2️⃣ Verificando conexión a la base de datos...');
        
        try {
            const { data, error } = await dbClient
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
        
        // 3. Probar autenticación
        console.log('3️⃣ Probando funcionalidad de autenticación...');
        
        // Obtener sesión actual
        const { data: session } = await dbClient.auth.getSession();
        if (session.session) {
            console.log('✅ Usuario ya autenticado:', session.session.user.email);
            
            // Probar acceso al perfil
            try {
                const { data: profile, error: profileError } = await dbClient
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
        
        // 4. Verificar backend local
        console.log('4️⃣ Verificando backend local...');
        
        try {
            const response = await fetch('http://localhost:3001/health');
            if (response.ok) {
                console.log('✅ Backend local está corriendo');
            } else {
                console.warn('⚠️ Backend local respondió con error:', response.status);
            }
        } catch (e) {
            console.warn('⚠️ No se pudo conectar al backend local. ¿Está corriendo en puerto 3001?');
        }
        
        console.log('🎉 Diagnóstico completado!');
        return dbClient;
        
    } catch (error) {
        console.error('💥 Error durante el diagnóstico:', error);
        return null;
    }
}

// Función para probar login específico
async function probarLogin(email, password) {
    console.log(`🧪 Probando login con: ${email}`);
    
    try {
        const dbClient = window.supabaseClient;
        
        if (!dbClient) {
            console.error('❌ Cliente de base de datos no disponible');
            return { success: false, error: 'Cliente no disponible' };
        }
        
        const { data, error } = await dbClient.auth.signInWithPassword({
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
            const { data: profile, error: profileError } = await dbClient
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
        const dbClient = window.supabaseClient;
        
        if (!dbClient) {
            console.error('❌ Cliente de base de datos no disponible');
            return { success: false, error: 'Cliente no disponible' };
        }
        
        const { data, error } = await dbClient.auth.signUp({
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
console.log('📋 Script de diagnóstico de autenticación cargado (Local Backend)');
console.log('📝 Comandos disponibles:');
console.log('  - diagnosticarProblemasAuth(): Ejecuta diagnóstico completo');
console.log('  - probarLogin(email, password): Prueba login con credenciales específicas');
console.log('  - crearUsuarioPrueba(): Crea un usuario de prueba');
console.log('ℹ️ Backend local: http://localhost:3001');

// Ejecutar diagnóstico automáticamente si no hay parámetros
if (typeof window !== 'undefined' && window.location && window.location.search.includes('autodiag')) {
    diagnosticarProblemasAuth();
}