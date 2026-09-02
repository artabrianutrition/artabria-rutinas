-- ============================================================
-- Ajusta los ejercicios básicos de Alfredo Linares (ce9gve) a 5
-- series con peso/reps objetivo prefijados (editable por el
-- cliente). La primera vez que registre cada uno, el campo de
-- peso vendrá con el objetivo ya puesto; a partir de ahí se
-- sugerirá lo último que realmente levantó, como el resto.
--
-- REQUISITO PREVIO: ejercicios.peso_objetivo
-- (migration_peso_objetivo.sql).
-- ============================================================

with cliente as (
  select id from clientes where codigo = 'ce9gve'
), rutina_activa as (
  select id from rutinas where cliente_id = (select id from cliente) and activa = true
), cambios (dia_nombre, ejercicio_nombre, nombre_nuevo, series_nuevo, reps_nuevo, peso_nuevo, notas_nueva) as (
  values
    ('Día 1 - Pierna (Sesión 1)', 'Prensa inclinada', null, 5, '5', 500, 'Objetivo: 500 kg.'),
    ('Día 1 - Pierna (Sesión 1)', 'Sentadilla libre', null, 5, '5', 140, 'Objetivo: 140 kg.'),
    ('Día 2 - Empujes (Sesión 1)', 'Press banca inclinada multipower', null, 5, '5', 100, 'Objetivo: 100 kg.'),
    ('Día 3 - Tracción (Sesión 1)', 'Peso muerto convencional', null, 5, '5', 150, 'Objetivo: 150 kg.'),
    ('Día 1 - Pierna (Sesión 2)', 'Hip thrust', null, 5, '5', 140, 'Objetivo: 140 kg.'),
    ('Día 2 - Empujes (Sesión 2)', 'Press banca plana multipower', null, 5, '5', 110, 'Objetivo: 110 kg.'),
    ('Día 3 - Tracción (Sesión 2)', 'Dominadas agarre neutro', 'Dominadas agarre neutro lastradas', 5, '5', null,
      'Para conservar tendones sin inflamación, con agarre neutro. No hay peso de referencia: usa el lastre con el que llegues al fallo o RIR 1 en la 5ª serie.'),
    ('Día 3 - Tracción (Sesión 2)', 'Peso muerto convencional', null, 5, '3', 160, 'Objetivo: 160 kg.')
)
update ejercicios set
  nombre = coalesce(cambios.nombre_nuevo, ejercicios.nombre),
  series = cambios.series_nuevo,
  reps_objetivo = cambios.reps_nuevo,
  peso_objetivo = cambios.peso_nuevo,
  notas = cambios.notas_nueva
from cambios
join dias on dias.nombre = cambios.dia_nombre and dias.rutina_id = (select id from rutina_activa)
where ejercicios.dia_id = dias.id
  and ejercicios.nombre = cambios.ejercicio_nombre
returning ejercicios.nombre, ejercicios.series, ejercicios.reps_objetivo, ejercicios.peso_objetivo;
