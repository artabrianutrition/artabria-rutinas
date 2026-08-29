-- ============================================================
-- Sustituye la rutina activa de Borja Bravo Llinares (xk29fa) por
-- "Plan de entrenamiento - Fase de adaptación". La rutina anterior
-- se desactiva (no se borra), para conservar su historial de
-- sesiones ya registradas.
-- ============================================================

with cliente as (
  select id from clientes where codigo = 'xk29fa'
), desactivar as (
  update rutinas set activa = false
  where cliente_id = (select id from cliente) and activa = true
  returning id
), nueva_rutina as (
  insert into rutinas (cliente_id, nombre, notas)
  select
    id,
    'Plan de entrenamiento - Fase de adaptación',
    'INDICACIONES GENERALES:
Cadencia 3-1: fase negativa controlada (~1,5 segundos) y fase concéntrica explosiva.

Vamos a empezar a reducir un poco el número de repeticiones. Ahora es importante que tantees bien el peso que tienes que seleccionar para las series. Las series son al fallo, RIR cero como máximo -es decir, que en la última repetición no puedas sacar una más. Para la segunda y tercera series, regula el peso: intenta mantener el mismo peso en la segunda serie, y si sale una o dos repeticiones menos, no te rayes, con que sea el máximo esfuerzo es lo que buscamos. Para la tercera serie, si queremos mantener el número de repeticiones, tendrás que ajustar bajando un poco el peso. Esto es lo que tienes que dominar ahora.

Todas las series son una oportunidad única para forzar al músculo a crecer. No lo olvides: día que no se haga, día que no se progresará lo que toca. El camino es largo, pero tenemos que llevar un ritmo continuo -cuando ves a alguien que progresa, es porque está cumpliendo esta premisa. Una pauta sin un esfuerzo máximo es solo un montón de directrices sin más.

Aún reduciremos un poquito más el número de reps hasta dejarlas en 8 para la mayoría de ejercicios. Mega importante: una técnica correcta, que el estímulo vaya al músculo que estamos entrenando y no desviemos a otros músculos el esfuerzo por tratar de tirar más kg. La fuerza irá aumentando poco a poco, tranquilo. Técnica correcta no equivale a ejercicios de demostración: pequeños balanceos o inercias pueden ser positivos siempre que no desvíes el esfuerzo a músculos accesorios -eso eres tú quien lo tiene que ir notando.

El entrenamiento es la base de la mejora; este apartado te toca a ti exprimirlo, yo no puedo hacer el esfuerzo por ti en el gimnasio. Piénsalo siempre: es tu esfuerzo, será tu recompensa.

Cuando llevemos dos semanas con este nuevo entrenamiento, valoraremos el volumen de trabajo y lo modificaremos si es necesario. Es importante que la intensidad, como te dije antes, no sea negociable: cada serie a muerte es la única manera de progresar en este mundillo.

Descanso aproximado de 3 minutos entre series y entre ejercicios.
Tras el día de descanso, se reinicia el ciclo desde el día 1.
Si se interrumpe el ciclo, se continúa por el día correspondiente al volver al gimnasio.'
  from cliente
  returning id
), dia1 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Día 1 - Pierna', 1 from nueva_rutina
  returning id
), dia2 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Día 2 - Tracción', 2 from nueva_rutina
  returning id
), dia3 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Día 3 - Empujes', 3 from nueva_rutina
  returning id
), ej_dia1 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia1.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia1, (values
    ('Femoral sentado', 3, '10', null::text, 1),
    ('Femoral tumbado', 3, '10', null::text, 2),
    ('Prensa inclinada', 3, '8-10', null::text, 3),
    ('Sentadilla hack', 3, '10', null::text, 4),
    ('Extensiones de máquina', 3, '12', null::text, 5),
    ('Aductor', 3, '15', null::text, 6)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia2 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia2.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia2, (values
    ('Pullover en polea (calentamiento)', 2, '15', 'Lentas.', 1),
    ('Jalón agarre cerrado', 2, '10', null::text, 2),
    ('Máquina jalón discos unilateral', 2, '10', null::text, 3),
    ('Remo con mancuerna', 3, '10', null::text, 4),
    ('Remo máquina sentado (tipo Dorian)', 3, '10', null::text, 5),
    ('Peso muerto convencional', 2, '8, 6', null::text, 6),
    ('Máquina Scott cable barra Z', 5, '12', null::text, 7)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia3 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia3.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia3, (values
    ('Press banca plana multipower', 3, '6, 8, 10', null::text, 1),
    ('Press mancuernas inclinado', 3, '10', null::text, 2),
    ('Aperturas máquina inclinada', 2, '10', null::text, 3),
    ('Elevaciones laterales mancuernas', 3, '12', null::text, 4),
    ('Elevaciones laterales máquina de pie', 3, '12', null::text, 5),
    ('Extensiones de tríceps agarre V', 5, '12', null::text, 6)
  ) as v(nombre, series, reps, notas, orden)
  returning id
)
select 'rutina borja actualizada' as status;
