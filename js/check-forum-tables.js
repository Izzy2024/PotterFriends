// Script para verificar el estado de las tablas del foro
import { supabase } from './supabase-client.js';

async function checkForumTables() {
    console.log('🔍 Verificando tablas del foro...\n');
    
    const tables = [
        'posts',
        'post_comments', 
        'post_likes',
        'comment_likes',
        'forum_categories',
        'user_stats'
    ];
    
    for (const table of tables) {
        try {
            const { data, error } = await supabase
                .from(table)
                .select('*')
                .limit(1);
                
            if (error) {
                console.log(`❌ ${table}: ${error.message}`);
            } else {
                console.log(`✅ ${table}: Existe y es accesible`);
            }
        } catch (e) {
            console.log(`❌ ${table}: Error - ${e.message}`);
        }
    }
    
    // Verificar si la tabla posts existe pero tiene problemas con las relaciones
    console.log('\n🔍 Verificando estructura de posts...');
    try {
        const { data, error } = await supabase
            .from('posts')
            .select('*')
            .limit(1);
            
        if (!error && data) {
            console.log('✅ Tabla posts existe');
            console.log('Columnas disponibles:', data.length > 0 ? Object.keys(data[0]) : 'Tabla vacía');
        }
    } catch (e) {
        console.log('❌ Error verificando posts:', e.message);
    }
    
    // Verificar relaciones
    console.log('\n🔍 Verificando foreign keys...');
    try {
        const { data, error } = await supabase.rpc('get_table_foreign_keys', {
            table_name: 'posts'
        });
        
        if (!error) {
            console.log('Foreign keys en posts:', data);
        }
    } catch (e) {
        // Si la función no existe, intentar otra forma
        console.log('No se pudo verificar foreign keys directamente');
    }
}

// Ejecutar si se llama directamente
if (import.meta.url === `file://${process.argv[1]}`) {
    checkForumTables().then(() => {
        console.log('\n✅ Verificación completada');
    }).catch(error => {
        console.error('\n❌ Error:', error);
    });
}

export { checkForumTables };
