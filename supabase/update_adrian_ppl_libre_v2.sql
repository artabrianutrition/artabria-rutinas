-- ============================================================
-- Modifica (no sustituye) la rutina activa de Adrian Acosta
-- (mw3i3u) "PPL libre", según el listado nuevo pasado. No se
-- desactiva la rutina ni se tocan los días: se actualizan los
-- ejercicios que siguen existiendo (mismo id -> conserva
-- historial y "sugerido" de la última sesión) y se añaden los 2
-- ejercicios nuevos. No hay ejercicios que quitar esta vez.
-- ============================================================

-- 1) Ejercicios que siguen existiendo (mismo nombre): se actualizan
--    en su sitio, conservando id -> conserva historial/progreso.
with rutina_activa as (
  select r.id from rutinas r
  join clientes c on c.id = r.cliente_id
  where c.codigo = 'mw3i3u' and r.activa = true
), cambios (dia_nombre, ejercicio_nombre, series_nuevo, reps_nuevo, notas_nueva, orden_nuevo) as (
  values
    ('Día 1 - Pierna', 'Femoral sentado', 4,
      '8, 10, 12; última serie descendente (parte del peso de la 1ª serie, 3 bajadas más)',
      'Pirámide invertida: bajando peso en cada serie. La primera serie es al peso máximo; la última serie (4ª) es descendente, partiendo del peso de la primera serie que hiciste, con 3 bajadas más.', 1),
    ('Día 1 - Pierna', 'Femoral tumbado', 4,
      '8, 10, 12; última serie descendente (parte del peso de la 1ª serie, 3 bajadas más)',
      'Pirámide invertida: bajando peso en cada serie. La primera serie es al peso máximo; la última serie (4ª) es descendente, partiendo del peso de la primera serie que hiciste, con 3 bajadas más.', 2),
    ('Día 1 - Pierna', 'Extensiones de cuádriceps', 4,
      '8, 10, 12; última serie descendente (parte del peso de la 1ª serie, 3 bajadas más)',
      'Pirámide invertida: bajando peso en cada serie. La primera serie es al peso máximo; la última serie (4ª) es descendente, partiendo del peso de la primera serie que hiciste, con 3 bajadas más.', 3),
    ('Día 1 - Pierna', 'Prensa inclinada', 4,
      '10-15; última serie descendente (parte del peso de la 1ª serie, 3 bajadas más)',
      'La primera serie es al peso máximo; la última serie (4ª) es descendente, partiendo del peso de la primera serie que hiciste, con 3 bajadas más.', 4),
    ('Día 1 - Pierna', 'Sentadilla libre', 3, '8, 12, 15',
      'Te aproximas hasta el peso máximo con el que puedas sacar 8 reps y haces la serie; en la segunda y tercera series modulas el peso para llegar a las repeticiones marcadas.', 5),
    ('Día 1 - Pierna', 'Aductor', 3, '12, 15, 20', null, 7),

    ('Día 2 - Tracción', 'Pullover con barra en polea (calentamiento)', 2, '15', 'Lentas y apretando.', 1),
    ('Día 2 - Tracción', 'Jalón agarre neutro', 4,
      '8, 10, 12; última serie descendente (parte del peso de la 1ª serie, 3 bajadas más)',
      'Pirámide invertida: bajando peso en cada serie. La primera serie es al peso máximo; la última serie (4ª) es descendente, partiendo del peso de la primera serie que hiciste, con 3 bajadas más.', 2),
    ('Día 2 - Tracción', 'Dominadas', 4, 'al fallo', null, 3),
    ('Día 2 - Tracción', 'Remo con mancuerna', 4,
      '8, 10, 12; última serie descendente (parte del peso de la 1ª serie, 3 bajadas más)',
      'Pirámide invertida: bajando peso en cada serie. La primera serie es al peso máximo; la última serie (4ª) es descendente, partiendo del peso de la primera serie que hiciste, con 3 bajadas más.', 4),
    ('Día 2 - Tracción', 'Remo con barra', 3, '8, 10, 12', 'Pirámide invertida: bajando peso en cada serie.', 5),
    ('Día 2 - Tracción', 'Peso muerto', 3, '6, 8, 10', 'Pirámide invertida: bajando peso en cada serie.', 6),
    ('Día 2 - Tracción', 'Curl con barra Z', 8, 'Al fallo (aprox. 10-12 reps), 30 s de descanso entre series',
      'Ejercicio de 10 minutos en total. Modula el peso para mantener 10-12 reps en todas las series; deberían salir unas 6-7 series. Deja vacías las filas que no uses.', 7),

    ('Día 3 - Empujes', 'Press banca plana', 4,
      '8, 10, 12; última serie descendente (parte del peso de la 1ª serie, 3 bajadas más)',
      'Pirámide invertida: bajando peso en cada serie. La primera serie es al peso máximo; la última serie (4ª) es descendente, partiendo del peso de la primera serie que hiciste, con 3 bajadas más.', 1),
    ('Día 3 - Empujes', 'Aperturas con mancuerna', 3, '8, 10, 12', 'Pirámide invertida: bajando peso en cada serie.', 2),
    ('Día 3 - Empujes', 'Fondos', 5, 'al fallo', null, 3),
    ('Día 3 - Empujes', 'Elevaciones laterales mancuernas', 4, '8, 10, 12, 15', 'Pirámide invertida: bajando peso en cada serie.', 5),
    ('Día 3 - Empujes', 'Elevaciones frontales', 4, '8, 10, 12, 15', 'Pirámide invertida: bajando peso en cada serie.', 6),
    ('Día 3 - Empujes', 'Extensiones de tríceps agarre V', 8, 'Al fallo (aprox. 10-12 reps), 30 s de descanso entre series',
      'Ejercicio de 10 minutos en total, igual que el curl con barra Z. Modula el peso para mantener 10-12 reps en todas las series; deberían salir unas 6-7 series. Deja vacías las filas que no uses.', 7)
)
update ejercicios set
  series = cambios.series_nuevo,
  reps_objetivo = cambios.reps_nuevo,
  notas = cambios.notas_nueva,
  orden = cambios.orden_nuevo
from cambios
join dias on dias.nombre = cambios.dia_nombre and dias.rutina_id = (select id from rutina_activa)
where ejercicios.dia_id = dias.id
  and ejercicios.nombre = cambios.ejercicio_nombre;

-- 2) Ejercicios nuevos que no existían: se insertan.
with rutina_activa as (
  select r.id from rutinas r
  join clientes c on c.id = r.cliente_id
  where c.codigo = 'mw3i3u' and r.activa = true
), nuevos (dia_nombre, nombre, series, reps, notas, orden) as (
  values
    ('Día 1 - Pierna', 'Zancadas caminando con mancuerna', 2, '12',
      'Una serie consta de 24 pasos, 12 con cada pierna. La pierna que se queda atrás roza la rodilla en el suelo. Pasos lentos, buscando estabilidad y levantándote con la pierna adelantada, trabajando así el cuádriceps.', 6),
    ('Día 3 - Empujes', 'Press hombros con mancuerna', 2, '10',
      'Banco ligeramente inclinado, no a 90°: colócalo en el anclaje siguiente. La mancuerna baja hasta rozar el hombro. No ahorres recorrido: mejor menos peso con recorrido completo que más peso con menos recorrido.', 4)
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
  e.reps_objetivo
from ejercicios e
join dias d on d.id = e.dia_id
join rutinas r on r.id = d.rutina_id
join clientes c on c.id = r.cliente_id
where c.codigo = 'mw3i3u' and r.activa = true and e.activo = true
order by d.orden, e.orden;
