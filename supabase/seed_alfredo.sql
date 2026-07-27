-- ============================================================
-- Alta de cliente: Alfredo Linares
-- "Fase 1 – Acoplamiento (2 semanas)", rotación Empujes / Descanso /
-- Espalda+Bíceps / Descanso / Pierna / Descanso (se repite cada 6 días).
-- Enlace del cliente: rutinas.artabrianutrition.com/c/ce9gve
--
-- REQUISITO PREVIO: este script usa las columnas rutinas.notas y
-- dias.notas. Si todavía no las tienes, ejecuta primero:
--   alter table rutinas add column if not exists notas text;
--   alter table dias add column if not exists notas text;
--
-- Los días de descanso no se incluyen como "día" en la app (no hay
-- nada que registrar en ellos); la rotación completa queda explicada
-- en las notas de la rutina. Los ejercicios con una serie final
-- "descendente"/al fallo sin número fijo se han dejado como una sola
-- fila, sumando el total de series reales, con el detalle técnico en
-- las notas del ejercicio — así cada ejercicio es una sola tarjeta en
-- la app, igual que en tu documento original.
-- ============================================================

with nuevo_cliente as (
  insert into clientes (nombre, codigo)
  values ('Alfredo Linares', 'ce9gve')
  returning id
), nueva_rutina as (
  insert into rutinas (cliente_id, nombre, notas)
  select
    id,
    'Fase 1 - Acoplamiento (2 semanas)',
    'ROTACIÓN (ciclo de 6 días; cada grupo muscular vuelve a entrenarse aprox. cada 6 días):
Día 1: Empujes
Día 2: Descanso
Día 3: Espalda + Bíceps
Día 4: Descanso
Día 5: Pierna
Día 6: Descanso
Día 7: volvemos al Día 1

NORMAS GENERALES:
- Las series de aproximación no cuentan; llegamos al peso de trabajo sin generar fatiga significativa.
- Todas las series son al fallo muscular. Si el peso permite superar las repeticiones objetivo, continúa hasta el fallo real: no te detengas al llegar al número marcado si todavía quedan repeticiones disponibles.
- La fase negativa siempre controlada; la fase concéntrica con intención explosiva.
- La técnica tiene prioridad absoluta sobre el peso utilizado. El peso se elige por sensaciones y tensión muscular, no por ego.
- Cuando aparezca el fallo, las últimas repeticiones podrán perder recorrido progresivamente.'
  from nuevo_cliente
  returning id
), dia1 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Día 1 - Empujes', 1 from nueva_rutina
  returning id
), dia2 as (
  insert into dias (rutina_id, nombre, notas, orden)
  select
    id,
    'Día 2 - Espalda + Bíceps',
    'Indicaciones generales de espalda: jamás nos retorcemos ni desviamos fuerzas a otros músculos accesorios para terminar una repetición; la técnica es perfecta tirando siempre de los músculos de la espalda. Las series, según se acercan al final, van perdiendo recorrido -sin poder cerrar la concéntrica del todo por fatiga- y terminan con las 2-3 últimas repeticiones sin completar el recorrido.',
    2
  from nueva_rutina
  returning id
), dia3 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Día 3 - Pierna', 3 from nueva_rutina
  returning id
), ej_dia1 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia1.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia1, (values
    ('Press Inclinado Multipower', 5, '8, 8, 6, 6, 6 (al fallo; descanso 45 s entre las 3 últimas)',
      'Sin contar series de aproximación: llega al peso de trabajo sin fatigarte antes de la primera serie. 1ª y 2ª serie con el mismo sistema (la 1ª es la Top Set): control máximo en la negativa, contracción explosiva al inicio, sin desviar fuerza tirando de más peso del que puedes. En las 3 últimas series, reduce el peso lo que consideres oportuno para mantener las repeticiones; todas al fallo -si llegas al número marcado y aún tienes margen, sigue hasta fallar de verdad (nunca te quedes en 8 si podías hacer 11).', 1),
    ('Aperturas Peck Deck', 4, '8, 8, 6, 6 (al fallo; descanso 45 s antes de las 2 últimas)',
      'Mismo criterio que el ejercicio anterior: tú eliges el peso, y si te quedas corto de kilos, sigues hasta fallar.', 2),
    ('Press Máquina Plana Convergente', 5, '8, 8, 10, 6, 6 (al fallo; descanso 45 s entre las últimas)',
      'Regula el peso; si necesitas bajarlo por fatiga, sin problema.', 3),
    ('Fondos Paralelas Libre con Lastre', 2, '12, 10', null::text, 4),
    ('Press Militar Frontal Sentado Multipower', 3, '10, 8, 6 (al fallo; descanso 45 s antes de la última)', null::text, 5),
    ('Elevaciones Laterales con Mancuerna', 4, '18, 15, 12, 10 aprox. (al fallo, mismo peso)',
      'La mancuerna no debe separarse del cuerpo al final de la serie. Intenta mantener el mismo peso en todas las series.', 6),
    ('Remo al Mentón con Barra Z', 2, '10, 8 (al fallo)',
      'Sin tirones. Extensión y contracción totalmente controladas; sube con potencia pero con máximo control.', 7),
    ('Elevaciones Laterales en Cable', 2, '15 (al fallo)',
      'Hasta que el cable suba solo hasta la mitad del recorrido.', 8),
    ('Extensiones de Tríceps por Encima de la Cabeza a una Mano con Mancuerna', 2, '12, 12 (al fallo)',
      'Regula el peso en la segunda serie.', 9),
    ('Extensiones Tríceps Polea Agarre V', 6, '8, 8, 8, 6, 6, 6 (al fallo; descanso 30 s entre las últimas)',
      'Regula el peso.', 10)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia2 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia2.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia2, (values
    ('Jalón al Pecho Agarre Cerrado', 3, '15, 10, 10 (al fallo)',
      'En la primera serie, las últimas repeticiones ya son parciales.', 1),
    ('Remo con Mancuerna Unilateral', 3, '10, 10, 20 (al fallo)',
      'En la primera serie, a partir de la repetición 8 ya no deberías llegar arriba del todo; las 2-3 últimas, parciales.', 2),
    ('Remo Alto en Máquina', 3, '12 (al fallo)', null::text, 3),
    ('Remo Gironda Agarre Ancho', 3, '10, 8, 8',
      'La técnica y las sensaciones mandan a la hora de elegir el peso, aunque uses el máximo. Mantén tensión continua en dorsal y espalda alta/media, y estira bien en la negativa para trabajar tanto por contracción como por elongación.', 4),
    ('Máquina Jalón de Discos Agarre Unilateral', 3, '10-12 (al fallo)',
      'Colócate un poco hacia un lado en el asiento para cargar la tensión en el dorsal. El brazo estira en la negativa pero no del todo -si estiras completamente, pierdes la tensión del dorsal. Las últimas 2-3 repeticiones apenas llegarán a contraer completamente.', 5),
    ('Peso Muerto en Multipower', 4, '8, 8, 8, 20 (al fallo)',
      'Buscamos tensión constante en la espalda: si te centras solo en el peso, moverás más kilos pero será menos eficiente. Sujeta el peso con la espalda tanto al subir como al bajar; los brazos solo enganchan la barra.', 6),
    ('Curl Scott con Mancuerna', 5, '10-12 (al fallo)', null::text, 7)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia3 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia3.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia3, (values
    ('Extensiones de Cuádriceps', 3, '15, 12, 20 (al fallo)',
      'Rebaja el ángulo entre la pierna y el torso al sentarte, retrasando el apoyo del asiento para dejar caer la espalda -así trabajas más el recto femoral y menos el vasto interno. Todas las series al fallo: las últimas repeticiones no deben poder completarse del todo; si terminas todas con recorrido completo es que aún no estabas cerca del fallo.', 1),
    ('Prensa Inclinada', 5, '15, 10, 25, ~6-8, al fallo (últimas 2 series con el mismo peso; descanso 30 s)',
      'Ve metiendo discos durante las series de aproximación sin fatigarte en exceso. 1ª serie (Top Set) al fallo real, 2ª serie (Back Off), 3ª serie al fallo -descansa 30 segundos. Con el mismo peso: otra serie al fallo (no deberían salir más de 6-8 repeticiones), descansa 30 segundos, y última serie al fallo con el mismo peso. El recorrido debe ser total: las piernas caen sobre el pectoral hasta que el ángulo de cadera se acerca a 60°; debes notar el gemelo clavado sobre el femoral.', 2),
    ('Sentadilla Multipower', 3, '8, 12, 15 (al fallo)',
      'Las piernas no deben ir demasiado adelantadas o aumentará en exceso la participación de glúteo e isquios. Siéntate literalmente sobre tus talones (glúteo encima de los talones); el recorrido es máximo.', 3),
    ('Femoral Tumbado', 5, '8-12',
      'Estiramiento máximo en la fase negativa; la pierna queda completamente extendida sin perder tensión.', 4),
    ('Femoral Sentado', 3, '15',
      'Misma filosofía: estiramiento total y controlado, fase concéntrica explosiva. Desde la mitad hasta el final de la repetición, el movimiento debe seguir muy controlado.', 5),
    ('Peso Muerto con Piernas Rígidas', 3, '10-12 (al fallo)',
      'Barra o mancuernas, es indiferente. En la última repetición apenas deberías poder enderezarte del todo -el número exacto de repeticiones es secundario, la intensidad es lo prioritario.', 6),
    ('Aductor', 3, '15-20',
      'Las últimas repeticiones deben terminar sin poder cerrar completamente el recorrido.', 7),
    ('Hip Thrust', 3, '25, 15, 10 (al fallo)',
      'La serie termina cuando ya no puedas elevar completamente la carga.', 8)
  ) as v(nombre, series, reps, notas, orden)
  returning id
)
select 'seed alfredo ok' as status;
