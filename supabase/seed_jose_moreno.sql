-- ============================================================
-- Alta de cliente: Jose Moreno
-- PPL (Pierna/Tracción/Empujes) en dos bloques.
-- Enlace del cliente: rutinas.artabrianutrition.com/c/af93my
-- ============================================================

with nuevo_cliente as (
  insert into clientes (nombre, codigo)
  values ('Jose Moreno', 'af93my')
  returning id
), nueva_rutina as (
  insert into rutinas (cliente_id, nombre, notas)
  select
    id,
    'PPL · 2 bloques',
    'INDICACIONES GENERALES:
- Cadencia 3-1: fase negativa controlada (~1,5 segundos) y fase concéntrica explosiva.
- Reducimos RIR hasta llegar a RIR cero o incluso fallo en algunas series. Cada serie debe ejecutarse con técnica correcta, máximo peso posible y evitando transferencias de fuerza a músculos accesorios.
- Las repeticiones son orientativas. Si puedes hacer más repeticiones manteniendo técnica correcta, continúa hasta fallo o RIR cero.
- El peso no tiene que ser fijo. Ajusta la carga según la fatiga acumulada para mantener el rango de repeticiones objetivo.
- Prioridad absoluta a la técnica correcta. La fuerza aumentará progresivamente con el tiempo y la constancia.
- Descanso aproximado de 3 minutos entre series y ejercicios.
- Tras el día de descanso, se reinicia el ciclo desde el día 1.
- Si se interrumpe el ciclo, se continúa por el día correspondiente al volver al gimnasio.
- Objetivo inicial: adherencia, asimilación de patrones correctos de movimiento y control total del peso evitando inercias y compensaciones.
- Cualquier duda, escríbeme o llámame sin problema.'
  from nuevo_cliente
  returning id
), dia1 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Bloque 1 - Pierna', 1 from nueva_rutina
  returning id
), dia2 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Bloque 1 - Tracción', 2 from nueva_rutina
  returning id
), dia3 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Bloque 1 - Empujes', 3 from nueva_rutina
  returning id
), dia4 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Bloque 2 - Pierna', 4 from nueva_rutina
  returning id
), dia5 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Bloque 2 - Tracción', 5 from nueva_rutina
  returning id
), dia6 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Bloque 2 - Empujes', 6 from nueva_rutina
  returning id
), ej_dia1 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia1.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia1, (values
    ('Femoral sentado', 3, '15', null::text, 1),
    ('Femoral tumbado', 3, '15', null::text, 2),
    ('Prensa inclinada', 3, '8-10', null::text, 3),
    ('Sentadilla hack', 3, '12', null::text, 4),
    ('Extensiones de máquina', 3, '15', null::text, 5),
    ('Aductor', 3, '15', null::text, 6)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia2 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia2.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia2, (values
    ('Pullover en polea (calentamiento)', 2, '15', 'Lentas.', 1),
    ('Jalón agarre cerrado', 2, '12', null::text, 2),
    ('Máquina jalón discos unilateral', 2, '12', null::text, 3),
    ('Remo con mancuerna', 3, '12', null::text, 4),
    ('Remo máquina sentado (tipo Dorian)', 3, '12', null::text, 5),
    ('Peso muerto convencional', 2, '8, 6', null::text, 6),
    ('Máquina Scott cable barra Z', 5, '12', null::text, 7)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia3 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia3.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia3, (values
    ('Press máquina plana discos', 3, '6, 8, 10', null::text, 1),
    ('Press multipower inclinado', 3, '12', null::text, 2),
    ('Aperturas máquina inclinada', 2, '12', null::text, 3),
    ('Fondos libres', 2, 'al fallo', null::text, 4),
    ('Elevaciones laterales mancuernas', 3, '12', null::text, 5),
    ('Elevaciones laterales máquina de pie', 3, '12', null::text, 6),
    ('Extensiones de tríceps agarre V', 5, '12', null::text, 7)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia4 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia4.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia4, (values
    ('Femoral sentado', 3, '15', null::text, 1),
    ('Femoral tumbado', 3, '15', null::text, 2),
    ('Hip thrust', 3, '10', null::text, 3),
    ('Sentadilla multipower', 3, '10', null::text, 4),
    ('Extensiones de máquina', 3, '15', null::text, 5),
    ('Aductor', 3, '15', null::text, 6)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia5 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia5.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia5, (values
    ('Pullover en polea (calentamiento)', 2, '15', 'Lentas.', 1),
    ('Jalón agarre abierto', 2, '12', null::text, 2),
    ('Remo en polea baja Gironda', 3, '12', null::text, 3),
    ('Remo unilateral en máquina', 3, '12', null::text, 4),
    ('Remo máquina sentado (tipo Dorian)', 3, '12', null::text, 5),
    ('Hiperextensiones', 3, 'al fallo real', null::text, 6),
    ('Máquina Scott cable anilla unilateral', 5, '12', null::text, 7)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia6 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia6.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia6, (values
    ('Press multipower inclinado', 3, '12', null::text, 1),
    ('Aperturas máquina inclinada', 2, '12', null::text, 2),
    ('Press máquina inclinada discos', 3, '10', null::text, 3),
    ('Aperturas Peck Deck', 2, '10', null::text, 4),
    ('Elevaciones laterales mancuernas', 3, '12', null::text, 5),
    ('Elevaciones laterales máquina de pie', 3, '12', null::text, 6),
    ('Press francés', 5, '12', null::text, 7)
  ) as v(nombre, series, reps, notas, orden)
  returning id
)
select 'seed jose moreno ok' as status;
