-- ============================================================
-- Crea/sustituye la rutina activa de Luis Coderque (nzq4y2):
-- 4 días de fuerza (Lunes/Martes/Jueves/Viernes, Lunes=Jueves y
-- Martes=Viernes) + 1 día funcional-metabólico por tiempo
-- (Sábado, tabata 30/30). Si ya tuviera una rutina activa se
-- desactivaría (no se borra), para conservar su historial.
-- ============================================================

with cliente as (
  select id from clientes where codigo = 'nzq4y2'
), desactivar as (
  update rutinas set activa = false
  where cliente_id = (select id from cliente) and activa = true
  returning id
), nueva_rutina as (
  insert into rutinas (cliente_id, nombre)
  select id, 'Fuerza (L-J) + Metabólico (Sábado)' from cliente
  returning id
), notas_fuerza as (
  select 'Los recorridos de los ejercicios serán máximos: no buscamos hipertrofia como tal, ni el entrenamiento más eficiente en cuanto a ganancia de masa muscular; antes de eso hay que optimizar tu metabolismo. Los descansos serán únicamente de 30 segundos entre series y entre ejercicios, por lo que no debería llevarte más de 25-30 minutos. El peso, el que necesites para llegar agotado al final de la serie sin dejar un RIR elevado, nunca más de RIR 2. Este entrenamiento iremos modificándolo semana a semana conforme te vayas adaptando. Cuando tengamos un metabolismo eficiente, habrá cambios tanto en entrenamiento como en alimentación.' as txt
), dia1 as (
  insert into dias (rutina_id, nombre, notas, orden)
  select nueva_rutina.id, 'Día 1 - Lunes', notas_fuerza.txt, 1 from nueva_rutina, notas_fuerza
  returning id
), dia2 as (
  insert into dias (rutina_id, nombre, notas, orden)
  select nueva_rutina.id, 'Día 2 - Martes', notas_fuerza.txt, 2 from nueva_rutina, notas_fuerza
  returning id
), dia3 as (
  insert into dias (rutina_id, nombre, notas, orden)
  select nueva_rutina.id, 'Día 3 - Jueves', notas_fuerza.txt, 3 from nueva_rutina, notas_fuerza
  returning id
), dia4 as (
  insert into dias (rutina_id, nombre, notas, orden)
  select nueva_rutina.id, 'Día 4 - Viernes', notas_fuerza.txt, 4 from nueva_rutina, notas_fuerza
  returning id
), dia5 as (
  insert into dias (rutina_id, nombre, notas, orden)
  select
    id,
    'Día 5 - Sábado (Metabólico)',
    'Entrenamos por tiempo con un tabata 30/30 (busca canciones de tabata 30/30 en YouTube): la mitad de la sesión estarás en esfuerzo, la otra mitad descansando. No pongas una intensidad que te fatigue en los primeros 30 segundos; las primeras rondas deben notarse ligeras y deberías ir fatigándote round a round hasta casi no poder completar las últimas. Totalmente en búsqueda de mejora metabólica, cero hipertrofia, aunque vas a congestionar sí o sí. Ten un poco de fe, esfuérzate y verás la rapidez de los resultados.',
    5
  from nueva_rutina
  returning id
), ej_dia1 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia1.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia1, (values
    ('Press banca plano', 3, '15', null::text, 1),
    ('Fondos en paralelas', 2, 'al fallo', null::text, 2),
    ('Elevaciones laterales', 3, '15', null::text, 3),
    ('Jalón al pecho agarre estrecho', 3, '15', null::text, 4),
    ('Remo sentado máquina unilateral', 3, '15', null::text, 5),
    ('Extensiones tríceps en polea', 4, '15',
      'En superserie con Curl bíceps con mancuerna: sin descanso entre ambos ejercicios, descansa solo al terminar los dos.', 6),
    ('Curl bíceps con mancuerna', 4, '15',
      'En superserie con Extensiones tríceps en polea: sin descanso entre ambos ejercicios, descansa solo al terminar los dos.', 7)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia2 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia2.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia2, (values
    ('Abdomen crunch en polea', 4, '20', null::text, 1),
    ('Femoral tumbado', 3, '15', null::text, 2),
    ('Prensa inclinada', 3, '15', null::text, 3),
    ('Búlgaras en multipower', 3, '15', null::text, 4),
    ('Abductor', 4, '15', null::text, 5),
    ('Gemelo de pie', 4, '15', null::text, 6)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia3 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia3.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia3, (values
    ('Press banca plano', 3, '15', null::text, 1),
    ('Fondos en paralelas', 2, 'al fallo', null::text, 2),
    ('Elevaciones laterales', 3, '15', null::text, 3),
    ('Jalón al pecho agarre estrecho', 3, '15', null::text, 4),
    ('Remo sentado máquina unilateral', 3, '15', null::text, 5),
    ('Extensiones tríceps en polea', 4, '15',
      'En superserie con Curl bíceps con mancuerna: sin descanso entre ambos ejercicios, descansa solo al terminar los dos.', 6),
    ('Curl bíceps con mancuerna', 4, '15',
      'En superserie con Extensiones tríceps en polea: sin descanso entre ambos ejercicios, descansa solo al terminar los dos.', 7)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia4 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia4.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia4, (values
    ('Abdomen crunch en polea', 4, '20', null::text, 1),
    ('Femoral tumbado', 3, '15', null::text, 2),
    ('Prensa inclinada', 3, '15', null::text, 3),
    ('Búlgaras en multipower', 3, '15', null::text, 4),
    ('Abductor', 4, '15', null::text, 5),
    ('Gemelo de pie', 4, '15', null::text, 6)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia5 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia5.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia5, (values
    ('Flexiones', 8, '30 s trabajo / 30 s descanso (tabata)',
      'Las primeras rondas deben notarse ligeras; ve fatigándote round a round hasta casi no poder completar las últimas.', 1),
    ('Press militar de pie con barra', 8, '30 s trabajo / 30 s descanso (tabata)',
      'No pongas más de 5 kg por lado. Las primeras rondas deben notarse ligeras; ve fatigándote round a round hasta casi no poder completar las últimas.', 2),
    ('Sentadillas sin peso', 10, '30 s trabajo / 30 s descanso (tabata)',
      'Las primeras rondas deben notarse ligeras; ve fatigándote round a round hasta casi no poder completar las últimas.', 3),
    ('Burpees', 8, '30 s trabajo / 30 s descanso (tabata)',
      'Tumbado totalmente en la flexión, sentadilla con salto. Las primeras rondas deben notarse ligeras; ve fatigándote round a round hasta casi no poder completar las últimas.', 4)
  ) as v(nombre, series, reps, notas, orden)
  returning id
)
select 'rutina luis coderque creada (fuerza + metabolico)' as status;
