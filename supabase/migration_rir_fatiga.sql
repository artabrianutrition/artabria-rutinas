-- ============================================================
-- Añade RIR por serie, y fatiga + anotaciones por sesión.
-- ============================================================

alter table sesiones add column if not exists fatiga smallint;
alter table sesiones add column if not exists notas text;
alter table registros_series add column if not exists rir text;
