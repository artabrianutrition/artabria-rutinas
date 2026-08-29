-- ============================================================
-- Añade el registro de series descendentes (drop-set): hasta 5
-- repeticiones encadenadas en una sola serie (ej. "20-15-10-6").
-- Se guarda como texto separado por guiones en una columna nueva;
-- "reps" se deja intacto para las series normales.
-- ============================================================

alter table registros_series add column if not exists reps_descendente text;
