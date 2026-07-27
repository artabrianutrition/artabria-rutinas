-- ============================================================
-- Alta de cliente: José Enrique
-- Rutina PPL (Pierna / Tracción / Empujes) en dos bloques.
-- Enlace del cliente: rutinas.artabrianutrition.com/c/4zkaax
--
-- Nota sobre las series "descendentes" (drop-set) que venían como una
-- segunda línea bajo el mismo ejercicio (ej. "3 x 12 reps" + "1 x
-- 15-12-10-8 descendente"): se han dejado como UN solo ejercicio,
-- sumando el total de series (3+1=4) y explicando la última serie
-- en las notas, para que sea una sola tarjeta por ejercicio en la app
-- (igual que en tu documento original).
--
-- Cómo ejecutar: Supabase → SQL Editor → New query → pega esto → Run.
-- ============================================================

with nuevo_cliente as (
  insert into clientes (nombre, codigo)
  values ('José Enrique', '4zkaax')
  returning id
), nueva_rutina as (
  insert into rutinas (cliente_id, nombre)
  select id, 'PPL · 2 bloques' from nuevo_cliente
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
    ('Femoral sentado', 2, '15-12-10-8 descendentes', null::text, 1),
    ('Femoral tumbado', 2, '15-12-10-8 descendentes', null::text, 2),
    ('Prensa inclinada', 3, '20 (última serie descendente)', 'Súper profunda, máximo recorrido. Última serie descendente: 20-15-10-8-6.', 3),
    ('Sentadilla hack', 2, '15', 'Súper profunda, como en el vídeo.', 4),
    ('Extensiones de máquina', 3, '20-15-10-6 descendentes', null::text, 5),
    ('Aductor', 3, '15', null::text, 6)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia2 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia2.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia2, (values
    ('Pullover con barra en polea (calentamiento)', 2, '15', 'Lentas y apretando.', 1),
    ('Jalón agarre cerrado', 4, '12 (última serie descendente)', 'Última serie descendente: 15-12-10-8.', 2),
    ('Remo con barra', 2, '8-10', null::text, 3),
    ('Remo con mancuerna', 2, '10', null::text, 4),
    ('Remo unilateral máquina Dorian', 3, '10 (última serie descendente)', 'Última serie descendente: 15-12-10-8.', 5),
    ('Máquina scoot cable con barra Z', 6, '10-12 (última serie descendente)', 'Scoot con barra Z en su defecto. Última serie descendente: 20-15-10-6.', 6)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia3 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia3.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia3, (values
    ('Press inclinado multipower', 3, '10', null::text, 1),
    ('Aperturas Peck deck', 4, '12 (última serie descendente)', 'Última serie descendente: 15-12-10-8.', 2),
    ('Press inclinado con mancuernas', 4, '10 (última serie descendente)', 'Última serie descendente: 15-12-10-8.', 3),
    ('Press militar máquina de placas', 3, '10 (última serie descendente)', 'Última serie descendente: 15-12-10-8.', 4),
    ('Elevaciones laterales con mancuernas', 4, '10-12', null::text, 5),
    ('Extensiones de tríceps agarre V', 6, '10 (última serie descendente)', 'Última serie descendente: 15-12-10-8.', 6)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia4 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia4.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia4, (values
    ('Extensiones', 3, '15 (última serie descendente)', 'Última serie descendente: 15-12-10-8.', 1),
    ('Péndulo', 4, '15 (última serie: rest-pause al fallo)', 'Última serie: 15 reps, descansa 30 segundos y repite al fallo; descansa 30 segundos más y repite al fallo otra vez.', 2),
    ('Extensiones', 3, '10-12', null::text, 3),
    ('Femoral sentado', 3, '8-10', null::text, 4),
    ('Peso muerto barra rumano', 2, '8-10', null::text, 5),
    ('Abductor (externo)', 3, '10-12', null::text, 6)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia5 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia5.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia5, (values
    ('Pullover con barra en polea (calentamiento)', 2, '15', 'Lentas.', 1),
    ('Jalón invertido', 3, '12', null::text, 2),
    ('Remo T en máquina', 4, '10-12 (última serie descendente)', 'Última serie descendente: 15-12-10-8.', 3),
    ('Remo con mancuerna', 2, '10-12', null::text, 4),
    ('Hiperextensiones', 3, '12-15', 'Extiende hasta que puedas llegar más arriba; deberías notarlo hasta la mitad de la espalda.', 5),
    ('Curl alterno bíceps', 5, '10-12', null::text, 6)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia6 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia6.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia6, (values
    ('Press máquina inclinada', 4, '10', null::text, 1),
    ('Aperturas inclinadas en máquina', 3, '12', null::text, 2),
    ('Press sentado vertical en máquina', 3, '15-12-10 descendente', null::text, 3),
    ('Elevaciones laterales en máquina', 3, '15-12-10-8 descendente', null::text, 4),
    ('Elevaciones frontales con mancuerna', 3, '10-12', null::text, 5),
    ('Extensiones de tríceps polea agarre V por encima de la cabeza', 4, '15-12-10-8 descendente', null::text, 6)
  ) as v(nombre, series, reps, notas, orden)
  returning id
)
select 'seed jose enrique ok' as status;
