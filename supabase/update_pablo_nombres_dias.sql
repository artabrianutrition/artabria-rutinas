-- ============================================================
-- Renombra los días de la rutina "Split semanal" de Pablo Lorenzo
-- (m2p8ec) para que el número de "Día" corresponda al día real de
-- la semana (Lunes=1, Martes=2, Miércoles=descanso/no se crea,
-- Jueves=4, Viernes=5, Sábado=6, Domingo=descanso/no se crea), en
-- vez de un correlativo de sesiones. No toca ejercicios ni orden.
-- ============================================================

with rutina_activa as (
  select r.id from rutinas r
  join clientes c on c.id = r.cliente_id
  where c.codigo = 'm2p8ec' and r.activa = true
), cambios (nombre_actual, nombre_nuevo) as (
  values
    ('Día 1 - Lunes mañana: Espalda', 'Día 1 (Lunes) - Mañana: Espalda'),
    ('Día 2 - Lunes tarde: Pecho-Brazo', 'Día 1 (Lunes) - Tarde: Pecho y Brazo'),
    ('Día 3 - Martes: Femoral y Glúteo', 'Día 2 (Martes): Femoral y Glúteo'),
    ('Día 4 - Jueves mañana: Espalda-Hombro', 'Día 4 (Jueves) - Mañana: Espalda y Hombro'),
    ('Día 5 - Jueves tarde: Pecho-Brazo', 'Día 4 (Jueves) - Tarde: Pecho y Brazo'),
    ('Día 6 - Viernes: Cuádriceps', 'Día 5 (Viernes): Cuádriceps'),
    ('Día 7 - Sábado: Torso', 'Día 6 (Sábado): Torso')
)
update dias set nombre = cambios.nombre_nuevo
from cambios
where dias.rutina_id = (select id from rutina_activa)
  and dias.nombre = cambios.nombre_actual
returning dias.nombre, dias.orden;
