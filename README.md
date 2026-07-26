# Artabria Rutinas

App web para que el entrenador gestione rutinas de entrenamiento y cada
cliente registre sus series desde un enlace único, sin contraseña.

Es una app **estática** (HTML/CSS/JS con módulos ES, sin paso de build) que
usa Supabase (`supabase-js` cargado desde CDN) como backend.

## Estructura

```
index.html               splash / enlace al panel
c/index.html              vista del cliente (lee el código de la URL)
admin/login.html            login del entrenador
admin/index.html              dashboard: lista de clientes
admin/cliente.html              editor de la rutina de un cliente
assets/css/styles.css           estética Artabria
assets/js/                      lógica de cada página
supabase/schema.sql              tablas + seguridad (RLS) + datos de ejemplo
vercel.json                       rewrite para que /c/<código> funcione
```

## 1. Configurar Supabase (una sola vez)

1. Entra en tu proyecto → **SQL Editor** → pega el contenido completo de
   [`supabase/schema.sql`](supabase/schema.sql) → **Run**.
   Esto crea las tablas, las políticas de seguridad (RLS) y el cliente de
   ejemplo "Borja Bravo Llinares" (enlace `/c/xk29fa`).
2. Ve a **Authentication → Sign In / Providers** y activa **"Allow anonymous
   sign-ins"**. Es lo que permite que un cliente entre con su enlace sin
   registrarse ni poner contraseña — sigue siendo seguro porque cada
   sesión anónima solo puede leer/escribir sus propios datos (RLS).
3. Abre `admin/login.html` (en local o ya desplegado) y pulsa **"¿Primera
   vez? Crear cuenta"** para registrarte con tu email y una contraseña.
4. Vuelve al SQL Editor y ejecuta (sustituyendo el email si hace falta):

   ```sql
   insert into admins (id)
   select id from auth.users where email = 'pablo.orji@gmail.com';
   ```

   Ahora esa cuenta ya puede entrar al panel de entrenador.

## 2. Probar en local

No hace falta Node ni ningún build. Basta un servidor estático simple:

```bash
python3 -m http.server 8000
```

Y abre `http://localhost:8000`. El panel está en `/admin/login.html` y el
enlace de ejemplo del cliente en `/c/xk29fa`.

> Nota: en local, rutas como `/c/xk29fa` las resuelve el JS leyendo
> `location.pathname` directamente sobre `c/index.html`; para que la URL
> "bonita" `/c/xk29fa` funcione sin el `index.html` explícito necesitas el
> rewrite de `vercel.json` (o el equivalente de tu hosting) — en producción
> (Vercel) ya está configurado.

## 3. Desplegar en Vercel

1. Sube esta carpeta a un repositorio Git y conéctalo en Vercel, o usa
   `vercel deploy` desde aquí (framework: **Other / Static**).
2. `vercel.json` ya incluye el rewrite para que `/c/<codigo>` sirva
   `c/index.html` manteniendo la URL.
3. Apunta tu dominio `rutinas.artabrianutrition.com` al proyecto de Vercel.

## 4. Uso del panel

- **Nuevo cliente**: desde el dashboard, botón "+ Nuevo cliente". El código
  del enlace se genera automáticamente (editable antes de guardar).
- **Copiar enlace**: cada cliente tiene un botón "Copiar" con su URL
  `.../c/<codigo>` lista para enviar por WhatsApp, email, etc.
- **Rutina**: dentro de la ficha del cliente, "Crear rutina" y luego añade
  días (p. ej. "Día 1 - Upper") y ejercicios (nombre, series, reps
  objetivo, notas). Las flechas ↑↓ reordenan días y ejercicios.
- **Desactivar cliente**: el interruptor junto al nombre desactiva su
  acceso sin borrar su histórico.

## Seguridad (cómo funciona el acceso sin contraseña)

- El código del enlace (`xk29fa`) no es solo una URL "secreta": al abrirlo,
  el cliente obtiene una sesión anónima real de Supabase Auth y esa sesión
  queda vinculada a su fila en `clientes` mediante la función `claim_cliente`.
  A partir de ahí, las políticas de Row Level Security comprueban
  `auth.uid()` igual que con cualquier usuario registrado — un cliente
  nunca puede ver ni modificar los datos de otro, aunque manipule las
  peticiones a la API.
- El entrenador usa email/contraseña (Supabase Auth) y debe estar en la
  tabla `admins` para tener acceso de escritura a clientes/rutinas.
