-- ============================================================
-- En la rutina activa de Pablo Lorenzo (m2p8ec), el "Día 5 (Viernes)"
-- pasa de Cuádriceps a ser copia del "Día 2 (Martes): Femoral y
-- Glúteo". Los ejercicios viejos del viernes se desactivan (no se
-- borran) y se copian los ejercicios activos del martes tal cual
-- (nombre, series, reps, peso objetivo, notas, orden). El día se
-- renombra para que el título coincida con el contenido.
-- ============================================================

with rutina_activa as (
  select r.id from rutinas r
  join clientes c on c.id = r.cliente_id
  where c.codigo = 'm2p8ec' and r.activa = true
), dia_origen as (
  select d.id from dias d
  where d.rutina_id = (select id from rutina_activa)
    and d.nombre = 'Día 2 (Martes): Femoral y Glúteo'
), dia_destino as (
  select d.id from dias d
  where d.rutina_id = (select id from rutina_activa)
    and d.nombre = 'Día 5 (Viernes): Cuádriceps'
), desactivar_viejos as (
  update ejercicios set activo = false
  where dia_id = (select id from dia_destino) and activo = true
  returning id
), renombrar as (
  update dias set nombre = 'Día 5 (Viernes): Femoral y Glúteo'
  where id = (select id from dia_destino)
  returning id
)
insert into ejercicios (dia_id, nombre, series, reps_objetivo, peso_objetivo, notas, orden)
select (select id from dia_destino), e.nombre, e.series, e.reps_objetivo, e.peso_objetivo, e.notas, e.orden
from ejercicios e
where e.dia_id = (select id from dia_origen) and e.activo = true
returning nombre, series, reps_objetivo, orden;
