-- ============================================================
-- Sustituye la rutina activa de Yoli Simo (h8kyvy) por una nueva de
-- 4 días (Cuádriceps / Espalda / Femoral y Glúteo / Hombro-brazo),
-- ordenados 1-2-3-4 (Cuádriceps, Hombro-brazo, Femoral y Glúteo, Espalda). La rutina
-- anterior se desactiva (no se borra), para conservar su historial.
--
-- REQUISITO PREVIO: ejercicios.peso_objetivo (migration_peso_objetivo.sql).
-- ============================================================

with cliente as (
  select id from clientes where codigo = 'h8kyvy'
), desactivar as (
  update rutinas set activa = false
  where cliente_id = (select id from cliente) and activa = true
  returning id
), nueva_rutina as (
  insert into rutinas (cliente_id, nombre)
  select id, 'Rutina 4 días Yoli' from cliente
  returning id
), dia1 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Día 1 - Cuádriceps', 1 from nueva_rutina
  returning id
), dia2 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Día 4 - Espalda', 4 from nueva_rutina
  returning id
), dia3 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Día 3 - Femoral y Glúteo', 3 from nueva_rutina
  returning id
), dia4 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Día 2 - Hombro-brazo', 2 from nueva_rutina
  returning id
), ej_dia1 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, peso_objetivo, notas, orden)
  select dia1.id, v.nombre, v.series, v.reps, v.peso, v.notas, v.orden
  from dia1, (values
    ('Extensiones de máquina', 2, '12, 8 (al fallo ambas)', null::numeric, null::text, 1),
    ('Sentadilla libre', 2, '10, 8 (RIR 0)', null::numeric,
      'Sentadilla profunda con movimiento controlado (que no lento), tanto bajando como subiendo.', 2),
    ('Prensa inclinada', 2, '15, 8 (RIR 0)', null::numeric,
      'Movimiento muy profundo, superando los 90 grados de ángulo entre tibia y peroné con el fémur.', 3),
    ('Abductor', 3, '20', null::numeric, 'Cerrando.', 4),
    ('Abdominales en máquina', 3, '15 (al fallo)', null::numeric, null::text, 5)
  ) as v(nombre, series, reps, peso, notas, orden)
  returning id
), ej_dia2 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, peso_objetivo, notas, orden)
  select dia2.id, v.nombre, v.series, v.reps, v.peso, v.notas, v.orden
  from dia2, (values
    ('Jalón al pecho agarre cerrado', 2, '12, 10 (al fallo)', null::numeric, null::text, 1),
    ('Remo polea baja Gironda', 2, '12, 10 (al fallo)', null::numeric, null::text, 2),
    ('Remo máquina de discos tipo Dorian (unilateral)', 2, '10 (al fallo)', null::numeric, null::text, 3),
    ('Pullover con polea', 3, '12 (al fallo)', null::numeric, null::text, 4),
    ('Hiperextensiones', 2, 'al fallo', null::numeric,
      'Lentas, hiperextensión real hasta arriba. Te lo enseño en persona cómo quiero que lo hagas.', 5)
  ) as v(nombre, series, reps, peso, notas, orden)
  returning id
), ej_dia3 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, peso_objetivo, notas, orden)
  select dia3.id, v.nombre, v.series, v.reps, v.peso, v.notas, v.orden
  from dia3, (values
    ('Sentadillas sumo', 2, '8 (RIR 0)', null::numeric,
      'Piernas bien abiertas, ligeramente adelantadas y con las puntas de los pies hacia fuera. Espalda recta y bajada profunda y controlada; abajo tienes que notar estiramiento en isquios y glúteo.', 1),
    ('Aductor (máquina paritorio)', 3, '20 (al fallo)', null::numeric,
      'Mucho control, movimiento analítico: aguanta 1 segundo de isométrico en el momento de máxima contracción.', 2),
    ('Hip thrust', 2, '12 (RIR 0)', null::numeric,
      'Importante: no arquear el lumbar para contraer el glúteo. Lumbar semirrelajado y sin arquear; se aprieta solo el glúteo.', 3),
    ('Curl femoral tumbado', 2, '12 (al fallo)', null::numeric, null::text, 4),
    ('Extensiones de cuádriceps', 3, '12', null::numeric,
      'Cadencia regular, a la misma velocidad en ambas fases del movimiento. Isométrico de 0,5-1 segundo en el punto de máxima contracción.', 5)
  ) as v(nombre, series, reps, peso, notas, orden)
  returning id
), ej_dia4 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, peso_objetivo, notas, orden)
  select dia4.id, v.nombre, v.series, v.reps, v.peso, v.notas, v.orden
  from dia4, (values
    ('Press mancuerna', 2, '12', 12.5::numeric, 'Usaremos las mancuernas de 12,5 kg en ambas series.', 1),
    ('Elevaciones laterales mancuerna', 3, '15', null::numeric, null::text, 2),
    ('Elevaciones frontales mancuerna', 3, '15', null::numeric, null::text, 3),
    ('Curl barra Z', 4, '15', null::numeric,
      'En superserie con Extensiones de tríceps en polea agarre V: sin descanso entre ambos ejercicios.', 4),
    ('Extensiones de tríceps en polea agarre V', 4, '15', null::numeric,
      'En superserie con Curl barra Z: sin descanso entre ambos ejercicios.', 5),
    ('Crunch abdomen en polea', 4, '15-20 (al fallo)', null::numeric, null::text, 6),
    ('Máquina scoot cable con barra Z', 5, '15', null::numeric, null::text, 7)
  ) as v(nombre, series, reps, peso, notas, orden)
  returning id
)
select 'rutina yoli 4 dias creada' as status;
