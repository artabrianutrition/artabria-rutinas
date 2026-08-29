-- ============================================================
-- Sustituye la rutina activa de Pedro Poderoso (gzvp5h) por una
-- nueva de 5 días entrenables (Espalda / Cuádriceps / Pecho /
-- Femoral y Glúteo / Hombro + Espalda) + 1 día de descanso, que no
-- se crea como "día" en la app. La rutina anterior se desactiva
-- (no se borra), para conservar su historial de sesiones.
--
-- REQUISITO PREVIO: requiere la columna registros_series.reps_descendente
-- (migration_reps_descendente.sql).
-- ============================================================

with cliente as (
  select id from clientes where codigo = 'gzvp5h'
), desactivar as (
  update rutinas set activa = false
  where cliente_id = (select id from cliente) and activa = true
  returning id
), nueva_rutina as (
  insert into rutinas (cliente_id, nombre)
  select id, 'Espalda / Cuádriceps / Pecho / Femoral-Glúteo / Hombro+Espalda'
  from cliente
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
  insert into dias (rutina_id, nombre, orden)
  select id, 'Día 4 - Femoral y Glúteo', 4 from nueva_rutina
  returning id
), dia5 as (
  insert into dias (rutina_id, nombre, notas, orden)
  select
    id,
    'Día 5 - Hombro + Espalda',
    'Segundo día de espalda: es analítico 100%. Se usa todo el peso que se pueda, pero el movimiento es lento en excéntrica, potente en concéntrica pero sin generar inercias -es decir, el tirón que des no puede crear un vacío en el peso, tienes que tener tensión constante durante todo el recorrido. Sujeta el peso en la excéntrica lento con el dorsal siempre; si no sientes cómo se desgarra el dorsal a medida que avanza la serie, algo no estarás haciendo bien. Busca esa sensación en este entreno. Buscamos medio segundo de contracción voluntaria en el punto máximo de contracción, para una conexión neuro-muscular total con el paso de las semanas.',
    5
  from nueva_rutina
  returning id
), ej_dia1 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia1.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia1, (values
    ('Jalón agarre neutro', 4, '3 x 10-12; última serie: 15 (máxima concentración en la contracción)', null::text, 1),
    ('Remo en punta (barra y acople con agarre cerrado)', 3, '2 x 10-12; última serie descendente: 8, mínimo 4 bajadas',
      'Si no tienes barra con agarre cerrado, usa el acople en punta. Ángulo respecto al suelo no superior a 30°: nada de ponerte casi de pie para meter kg, ese trabajo se lo lleva el trapecio y desaprovechamos el ejercicio. En la descendente vas sacando 1 disco de la barra y sigues hasta que solo quede el primer disco de 20 kg; el tamaño de los discos lo irás afinando en un par de sesiones.', 2),
    ('Remo con mancuerna', 3, '10-12', null::text, 3),
    ('Remo vertical máquina tipo Dorian (unilateral)', 3, '2 x 10-12; última serie descendente: al fallo para 15, mínimo 3 bajadas más la primera (por brazo)',
      'Quitas un disco o 3-4 placas cada bajada y sigues hasta fallar.', 4),
    ('Peso muerto convencional', 3, '10-12', null::text, 5),
    ('Curl bíceps con barra Z', 10, 'Al fallo (primera serie para 15 reps), 30 s de descanso entre series',
      'Ejercicio de 10 minutos en total. Haz las series que salgan en ese tiempo; deja vacías las filas que no uses.', 6)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia2 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia2.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia2, (values
    ('Extensiones', 3, '12-15', null::text, 1),
    ('Prensa inclinada', 3, '20, 12, 8',
      'Series de aproximación no cuentan: ve subiendo y tanteando el peso, sin buscar fatiga, sin pasar de 6-8 reps. Las 3 series de trabajo son al máximo peso posible.', 2),
    ('Sentadilla multipower', 3, '15, 12, 10', null::text, 3),
    ('Sentadilla búlgara a una pierna', 3, '12, 10, 8', null::text, 4),
    ('Aductor (cerrando)', 3, '15', null::text, 5),
    ('Gemelo de pie', 3, '15', null::text, 6)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia3 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia3.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia3, (values
    ('Press de banca plano', 3, '12, 10, 8', 'Indistinto libre o multipower.', 1),
    ('Aperturas inclinadas con mancuerna', 3, '10-12', null::text, 2),
    ('Press inclinado con mancuernas', 3, '10-12', null::text, 3),
    ('Aperturas máquina Peck Deck', 3, '12-15', null::text, 4),
    ('Fondos libres lastrados', 3, '15-20',
      'Elevamos las repeticiones porque tira mucho de los tendones y llegamos con fatiga ya alta; a baja repetición habría que subir mucho la carga y aumenta el riesgo de lesión.', 5),
    ('Press francés', 10, 'Al fallo (primera serie para 15 reps), 30 s de descanso entre series',
      'Ejercicio de 10 minutos en total, igual que el curl de bíceps. Haz las series que salgan en ese tiempo; deja vacías las filas que no uses.', 6)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia4 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia4.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia4, (values
    ('Femoral sentado', 3, '12-15', 'Si te quedas corto de peso, sube las repeticiones hasta el fallo.', 1),
    ('Femoral tumbado', 3, '10-12', 'Si te quedas corto de peso, sigue hasta el fallo.', 2),
    ('Peso muerto piernas rígidas', 4, '10-12',
      'Puedes hacerlo en multipower si tienes rango para estirar bien, o con barra libre. Lo hacemos con barra porque la progresión será superior y acabarás moviendo más peso; además ayuda indirectamente a dar densidad a la espalda.', 3),
    ('Abductor', 3, '15', null::text, 4),
    ('Hip thrust', 3, '20, 15, 12', null::text, 5),
    ('Prensa inclinada (estiramiento)', 1, '1 serie descendente: 25 (recorrido extremo), sacando un disco de 20 kg por lado cada bajada hasta quedar con 1 disco por lado',
      'No es día de cuádriceps ni de cargar peso, es día de estirar. No corras entre bajadas. Todas las series al fallo o RIR 0.', 6)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia5 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia5.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia5, (values
    ('Press hombro con mancuerna', 3, '10-12', null::text, 1),
    ('Elevaciones laterales con mancuerna', 6, '6 series descendentes, primera 15 reps, mínimo 4 bajadas por descendente',
      'Ve bajando peso y manteniendo las reps en la medida de lo posible. Volumen equivalente a 24 series si se separaran.', 2),
    ('Jalón agarre cerrado', 3, '15', null::text, 3),
    ('Remo unilateral con polea alta', 3, '15',
      'En la polea de tríceps donde se puede regular la altura: siéntate en un banco, acóplalo para que no ceda con el peso y apóyate a él sentado a la inversa. Movimiento 100% controlado, la excéntrica la sujeta el dorsal. El codo se clava abajo, no hacia atrás, para no involucrar el hombro posterior.', 4),
    ('Remo unilateral polea de tríceps (altura media)', 3, '15',
      'Rota un poco el tronco en el punto máximo de la concéntrica para que el trabajo recaiga en el dorsal; codo abajo para bajar el trabajo lo máximo posible.', 5),
    ('Remo unilateral polea de tríceps (polea abajo del todo)', 3, '15',
      'Mismo sistema de rotación de tronco en el punto de máxima contracción.', 6)
  ) as v(nombre, series, reps, notas, orden)
  returning id
)
select 'rutina pedro actualizada' as status;
