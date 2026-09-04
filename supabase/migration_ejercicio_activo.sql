-- ============================================================
-- Permite desactivar un ejercicio suelto dentro de una rutina
-- activa (en vez de borrarlo), para no perder el historial de
-- series ya registradas contra ese ejercicio (registros_series
-- tiene "on delete cascade" sobre ejercicio_id).
-- ============================================================

alter table ejercicios add column if not exists activo boolean not null default true;
