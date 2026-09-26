-- ============================================================
-- Sustituye el contenido del "Día 2 - Cuádriceps" de Pedro
-- Poderoso (gzvp5h) por la nueva rutina de cuádriceps. Los
-- ejercicios viejos de ese día se desactivan (no se borran), para
-- conservar el historial de series ya registradas; los nuevos se
-- insertan desde cero.
--
-- Notas sobre los descendentes de este día (para que cuadre con la
-- UI de "reps descendente", que admite hasta 6 números):
--  - Extensiones de cuádriceps: 5 series lineales de 20 + 1 última
--    serie descendente de 5 bajadas (15-10-8-8-6) -> 6 series en
--    total, solo la 6ª muestra el desplegable de reps.
--  - Prensa horizontal: 1 sola serie, descendente desde el principio
--    con 6 bajadas (35-20-15-10-8-6, 94 reps sumadas) -> 1 serie,
--    con el desplegable de reps.
--  - Femoral tumbado y Gemelo de pie: "N series descendentes" sin
--    acotarlo a la última -> las N series muestran el desplegable
--    (igual que "Elevaciones laterales" de Alfredo/Pedro).
--
-- REQUISITO PREVIO: código ya desplegado con MAX_REPS_DESCENDENTE=6
-- en client-app.js (antes 5).
-- ============================================================

with rutina_activa as (
  select r.id from rutinas r
  join clientes c on c.id = r.cliente_id
  where c.codigo = 'gzvp5h' and r.activa = true
), dia_cuadriceps as (
  select d.id from dias d
  where d.rutina_id = (select id from rutina_activa)
    and d.nombre = 'Día 2 - Cuádriceps'
), desactivar_viejos as (
  update ejercicios set activo = false
  where dia_id = (select id from dia_cuadriceps)
  returning id
)
insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
select dia_cuadriceps.id, v.nombre, v.series, v.reps, v.notas, v.orden
from dia_cuadriceps, (values
  ('Extensiones de cuádriceps', 6,
    '5 x 20 (lineales, máximo peso con control total); última serie descendente: 15-10-8-8-6 (bajadas mínimas de peso)',
    'Se graba en vídeo la primera y la última serie.', 1),
  ('Prensa horizontal', 1,
    'Descendente con recorrido completo: 35-20-15-10-8-6 (94 reps en total)',
    'Empieza al peso máximo con el que puedas hacer recorrido completo. Si los primeros días no llegas a las 94 reps, no te preocupes: apunta lo que hagas e intenta aumentar el volumen en las próximas sesiones. Se graba en vídeo la primera y la última serie.', 2),
  ('Sentadilla hack', 3, '12', 'RIR 0.', 3),
  ('Femoral tumbado', 5, '12-8-6 aprox., descendente en cada serie', null::text, 4),
  ('Gemelo de pie', 4, '20-15-10 aprox., descendentes', null::text, 5)
) as v(nombre, series, reps, notas, orden)
returning id;
