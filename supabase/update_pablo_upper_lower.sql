-- ============================================================
-- Sustituye la rutina activa de Pablo Lorenzo (m2p8ec) por un
-- Upper / Lower de 2 días. La rutina anterior ("Split semanal") se
-- desactiva (no se borra), para conservar su historial de sesiones.
-- ============================================================

with cliente as (
  select id from clientes where codigo = 'm2p8ec'
), desactivar as (
  update rutinas set activa = false
  where cliente_id = (select id from cliente) and activa = true
  returning id
), nueva_rutina as (
  insert into rutinas (cliente_id, nombre)
  select id, 'Upper / Lower' from cliente
  returning id
), dia1 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Día 1 - Upper', 1 from nueva_rutina
  returning id
), dia2 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Día 2 - Lower', 2 from nueva_rutina
  returning id
), ej_dia1 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia1.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia1, (values
    ('Press máquina convergente', 3, '8-10', null::text, 1),
    ('Contractora Peck Deck', 3, '8-10', null::text, 2),
    ('Jalón agarre neutro', 3, '8-10', null::text, 3),
    ('Remo en punta libre', 3, '8-10', null::text, 4),
    ('Elevaciones laterales', 5, '10-12', null::text, 5),
    ('Curl bíceps barra Z', 4, '10-12', null::text, 6),
    ('Press francés', 4, '10-12', null::text, 7)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia2 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia2.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia2, (values
    ('Curl femoral sentado', 3, '12-15', null::text, 1),
    ('Curl femoral tumbado', 2, '10-12', null::text, 2),
    ('Abductor', 3, '12-15', null::text, 3),
    ('Extensiones cuádriceps', 2, '10-12', null::text, 4),
    ('Prensa inclinada', 4, '10-12', null::text, 5),
    ('Aductor', 3, '15-20', null::text, 6)
  ) as v(nombre, series, reps, notas, orden)
  returning id
)
select 'rutina pablo upper/lower creada' as status;
