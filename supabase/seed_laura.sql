-- ============================================================
-- Alta de cliente: Laura Pallarés Álvarez
-- Enlace del cliente: rutinas.artabrianutrition.com/c/8kyzbz
--
-- Cómo ejecutar: Supabase → SQL Editor → New query → pega esto → Run.
-- ============================================================

with nuevo_cliente as (
  insert into clientes (nombre, codigo)
  values ('Laura Pallarés Álvarez', '8kyzbz')
  returning id
), nueva_rutina as (
  insert into rutinas (cliente_id, nombre)
  select id, 'Primera rutina · Adaptación' from nuevo_cliente
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
    ('Jalón agarre cerrado', 3, '8-10', null::text, 1),
    ('Remo en polea baja', 3, '8-10', null::text, 2),
    ('Press máquina hombros', 3, '8-10', null::text, 3),
    ('Elevaciones laterales en máquina', 3, '10-12', null::text, 4),
    ('Extensiones de tríceps con polea', 3, '8-10', null::text, 5),
    ('Curl de bíceps en polea', 3, '8-10', null::text, 6),
    ('Abdominales en banco', 3, '10-12', null::text, 7)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ejercicios_dia2 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia2.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia2, (values
    ('Extensiones de cuádriceps en máquina', 4, '15', null::text, 1),
    ('Prensa inclinada', 2, '10-12', 'Todo lo profunda que puedas', 2),
    ('Abductor', 3, '8-10', 'Cerrar', 3),
    ('Aductor, máquina glúteo (paritorio)', 3, '10-12', null::text, 4),
    ('Curl femoral sentado', 2, '12-15', null::text, 5),
    ('Curl femoral tumbado en máquina', 2, '12-15', null::text, 6),
    ('Peso muerto multipower, piernas rectas', 1, '12-15', null::text, 7),
    ('Elevación de talones sentado', 3, '15-20', null::text, 8)
  ) as v(nombre, series, reps, notas, orden)
  returning id
)
select 'seed laura ok' as status;
