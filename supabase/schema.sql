-- ============================================================
-- Artabria Rutinas — esquema, seguridad (RLS) y datos de ejemplo
--
-- Cómo ejecutar: copia todo este archivo y pégalo en
-- Supabase → SQL Editor → New query → Run. Se ejecuta una sola vez.
--
-- Después de ejecutarlo, en el dashboard de Supabase:
--   1. Authentication → Sign In / Providers → activa "Allow anonymous sign-ins".
--      (Es lo que permite que un cliente entre con su enlace sin
--       contraseña ni registro.)
--   2. Regístrate una vez en /admin/login.html con tu email.
--   3. Vuelve aquí y ejecuta el INSERT de la sección "Alta del
--      primer administrador" al final de este archivo, sustituyendo
--      el email por el tuyo.
-- ============================================================

create extension if not exists pgcrypto;

-- ------------------------------------------------------------
-- Tablas
-- ------------------------------------------------------------

create table admins (
  id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table clientes (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,
  codigo text not null unique,
  auth_user_id uuid unique references auth.users(id) on delete set null,
  activo boolean not null default true,
  created_at timestamptz not null default now()
);

create table rutinas (
  id uuid primary key default gen_random_uuid(),
  cliente_id uuid not null references clientes(id) on delete cascade,
  nombre text not null,
  activa boolean not null default true,
  created_at timestamptz not null default now()
);

create table dias (
  id uuid primary key default gen_random_uuid(),
  rutina_id uuid not null references rutinas(id) on delete cascade,
  nombre text not null,
  orden int not null default 0
);

create table ejercicios (
  id uuid primary key default gen_random_uuid(),
  dia_id uuid not null references dias(id) on delete cascade,
  nombre text not null,
  series int not null,
  reps_objetivo text not null,
  notas text,
  orden int not null default 0
);

create table sesiones (
  id uuid primary key default gen_random_uuid(),
  dia_id uuid not null references dias(id) on delete cascade,
  cliente_id uuid not null references clientes(id) on delete cascade,
  fecha timestamptz not null default now(),
  completada boolean not null default false
);

create table registros_series (
  id uuid primary key default gen_random_uuid(),
  sesion_id uuid not null references sesiones(id) on delete cascade,
  ejercicio_id uuid not null references ejercicios(id) on delete cascade,
  numero_serie int not null,
  peso numeric,
  reps int,
  completada boolean not null default false,
  created_at timestamptz not null default now(),
  unique (sesion_id, ejercicio_id, numero_serie)
);

create index on rutinas (cliente_id);
create index on dias (rutina_id);
create index on ejercicios (dia_id);
create index on sesiones (cliente_id);
create index on sesiones (dia_id);
create index on registros_series (sesion_id);
create index on registros_series (ejercicio_id);

-- ------------------------------------------------------------
-- Funciones auxiliares (security definer para evitar recursión de RLS)
-- ------------------------------------------------------------

create or replace function is_admin()
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (select 1 from admins where id = auth.uid());
$$;

create or replace function mi_cliente_id()
returns uuid
language sql
security definer
set search_path = public
stable
as $$
  select id from clientes where auth_user_id = auth.uid();
$$;

-- RPC que un cliente llama tras iniciar sesión anónima, para vincular
-- su sesión al código de su enlace único (rutinas.artabrianutrition.com/c/<codigo>).
-- Es idempotente y re-vinculable: conocer el código es la credencial,
-- así que también funciona si el cliente entra desde otro dispositivo.
create or replace function claim_cliente(p_codigo text)
returns clientes
language plpgsql
security definer
set search_path = public
as $$
declare
  v_cliente clientes;
begin
  if auth.uid() is null then
    raise exception 'No autenticado';
  end if;

  -- libera cualquier otro cliente que estuviera ligado a esta misma sesión
  -- (p. ej. el entrenador probando varios enlaces desde el mismo dispositivo)
  update clientes
  set auth_user_id = null
  where auth_user_id = auth.uid() and codigo <> p_codigo;

  update clientes
  set auth_user_id = auth.uid()
  where codigo = p_codigo and activo = true
  returning * into v_cliente;

  if v_cliente.id is null then
    raise exception 'Código no válido';
  end if;

  return v_cliente;
end;
$$;

grant execute on function is_admin() to anon, authenticated;
grant execute on function mi_cliente_id() to anon, authenticated;
grant execute on function claim_cliente(text) to anon, authenticated;

-- ------------------------------------------------------------
-- Row Level Security
-- ------------------------------------------------------------

-- Permiso base de tabla: sin esto Postgres devuelve "permission denied"
-- antes siquiera de evaluar las políticas de RLS de abajo.
grant usage on schema public to anon, authenticated;
grant select, insert, update, delete on
  admins, clientes, rutinas, dias, ejercicios, sesiones, registros_series
  to anon, authenticated;

alter table admins enable row level security;
alter table clientes enable row level security;
alter table rutinas enable row level security;
alter table dias enable row level security;
alter table ejercicios enable row level security;
alter table sesiones enable row level security;
alter table registros_series enable row level security;

create policy admins_select_self on admins
  for select using (id = auth.uid());

create policy clientes_select on clientes
  for select using (is_admin() or auth_user_id = auth.uid());
create policy clientes_insert on clientes
  for insert with check (is_admin());
create policy clientes_update on clientes
  for update using (is_admin()) with check (is_admin());
create policy clientes_delete on clientes
  for delete using (is_admin());

create policy rutinas_select on rutinas
  for select using (is_admin() or cliente_id = mi_cliente_id());
create policy rutinas_insert on rutinas
  for insert with check (is_admin());
create policy rutinas_update on rutinas
  for update using (is_admin()) with check (is_admin());
create policy rutinas_delete on rutinas
  for delete using (is_admin());

create policy dias_select on dias
  for select using (
    is_admin() or exists (
      select 1 from rutinas r where r.id = dias.rutina_id and r.cliente_id = mi_cliente_id()
    )
  );
create policy dias_insert on dias
  for insert with check (is_admin());
create policy dias_update on dias
  for update using (is_admin()) with check (is_admin());
create policy dias_delete on dias
  for delete using (is_admin());

create policy ejercicios_select on ejercicios
  for select using (
    is_admin() or exists (
      select 1 from dias d
      join rutinas r on r.id = d.rutina_id
      where d.id = ejercicios.dia_id and r.cliente_id = mi_cliente_id()
    )
  );
create policy ejercicios_insert on ejercicios
  for insert with check (is_admin());
create policy ejercicios_update on ejercicios
  for update using (is_admin()) with check (is_admin());
create policy ejercicios_delete on ejercicios
  for delete using (is_admin());

create policy sesiones_select on sesiones
  for select using (is_admin() or cliente_id = mi_cliente_id());
create policy sesiones_insert on sesiones
  for insert with check (is_admin() or cliente_id = mi_cliente_id());
create policy sesiones_update on sesiones
  for update using (is_admin() or cliente_id = mi_cliente_id())
  with check (is_admin() or cliente_id = mi_cliente_id());
create policy sesiones_delete on sesiones
  for delete using (is_admin());

create policy registros_select on registros_series
  for select using (
    is_admin() or exists (
      select 1 from sesiones s where s.id = registros_series.sesion_id and s.cliente_id = mi_cliente_id()
    )
  );
create policy registros_insert on registros_series
  for insert with check (
    is_admin() or exists (
      select 1 from sesiones s where s.id = registros_series.sesion_id and s.cliente_id = mi_cliente_id()
    )
  );
create policy registros_update on registros_series
  for update using (
    is_admin() or exists (
      select 1 from sesiones s where s.id = registros_series.sesion_id and s.cliente_id = mi_cliente_id()
    )
  ) with check (
    is_admin() or exists (
      select 1 from sesiones s where s.id = registros_series.sesion_id and s.cliente_id = mi_cliente_id()
    )
  );
create policy registros_delete on registros_series
  for delete using (is_admin());

-- ------------------------------------------------------------
-- Seed: cliente de ejemplo "Borja Bravo Llinares"
-- Enlace del cliente: rutinas.artabrianutrition.com/c/xk29fa
-- ------------------------------------------------------------

with nuevo_cliente as (
  insert into clientes (nombre, codigo)
  values ('Borja Bravo Llinares', 'xk29fa')
  returning id
), nueva_rutina as (
  insert into rutinas (cliente_id, nombre)
  select id, 'Rutina inicial' from nuevo_cliente
  returning id
), dia1 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Día 1 - Upper', 1 from nueva_rutina
  returning id
), dia2 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Día 2 - Lower', 2 from nueva_rutina
  returning id
), ejercicios_dia1 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia1.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia1, (values
    ('Press de banca', 2, '8-10', null::text, 1),
    ('Press inclinado con multipower', 2, '8-10', null::text, 2),
    ('Fondos en paralelas', 2, 'al fallo', null::text, 3),
    ('Jalón agarre cerrado', 3, '8-10', null::text, 4),
    ('Remo en polea baja', 3, '8-10', null::text, 5),
    ('Peso muerto', 2, '8', null::text, 6),
    ('Press militar multipower', 2, '8-10', null::text, 7),
    ('Elevaciones laterales', 2, '10-12', null::text, 8),
    ('Extensiones de tríceps con polea', 3, '8-10', null::text, 9),
    ('Curl de bíceps con barra Z', 3, '8-10', null::text, 10)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ejercicios_dia2 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia2.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia2, (values
    ('Extensiones de cuádriceps en máquina', 3, '10-12', null::text, 1),
    ('Prensa inclinada', 2, '10-12', 'Lenta y profunda hasta notar el estiramiento en el glúteo', 2),
    ('Sentadilla multipower', 2, '8-10', null::text, 3),
    ('Curl femoral tumbado en máquina', 3, '15-20', null::text, 4),
    ('Peso muerto con mancuerna, piernas rígidas', 2, '8-10', null::text, 5),
    ('Elevación de talones sentado', 3, '15-20', null::text, 6),
    ('Hiperextensiones', 3, 'hasta que agarre', 'Que no duela, solo fortalecer', 7)
  ) as v(nombre, series, reps, notas, orden)
  returning id
)
select 'seed ok' as status;

-- ------------------------------------------------------------
-- Alta del primer administrador (ejecutar TRAS registrarte una vez
-- en /admin/login.html con tu email). Sustituye el email si hace falta.
-- ------------------------------------------------------------

-- insert into admins (id)
-- select id from auth.users where email = 'pablo.orji@gmail.com';
