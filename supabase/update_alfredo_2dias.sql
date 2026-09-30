-- ============================================================
-- Sustituye la rutina activa de Alfredo Linares (ce9gve) por una
-- nueva de 2 días alternos (antes tenía "Plan de entrenamiento -
-- Fase de adaptación", 3 días x 2 sesiones = 6 días). La rutina
-- anterior se desactiva (no se borra), para conservar su
-- historial de sesiones.
-- ============================================================

with cliente as (
  select id from clientes where codigo = 'ce9gve'
), desactivar as (
  update rutinas set activa = false
  where cliente_id = (select id from cliente) and activa = true
  returning id
), nueva_rutina as (
  insert into rutinas (cliente_id, nombre)
  select id, 'Rutina (2 días alternos)' from cliente
  returning id
), dia1 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Día 1', 1 from nueva_rutina
  returning id
), dia2 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Día 2', 2 from nueva_rutina
  returning id
), ej_dia1 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia1.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia1, (values
    ('Press banca plano', 4, '10', null::text, 1),
    ('Fondos en paralelas lastrados', 4, '12', null::text, 2),
    ('Elevaciones laterales', 4, '12', null::text, 3),
    ('Femoral tumbado', 4, '12', null::text, 4),
    ('Prensa inclinada', 4, '10', null::text, 5),
    ('Búlgaras en multipower', 3, '15', null::text, 6),
    ('Abductor', 4, '15', null::text, 7)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia2 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia2.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia2, (values
    ('Pullover con barra en polea (calentamiento)', 2, '15', 'Lentas y apretando.', 1),
    ('Remo en punta libre (barra con agarre cerrado)', 4, '10', null::text, 2),
    ('Remo unilateral máquina', 4, '10', null::text, 3),
    ('Curl barra Z', 4, '10', null::text, 4),
    ('Pájaro sentado mancuernas', 4, '12', null::text, 5),
    ('Abdomen crunch en polea', 4, '20', null::text, 6),
    ('Gemelo de pie', 4, '15', null::text, 7)
  ) as v(nombre, series, reps, notas, orden)
  returning id
)
select 'rutina alfredo 2 dias creada' as status;
