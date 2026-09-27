-- ============================================================
-- Sustituye la rutina activa de Jose Moreno (af93my) por un PPL
-- de 3 días, sin notas (antes tenía "PPL · 2 bloques", 6 días con
-- indicaciones generales). La rutina anterior se desactiva (no se
-- borra), para conservar su historial de sesiones.
-- ============================================================

with cliente as (
  select id from clientes where codigo = 'af93my'
), desactivar as (
  update rutinas set activa = false
  where cliente_id = (select id from cliente) and activa = true
  returning id
), nueva_rutina as (
  insert into rutinas (cliente_id, nombre)
  select id, 'PPL (3 días)' from cliente
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
    ('Femoral sentado', 3, '20', null::text, 1),
    ('Femoral tumbado', 3, '20', null::text, 2),
    ('Prensa inclinada', 3, '8, 10, 12', null::text, 3),
    ('Sentadilla hack', 3, '15', null::text, 4),
    ('Extensiones de máquina', 3, '20', null::text, 5),
    ('Aductor', 3, '20', null::text, 6)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia2 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia2.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia2, (values
    ('Pullover con barra en polea (calentamiento)', 2, '15', 'Lentas y apretando.', 1),
    ('Jalón agarre cerrado', 3, '15', null::text, 2),
    ('Máquina jalón discos unilateral', 2, '15', null::text, 3),
    ('Remo con mancuerna', 3, '15', null::text, 4),
    ('Remo máquina sentado (la de discos tipo Dorian)', 3, '15', null::text, 5),
    ('Peso muerto convencional', 3, '6, 8, 10', null::text, 6),
    ('Máquina scoot cable con barra Z', 5, '15', null::text, 7)
  ) as v(nombre, series, reps, notas, orden)
  returning id
), ej_dia3 as (
  insert into ejercicios (dia_id, nombre, series, reps_objetivo, notas, orden)
  select dia3.id, v.nombre, v.series, v.reps, v.notas, v.orden
  from dia3, (values
    ('Press banca plana', 3, '6, 8, 10', null::text, 1),
    ('Press multipower inclinado', 3, '15', null::text, 2),
    ('Aperturas con máquina inclinada disco', 3, '15', null::text, 3),
    ('Elevaciones laterales mancuernas', 3, '15', null::text, 4),
    ('Elevaciones laterales máquina de pie', 3, '15', null::text, 5),
    ('Extensiones de tríceps agarre V', 5, '15', null::text, 6)
  ) as v(nombre, series, reps, notas, orden)
  returning id
)
select 'rutina jose moreno actualizada (ppl 3 dias)' as status;
