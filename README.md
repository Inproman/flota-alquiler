# Flota de alquiler

Aplicación web (PC y móvil) para controlar la flota de carretillas de alquiler: estado, ubicación o cliente, alquileres, horas del contador, plan de revisiones, averías, seguros e historial de cada máquina.

## Cómo está montada

- **La web** (esta carpeta) se publica gratis con GitHub Pages. Solo contiene el diseño y el funcionamiento de la app, no los datos.
- **Los datos** están en Supabase (base de datos gratuita). Solo se pueden ver y cambiar tras iniciar sesión con correo y contraseña.

## Puesta en marcha (una sola vez)

1. En Supabase, abre **SQL Editor → New query**, pega el contenido de `supabase.sql` y pulsa **Run**. Crea las tablas, la seguridad y carga las 25 máquinas.
2. En `config.js` pon la **Project URL** y la clave **anon public** (Project Settings → API).
3. En Supabase, **Authentication → Sign In / Providers → Email**: desactiva «Allow new users to sign up», para que nadie de fuera pueda crearse una cuenta.
4. Da de alta a cada usuario en **Authentication → Users → Add user → Create new user** (correo y contraseña, marcando «Auto Confirm User»). Cada uno puede cambiar su contraseña desde la app.
5. En GitHub, **Settings → Pages**: «Deploy from a branch», rama `main`, carpeta `/ (root)`.

## Instalar en el móvil

Abre la web en el móvil y elige **Añadir a pantalla de inicio** (Safari: botón Compartir; Chrome: menú ⋮).

## Archivos

| Archivo | Qué es |
|---|---|
| `index.html` | La aplicación |
| `config.js` | Datos de conexión a Supabase |
| `supabase.sql` | Tablas, seguridad y datos iniciales |
| `manifest.json`, `sw.js`, `icon-*.png` | Para instalarla como app en el móvil |
