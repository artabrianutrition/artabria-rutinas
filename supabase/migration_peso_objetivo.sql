-- ============================================================
-- Añade un peso objetivo prefijado por el entrenador para un
-- ejercicio (opcional). Se usa como valor de partida en el campo
-- de peso la primera vez que el cliente registra ese ejercicio;
-- después, como con el resto, se sugiere lo último que levantó.
-- ============================================================

alter table ejercicios add column if not exists peso_objetivo numeric;
