-- Mejoras del 21/10/2026: fotos y certificados, caducidad del seguro, ubicación/obra y tarifas de alquiler.
-- Pegar entero en Supabase > SQL Editor > New query, y pulsar «Run». Se puede ejecutar más de una vez.

-- 1. Nuevos datos de cada máquina
alter table public.maquinas add column if not exists foto text;
alter table public.maquinas add column if not exists cert_ce text;
alter table public.maquinas add column if not exists cert_seguro text;
alter table public.maquinas add column if not exists seguro_caduca date;

-- 2. Carpeta privada para fotos y PDF (máx. 10 MB por archivo). Solo la ven los usuarios con sesión iniciada.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('documentos', 'documentos', false, 10485760, array['image/jpeg','image/png','image/webp','application/pdf'])
on conflict (id) do nothing;

drop policy if exists "flota ver documentos" on storage.objects;
create policy "flota ver documentos" on storage.objects for select to authenticated using (bucket_id = 'documentos');
drop policy if exists "flota subir documentos" on storage.objects;
create policy "flota subir documentos" on storage.objects for insert to authenticated with check (bucket_id = 'documentos');
drop policy if exists "flota cambiar documentos" on storage.objects;
create policy "flota cambiar documentos" on storage.objects for update to authenticated using (bucket_id = 'documentos');
drop policy if exists "flota borrar documentos" on storage.objects;
create policy "flota borrar documentos" on storage.objects for delete to authenticated using (bucket_id = 'documentos');

-- 3. Tarifas: el antiguo «precio al mes» pasa a tarifa + precio.
--    Los alquileres de menos de 30 días se guardaron con el precio TOTAL, así que pasan a «precio cerrado».
update public.maquinas
set alquiler = (alquiler - 'precioMes') || jsonb_build_object(
  'tarifa', case
    when coalesce(alquiler->>'inicio','') <> '' and coalesce(alquiler->>'fin','') <> ''
     and (alquiler->>'fin')::date - (alquiler->>'inicio')::date < 30 then 'total'
    else 'mes' end,
  'precio', alquiler->'precioMes')
where alquiler ? 'precioMes' and jsonb_typeof(alquiler->'precioMes') = 'number';

update public.maquinas set alquiler = alquiler - 'precioMes' where alquiler ? 'precioMes';

-- 4. Comprobación: alquileres en curso y la tarifa con la que han quedado.
select upper(codigo) as maquina, ubicacion as cliente, alquiler->>'inicio' as desde, alquiler->>'fin' as hasta,
       alquiler->>'tarifa' as tarifa, alquiler->>'precio' as precio
from public.maquinas where situacion = 'alquilada' and alquiler ? 'tarifa'
order by ubicacion, codigo;
