const { chromium } = require('playwright');

async function testProfileWithAuth() {
    const browser = await chromium.launch({ headless: false });
    const context = await browser.newContext();
    const page = await context.newPage();

    // Capturar errores de consola desde el inicio
    const consoleErrors = [];
    const consoleWarnings = [];
    page.on('console', msg => {
        if (msg.type() === 'error') {
            consoleErrors.push(msg.text());
        } else if (msg.type() === 'warning') {
            consoleWarnings.push(msg.text());
        }
    });

    try {
        console.log('🔍 Analizando el sistema de autenticación y perfil...');

        // Ir directamente al perfil para verificar la redirección automática
        console.log('🚀 Accediendo directamente a la página de perfil...');
        await page.goto('http://localhost:8080/pages/user_profile_achievement_system.html');
        await page.waitForLoadState('networkidle');
        await page.waitForTimeout(2000); // Dar tiempo a que se ejecute la redirección
        
        console.log('🌐 URL después de acceso directo:', page.url());
        console.log('📄 Título:', await page.title());
        
        if (page.url().includes('user_login.html')) {
            console.log('✅ Sistema de protección funcionando correctamente - redirigió al login');
        }

        console.log('🔧 Ahora vamos a simular autenticación de Supabase...');
        
        // Simular una sesión válida de Supabase
        await page.evaluate(() => {
            // Mock de Supabase para simular autenticación
            window.mockSupabaseAuth = {
                session: {
                    access_token: 'mock_token_123',
                    user: {
                        id: 'user-123',
                        email: 'hermione@hogwarts.edu',
                        user_metadata: {
                            wizard_name: 'Hermione Granger',
                            full_name: 'Hermione Granger'
                        },
                        created_at: new Date().toISOString()
                    }
                }
            };

            // Mock del cliente de Supabase
            window.supabase = {
                createClient: () => ({
                    auth: {
                        getUser: () => Promise.resolve({
                            data: { user: window.mockSupabaseAuth.session.user },
                            error: null
                        }),
                        getSession: () => Promise.resolve({
                            data: { session: window.mockSupabaseAuth.session },
                            error: null
                        }),
                        signOut: () => Promise.resolve({ error: null })
                    },
                    from: (table) => ({
                        select: () => ({
                            eq: () => ({
                                single: () => Promise.resolve({
                                    data: {
                                        id: 'user-123',
                                        display_name: 'Hermione Granger',
                                        bio: 'La bruja más inteligente de su generación',
                                        house: 'gryffindor',
                                        wizard_name: 'Hermione Granger',
                                        first_name: 'Hermione',
                                        last_name: 'Granger',
                                        created_at: new Date().toISOString(),
                                        privacy_public_profile: true,
                                        privacy_show_stats: true,
                                        privacy_allow_messages: true
                                    },
                                    error: null
                                })
                            })
                        })
                    })
                })
            };

            // Datos adicionales en localStorage
            const userData = {
                id: 'user-123',
                email: 'hermione@hogwarts.edu',
                wizard_name: 'Hermione Granger',
                house: 'gryffindor',
                display_name: 'Hermione Granger'
            };
            
            localStorage.setItem('hogwarts_user', JSON.stringify(userData));
            localStorage.setItem('userHouse', 'gryffindor');
            localStorage.setItem('selectedHouse', 'gryffindor');

            console.log('✅ Autenticación simulada configurada');
        });

        console.log('🔄 Intentando acceder al perfil con autenticación simulada...');
        await page.goto('http://localhost:8080/pages/user_profile_achievement_system.html');
        await page.waitForLoadState('networkidle');
        await page.waitForTimeout(3000); // Dar tiempo suficiente para que cargue
        
        const authenticatedUrl = page.url();
        const authenticatedTitle = await page.title();
        
        console.log('🎯 URL con autenticación simulada:', authenticatedUrl);
        console.log('📄 Título con autenticación:', authenticatedTitle);

        if (authenticatedUrl.includes('user_profile_achievement_system.html')) {
            console.log('🎉 ¡Éxito! La página de perfil se cargó correctamente');
            
            // Analizar el contenido del perfil
            await page.waitForTimeout(2000);
            
            const profileName = await page.locator('#profileName, .profile-name, h1').first().textContent().catch(() => 'No encontrado');
            const profileElements = await page.locator('[id*="profile"], [class*="profile"]').count();
            const achievements = await page.locator('.achievement-badge, [class*="achievement"]').count();
            
            console.log('👤 Nombre del perfil:', profileName);
            console.log('🔢 Elementos de perfil encontrados:', profileElements);
            console.log('🏆 Logros/badges encontrados:', achievements);
            
            // Verificar elementos específicos de la interfaz
            const editButton = await page.locator('#editProfileBtn, button:has-text("Editar")').count();
            const saveButton = await page.locator('#saveProfileBtn, button:has-text("Guardar")').count();
            const statsElements = await page.locator('[class*="stat"], .stats').count();
            
            console.log('✏️ Botones de edición:', editButton);
            console.log('💾 Botones de guardado:', saveButton);
            console.log('📊 Elementos de estadísticas:', statsElements);
            
            // Tomar captura exitosa
            await page.screenshot({ path: 'profile_success.png', fullPage: true });
            
        } else {
            console.log('❌ La simulación no funcionó, aún redirige al login');
            await page.screenshot({ path: 'auth_simulation_failed.png' });
        }

        // Mostrar errores y warnings de consola
        if (consoleErrors.length > 0) {
            console.log('\n❌ ERRORES DE CONSOLA:');
            consoleErrors.forEach((error, index) => {
                console.log(`${index + 1}. ${error}`);
            });
        }

        if (consoleWarnings.length > 0) {
            console.log('\n⚠️ WARNINGS DE CONSOLA:');
            consoleWarnings.forEach((warning, index) => {
                console.log(`${index + 1}. ${warning}`);
            });
        }

        // Verificar el estado actual del localStorage
        const finalStorage = await page.evaluate(() => {
            const items = {};
            for (let i = 0; i < localStorage.length; i++) {
                const key = localStorage.key(i);
                items[key] = localStorage.getItem(key);
            }
            return items;
        });
        
        console.log('\n💾 Estado final del localStorage:', finalStorage);
        
    } catch (error) {
        console.error('💥 Error durante la prueba:', error);
        await page.screenshot({ path: 'error_screenshot.png' });
    } finally {
        console.log('\n🔚 Manteniendo el navegador abierto para inspección manual...');
        console.log('Presiona Ctrl+C para cerrar cuando hayas terminado.');
        
        // Mantener el navegador abierto para inspección manual
        await new Promise(() => {});
        //await browser.close();
    }
}

testProfileWithAuth();
