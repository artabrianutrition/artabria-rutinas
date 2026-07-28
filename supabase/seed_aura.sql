-- ============================================================
-- Alta de cliente: Aura
-- Rutina Upper-Lower (2 días).
-- Enlace del cliente: rutinas.artabrianutrition.com/c/6anr5d
-- ============================================================

with nuevo_cliente as (
  insert into clientes (nombre, codigo)
  values ('Aura', '6anr5d')
  returning id
), nueva_rutina as (
  insert into rutinas (cliente_id, nombre, notas)
  select
    id,
    'Rutina Upper-Lower',
    'EXPLICACIONES:
Hemos añadido un ejercicio en cada día de entrenamiento. Todas las series las llevamos a una sensación de fatiga grande, hasta que ya no puedas hacer más repeticiones bien hechas con el peso que tengas seleccionado. Si llegas al número de repeticiones marcado y tienes energía para continuar, continúas hasta que se te acabe la energía y no puedas más.

Añadimos abdominales y abductores a la rutina 26-07-2026.

Es mucho más importante llegar a esa fatiga final que hacer el número exacto de repeticiones que tienes marcado en el entrenamiento.'
  from nuevo_cliente
  returning id
), dia1 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Día 1 - Upper', 1 from nueva_rutina
  returning id
), dia2 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Día 2 - Lower', 2 from nueva_rutina
  returning id
), ej_dia1 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia1.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia1, (values
    ('Jalón agarre cerrado', 4, '8-10', null::text, 1),
    ('Remo en polea baja', 4, '8-10', null::text, 2),
    ('Peso muerto', 4, '8', null::text, 3),
    ('Press hombro máquina inclinada', 4, '10-12', null::text, 4),
    ('Elevaciones laterales en máquina', 4, '10-12', null::text, 5),
    ('Extensiones de tríceps con polea', 4, '8-10', null::text, 6),
    ('Curl de bíceps en polea', 4, '8-10', null::text, 7),
    ('Abdominales en banco', 4, '12', null::text, 8)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia2 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia2.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia2, (values
    ('Extensiones de cuádriceps en máquina', 4, '15', null::text, 1),
    ('Prensa inclinada', 4, '10-12',
      'Lentas y profundas hasta que notes que te estira el músculo del glúteo; olvídate del peso y céntrate en sentir el estiramiento y el cuádriceps hasta la conexión con la cadera.', 2),
    ('Abductor', 4, '15', null::text, 3),
    ('Aductor de glúteo (máquina de ginecólogo)', 4, '15', null::text, 4),
    ('Curl femoral sentado', 4, '15', null::text, 5),
    ('Curl femoral tumbado en máquina', 4, '15', null::text, 6),
    ('Peso muerto multipower, piernas rectas', 2, '8-10', null::text, 7),
    ('Hiperextensiones', 3, 'hasta que agarre',
      'Igual que el día de espalda. Que no duela, solo buscamos fortalecer; añadiremos más ejercicios a medida que mejore el lumbar.', 8),
    ('Elevación de talones sentado', 3, '15-20', null::text, 9)
  ) as v(nombre, series, reps, notas, orden)
  returning id
)
select 'seed aura ok' as status;
