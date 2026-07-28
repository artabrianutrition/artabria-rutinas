-- ============================================================
-- Añade el párrafo de "Explicaciones" que faltaba en la rutina de
-- Laura Pallarés Álvarez (se quedó fuera cuando se dio de alta,
-- porque entonces todavía no existía la columna rutinas.notas).
-- ============================================================

update rutinas
set notas = 'EXPLICACIONES:
Empezamos un entrenamiento sencillo, con bajo volumen. La idea de estas dos primeras semanas no es que progreses en nada del entrenamiento; la idea es simple: acude al gimnasio todos los días que puedas, utiliza un peso ligero, y al acabar la serie con las repeticiones pautadas no tienes que sentir una gran fatiga. Si eso sucede, las agujetas serán demasiado grandes como para poder realizar una sesión al día siguiente.

Te he dividido el cuerpo en dos secciones, te explico por qué: al no hacer ejercicio nunca, si hacemos una rutina diaria posiblemente tengas las suficientes agujetas como para que te moleste entrenar todos los días, o incluso no puedas. Lo que prefiero que pase estos 15 días es que intentes coger la rutina de ir a diario al gimnasio; eso es más importante que cualquier esfuerzo mayor que puedas hacer puntualmente en una sesión. El gimnasio aporta cambios con la constancia, no con reventarse un par de días sueltos, así que vamos paso a paso a construir la casa con unos buenos cimientos para que aguanten mucho tiempo.

Como irás con Yoli, que te explique un poco cómo se hacen los ejercicios; aunque te he puesto ejercicios muy sencillos y guiados, no tendrás demasiado problema en hacerte con ellos.

Otro apunte: intenta desde el primer día hacer los ejercicios super controlados, contrayendo los músculos que estás entrenando, olvidándote del peso y aprendiendo bien el patrón que te obliga a hacer la máquina. Lo fundamental para poder tener una buena evolución es eso: sentir en cada repetición cómo el músculo se contrae y luego soporta el peso para volver a la posición inicial. El peso es algo que poco a poco irás subiendo al ganar fuerza, y de eso iremos hablando y pautándolo más adelante.'
where cliente_id = (select id from clientes where codigo = '8kyzbz')
  and activa = true;
