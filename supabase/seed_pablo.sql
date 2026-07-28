-- ============================================================
-- Alta de cliente: Pablo Lorenzo
-- "Primera variante PPL (altas repes)", cadencia 3 días de
-- entrenamiento + 1 de descanso (sin atarse a días de la semana).
-- Enlace del cliente: rutinas.artabrianutrition.com/c/m2p8ec
--
-- REQUISITO PREVIO: usa rutinas.notas. Si no la tienes todavía:
--   alter table rutinas add column if not exists notas text;
--   alter table dias add column if not exists notas text;
-- ============================================================

with nuevo_cliente as (
  insert into clientes (nombre, codigo)
  values ('Pablo Lorenzo', 'm2p8ec')
  returning id
), nueva_rutina as (
  insert into rutinas (cliente_id, nombre, notas)
  select
    id,
    'Primera variante PPL (altas repes)',
    'CADENCIA: 3 días de entrenamiento + 1 día de descanso, repitiendo el ciclo sin atarlo a días de la semana. Tras el descanso, se vuelve a empezar por el Día 1. Si algún día descansas antes de completar el ciclo de tres días, no pasa nada: cuando vuelvas al gimnasio, continúas por el día que te tocaría según la cadencia.

Estas dos primeras semanas, con repeticiones tan altas y dejando RIR 1-2, el desgaste no será muy alto. Olvídate de todo lo que sabías hasta ahora: los movimientos deben ser lentos y controlados (aprox. 1,5 segundos en la fase negativa) y la fase concéntrica más explosiva. El control total viene en la fase negativa: tiene que ser el músculo que estés entrenando el que sujete el peso y haga el movimiento, sin desviarlo a otros músculos ni a las articulaciones.

Descanso entre series y al cambiar de ejercicio: unos 3 minutos.

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
    ('Femoral sentado', 3, '20', null::text, 1),
    ('Femoral tumbado', 3, '20', null::text, 2),
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
    ('Peso muerto convencional', 3, '6, 8, 10', null::text, 6),
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
    ('Elevaciones laterales mancuernas', 3, '15', null::text, 4),
    ('Elevaciones laterales máquina de pie', 3, '15', null::text, 5),
    ('Extensiones de tríceps agarre V', 5, '15', null::text, 6)
  ) as v(nombre, series, reps, notas, orden)
  returning id
)
select 'seed pablo ok' as status;
