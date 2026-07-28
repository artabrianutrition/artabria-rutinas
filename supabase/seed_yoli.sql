-- ============================================================
-- Alta de cliente: Yoli Simo
-- "Altas repes", split de 4 días (Cuádriceps / Hombro-brazo /
-- Femoral y Glúteo / Espalda) con cadencia semanal irregular.
-- Enlace del cliente: rutinas.artabrianutrition.com/c/h8kyvy
-- ============================================================

with nuevo_cliente as (
  insert into clientes (nombre, codigo)
  values ('Yoli Simo', 'h8kyvy')
  returning id
), nueva_rutina as (
  insert into rutinas (cliente_id, nombre, notas)
  select
    id,
    'Altas repes',
    'CADENCIA SEMANAL:
Lunes, martes y miércoles: entreno.
Jueves: descanso.
Viernes y sábado: entreno.
Domingo: descanso.

Se respeta la cadencia de los días de entrenamiento (no de la semana): el viernes se hace el último día del ciclo (Espalda), el sábado se empieza de nuevo por Cuádriceps, se descansa el domingo, y el lunes se sigue la cadencia con Hombro-brazo, y así sucesivamente.

DESCANSOS: máximo 120 segundos en los días con ejercicios más pesados, máximo 90 segundos en los ejercicios menos demandantes.

OBJETIVO: producir adaptaciones de fuerza-resistencia como base para el trabajo de las pruebas, y aumentar el consumo de VO2 durante los entrenamientos para elevar el gasto calórico durante y después de entrenar. Junto con el cardio de 1 hora ya pautado, esto debería notarse pronto en reducción de grasa, retención de líquidos y mejora del aspecto.

Cuando el entrenamiento esté adaptado, se introducirán cambios sobre este bloque antes de pasar al siguiente, buscando entonces ganar fuerza con el cuerpo ya optimizado, pesando unos 5 kg menos que ahora.'
  from nuevo_cliente
  returning id
), dia1 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Día 1 - Cuádriceps', 1 from nueva_rutina
  returning id
), dia2 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Día 2 - Hombro-brazo', 2 from nueva_rutina
  returning id
), dia3 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Día 3 - Femoral y Glúteo', 3 from nueva_rutina
  returning id
), dia4 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Día 4 - Espalda', 4 from nueva_rutina
  returning id
), ej_dia1 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia1.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia1, (values
    ('Extensiones de máquina', 3, '20, 20 (última serie descendente: 20-15-10-6)', null::text, 1),
    ('Sentadilla libre', 3, '20', 'Lo más cercano al fallo posible.', 2),
    ('Prensa inclinada', 3, '20, 20 (última serie descendente: 25-15-10-6)', null::text, 3),
    ('Zancadas con mancuerna', 2, '15 por pierna', 'Caminando.', 4),
    ('Abductor', 3, '20', 'Cerrando.', 5),
    ('Elevaciones talón de pie', 3, '20', null::text, 6)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia2 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia2.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia2, (values
    ('Press mancuerna', 2, '15', null::text, 1),
    ('Elevaciones laterales mancuerna', 4, '15', null::text, 2),
    ('Elevaciones frontales mancuerna', 3, '15', null::text, 3),
    ('Curl barra Z', 3, '15', 'En superserie con Extensiones de tríceps en polea agarre V: sin descanso entre ambos ejercicios.', 4),
    ('Extensiones de tríceps en polea agarre V', 3, '15', 'En superserie con Curl barra Z: sin descanso entre ambos ejercicios.', 5),
    ('Curl unilateral en banco scoot', 3, '15', 'En superserie con Fondos en máquina: sin descanso entre ambos ejercicios.', 6),
    ('Fondos en máquina', 3, '15', 'En superserie con Curl unilateral en banco scoot: sin descanso entre ambos ejercicios.', 7),
    ('Crunch abdomen en polea', 4, '15-20 (al fallo)', null::text, 8),
    ('Máquina scoot cable con barra Z', 5, '15', null::text, 9)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia3 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia3.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia3, (values
    ('Sentadillas libres', 2, '10 (al fallo), 20 (RIR 1-2)', null::text, 1),
    ('Aductor (máquina paritorio)', 4, '20-15-10-10 descendentes', 'Coloca discos pequeños que te permitan ir quitando peso y seguir la serie.', 2),
    ('Hip thrust', 2, '20-15-10-8 descendentes', 'Coloca discos que puedas quitar para poder hacer la serie descendente.', 3),
    ('Hack invertida', 2, '15-10-8-6 descendente', 'Mismo sistema: discos que puedas ir quitando.', 4),
    ('Curl femoral de pie', 2, '15 (al fallo)', null::text, 5),
    ('Curl femoral sentado', 3, '15, 15 (al fallo); última serie descendente: 20-15-10-8', 'Mismo sistema descendente que los anteriores.', 6),
    ('Peso muerto libre', 3, '8', null::text, 7)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia4 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia4.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia4, (values
    ('Jalón al pecho agarre ancho', 3, '15, 15 (última serie descendente: 15-12-10-8)', null::text, 1),
    ('Remo polea baja Gironda', 3, '15, 15 (última serie descendente: 15-10-8)', null::text, 2),
    ('Remo máquina de discos tipo Dorian (unilateral)', 3, '10-12', null::text, 3),
    ('Remo con mancuerna', 3, '12', null::text, 4),
    ('Pullover con polea', 3, '15', null::text, 5),
    ('Hiperextensiones', 2, 'al fallo', 'Lentas, hiperextensión real hasta arriba -te lo enseño en persona cómo quiero que lo hagas.', 6)
  ) as v(nombre, series, reps, notas, orden)
  returning id
)
select 'seed yoli ok' as status;
