-- Flota de alquiler: crea las tablas, la seguridad y carga las 25 máquinas.
-- Pegar entero en Supabase > SQL Editor > New query, y pulsar «Run».

create table if not exists public.maquinas (
  id text primary key default gen_random_uuid()::text,
  codigo text,
  tipo text not null default 'Carretilla',
  anio_compra int,
  marca text,
  modelo text,
  serie text,
  combustible text,
  potencia_kw numeric,
  anio int,
  coste numeric,
  pvp numeric,
  mastil text,
  altura_mastil numeric,
  ruedas int,
  situacion text not null default 'disponible'
    check (situacion in ('alquilada','disponible','averiada','taller','vendida')),
  ubicacion text,
  poliza text,
  notas text,
  alquiler jsonb,
  horas numeric,
  horas_fecha date,
  revision_cada_h numeric,
  revision_cada_meses numeric,
  ultima_revision_fecha date,
  ultima_revision_h numeric,
  proxima_revision_h numeric,
  proxima_revision_fecha date,
  actualizado timestamptz not null default now()
);

create table if not exists public.movimientos (
  id uuid primary key default gen_random_uuid(),
  maquina text not null references public.maquinas(id) on delete cascade,
  fecha date not null default current_date,
  tipo text not null,
  detalle text,
  cliente text,
  coste numeric,
  horas numeric,
  por uuid default auth.uid(),
  por_email text,
  creado timestamptz not null default now()
);
create index if not exists movimientos_maquina on public.movimientos(maquina);

create or replace function public.tocar_actualizado() returns trigger language plpgsql as $$
begin new.actualizado = now(); return new; end $$;
drop trigger if exists maquinas_actualizado on public.maquinas;
create trigger maquinas_actualizado before update on public.maquinas
  for each row execute function public.tocar_actualizado();

-- Seguridad: solo los usuarios que han iniciado sesión pueden ver y cambiar datos.
alter table public.maquinas enable row level security;
alter table public.movimientos enable row level security;
drop policy if exists "usuarios" on public.maquinas;
create policy "usuarios" on public.maquinas for all to authenticated using (true) with check (true);
drop policy if exists "usuarios" on public.movimientos;
create policy "usuarios" on public.movimientos for all to authenticated using (true) with check (true);

-- Avisos en directo para que todos vean los cambios al momento.
do $$ begin
  alter publication supabase_realtime add table public.maquinas;
exception when duplicate_object then null; end $$;
do $$ begin
  alter publication supabase_realtime add table public.movimientos;
exception when duplicate_object then null; end $$;

-- Para añadir más máquinas o cambios posteriores, ver la carpeta «actualizaciones».

-- Las 25 máquinas del inventario (21/10/2026).
insert into public.maquinas (id, codigo, marca, modelo, serie, combustible, potencia_kw, anio, coste, pvp, mastil, altura_mastil, ruedas, situacion, ubicacion, poliza, notas, alquiler) values
('m01', 'i106', 'STILL', 'RX20-16P', '516212C00328', 'Eléctrica', 9, 2012, 9800, 8000, 'Triple', null, 4, 'alquilada', 'GAS ECO/FLRY', '02.17.10000109.00001', null, '{"inicio":null,"fin":null,"precioMes":null}'::jsonb),
('m02', 'i104', 'STILL', 'RX20-15', '516210D00132', 'Eléctrica', 9, 2013, 9000, 8000, 'Triple', null, 3, 'alquilada', 'TSB', '02.17.10000109.00002', null, '{"inicio":null,"fin":null,"precioMes":null}'::jsonb),
('m03', 'i109', 'MITSUBISHI', 'FB16NT', 'EFB11 21332', 'Eléctrica', 10, 2008, 4000, 5000, 'Triple', null, 3, 'alquilada', 'UMACO', '02.17.10000109.00003', null, '{"inicio":null,"fin":null,"precioMes":null}'::jsonb),
('m04', 'i107', 'STILL', 'RX20-16', '516211E00465', 'Eléctrica', 9, 2014, 7050, 8500, 'Triple', 4960, 3, 'alquilada', 'MAHESO', '02.17.10000109.00004', 'En la hoja figura como «I107-I50».', '{"inicio":null,"fin":null,"precioMes":null}'::jsonb),
('m05', 'i108', 'NISSAN', 'S1N1L15Q', 'S1N1E721540', 'Eléctrica', 10, 2010, 4450, 6000, 'Triple', 4300, 3, 'alquilada', 'Tableteados', null, null, '{"inicio":null,"fin":null,"precioMes":null}'::jsonb),
('m06', 'i201', 'NISSAN', 'FD01A18Q', 'FD01E703256', 'Diésel', 42, 2005, 6500, 8000, 'Triple', null, 4, 'alquilada', 'HIERROS Y METALES', '02.17.10000109.00006', null, '{"inicio":null,"fin":null,"precioMes":null}'::jsonb),
('m07', 'i206', 'TOYOTA', '02-7FDF20', '7FDF25 13311', 'Diésel', 49, 2003, 6500, 6000, 'Triple', 4700, 4, 'alquilada', 'ADJ', '02.17.10000109.00007', 'Fecha 22/01/2025 en la hoja, sin título de columna.', '{"inicio":null,"fin":null,"precioMes":null}'::jsonb),
('m08', 'i100', 'STILL', 'RX60-16', '516311B00030', 'Eléctrica', 11, 2011, 6550, 7500, 'Triple', null, null, 'disponible', 'NAVE 1', '02.17.10000109.00018', null, null),
('m09', null, 'STILL', 'R60-20I', '516055000734', 'Eléctrica', 11.8, 2004, 4500, 2000, 'Triple', null, 4, 'taller', 'NAVE 1', null, 'En reparación. Neumático 200/50-10.', null),
('m10', null, 'STILL', 'RX20-16', '516221X00742', 'Eléctrica', 13, 2020, 1500, 9000, 'Triple', 6000, 3, 'disponible', 'NAVE 1', '02.17.10000109.00008', 'Batería 625 Ah.', null),
('m11', null, 'STILL', 'RX20-16', '516221X00744', 'Eléctrica', 13, 2020, 1500, 9000, 'Triple', 6000, 3, 'disponible', 'NAVE 2', '02.17.10000109.00009', 'Batería 625 Ah.', null),
('m12', null, 'STILL', 'RX20-16', '516221X00307', 'Eléctrica', 13, 2020, 1500, 9000, 'Triple', 5200, 3, 'disponible', 'NAVE 1', '02.17.10000109.00010', 'Batería 625 Ah.', null),
('m13', null, 'STILL', 'RX60-50', '516329B00281', 'Eléctrica', 15, 2011, 11500, 9000, null, null, 4, 'disponible', 'NAVE 2', '02.17.10000109.00011', null, null),
('m14', null, 'NISSAN', 'GN01L16V', null, 'Eléctrica', 7.8, null, 1000, 1500, 'Triple', 4700, 3, 'averiada', 'NAVE 1', null, 'Recogida de Tableteados.', null),
('m15', 'i105', 'STILL', 'RX20-16 DRIVE', '516211B00236', 'Eléctrica', 9, 2011, 7350, 8000, null, 5220, null, 'disponible', 'NAVE 1', '02.17.10000109.00012', null, null),
('m16', 'i103', 'STILL', 'RX20-16P', '516212Z25844', 'Eléctrica', 9, 2009, 6000, 7500, 'Triple', 4660, 4, 'disponible', 'NAVE 1', null, null, null),
('m17', 'i101', 'STILL', 'RX60-16', '516311E00014', 'Eléctrica', 11, 2014, 5650, 8500, null, 4260, 4, 'disponible', 'NAVE 2', null, null, null),
('m18', 'i102', 'STILL', 'RX60-16', '516311D00019', 'Eléctrica', 11, 2013, 6800, 9000, null, 4920, null, 'disponible', 'NAVE 1', null, null, null),
('m19', 'i203', 'MAXIMAL', 'GSMC', '1702505940', 'Diésel', 36.9, 2017, 11270, 6000, null, 4545, 4, 'disponible', 'NAVE 2', '02.17.10000109.00013', null, null),
('m20', 'i204', 'NISSAN', '1D', 'Y1D1E700800', 'Diésel', 38, 2011, 10700, 6000, 'Triple', 4750, 4, 'averiada', 'NAVE 1', null, null, null),
('m21', 'i200', 'NISSAN', 'FD01A18Q', 'FD01E703348', 'Diésel', 42, 2005, 6500, 8000, 'Triple', null, 4, 'disponible', 'NAVE 2', '02.17.10000109.00019', null, null),
('m22', 'i205', 'YALE', 'GDP30', 'B875B20163H', 'Diésel', 48.5, 2010, 6550, 10800, 'Triple', 5120, 4, 'disponible', 'NAVE 2', '02.17.10000109.00014', null, null),
('m23', 'i202', 'NISSAN', 'FJ01A150', 'FJ01E796241', 'Diésel', 42.5, null, 6000, 6000, 'Triple', 5500, 3, 'disponible', 'NAVE 2', '02.17.10000109.00015', 'Fecha 14/01/2026 en la hoja, sin título de columna.', null),
('m24', null, 'AUSA', 'C-200H X4', '20564593', 'Diésel', 33.8, 2010, 11000, 12000, 'Triple', null, 4, 'disponible', 'NAVE 2', '02.17.10000109.00017', 'Matrícula E7271BFT (venía junto al nº de serie).', null),
('m25', null, 'NISSAN', 'Y1D2A25Q', 'Y1D2E705049', 'Diésel', 36, null, 5775, null, null, null, 4, 'disponible', 'NAVE 2', '02.17.10000109.00016', null, null)
on conflict (id) do nothing;
