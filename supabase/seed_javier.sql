-- ============================================================
-- Alta de cliente: Javier Pozuelo
-- "Primera variante PPL", cadencia 3 días de entrenamiento + 1 de
-- descanso.
-- Enlace del cliente: rutinas.artabrianutrition.com/c/bwqyrk
-- ============================================================

with nuevo_cliente as (
  insert into clientes (nombre, codigo)
  values ('Javier Pozuelo', 'bwqyrk')
  returning id
), nueva_rutina as (
  insert into rutinas (cliente_id, nombre, notas)
  select
    id,
    'Primera variante PPL',
    'CADENCIA: 3 días de entrenamiento + 1 día de descanso. Si por algún motivo descansas antes de lo que te tocaría, al volver continúas con el grupo muscular que te habías saltado, siguiendo la cadencia original.

Quiero que mantengas una técnica apropiada, pero que además empieces a esforzarte bien: las series tienen que acercarse mucho al fallo muscular -si no empezamos a hacer eso, no habrá mucha mejora.

Mantén los descansos entre series entre 90 y 120 segundos.

Es importante que empieces a llevar el entrenamiento a más nivel: esfuérzate lo que toca en cada serie y, en la medida de lo posible, ve subiendo los pesos que manejas, para que haya una mejora real.

Cualquier duda, escríbeme o llámame sin problema.'
  from nuevo_cliente
  returning id
), dia1 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Día 1 - Pierna', 1 from nueva_rutina
  returning id
), dia2 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Día 2 - Tracción', 2 from nueva_rutina
  returning id
), dia3 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Día 3 - Empujes', 3 from nueva_rutina
  returning id
), ej_dia1 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia1.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia1, (values
    ('Femoral sentado', 3, '15', null::text, 1),
    ('Femoral tumbado', 3, '15', null::text, 2),
    ('Prensa inclinada', 3, '8, 10, 12', null::text, 3),
    ('Sentadilla hack', 3, '15', null::text, 4),
    ('Extensiones de máquina', 3, '20', null::text, 5),
    ('Aductor', 3, '20', null::text, 6)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia2 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia2.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia2, (values
    ('Pullover con barra en polea (calentamiento)', 2, '15', 'Lentas y apretando.', 1),
    ('Jalón agarre cerrado', 2, '15', null::text, 2),
    ('Máquina jalón discos unilateral', 2, '15', null::text, 3),
    ('Remo con mancuerna', 3, '15', null::text, 4),
    ('Remo máquina sentado (la de discos tipo Dorian)', 3, '15', null::text, 5),
    ('Peso muerto convencional', 3, '6, 8, 10', 'Poco peso: buscamos mejorar estabilizadores y potenciar erectores.', 6),
    ('Máquina scoot cable con barra Z', 5, '15', null::text, 7)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia3 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia3.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia3, (values
    ('Press banca plana', 3, '6, 8, 10', null::text, 1),
    ('Press multipower inclinado', 3, '15', null::text, 2),
    ('Aperturas con máquina inclinada disco', 2, '15', null::text, 3),
    ('Elevaciones frontales mancuernas', 3, '15', null::text, 4),
    ('Elevaciones laterales máquina de pie', 3, '15', null::text, 5),
    ('Extensiones de tríceps agarre V', 5, '15', null::text, 6)
  ) as v(nombre, series, reps, notas, orden)
  returning id
)
select 'seed javier ok' as status;
