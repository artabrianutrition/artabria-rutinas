-- ============================================================
-- Alta de cliente: Danny Falquet
-- Rutina Upper-Lower (2 días).
-- Enlace del cliente: rutinas.artabrianutrition.com/c/zgwsib
--
-- REQUISITO PREVIO: usa la columna rutinas.notas (mismo requisito
-- que seed_alfredo.sql / seed_pedro.sql). Si no la tienes:
--   alter table rutinas add column if not exists notas text;
--   alter table dias add column if not exists notas text;
-- ============================================================

with nuevo_cliente as (
  insert into clientes (nombre, codigo)
  values ('Danny Falquet', 'zgwsib')
  returning id
), nueva_rutina as (
  insert into rutinas (cliente_id, nombre, notas)
  select
    id,
    'Rutina Upper-Lower',
    'EXPLICACIONES:
Empezamos con un entrenamiento básico, en el que buscamos una adaptación al ejercicio guiado. Tenemos un volumen bastante alto, así que vamos a intentar regularlo bien desde el principio. Las dos primeras semanas no buscaremos acercarnos al fallo en ninguno de los ejercicios, dejando margen de 2-3-4 repeticiones en cada serie que no haremos, para no generar una fatiga excesiva y ver qué grado de estrés tiene el cuerpo con ese ejercicio y cuánta recuperación disponemos al finalizar los entrenamientos.

Tenemos el cuerpo dividido en dos partes solamente de momento. Con esto tenemos tiempo de realizar dos veces en semana la rutina completa. Como ejemplo podría quedar así: martes y miércoles hacemos la rutina upper-lower, descansamos jueves (o jueves y viernes) y volvemos a repetir, dejando luego como mínimo otro día más entero hasta volver a iniciar la rutina la semana siguiente.

Si después de realizar la primera vuelta de la rutina notas que apenas tienes agujetas y la recuperación es óptima, en la segunda sesión aprieta un poco más y deja menos margen hasta llegar al fallo muscular. La intensidad hay que ir subiéndola poco a poco las primeras semanas, hasta que sobre la semana 4-5 podamos estar haciendo la rutina al fallo muscular en todas las series.

En esta primera fase, los descansos entre series serán cortos: de momento no buscamos subir de fuerza en los ejercicios (aunque, aun con descansos cortos, subirá igualmente, aunque menos que más adelante). Los descansos entre series serán de 1:30 minutos máximo -quiero que exista congestión, y con tan pocas series por grupo, si aplicamos demasiado descanso no la habrá; lo que busco es que haya adaptaciones musculares mediadas por esa situación.

Es una rutina básica pero que funciona sobre todo en personas con poco tiempo entrenando: al hacer la rutina dos veces por semana, señalizamos dos veces la necesidad de cada músculo de absorber nutrientes mediada por ejercicio mecánico, haciendo que las adaptaciones musculares sean más cercanas entre sí, manteniendo una señalización continua sobre todo el cuerpo para producir hipertrofia muscular.'
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
    ('Press de Banca', 2, '8-10', null::text, 1),
    ('Press Inclinado con multipower', 2, '8-10', null::text, 2),
    ('Aperturas en máquina', 2, '8-10', null::text, 3),
    ('Fondos en Paralelas', 2, 'al fallo', null::text, 4),
    ('Jalón agarre cerrado', 3, '8-10', null::text, 5),
    ('Remo en polea baja', 2, '8-10', null::text, 6),
    ('Dominadas', 2, 'al fallo', null::text, 7),
    ('Peso muerto', 2, '8', null::text, 8),
    ('Press militar multipower', 2, '8-10', null::text, 9),
    ('Elevaciones laterales', 2, '10-12', null::text, 10),
    ('Extensiones de tríceps con polea', 3, '8-10', null::text, 11),
    ('Curl de bíceps con barra Z', 3, '8-10', null::text, 12)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia2 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia2.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia2, (values
    ('Extensiones de cuádriceps en máquina', 4, '15-20', null::text, 1),
    ('Prensa inclinada', 4, '10-12',
      'Lentas y profundas hasta que notes que te estira el músculo del glúteo; olvídate del peso y céntrate en sentir el estiramiento y el cuádriceps hasta la conexión con la cadera.', 2),
    ('Curl femoral tumbado en máquina', 4, '15-20', null::text, 3),
    ('Peso muerto con mancuerna, piernas rígidas', 2, '8-10', null::text, 4),
    ('Elevación de talones sentado', 3, '15-20', null::text, 5),
    ('Hiperextensiones', 3, 'hasta que agarre',
      'Igual que el día de espalda: que no duela, solo buscamos fortalecer; añadiremos más ejercicios a medida que mejore el lumbar.', 6)
  ) as v(nombre, series, reps, notas, orden)
  returning id
)
select 'seed danny ok' as status;
