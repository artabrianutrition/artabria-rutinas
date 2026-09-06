-- ============================================================
-- Sustituye la rutina activa de José Enrique (4zkaax) por "PPL
-- libre" (Pierna/Tracción/Empujes) -esencialmente la misma que la
-- de Adrian Acosta, salvo "Péndulo" en vez de "Sentadilla libre".
-- La rutina anterior se desactiva (no se borra), para conservar su
-- historial de sesiones.
-- ============================================================

with cliente as (
  select id from clientes where codigo = '4zkaax'
), desactivar as (
  update rutinas set activa = false
  where cliente_id = (select id from cliente) and activa = true
  returning id
), nueva_rutina as (
  insert into rutinas (cliente_id, nombre)
  select id, 'PPL libre' from cliente
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
    ('Femoral sentado', 4, '8, 10, 12; última serie descendente (parte del peso de la 1ª serie, 3 bajadas más)',
      'Pirámide invertida: bajando peso en cada serie. La primera serie es al peso máximo; la última serie (4ª) es descendente, partiendo del peso de la primera serie que hiciste, con 3 bajadas más.', 1),
    ('Femoral tumbado', 4, '8, 10, 12; última serie descendente (parte del peso de la 1ª serie, 3 bajadas más)',
      'Pirámide invertida: bajando peso en cada serie. La primera serie es al peso máximo; la última serie (4ª) es descendente, partiendo del peso de la primera serie que hiciste, con 3 bajadas más.', 2),
    ('Extensiones de cuádriceps', 4, '8, 10, 12; última serie descendente (parte del peso de la 1ª serie, 3 bajadas más)',
      'Pirámide invertida: bajando peso en cada serie. La primera serie es al peso máximo; la última serie (4ª) es descendente, partiendo del peso de la primera serie que hiciste, con 3 bajadas más.', 3),
    ('Prensa inclinada', 3, '10-15; última serie descendente (parte del peso de la 1ª serie, 3 bajadas más)',
      'La primera serie es al peso máximo; la última serie (4ª) es descendente, partiendo del peso de la primera serie que hiciste, con 3 bajadas más.', 4),
    ('Péndulo', 3, '8, 12, 15',
      'Te aproximas hasta el peso máximo con el que puedas sacar 8 reps y haces la serie; en la segunda y tercera series modulas el peso para llegar a las repeticiones marcadas.', 5),
    ('Zancadas caminando con mancuerna', 2, '12',
      'Una serie consta de 24 pasos, 12 con cada pierna. La pierna que se queda atrás roza la rodilla en el suelo. Pasos lentos, buscando estabilidad y levantándote con la pierna adelantada, trabajando así el cuádriceps.', 6),
    ('Aductor', 3, '12, 15, 20', null::text, 7)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia2 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia2.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia2, (values
    ('Pullover con barra en polea (calentamiento)', 2, '15', 'Lentas y apretando.', 1),
    ('Jalón agarre neutro', 4, '8, 10, 12; última serie descendente (parte del peso de la 1ª serie, 3 bajadas más)',
      'Pirámide invertida: bajando peso en cada serie. La primera serie es al peso máximo; la última serie (4ª) es descendente, partiendo del peso de la primera serie que hiciste, con 3 bajadas más.', 2),
    ('Dominadas', 4, 'al fallo', null::text, 3),
    ('Remo con mancuerna', 4, '8, 10, 12; última serie descendente (parte del peso de la 1ª serie, 3 bajadas más)',
      'Pirámide invertida: bajando peso en cada serie. La primera serie es al peso máximo; la última serie (4ª) es descendente, partiendo del peso de la primera serie que hiciste, con 3 bajadas más.', 4),
    ('Remo con barra', 3, '8, 10, 12', 'Pirámide invertida: bajando peso en cada serie.', 5),
    ('Peso muerto', 3, '6, 8, 10', 'Pirámide invertida: bajando peso en cada serie.', 6),
    ('Curl con barra Z', 8, 'Al fallo (aprox. 10-12 reps), 30 s de descanso entre series',
      'Ejercicio de 10 minutos en total. Modula el peso para mantener 10-12 reps en todas las series; deberían salir unas 6-7 series. Deja vacías las filas que no uses.', 7)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia3 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia3.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia3, (values
    ('Press banca plana', 4, '8, 10, 12; última serie descendente (parte del peso de la 1ª serie, 3 bajadas más)',
      'Pirámide invertida: bajando peso en cada serie. La primera serie es al peso máximo; la última serie (4ª) es descendente, partiendo del peso de la primera serie que hiciste, con 3 bajadas más.', 1),
    ('Aperturas con mancuerna', 3, '8, 10, 12', 'Pirámide invertida: bajando peso en cada serie.', 2),
    ('Fondos', 5, 'al fallo', null::text, 3),
    ('Press hombros con mancuerna', 2, '10',
      'Banco ligeramente inclinado, no a 90°, colocado de manera que se pueda apoyar sobre el pectoral sin que duelan ni molesten los hombros. La mancuerna baja hasta rozar el hombro. No ahorres recorrido: mejor menos peso con recorrido completo que más peso con menos recorrido.', 4),
    ('Elevaciones laterales mancuernas', 4, '8, 10, 12, 15', 'Pirámide invertida: bajando peso en cada serie.', 5),
    ('Elevaciones frontales', 4, '8, 10, 12, 15', 'Pirámide invertida: bajando peso en cada serie.', 6),
    ('Extensiones de tríceps agarre V', 8, 'Al fallo (aprox. 10-12 reps), 30 s de descanso entre series',
      'Ejercicio de 10 minutos en total, igual que el curl con barra Z. Modula el peso para mantener 10-12 reps en todas las series; deberían salir unas 6-7 series. Deja vacías las filas que no uses.', 7)
  ) as v(nombre, series, reps, notas, orden)
  returning id
)
select 'rutina jose enrique actualizada' as status;
