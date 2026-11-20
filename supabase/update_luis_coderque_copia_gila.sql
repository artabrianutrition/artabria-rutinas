-- ============================================================
-- Sustituye la rutina activa de Luis Coderque (nzq4y2) por una copia
-- EXACTA de la rutina activa de Gila (akttwi) tal como está ahora
-- mismo en la base de datos (nombre, notas, días y ejercicios activos,
-- con sus series, reps, peso objetivo y orden). La rutina anterior de
-- Luis se desactiva (no se borra), para conservar su historial. Si
-- Gila no tuviera rutina activa, no se toca nada.
-- ============================================================

with cliente_dest as (
  select id from clientes where codigo = 'nzq4y2'
), cliente_orig as (
  select id from clientes where codigo = 'akttwi'
), rutina_orig as (
  select r.id, r.nombre, r.notas from rutinas r
  where r.cliente_id = (select id from cliente_orig) and r.activa = true
  order by r.created_at desc limit 1
), desactivar as (
  update rutinas set activa = false
  where cliente_id = (select id from cliente_dest) and activa = true
    and exists (select 1 from rutina_orig)
  returning id
), nueva_rutina as (
  insert into rutinas (cliente_id, nombre, notas)
  select (select id from cliente_dest), nombre, notas from rutina_orig
  returning id
), nuevos_dias as (
  insert into dias (rutina_id, nombre, notas, orden)
  select (select id from nueva_rutina), d.nombre, d.notas, d.orden
  from dias d
  where d.rutina_id = (select id from rutina_orig)
  returning id, nombre, orden
)
insert into ejercicios (dia_id, nombre, series, reps_objetivo, peso_objetivo, notas, orden)
select nd.id, e.nombre, e.series, e.reps_objetivo, e.peso_objetivo, e.notas, e.orden
from dias d
join nuevos_dias nd on nd.orden = d.orden and nd.nombre = d.nombre
join ejercicios e on e.dia_id = d.id and e.activo = true
where d.rutina_id = (select id from rutina_orig)
returning nombre, series, reps_objetivo, orden;
