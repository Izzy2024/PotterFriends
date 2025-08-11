// Script para verificar posts en la base de datos
import { supabase } from './supabase-client.js';

async function checkPosts() {
    console.log('🔍 Verificando posts en la base de datos...\n');
    
    try {
        // Obtener todos los posts
        const { data: posts, error } = await supabase
            .from('posts')
            .select('*')
            .order('created_at', { ascending: false });
            
        if (error) {
            console.error('❌ Error al obtener posts:', error);
            return;
        }
        
        console.log(`✅ Total de posts encontrados: ${posts.length}`);
        
        if (posts.length > 0) {
            console.log('\n📝 Posts existentes:');
            posts.forEach((post, index) => {
                console.log(`\n${index + 1}. ${post.title}`);
                console.log(`   ID: ${post.id}`);
                console.log(`   Usuario: ${post.user_id}`);
                console.log(`   Categoría: ${post.category_id}`);
                console.log(`   Casa: ${post.house_id}`);
                console.log(`   Creado: ${new Date(post.created_at).toLocaleString()}`);
                console.log(`   Contenido: ${post.content.substring(0, 100)}...`);
            });
        } else {
            console.log('\n⚠️ No hay posts en la base de datos');
        }
        
        // Verificar la estructura de la tabla
        console.log('\n🔍 Verificando estructura de la tabla posts...');
        const { data: sample, error: sampleError } = await supabase
            .from('posts')
            .select('*')
            .limit(1);
            
        if (!sampleError && sample.length > 0) {
            console.log('Columnas disponibles:', Object.keys(sample[0]));
        }
        
    } catch (error) {
        console.error('❌ Error general:', error);
    }
}

// Hacer la función disponible globalmente
window.checkPosts = checkPosts;

console.log('📝 Para verificar los posts, ejecuta: checkPosts()');

export { checkPosts };
