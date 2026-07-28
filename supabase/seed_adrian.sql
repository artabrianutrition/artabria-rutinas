-- ============================================================
-- Alta de cliente: Adrian Acosta
-- "PPL libre" (Pierna/Tracción/Empujes), pirámide invertida en la
-- mayoría de ejercicios.
-- Enlace del cliente: rutinas.artabrianutrition.com/c/mw3i3u
-- ============================================================

with nuevo_cliente as (
  insert into clientes (nombre, codigo)
  values ('Adrian Acosta', 'mw3i3u')
  returning id
), nueva_rutina as (
  insert into rutinas (cliente_id, nombre)
  select id, 'PPL libre' from nuevo_cliente
  returning id
), dia1 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Día 1 - Pierna', 1 from nueva_rutina
  returning id
), dia2 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Día 2 - Tracción', 2 from nueva_rutina
  returning id
), dia3 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Día 3 - Empujes', 3 from nueva_rutina
  returning id
), ej_dia1 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia1.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia1, (values
    ('Femoral sentado', 4, '8, 10, 12, 15', 'Pirámide invertida: bajando peso en cada serie.', 1),
    ('Femoral tumbado', 4, '8, 10, 12, 15', 'Pirámide invertida: bajando peso en cada serie.', 2),
    ('Extensiones de cuádriceps', 4, '8, 10, 12, 15', 'Pirámide invertida: bajando peso en cada serie.', 3),
    ('Prensa inclinada', 2, '10-15', 'Bajando peso en la segunda serie.', 4),
    ('Sentadilla libre', 2, '10-15', 'Bajando peso en la segunda serie.', 5),
    ('Aductor', 3, '12, 15, 20', null::text, 6)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia2 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia2.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia2, (values
    ('Pullover con barra en polea (calentamiento)', 2, '15', 'Lentas y apretando.', 1),
    ('Jalón agarre neutro', 3, '8, 10, 12', 'Pirámide invertida: bajando peso en cada serie.', 2),
    ('Dominadas', 3, 'al fallo', null::text, 3),
    ('Remo con mancuerna', 3, '8, 10, 12', 'Pirámide invertida: bajando peso en cada serie.', 4),
    ('Remo con barra', 3, '8, 10, 12', 'Pirámide invertida: bajando peso en cada serie.', 5),
    ('Peso muerto', 3, '6, 8, 10', 'Pirámide invertida: bajando peso en cada serie.', 6),
    ('Curl con barra Z', 5, '8, 10, 12, 10, 8', 'Modula el peso para llegar al fallo aproximadamente en las repeticiones marcadas.', 7)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia3 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia3.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia3, (values
    ('Press banca plana', 3, '8, 10, 12', 'Pirámide invertida: bajando peso en cada serie.', 1),
    ('Aperturas con mancuerna', 3, '8, 10, 12', 'Pirámide invertida: bajando peso en cada serie.', 2),
    ('Fondos', 4, 'al fallo', null::text, 3),
    ('Elevaciones laterales mancuernas', 4, '8, 10, 12, 15', 'Pirámide invertida: bajando peso en cada serie.', 4),
    ('Elevaciones frontales', 4, '8, 10, 12, 15', 'Pirámide invertida: bajando peso en cada serie.', 5),
    ('Extensiones de tríceps agarre V', 4, '8, 10, 12, 15', 'Pirámide invertida: bajando peso en cada serie.', 6)
  ) as v(nombre, series, reps, notas, orden)
  returning id
)
select 'seed adrian ok' as status;
