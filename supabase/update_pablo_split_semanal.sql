-- ============================================================
-- Sustituye la rutina activa de Pablo Lorenzo (m2p8ec) por un
-- split semanal de 7 sesiones (doble sesión lunes y jueves),
-- descansando miércoles y domingo (no se crean como "día"). La
-- rutina anterior ("PPL · 2 bloques") se desactiva (no se borra),
-- para conservar su historial de sesiones.
-- ============================================================

with cliente as (
  select id from clientes where codigo = 'm2p8ec'
), desactivar as (
  update rutinas set activa = false
  where cliente_id = (select id from cliente) and activa = true
  returning id
), nueva_rutina as (
  insert into rutinas (cliente_id, nombre)
  select id, 'Split semanal (doble sesión lunes y jueves)' from cliente
  returning id
), dia1 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Día 1 - Lunes mañana: Espalda', 1 from nueva_rutina
  returning id
), dia2 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Día 2 - Lunes tarde: Pecho-Brazo', 2 from nueva_rutina
  returning id
), dia3 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Día 3 - Martes: Femoral y Glúteo', 3 from nueva_rutina
  returning id
), dia4 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Día 4 - Jueves mañana: Espalda-Hombro', 4 from nueva_rutina
  returning id
), dia5 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Día 5 - Jueves tarde: Pecho-Brazo', 5 from nueva_rutina
  returning id
), dia6 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Día 6 - Viernes: Cuádriceps', 6 from nueva_rutina
  returning id
), dia7 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Día 7 - Sábado: Torso', 7 from nueva_rutina
  returning id
), ej_dia1 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia1.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia1, (values
    ('Pullover con cuerda (calentamiento)', 2, '12', null::text, 1),
    ('Dominadas lastradas', 3, '8', null::text, 2),
    ('Jalón unilateral', 3, '8', null::text, 3),
    ('Remo en punta', 3, '10', null::text, 4),
    ('Rack pull', 3, '8', null::text, 5)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia2 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia2.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia2, (values
    ('Press banca', 3, '10', null::text, 1),
    ('Fondos', 3, '20', null::text, 2),
    ('Curl bíceps con mancuerna', 4, '12-15',
      'En superserie con Extensiones en polea: sin descanso entre ambos ejercicios, descansa solo al terminar los dos.', 3),
    ('Extensiones en polea', 4, '12-15',
      'En superserie con Curl bíceps con mancuerna: sin descanso entre ambos ejercicios, descansa solo al terminar los dos.', 4)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia3 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia3.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia3, (values
    ('Femoral tumbado', 3, '10', null::text, 1),
    ('Femoral sentado', 3, '15', null::text, 2),
    ('Peso muerto pierna rígida', 3, '10', null::text, 3),
    ('Abductor', 4, '15', null::text, 4),
    ('Prensa', 4, '15', null::text, 5)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia4 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia4.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia4, (values
    ('Dominadas lastradas', 3, '8', null::text, 1),
    ('Remo con mancuerna', 3, '10', null::text, 2),
    ('Remo en punta', 3, '10', null::text, 3),
    ('Elevaciones laterales', 5, '12', null::text, 4)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia5 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia5.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia5, (values
    ('Press banca', 5, '5', null::text, 1),
    ('Fondos', 4, '20', null::text, 2),
    ('Curl barra Z', 4, '12-15',
      'En superserie con Press francés: sin descanso entre ambos ejercicios, descansa solo al terminar los dos.', 3),
    ('Press francés', 4, '12-15',
      'En superserie con Curl barra Z: sin descanso entre ambos ejercicios, descansa solo al terminar los dos.', 4)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia6 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia6.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia6, (values
    ('Extensiones', 4, '15', null::text, 1),
    ('Prensa', 4, '10', null::text, 2),
    ('Búlgaras multipower', 3, '10', null::text, 3),
    ('Aductor', 3, '15', null::text, 4),
    ('Femoral tumbado', 4, '10', null::text, 5)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia7 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia7.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia7, (values
    ('Dominadas', 2, '8', null::text, 1),
    ('Remo en punta', 2, '8', null::text, 2),
    ('Press banca', 2, '8', null::text, 3),
    ('Aperturas', 2, '8', null::text, 4),
    ('Press militar multipower', 2, '8', null::text, 5),
    ('Elevaciones laterales', 2, '8', null::text, 6),
    ('Curl banco Scott', 3, '10',
      'En superserie con Extensiones de tríceps por encima de la cabeza: sin descanso entre ambos ejercicios, descansa solo al terminar los dos.', 7),
    ('Extensiones de tríceps por encima de la cabeza', 3, '10',
      'En superserie con Curl banco Scott: sin descanso entre ambos ejercicios, descansa solo al terminar los dos.', 8)
  ) as v(nombre, series, reps, notas, orden)
  returning id
)
select 'rutina pablo split semanal creada' as status;
