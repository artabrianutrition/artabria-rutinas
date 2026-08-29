-- ============================================================
-- Sustituye la rutina activa de Alfredo Linares (ce9gve) por
-- "Plan de entrenamiento - Fase de adaptación" (3 días x 2 sesiones).
-- La rutina anterior se desactiva (no se borra), para conservar
-- su historial de sesiones ya registradas.
-- ============================================================

with cliente as (
  select id from clientes where codigo = 'ce9gve'
), desactivar as (
  update rutinas set activa = false
  where cliente_id = (select id from cliente) and activa = true
  returning id
), nueva_rutina as (
  insert into rutinas (cliente_id, nombre, notas)
  select
    id,
    'Plan de entrenamiento - Fase de adaptación',
    'Cadencia 3-1: fase negativa controlada (~1,5 segundos) y fase concéntrica explosiva.'
  from cliente
  returning id
), dia1 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Día 1 - Pierna (Sesión 1)', 1 from nueva_rutina
  returning id
), dia2 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Día 2 - Empujes (Sesión 1)', 2 from nueva_rutina
  returning id
), dia3 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Día 3 - Tracción (Sesión 1)', 3 from nueva_rutina
  returning id
), dia4 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Día 1 - Pierna (Sesión 2)', 4 from nueva_rutina
  returning id
), dia5 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Día 2 - Empujes (Sesión 2)', 5 from nueva_rutina
  returning id
), dia6 as (
  insert into dias (rutina_id, nombre, orden)
  select id, 'Día 3 - Tracción (Sesión 2)', 6 from nueva_rutina
  returning id
), ej_dia1 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia1.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia1, (values
    ('Extensiones de cuádriceps', 3, '15', null::text, 1),
    ('Prensa inclinada', 4, '15', null::text, 2),
    ('Sentadilla libre', 3, '15', null::text, 3),
    ('Abductor (cerrando)', 3, '15', null::text, 4),
    ('Peso muerto piernas rectas con mancuerna', 3, '15', null::text, 5),
    ('Hip thrust', 3, '15', null::text, 6)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia2 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia2.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia2, (values
    ('Press banca inclinada multipower', 3, '15', null::text, 1),
    ('Press mancuernas plano', 3, '15', null::text, 2),
    ('Aperturas inclinadas con mancuerna', 3, '15', null::text, 3),
    ('Fondos lastrados en paralelas libres', 3, 'al fallo', null::text, 4),
    ('Elevaciones laterales mancuernas', 6, '15', null::text, 5),
    ('Press francés', 6, '15', null::text, 6)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia3 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia3.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia3, (values
    ('Pullover en polea (calentamiento)', 2, '15', 'Lentas.', 1),
    ('Dominadas agarre neutro', 3, 'al fallo', 'Para conservar tendones sin inflamación.', 2),
    ('Remo con mancuerna', 3, '15', null::text, 3),
    ('Remo apoyado en banco en polea', 3, '15', null::text, 4),
    ('Remo en máquina (unilateral)', 3, '15', null::text, 5),
    ('Remo con barra', 3, '15', null::text, 6),
    ('Peso muerto convencional', 2, '15', null::text, 7),
    ('Máquina Scott con barra Z', 6, '15', null::text, 8)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia4 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia4.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia4, (values
    ('Femoral sentado', 3, '15', null::text, 1),
    ('Femoral tumbado', 3, '15', null::text, 2),
    ('Femoral de pie a una pierna', 3, '15', null::text, 3),
    ('Peso muerto piernas rígidas', 3, '15', null::text, 4),
    ('Hip thrust', 3, '15', null::text, 5),
    ('Aductor (abriendo para glúteo)', 3, '15', null::text, 6),
    ('Extensiones de máquina', 3, '15', null::text, 7),
    ('Aductor', 3, '15', null::text, 8)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia5 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia5.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia5, (values
    ('Press banca plana multipower', 3, '15', null::text, 1),
    ('Press mancuernas inclinado', 3, '15', null::text, 2),
    ('Aperturas máquina inclinada', 3, '15', null::text, 3),
    ('Press militar con mancuerna', 3, '15', null::text, 4),
    ('Elevaciones laterales mancuernas', 3, '15', null::text, 5),
    ('Elevaciones frontales mancuerna de pie', 3, '15', null::text, 6),
    ('Extensiones de tríceps agarre V', 6, '15', null::text, 7)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia6 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia6.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia6, (values
    ('Pullover en polea (calentamiento)', 2, '15', 'Lentas.', 1),
    ('Dominadas agarre neutro', 3, 'al fallo', 'Para conservar tendones sin inflamación.', 2),
    ('Jalón agarre cerrado', 3, '15', null::text, 3),
    ('Jalón agarre abierto', 3, '15', null::text, 4),
    ('Remo en máquina (unilateral)', 3, '15', null::text, 5),
    ('Peso muerto convencional', 2, '15', null::text, 6),
    ('Máquina Scott con barra Z', 6, '15', null::text, 7)
  ) as v(nombre, series, reps, notas, orden)
  returning id
)
select 'rutina alfredo actualizada' as status;
