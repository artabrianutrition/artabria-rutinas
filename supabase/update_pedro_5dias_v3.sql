-- ============================================================
-- Sustituye la rutina activa de Pedro Poderoso (gzvp5h) por la nueva
-- de 5 días (Espalda / Cuádriceps / Pecho / Hombro + Espalda /
-- Femoral y Glúteo), tal cual el listado pasado. La rutina anterior se
-- desactiva (no se borra), para conservar su historial de sesiones.
-- ============================================================

with cliente as (
  select id from clientes where codigo = 'gzvp5h'
), desactivar as (
  update rutinas set activa = false
  where cliente_id = (select id from cliente) and activa = true
  returning id
), nueva_rutina as (
  insert into rutinas (cliente_id, nombre)
  select id, 'Espalda / Cuádriceps / Pecho / Hombro+Espalda / Femoral-Glúteo' from cliente
  returning id
), dia1 as (
  insert into dias (rutina_id, nombre, notas, orden)
  select
    id,
    'Día 1 - Espalda',
    'Es super importante que te centres en la técnica, en sentir la espalda, cada zona que estés trabajando. No trates de meter todo el peso que puedas desde el día 1. Busca la fatiga por contracción y acompaña los pesos en la fase excéntrica, sujetando el dorsal todo el peso en la caída de forma controlada. El volumen lo iremos subiendo poco a poco y el peso irá subiendo solo a medida que vayamos metiendo comida y química, así que por favor, hazme caso y todo irá llegando a medida que avancen las semanas.',
    1
  from nueva_rutina
  returning id
), dia2 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Día 2 - Cuádriceps', 2 from nueva_rutina
  returning id
), dia3 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Día 3 - Pecho', 3 from nueva_rutina
  returning id
), dia4 as (
  insert into dias (rutina_id, nombre, notas, orden)
  select
    id,
    'Día 4 - Hombro + Espalda',
    'Segundo día de espalda: es analítico 100%. Se usa todo el peso que se pueda, pero el movimiento es lento en excéntrica, potente en concéntrica pero sin generar inercias -es decir, el tirón que des no puede crear un vacío en el peso, tienes que tener tensión constante durante todo el recorrido. Sujeta el peso en la excéntrica lento con el dorsal siempre; si no sientes cómo se desgarra el dorsal a medida que avanza la serie, algo no estarás haciendo bien. Busca esa sensación en este entreno. Buscamos medio segundo de contracción voluntaria en el punto máximo de contracción, para una conexión neuro-muscular total con el paso de las semanas.',
    4
  from nueva_rutina
  returning id
), dia5 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Día 5 - Femoral y Glúteo', 5 from nueva_rutina
  returning id
), ej_dia1 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia1.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia1, (values
    ('Jalón agarre neutro', 3, '10-12', null::text, 1),
    ('Remo en punta (barra y acople con agarre cerrado)', 3, '10-12', null::text, 2),
    ('Remo con mancuerna', 3, '10-12', null::text, 3),
    ('Remo vertical máquina tipo Dorian (unilateral)', 3, '10-12', null::text, 4),
    ('Peso muerto convencional', 3, '10-12', null::text, 5),
    ('Extensiones en polea', 4, '10-12', null::text, 6),
    ('Press francés', 4, '10-12', null::text, 7)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia2 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia2.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia2, (values
    ('Extensiones de cuádriceps', 4, '15-20', null::text, 1),
    ('Prensa inclinada', 4, '12-15',
      'Intenta bajar lo máximo con control total en la repe y no bajes de 12 repes. Cuidado con la hernia.', 2),
    ('Sentadilla hack', 3, '20',
      'RIR 0. Para hacerlo útil, baja lento (sin tardar 8 segundos, claro) con control total y tratando de señalizar totalmente en el cuádriceps, tanto al bajar como al subir.', 3),
    ('Femoral tumbado', 5, '10-12', null::text, 4),
    ('Gemelo de pie', 4, '15-20', null::text, 5)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia3 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia3.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia3, (values
    ('Press de banca plano', 3, '8-10', 'Indistinto libre o multipower.', 1),
    ('Aperturas inclinadas con mancuerna', 3, '10-12', null::text, 2),
    ('Press inclinado con mancuernas', 2, '8-10', null::text, 3),
    ('Aperturas máquina Peck Deck', 2, '12-15', null::text, 4),
    ('Fondos libres lastrados', 2, '15-20',
      'Elevamos las repeticiones porque tira mucho de los tendones y llegamos con fatiga ya alta; a baja repetición habría que subir mucho la carga y aumenta el riesgo de lesión. Aquí me mantengo', 5),
    ('Curl bíceps barra Z', 4, '8-10', null::text, 6),
    ('Curl martillo', 4, '8-10', null::text, 7)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia4 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia4.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia4, (values
    ('Press hombro multipower', 3, '10-12', null::text, 1),
    ('Elevaciones laterales con mancuerna', 5, '10-12', null::text, 2),
    ('Jalón agarre cerrado', 3, '15',
      'Olvídate totalmente del peso: engancha los straps y solo tira del codo hacia abajo, con los codos cerca del cuerpo y ligeramente por delante de ti. Prueba hasta que encuentres el punto óptimo para ti.', 3),
    ('Remo unilateral con polea alta', 3, '15',
      'En la polea de tríceps donde se puede regular la altura: siéntate en un banco, acóplalo para que no ceda con el peso y apóyate a él sentado a la inversa. Movimiento 100% controlado, la excéntrica la sujeta el dorsal. El codo se clava abajo, no hacia atrás, para no involucrar el hombro posterior.', 4),
    ('Remo unilateral polea de tríceps (altura media)', 3, '15',
      'Rota un poco el tronco en el punto máximo de la concéntrica para que el trabajo recaiga en el dorsal; codo abajo para bajar el trabajo lo máximo posible.', 5),
    ('Remo unilateral polea de tríceps (polea abajo del todo)', 3, '15',
      'Mismo sistema de rotación de tronco en el punto de máxima contracción.', 6)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia5 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia5.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia5, (values
    ('Femoral sentado', 4, '10-12', 'Si te quedas corto de peso, sube las repeticiones hasta el fallo.', 1),
    ('Femoral tumbado', 4, '10-12', 'Si te quedas corto de peso, sigue hasta el fallo.', 2),
    ('Abductor', 4, '15', null::text, 3),
    ('Hip thrust', 3, '20, 15, 12', null::text, 4),
    ('Prensa inclinada (estiramiento)', 4, '10-12', null::text, 5),
    ('Gemelo de pie o con la propia prensa', 4, '15', 'Usa la prensa que tenías montada para trabajar el gemelo.', 6)
  ) as v(nombre, series, reps, notas, orden)
  returning id
)
select 'rutina pedro 5 dias creada' as status;
