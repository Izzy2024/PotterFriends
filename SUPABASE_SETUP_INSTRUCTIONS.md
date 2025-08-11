# 🏰 Instrucciones para Configurar Supabase - Sistema de Casas

## ❌ Problemas Identificados

1. **Error 404**: `tmp_rovodev_sync_houses.js` no existe (ya eliminado)
2. **Campo `house` faltante**: La tabla `profiles` no tiene el campo para guardar la casa del usuario
3. **Múltiples cargas**: La página se inicializaba varias veces (ya corregido)
4. **Navegación inconsistente**: El botón "Mi Casa" no se actualizaba correctamente (ya corregido)

## ✅ Soluciones Implementadas

### 1. **Código actualizado**:
- ✅ Funciones `saveUserHouse()` y `getUserHouse()` agregadas a `auth.js`
- ✅ Quiz actualizado para guardar en Supabase
- ✅ Sala común actualizada para leer desde Supabase
- ✅ Navegación universal corregida
- ✅ Prevención de múltiples inicializaciones
- ✅ Mensaje de bienvenida personalizado agregado

### 2. **Pendiente - Configuración de Base de Datos**:

## 🔧 PASOS REQUERIDOS EN SUPABASE

### **Paso 1: Agregar campos a la tabla `profiles`**

Ve a tu dashboard de Supabase y ejecuta este SQL:

```sql
-- Agregar campo para la casa del usuario
ALTER TABLE profiles ADD COLUMN house TEXT;

-- Agregar campo para fecha de selección de casa
ALTER TABLE profiles ADD COLUMN house_selected_at TIMESTAMPTZ;

-- Opcional: Agregar índice para búsquedas más rápidas
CREATE INDEX idx_profiles_house ON profiles(house);
```

### **Paso 2: Verificar la estructura**

Después de ejecutar el SQL, tu tabla `profiles` debería tener estos campos:
- `id` (UUID, Primary Key)
- `first_name` (TEXT)
- `last_name` (TEXT)
- `wizard_name` (TEXT)
- `email` (TEXT)
- `house` (TEXT) ← **NUEVO**
- `house_selected_at` (TIMESTAMPTZ) ← **NUEVO**
- `created_at` (TIMESTAMPTZ)
- `updated_at` (TIMESTAMPTZ)

### **Paso 3: Verificar permisos RLS (Row Level Security)**

Asegúrate de que las políticas RLS permitan:
- **SELECT**: Los usuarios pueden leer su propio perfil
- **UPDATE**: Los usuarios pueden actualizar su propio perfil (incluyendo `house`)

```sql
-- Verificar políticas existentes
SELECT * FROM pg_policies WHERE tablename = 'profiles';

-- Si no existen, crear políticas básicas:
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Política para SELECT
CREATE POLICY "Users can view own profile" ON profiles
    FOR SELECT USING (auth.uid() = id);

-- Política para UPDATE
CREATE POLICY "Users can update own profile" ON profiles
    FOR UPDATE USING (auth.uid() = id);
```

## 🧪 Cómo Probar

### **Opción 1: Usar el archivo de verificación**
1. Abre `tmp_rovodev_check_database.html` en tu navegador
2. Inicia sesión en tu aplicación
3. Ejecuta las verificaciones paso a paso

### **Opción 2: Probar manualmente**
1. Inicia sesión en tu aplicación
2. Ve al quiz del sombrero seleccionador
3. Completa el quiz
4. Verifica en Supabase que el campo `house` se guardó en tu perfil
5. Cambia de dispositivo/navegador y verifica que tu casa persiste

## 📋 Checklist de Verificación

- [ ] Campo `house` agregado a tabla `profiles`
- [ ] Campo `house_selected_at` agregado a tabla `profiles`
- [ ] Políticas RLS configuradas correctamente
- [ ] Quiz guarda casa en Supabase (verificar en tabla)
- [ ] Sala común lee casa desde Supabase
- [ ] Navegación muestra casa correcta en todas las páginas
- [ ] Casa persiste al cambiar de dispositivo/navegador
- [ ] No hay errores 404 en consola del navegador

## 🔍 Comandos de Verificación SQL

```sql
-- Ver estructura de la tabla profiles
\d profiles;

-- Ver todos los perfiles con sus casas
SELECT id, wizard_name, email, house, house_selected_at 
FROM profiles 
ORDER BY house_selected_at DESC;

-- Contar usuarios por casa
SELECT house, COUNT(*) as total_users 
FROM profiles 
WHERE house IS NOT NULL 
GROUP BY house 
ORDER BY total_users DESC;
```

## 🚨 Troubleshooting

### Si el quiz no guarda en Supabase:
1. Verifica que el campo `house` existe en la tabla `profiles`
2. Revisa la consola del navegador para errores
3. Verifica que las políticas RLS permiten UPDATE

### Si la navegación no se actualiza:
1. Limpia localStorage: `localStorage.clear()`
2. Recarga la página
3. Vuelve a hacer el quiz

### Si aparecen errores 404:
1. Verifica que no hay referencias a archivos `tmp_rovodev_*` en el código
2. Limpia caché del navegador

---

**Una vez completados estos pasos, el sistema de casas funcionará completamente con Supabase y será persistente entre dispositivos.**