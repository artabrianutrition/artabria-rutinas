-- ============================================================
-- Modifica (no sustituye) la rutina activa de Pablo Lorenzo
-- (m2p8ec) "PPL · 2 bloques", según el listado nuevo pasado.
-- No se desactiva la rutina ni se tocan los días: se actualizan
-- los ejercicios que siguen existiendo (mismo id -> conserva
-- historial y el "sugerido" de la última sesión), se desactivan
-- (no se borran) los que ya no están, y se añaden los nuevos.
--
-- REQUISITO PREVIO: ejercicios.activo (migration_ejercicio_activo.sql).
-- ============================================================

-- 1) Ejercicios que siguen existiendo (mismo nombre): se actualizan
--    en su sitio, conservando id -> conserva historial/progreso.
with rutina_activa as (
  select r.id from rutinas r
  join clientes c on c.id = r.cliente_id
  where c.codigo = 'm2p8ec' and r.activa = true
), cambios (dia_nombre, ejercicio_nombre, nombre_nuevo, series_nuevo, reps_nuevo, notas_nueva, orden_nuevo) as (
  values
    ('Bloque 1 - Empujes', 'Press multipower inclinado', null, 3, '8-10', null, 1),
    ('Bloque 1 - Empujes', 'Aperturas inclinadas con máquina', null, 3, '8-10', null, 2),
    ('Bloque 1 - Empujes', 'Fondos en paralelas', null, 3, 'al fallo', null, 3),
    ('Bloque 1 - Empujes', 'Press militar multipower', null, 2, '8-10', null, 4),
    ('Bloque 1 - Empujes', 'Elevaciones laterales con mancuerna', null, 5, '10-12', null, 5),
    ('Bloque 1 - Empujes', 'Extensiones tríceps agarre V', null, 5, '10-12', null, 6),

    ('Bloque 1 - Tracción', 'Pullover con cuerda (calentamiento)', null, 2, '15', 'Lentas y apretando.', 1),
    ('Bloque 1 - Tracción', 'Jalón agarre cerrado', null, 3, '8-10', null, 2),
    ('Bloque 1 - Tracción', 'Remo con mancuerna', null, 3, '8-10', null, 3),
    ('Bloque 1 - Tracción', 'Curl bíceps banco scoot', null, 5, '12', null, 6),

    ('Bloque 1 - Pierna', 'Femoral sentado', null, 4, '12 (al fallo); última serie descendente: 20-15-10-6', null, 1),
    ('Bloque 1 - Pierna', 'Femoral tumbado', null, 4, '10; última serie descendente: 20-15-10-6', null, 2),
    ('Bloque 1 - Pierna', 'Máquina abductor (glúteo)', null, 4, '20-25', null, 4),
    ('Bloque 1 - Pierna', 'Extensiones de máquina', null, 5, '10-12', null, 6),

    ('Bloque 2 - Empujes', 'Aperturas Peck Deck', null, 3, '10-12', null, 2),
    ('Bloque 2 - Empujes', 'Press máquina discos inclinado', null, 3, '8-10', null, 4),
    ('Bloque 2 - Empujes', 'Elevaciones laterales máquina de pie', null, 6, '15-20', null, 5),
    ('Bloque 2 - Empujes', 'Press francés', null, 5, '12-15', null, 6),

    ('Bloque 2 - Tracción', 'Pullover con cuerda (calentamiento)', null, 2, '15', 'Lentas y apretando.', 1),
    ('Bloque 2 - Tracción', 'Jalón unilateral con anilla', null, 4, '8-10 (al fallo)', null, 2),
    ('Bloque 2 - Tracción', 'Remo bajo en polea (Gironda)', null, 4, '8-10', null, 3),
    ('Bloque 2 - Tracción', 'Remo con mancuerna a dos manos, apoyando cabeza en banco', null, 2, '8-10', null, 4),
    ('Bloque 2 - Tracción', 'Rack pull', null, 3, '8', null, 5),
    ('Bloque 2 - Tracción', 'Curl bíceps en máquina scoot con agarre Z', null, 5, '10', null, 6),

    ('Bloque 2 - Pierna', 'Extensiones de máquina', null, 4, '10-12 (última serie descendente: 20-15-10-6)', null, 1),
    ('Bloque 2 - Pierna', 'Prensa inclinada', 'Prensa inclinada unilateral', 3, '10-12',
      'Con todo el recorrido que puedas darle, rozando el tope que esté en el mínimo.', 2),
    ('Bloque 2 - Pierna', 'Aductor', null, 4, '12-15', null, 4),
    ('Bloque 2 - Pierna', 'Femoral tumbado', null, 5, '10-12', null, 5)
)
update ejercicios set
  nombre = coalesce(cambios.nombre_nuevo, ejercicios.nombre),
  series = cambios.series_nuevo,
  reps_objetivo = cambios.reps_nuevo,
  notas = cambios.notas_nueva,
  orden = cambios.orden_nuevo
from cambios
join dias on dias.nombre = cambios.dia_nombre and dias.rutina_id = (select id from rutina_activa)
where ejercicios.dia_id = dias.id
  and ejercicios.nombre = cambios.ejercicio_nombre;

-- 2) Ejercicios que ya no están en el listado nuevo: se desactivan
--    (no se borran), para conservar su historial.
with rutina_activa as (
  select r.id from rutinas r
  join clientes c on c.id = r.cliente_id
  where c.codigo = 'm2p8ec' and r.activa = true
), quitados (dia_nombre, ejercicio_nombre) as (
  values
    ('Bloque 1 - Tracción', 'Remo con barra'),
    ('Bloque 1 - Tracción', 'Remo máquina sentado (la de discos tipo Dorian)'),
    ('Bloque 1 - Pierna', 'Hack invertida'),
    ('Bloque 2 - Empujes', 'Press máquina tumbado'),
    ('Bloque 2 - Pierna', 'Péndulo')
)
update ejercicios set activo = false
from quitados
join dias on dias.nombre = quitados.dia_nombre and dias.rutina_id = (select id from rutina_activa)
where ejercicios.dia_id = dias.id
  and ejercicios.nombre = quitados.ejercicio_nombre;

-- 3) Ejercicios nuevos que no existían: se insertan.
with rutina_activa as (
  select r.id from rutinas r
  join clientes c on c.id = r.cliente_id
  where c.codigo = 'm2p8ec' and r.activa = true
), nuevos (dia_nombre, nombre, series, reps, notas, orden) as (
  values
    ('Bloque 1 - Tracción', 'Remo en punta libre', 3, '8-10', null, 4),
    ('Bloque 1 - Tracción', 'Remo con mancuerna a dos manos', 3, '8-10', null, 5),
    ('Bloque 1 - Pierna', 'Peso muerto piernas rígidas', 2, '10', null, 3),
    ('Bloque 1 - Pierna', 'Máquina aductor', 3, '12-15', null, 5),
    ('Bloque 2 - Empujes', 'Press multipower plano', 2, '10-12', null, 1),
    ('Bloque 2 - Empujes', 'Press máquina convergente plana', 2, '8-10', null, 3),
    ('Bloque 2 - Pierna', 'Zancadas', 3, '12', null, 3)
)
insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
select dias.id, nuevos.nombre, nuevos.series, nuevos.reps, nuevos.notas, nuevos.orden
from nuevos
join dias on dias.nombre = nuevos.dia_nombre and dias.rutina_id = (select id from rutina_activa);

select
  d.nombre as dia,
  e.orden,
  e.nombre,
  e.series,
  e.reps_objetivo,
  e.activo
from ejercicios e
join dias d on d.id = e.dia_id
join rutinas r on r.id = d.rutina_id
join clientes c on c.id = r.cliente_id
where c.codigo = 'm2p8ec' and r.activa = true
order by d.orden, e.orden;
