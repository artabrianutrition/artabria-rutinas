-- ============================================================
-- Intercambia el orden de Día 4 (Femoral y Glúteo) y Día 5
-- (Hombro + Espalda) en la rutina activa de Pedro Poderoso (gzvp5h).
-- No toca ejercicios ni notas, solo el orden y el número en el nombre.
-- ============================================================

with cliente as (
  select id from clientes where codigo = 'gzvp5h'
), rutina_activa as (
  select id from rutinas where cliente_id = (select id from cliente) and activa = true
), cambios (nombre_actual, orden_nuevo, nombre_nuevo) as (
  values
    ('Día 4 - Femoral y Glúteo', 5, 'Día 5 - Femoral y Glúteo'),
    ('Día 5 - Hombro + Espalda', 4, 'Día 4 - Hombro + Espalda')
)
update dias set orden = cambios.orden_nuevo, nombre = cambios.nombre_nuevo
from cambios
where dias.rutina_id = (select id from rutina_activa)
  and dias.nombre = cambios.nombre_actual
returning dias.nombre, dias.orden;
