-- ============================================================
-- Sustituye la rutina activa de Pablo Lorenzo (m2p8ec) por
-- "PPL · 2 bloques". La rutina anterior se desactiva (no se borra),
-- para conservar su historial de sesiones.
-- ============================================================

with cliente as (
  select id from clientes where codigo = 'm2p8ec'
), desactivar as (
  update rutinas set activa = false
  where cliente_id = (select id from cliente) and activa = true
  returning id
), nueva_rutina as (
  insert into rutinas (cliente_id, nombre, notas)
  select id, 'PPL · 2 bloques', 'Los días de descanso: 8 series de abdomen, aunque sea en casa.'
  from cliente
  returning id
), dia1 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Bloque 1 - Empujes', 1 from nueva_rutina
  returning id
), dia2 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Bloque 1 - Tracción', 2 from nueva_rutina
  returning id
), dia3 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Bloque 1 - Pierna', 3 from nueva_rutina
  returning id
), dia4 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Bloque 2 - Empujes', 4 from nueva_rutina
  returning id
), dia5 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Bloque 2 - Tracción', 5 from nueva_rutina
  returning id
), dia6 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Bloque 2 - Pierna', 6 from nueva_rutina
  returning id
), ej_dia1 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia1.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia1, (values
    ('Press multipower inclinado', 3, '8-10 (con una serie final de 15)', null::text, 1),
    ('Aperturas inclinadas con máquina', 3, '8-10', null::text, 2),
    ('Fondos en paralelas', 3, 'al fallo', null::text, 3),
    ('Press militar multipower', 2, '8-10 (con una serie final de 15)', null::text, 4),
    ('Elevaciones laterales con mancuerna', 5, '10-12', null::text, 5),
    ('Extensiones tríceps agarre V', 5, '10-12', null::text, 6)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia2 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia2.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia2, (values
    ('Pullover con cuerda (calentamiento)', 2, '15', 'Lentas y apretando.', 1),
    ('Jalón agarre cerrado', 3, '8-10 (con una serie final de 15)', null::text, 2),
    ('Remo con barra', 2, '8-10', null::text, 3),
    ('Remo con mancuerna', 3, '8-10 (con una serie final de 15)', null::text, 4),
    ('Remo máquina sentado (la de discos tipo Dorian)', 3, '8-10 (con una serie final de 15)', null::text, 5),
    ('Curl bíceps banco scoot', 5, '12', null::text, 6)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia3 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia3.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia3, (values
    ('Femoral sentado', 4, '12 (al fallo); última serie descendente: 20-15-10-6', null::text, 1),
    ('Femoral tumbado', 4, '10; última serie descendente: 20-15-10-6', null::text, 2),
    ('Hack invertida', 2, '15', null::text, 3),
    ('Máquina abductor (glúteo)', 4, '12-15 (última serie: 25 reps, pausa de 30 s, al fallo con el mismo peso)', null::text, 4),
    ('Extensiones de máquina', 5, '10-12', null::text, 5)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia4 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia4.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia4, (values
    ('Press máquina tumbado', 3, '8-10 (con una serie final de 15)', null::text, 1),
    ('Aperturas Peck Deck', 3, '10-12', null::text, 2),
    ('Press máquina discos inclinado', 3, '8-10 (con una serie final de 15)', null::text, 3),
    ('Elevaciones laterales máquina de pie', 6, '15-20', null::text, 4),
    ('Press francés', 5, '12-15', null::text, 5)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia5 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia5.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia5, (values
    ('Pullover con cuerda (calentamiento)', 2, '15', 'Lentas y apretando.', 1),
    ('Jalón unilateral con anilla', 4, '8-10 (al fallo); última serie descendente: 15-10-6', 'Baja el codo hacia abajo, no hacia atrás; el codo queda por delante del cuerpo, no pegado.', 2),
    ('Remo bajo en polea (Gironda)', 4, '8-10 (con una serie final de 15)', null::text, 3),
    ('Remo con mancuerna a dos manos, apoyando cabeza en banco', 2, '8-10', null::text, 4),
    ('Rack pull', 3, '8', null::text, 5),
    ('Curl bíceps en máquina scoot con agarre Z', 5, '10', null::text, 6)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia6 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia6.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia6, (values
    ('Extensiones de máquina', 4, '10-12 (última serie descendente: 20-15-10-6)', null::text, 1),
    ('Péndulo', 3, '8', null::text, 2),
    ('Prensa inclinada', 3, '10', 'Con todo el recorrido que puedas darle, rozando el tope que esté en el mínimo.', 3),
    ('Aductor', 4, '12-15', null::text, 4),
    ('Femoral tumbado', 5, '10-12', null::text, 5)
  ) as v(nombre, series, reps, notas, orden)
  returning id
)
select 'rutina pablo actualizada' as status;
