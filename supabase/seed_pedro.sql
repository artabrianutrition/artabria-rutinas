-- ============================================================
-- Alta de cliente: Pedro Poderoso
-- "Fase 1 – Acoplamiento (2 semanas)", rotación de 7 días:
-- Tirón+Bíceps / Cuádriceps / Descanso / Empujes / Femoral /
-- Hombro+Brazo / Descanso.
-- Enlace del cliente: rutinas.artabrianutrition.com/c/gzvp5h
--
-- REQUISITO PREVIO: usa las columnas rutinas.notas y dias.notas
-- (mismo requisito que seed_alfredo.sql). Si no las tienes:
--   alter table rutinas add column if not exists notas text;
--   alter table dias add column if not exists notas text;
--
-- Los días de descanso no se crean como "día" en la app. Los
-- ejercicios con series descendentes/serie gigante final se dejan
-- como una sola fila (total de series reales, detalle en notas). Las
-- superseries (dos ejercicios sin descanso entre sí) se guardan como
-- dos ejercicios independientes, cada uno con una nota indicando con
-- cuál va emparejado.
-- ============================================================

with nuevo_cliente as (
  insert into clientes (nombre, codigo)
  values ('Pedro Poderoso', 'gzvp5h')
  returning id
), nueva_rutina as (
  insert into rutinas (cliente_id, nombre, notas)
  select
    id,
    'Fase 1 - Acoplamiento (2 semanas)',
    'ROTACIÓN (ciclo de 7 días; cada grupo muscular recibe estímulo directo cada 7 días aproximadamente):
Día 1: Tirón + Bíceps
Día 2: Cuádriceps
Día 3: Descanso
Día 4: Empujes
Día 5: Femoral
Día 6: Hombro + Brazo
Día 7: Descanso

NORMAS GENERALES:
- Las series de aproximación no cuentan; llegamos al peso de trabajo sin generar fatiga significativa.
- Todas las series son al fallo muscular. Si el peso permite superar las repeticiones objetivo, continúa hasta el fallo real: no te detengas al llegar al número marcado si todavía quedan repeticiones disponibles.
- La fase negativa siempre controlada; la fase concéntrica con intención explosiva.
- La técnica tiene prioridad absoluta sobre el peso utilizado. El peso se elige por sensaciones y tensión muscular, no por ego.
- Cuando aparezca el fallo, las últimas repeticiones podrán perder recorrido progresivamente.
- Las repeticiones parciales solo aparecen cuando el recorrido completo ya no es posible.
- Buscamos máxima tensión mecánica y máxima estimulación muscular, no demostrar fuerza.'
  from nuevo_cliente
  returning id
), dia1 as (
  insert into dias (rutina_id, nombre, notas, orden)
  select
    id,
    'Día 1 - Tirón + Bíceps',
    'Indicaciones generales de espalda: jamás nos retorcemos o desviamos fuerzas a otros músculos accesorios para finalizar una repetición; la técnica es perfecta tirando siempre de los músculos de la espalda. Las series, llegando al final, van perdiendo recorrido -sin poder cerrar la concéntrica del todo por fatiga- y acaban con las 2-3 últimas repeticiones que no se han completado en recorrido completo.',
    1
  from nueva_rutina
  returning id
), dia2 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Día 2 - Cuádriceps', 2 from nueva_rutina
  returning id
), dia3 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Día 3 - Empujes', 3 from nueva_rutina
  returning id
), dia4 as (
  insert into dias (rutina_id, nombre, notas, orden)
  select id, 'Día 4 - Femoral', 'Recordatorio técnico de espalda: por eso este día empieza con un ejercicio de espalda (Remo con Cable).', 4 from nueva_rutina
  returning id
), dia5 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Día 5 - Hombro + Brazo', 5 from nueva_rutina
  returning id
), ej_dia1 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia1.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia1, (values
    ('Jalón al Pecho Agarre Cerrado', 4, '15, 10, 10, 15 + descendente al 70% (al fallo)',
      'Últimas repeticiones parciales. Buscamos máxima depresión escapular y máxima activación dorsal.', 1),
    ('Remo con Mancuerna Unilateral', 4, '10, 10, 8, 20 (al fallo)',
      'Máximo enfoque en dorsal, peso contenido. Marca cada repetición manteniendo aproximadamente medio segundo de contracción máxima. No busques mover peso: busca sentir el dorsal trabajando.', 2),
    ('Remo Alto en Máquina', 3, '12 (al fallo)',
      'Sin impulso. Control absoluto de la negativa.', 3),
    ('Remo Gironda Agarre Medio Neutro', 4, '10, 8, 8, 20 + descendente al 70% (al fallo)',
      'El movimiento mantiene tensión continua sobre dorsal y espalda media. Estira completamente bajo control.', 4),
    ('Máquina Jalón de Discos Agarre Unilateral', 4, '10-12 (al fallo); última serie: 8 + descendente al 70%',
      'Colócate ligeramente desplazado hacia un lado para favorecer la línea de fuerza sobre el dorsal. El brazo estira pero nunca pierde completamente la tensión.', 5),
    ('Rack Pull en Multipower', 4, '8 (al fallo); última serie: 20 (al fallo)',
      'Al ir guiada la trayectoria, centra toda la atención en mantener tensión continua sobre dorsal y erectores. Los brazos solo enganchan la barra; la espalda mueve la carga.', 6),
    ('Curl Scott con Mancuerna', 6, '10-12 (al fallo)',
      'Negativa lenta. Sin balanceos.', 7)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia2 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia2.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia2, (values
    ('Extensiones de Cuádriceps', 3, '15, 12, 20 + descendente al 70% (al fallo)',
      'Rebaja el ángulo entre la pierna y el torso al sentarte, retrasando el apoyo del asiento para dejar caer ligeramente la espalda. Las últimas repeticiones deben terminar sin poder completar totalmente el recorrido.', 1),
    ('Prensa Inclinada', 5, '15, 15, 10, 8 (al fallo) + serie gigante final (descendente por discos)',
      'Durante las aproximaciones ve añadiendo discos sin generar fatiga; rodillas literalmente al pecho, cerrando al máximo el ángulo fémur-tibia. Serie gigante final: vuelve al peso máximo, una serie al fallo, retira un disco de 20 kg por lado, vuelve al fallo, y repite el proceso hasta quedar con un solo disco por lado -sin prisa entre mini-series; cada bajada de peso debe aumentar el control y la contracción voluntaria del cuádriceps. Esta serie final debe ser extremadamente exigente.', 2),
    ('Sentadilla Multipower', 5, '8, 12, 15 (al fallo) + 2 series descendentes (quitando 30-40 kg cada vez)',
      'Las piernas no deben ir demasiado adelantadas. Siéntate sobre los talones (glúteo encima de los talones), recorrido máximo. Mantén la misma profundidad en todas las series, incluidas las descendentes.', 3),
    ('Aductor', 4, '15-20 (al fallo)',
      'Las últimas repeticiones deben terminar sin poder cerrar completamente el recorrido.', 4)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia3 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia3.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia3, (values
    ('Press Plano Multipower', 5, '8, 8, 6, 6, 6 (al fallo; descanso 45 s entre las 3 últimas)',
      'Sin contar series de aproximación: llega al peso de trabajo sin generar fatiga.', 1),
    ('Aperturas Inclinadas', 4, '10, 10, 8, 6 (al fallo; descanso 45 s antes de la última)',
      'Máximo estiramiento, máxima tensión.', 2),
    ('Press Inclinado con Mancuernas', 2, '8, 8 (al fallo)',
      'Control absoluto en la negativa.', 3),
    ('Press Máquina Convergente', 5, '8, 8, 10, 6, 6 (al fallo; descanso 45 s entre las últimas)', null::text, 4),
    ('Fondos en Paralelas con Lastre', 2, '12, 10 (al fallo)', null::text, 5),
    ('Elevaciones Laterales con Mancuernas', 7, '15, 15, 15, 15, 20, 20 (al fallo); última serie descendente de 15 repeticiones hasta fallo',
      'El brazo nunca descansa abajo: tensión continua.', 6)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia4 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia4.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia4, (values
    ('Remo con Cable', 3, '20 (al fallo)',
      'Marca al máximo cada contracción. Movimiento tipo "capote de torero": el ángulo del brazo apenas cambia. Buscamos conexión neuromuscular, no peso.', 1),
    ('Pull-over con Mancuerna', 4, '15',
      'Máximo estiramiento. La mancuerna queda encima de la cara, sin bajar hacia el abdomen. Buscamos mantener tensión constante.', 2),
    ('Femoral Tumbado', 5, '8-12 (al fallo)', 'Estiramiento máximo.', 3),
    ('Femoral Sentado', 3, '15 (al fallo)', 'Fase negativa totalmente controlada.', 4),
    ('Peso Muerto Piernas Rígidas Multipower', 3, '10-12 (al fallo)',
      'Realizado sobre plataforma o step, buscando aumentar el estiramiento de los isquios.', 5),
    ('Hip Thrust', 3, '25, 15, 10 (al fallo)',
      'La serie termina cuando ya no podamos completar el recorrido.', 6),
    ('Aductor Apertura para Glúteo', 3, '15-20 (al fallo)', null::text, 7)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia5 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia5.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia5, (values
    ('Press Militar Frontal Sentado Multipower', 4, '10, 8, 6, 8 (al fallo)',
      'Descanso 45 s antes de la 3ª serie; recupera completamente antes de la 4ª.', 1),
    ('Elevaciones Laterales con Mancuernas', 4, '18, 15, 12, 10 (al fallo)', null::text, 2),
    ('Remo al Mentón Barra Z', 2, '10, 8 (al fallo)', 'Sin tirones. Control absoluto.', 3),
    ('Elevaciones Laterales en Cable', 2, '15 (al fallo)', 'Hasta que el recorrido ya no pueda completarse.', 4),
    ('Extensión Tríceps por Encima de la Cabeza Unilateral', 4, '12 (al fallo)',
      'En superserie con Curl Scott Mancuerna: sin descanso entre ambos ejercicios, descansa solo al terminar los dos.', 5),
    ('Curl Scott Mancuerna', 4, '12 (al fallo)',
      'En superserie con Extensión Tríceps por Encima de la Cabeza Unilateral: sin descanso entre ambos ejercicios, descansa solo al terminar los dos.', 6),
    ('Extensión Tríceps Polea Agarre V', 6, '8, 8, 8, 6, 6, 6 (al fallo; descanso 30 s entre las 3 últimas)',
      'En superserie con Curl Barra Z: sin descanso entre ambos ejercicios, descansa solo al terminar los dos.', 7),
    ('Curl Barra Z', 6, '8, 8, 8, 6, 6, 6 (al fallo; descanso 30 s entre las 3 últimas)',
      'En superserie con Extensión Tríceps Polea Agarre V: sin descanso entre ambos ejercicios, descansa solo al terminar los dos.', 8),
    ('Press Francés', 3, '12, 12, 10 (al fallo)',
      'En superserie con Curl Martillo: sin descanso entre ambos ejercicios, descansa solo al terminar los dos.', 9),
    ('Curl Martillo', 3, '12, 12, 10 (al fallo)',
      'En superserie con Press Francés: sin descanso entre ambos ejercicios, descansa solo al terminar los dos.', 10)
  ) as v(nombre, series, reps, notas, orden)
  returning id
)
select 'seed pedro ok' as status;
