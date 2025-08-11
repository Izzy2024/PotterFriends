const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();
  
  try {
    // Navegar a la página
    await page.goto('http://localhost:8080/pages/user_profile_achievement_system.html');
    
    // Esperar a que la página cargue
    await page.waitForLoadState('networkidle');
    
    // Obtener información básica de la página
    const title = await page.title();
    console.log('🎯 Título de la página:', title);
    
    // Obtener el contenido del perfil
    const profileName = await page.textContent('#profileName').catch(() => 'No encontrado');
    console.log('👤 Nombre del perfil:', profileName);
    
    const profileHouse = await page.textContent('#profileHouse').catch(() => 'No encontrado');
    console.log('🏠 Casa:', profileHouse);
    
    // Contar elementos de logros
    const achievementBadges = await page.locator('.achievement-badge').count();
    console.log('🏆 Badges de logros encontrados:', achievementBadges);
    
    // Verificar secciones principales
    const sections = await page.locator('section').count();
    console.log('📄 Secciones en la página:', sections);
    
    // Verificar errores en consola
    page.on('console', msg => {
      if (msg.type() === 'error') {
        console.log('❌ Error de consola:', msg.text());
      }
    });
    
    // Obtener estructura de la página
    const mainContent = await page.locator('.max-w-6xl').first().isVisible();
    console.log('📱 Contenido principal visible:', mainContent);
    
    // Verificar si hay elementos duplicados
    const footers = await page.locator('footer').count();
    console.log('🔗 Número de footers:', footers);
    
    // Tomar una captura de pantalla para referencia
    await page.screenshot({ path: 'profile_page_screenshot.png', fullPage: true });
    console.log('📸 Captura de pantalla guardada como profile_page_screenshot.png');
    
  } catch (error) {
    console.error('❌ Error al analizar la página:', error.message);
  } finally {
    await browser.close();
  }
})();
