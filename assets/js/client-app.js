import { supabase } from './supabaseClient.js';
import { escapeHtml, formatFecha, obtenerDetalleSesionHtml, obtenerProgresoEjercicioHtml } from './utils.js';

const app = document.getElementById('app');

let clienteActual = null;
let diasCache = [];

function showLoading() {
  app.className = '';
  app.innerHTML = `<div class="center-screen"><span class="spinner"></span></div>`;
}

function showError(mensaje) {
  app.className = '';
  app.innerHTML = `
    <div class="center-screen">
      <div class="card text-center" style="max-width:380px">
        <div class="brand" style="font-size:1.6rem">Artabria</div>
        <p class="mt-16">${escapeHtml(mensaje)}</p>
      </div>
    </div>
  `;
}

function primerNombre(nombreCompleto) {
  return (nombreCompleto || '').split(' ')[0];
}

function mostrarToast(mensaje, tipo = 'error') {
  let toast = document.getElementById('toast');
  if (!toast) {
    toast = document.createElement('div');
    toast.id = 'toast';
    toast.className = 'toast-fixed';
    document.body.appendChild(toast);
  }
  toast.className = `toast-fixed alert alert-${tipo}`;
  toast.textContent = mensaje;
  toast.style.display = 'block';
  clearTimeout(toast._timer);
  toast._timer = setTimeout(() => {
    toast.style.display = 'none';
  }, 3500);
}

async function init() {
  const partes = location.pathname.split('/').filter(Boolean);
  const codigo = partes[1];
  if (!codigo) {
    showError('Enlace no válido. Pide a tu entrenador que te reenvíe tu enlace.');
    return;
  }

  showLoading();
  try {
    const { data: { session } } = await supabase.auth.getSession();
    if (!session) {
      const { error: anonError } = await supabase.auth.signInAnonymously();
      if (anonError) throw anonError;
    }

    const { data: cliente, error: claimError } = await supabase.rpc('claim_cliente', { p_codigo: codigo });
    if (claimError) throw claimError;

    clienteActual = cliente;
    await renderDiasView();
  } catch (e) {
    console.error(e);
    showError('Este enlace no es válido o tu cuenta está inactiva. Contacta con tu entrenador.');
  }
}

async function renderDiasView() {
  showLoading();
  const { data: rutina } = await supabase
    .from('rutinas')
    .select('*')
    .eq('cliente_id', clienteActual.id)
    .eq('activa', true)
    .order('created_at', { ascending: false })
    .limit(1)
    .maybeSingle();

  let dias = [];
  if (rutina) {
    const { data } = await supabase
      .from('dias')
      .select('*')
      .eq('rutina_id', rutina.id)
      .order('orden');
    dias = data || [];
  }
  diasCache = dias;
  renderDias(rutina, dias);
}

function renderDias(rutina, dias) {
  app.className = '';
  app.innerHTML = `
    <div class="hero-logo-wrap">
      <img src="/assets/img/logo.png" alt="Artabria" class="hero-logo">
    </div>
    <div class="page hero-page">
      <h1>Hola, ${escapeHtml(primerNombre(clienteActual.nombre))}</h1>
      <p class="muted">${rutina ? escapeHtml(rutina.nombre) : 'Aún no tienes una rutina asignada'}</p>
      ${rutina?.notas ? `<div class="card mt-16"><h3 style="margin:0 0 8px">Notas de la rutina</h3><p class="hint" style="white-space:pre-line">${escapeHtml(rutina.notas)}</p></div>` : ''}
      <div class="stack mt-16" id="lista-dias"></div>
      <button class="btn btn-ghost btn-block mt-16" id="btn-ver-historial">Ver historial</button>
    </div>
  `;

  document.getElementById('btn-ver-historial').addEventListener('click', renderHistorial);

  const cont = document.getElementById('lista-dias');
  if (!dias.length) {
    cont.innerHTML = `<div class="empty-state">Tu entrenador todavía no te ha asignado ejercicios. Vuelve pronto.</div>`;
    return;
  }

  dias.forEach((d) => {
    const el = document.createElement('div');
    el.className = 'card card-link';
    el.innerHTML = `
      <div class="row">
        <h3 style="margin:0">${escapeHtml(d.nombre)}</h3>
        <span class="muted">→</span>
      </div>
    `;
    el.addEventListener('click', () => abrirDia(d.id));
    cont.appendChild(el);
  });
}

async function abrirDia(diaId) {
  showLoading();
  const dia = diasCache.find((d) => d.id === diaId);

  const { data: ejercicios } = await supabase
    .from('ejercicios')
    .select('*')
    .eq('dia_id', diaId)
    .order('orden');

  const { data: abiertas } = await supabase
    .from('sesiones')
    .select('*')
    .eq('dia_id', diaId)
    .eq('cliente_id', clienteActual.id)
    .eq('completada', false)
    .order('fecha', { ascending: false })
    .limit(1);

  let sesion = abiertas && abiertas[0];
  if (!sesion) {
    const { data: nueva, error } = await supabase
      .from('sesiones')
      .insert({ dia_id: diaId, cliente_id: clienteActual.id })
      .select()
      .single();
    if (error) {
      showError('No se pudo iniciar la sesión. Inténtalo de nuevo.');
      return;
    }
    sesion = nueva;
  }

  const { data: anteriores } = await supabase
    .from('sesiones')
    .select('id, fecha')
    .eq('dia_id', diaId)
    .eq('cliente_id', clienteActual.id)
    .eq('completada', true)
    .neq('id', sesion.id)
    .order('fecha', { ascending: false })
    .limit(1);

  const prevMap = {};
  if (anteriores && anteriores[0]) {
    const { data: regs } = await supabase
      .from('registros_series')
      .select('*')
      .eq('sesion_id', anteriores[0].id);
    (regs || []).forEach((r) => {
      prevMap[`${r.ejercicio_id}_${r.numero_serie}`] = r;
    });
  }

  const { data: actuales } = await supabase
    .from('registros_series')
    .select('*')
    .eq('sesion_id', sesion.id);
  const curMap = {};
  (actuales || []).forEach((r) => {
    curMap[`${r.ejercicio_id}_${r.numero_serie}`] = r;
  });

  renderSesion(dia, ejercicios || [], sesion, prevMap, curMap);
}

function opcionesRir(valorActual) {
  const opciones = [
    ['', 'RIR'],
    ['fallo', 'Fallo'],
    ['0', '0'],
    ['1', '1'],
    ['2', '2'],
    ['3', '3'],
    ['4', '4'],
    ['5', '5'],
  ];
  return opciones
    .map(([val, label]) => `<option value="${val}" ${valorActual === val ? 'selected' : ''}>${label}</option>`)
    .join('');
}

function renderEjercicioCard(ej, prevMap, curMap) {
  const filas = Array.from({ length: ej.series })
    .map((_, i) => {
      const n = i + 1;
      const prev = prevMap[`${ej.id}_${n}`];
      const cur = curMap[`${ej.id}_${n}`];
      // Si aún no hay nada guardado en esta sesión, se parte del peso/reps/RIR de
      // la sesión anterior (editable) en vez de dejar los campos vacíos.
      const pesoValue = cur?.peso ?? prev?.peso ?? '';
      const repsValue = cur?.reps ?? prev?.reps ?? '';
      const rirValue = cur?.rir ?? prev?.rir ?? '';
      return `
        <div class="input-set" data-ejercicio="${ej.id}" data-serie="${n}">
          <span class="muted" style="width:16px;flex-shrink:0">${n}</span>
          <input type="number" step="0.5" inputmode="decimal" class="input-num campo-peso" placeholder="kg" value="${pesoValue}">
          <input type="number" inputmode="numeric" class="input-num campo-reps" placeholder="reps" value="${repsValue}">
          <select class="input-num campo-rir">${opcionesRir(rirValue)}</select>
          <input type="checkbox" class="checkbox-big campo-completada" ${cur?.completada ? 'checked' : ''}>
        </div>`;
    })
    .join('');

  return `
    <div class="card">
      <div class="row">
        <h3 style="margin:0">${escapeHtml(ej.nombre)}</h3>
        <span class="badge badge-gold">${ej.series} × ${escapeHtml(ej.reps_objetivo)}</span>
      </div>
      ${ej.notas ? `<p class="hint">${escapeHtml(ej.notas)}</p>` : ''}
      <div class="stack mt-16">${filas}</div>
      <button class="btn btn-ghost btn-sm mt-16" data-accion="ver-progreso" data-ejercicio="${ej.id}">Ver progreso</button>
      <div class="stack mt-8 oculto" data-progreso="${ej.id}"></div>
    </div>`;
}

const progresoCache = {};

async function toggleProgreso(ejercicioId, btn) {
  const card = btn.closest('.card');
  const slot = card.querySelector(`[data-progreso="${ejercicioId}"]`);
  const estabaOculto = slot.classList.contains('oculto');

  if (!estabaOculto) {
    slot.classList.add('oculto');
    btn.textContent = 'Ver progreso';
    return;
  }

  slot.classList.remove('oculto');
  btn.textContent = 'Ocultar progreso';

  if (progresoCache[ejercicioId]) {
    slot.innerHTML = progresoCache[ejercicioId];
    return;
  }

  slot.innerHTML = `<div class="text-center"><span class="spinner"></span></div>`;
  const html = await obtenerProgresoEjercicioHtml(ejercicioId);
  progresoCache[ejercicioId] = html;
  slot.innerHTML = html;
}

function renderSesion(dia, ejercicios, sesion, prevMap, curMap) {
  app.className = 'page';
  app.innerHTML = `
    <div class="topbar">
      <button class="btn btn-ghost btn-sm" id="btn-volver">← Volver</button>
      <span class="badge badge-gold">${formatFecha(sesion.fecha)}</span>
    </div>
    <h1>${escapeHtml(dia.nombre)}</h1>
    ${dia.notas ? `<div class="card mb-16"><p class="hint" style="white-space:pre-line">${escapeHtml(dia.notas)}</p></div>` : ''}
    <div class="stack" id="lista-ejercicios"></div>
    <div class="card mt-16">
      <h3 style="margin:0 0 12px">Cómo ha ido la sesión</h3>
      <div class="field">
        <label>Fatiga (1 = muy poca, 10 = extrema)</label>
        <select id="campo-fatiga">
          <option value="">Sin marcar</option>
          ${Array.from({ length: 10 }, (_, i) => i + 1)
            .map((n) => `<option value="${n}" ${sesion.fatiga === n ? 'selected' : ''}>${n}</option>`)
            .join('')}
        </select>
      </div>
      <div class="field" style="margin-bottom:0">
        <label>Anotaciones (opcional)</label>
        <textarea id="campo-notas-sesion" rows="3" placeholder="¿Cómo te has sentido? ¿Algo que quieras comentar?">${escapeHtml(sesion.notas || '')}</textarea>
      </div>
    </div>
    <div class="bottom-bar">
      <div class="bottom-bar-inner">
        <button class="btn btn-primary btn-block" id="btn-terminar">Terminar sesión</button>
      </div>
    </div>
  `;

  const cont = document.getElementById('lista-ejercicios');
  ejercicios.forEach((ej) => {
    cont.insertAdjacentHTML('beforeend', renderEjercicioCard(ej, prevMap, curMap));
  });

  document.querySelectorAll('.input-set').forEach((row) => {
    const ejercicioId = row.dataset.ejercicio;
    const numeroSerie = Number(row.dataset.serie);
    const guardar = () => guardarSerie(sesion.id, ejercicioId, numeroSerie, row);
    row.querySelector('.campo-peso').addEventListener('blur', guardar);
    row.querySelector('.campo-reps').addEventListener('blur', guardar);
    row.querySelector('.campo-rir').addEventListener('change', guardar);
    row.querySelector('.campo-completada').addEventListener('change', guardar);
  });

  document.querySelectorAll('[data-accion="ver-progreso"]').forEach((btn) => {
    btn.addEventListener('click', () => toggleProgreso(btn.dataset.ejercicio, btn));
  });

  document.getElementById('campo-fatiga').addEventListener('change', (e) => {
    guardarSesionMeta(sesion.id, { fatiga: e.target.value === '' ? null : Number(e.target.value) });
  });
  document.getElementById('campo-notas-sesion').addEventListener('blur', (e) => {
    guardarSesionMeta(sesion.id, { notas: e.target.value.trim() || null });
  });

  document.getElementById('btn-volver').addEventListener('click', renderDiasView);
  document.getElementById('btn-terminar').addEventListener('click', () => terminarSesion(sesion.id));
}

async function guardarSesionMeta(sesionId, cambios) {
  const { error } = await supabase.from('sesiones').update(cambios).eq('id', sesionId);
  if (error) {
    console.error(error);
    mostrarToast('No se pudo guardar. Comprueba tu conexión e inténtalo de nuevo.');
  }
}

async function guardarSerie(sesionId, ejercicioId, numeroSerie, row) {
  const pesoVal = row.querySelector('.campo-peso').value;
  const repsVal = row.querySelector('.campo-reps').value;
  const rirVal = row.querySelector('.campo-rir').value;
  const completada = row.querySelector('.campo-completada').checked;

  const { error } = await supabase.from('registros_series').upsert(
    {
      sesion_id: sesionId,
      ejercicio_id: ejercicioId,
      numero_serie: numeroSerie,
      peso: pesoVal === '' ? null : Number(pesoVal),
      reps: repsVal === '' ? null : Number(repsVal),
      rir: rirVal === '' ? null : rirVal,
      completada,
    },
    { onConflict: 'sesion_id,ejercicio_id,numero_serie' }
  );

  if (error) {
    console.error(error);
    row.classList.add('input-set-error');
    mostrarToast('No se pudo guardar esta serie. Comprueba tu conexión e inténtalo de nuevo.');
  } else {
    row.classList.remove('input-set-error');
  }
}

async function terminarSesion(sesionId) {
  const btn = document.getElementById('btn-terminar');
  const textoOriginal = btn.textContent;
  btn.disabled = true;
  btn.textContent = 'Guardando...';

  const { error } = await supabase.from('sesiones').update({ completada: true }).eq('id', sesionId);

  if (error) {
    console.error(error);
    mostrarToast('No se pudo guardar la sesión. Comprueba tu conexión e inténtalo de nuevo.');
    btn.disabled = false;
    btn.textContent = textoOriginal;
    return;
  }

  mostrarToast('Sesión guardada.', 'success');
  await renderDiasView();
}

const detalleHistorialCache = {};

async function renderHistorial() {
  showLoading();
  const { data: sesiones, error } = await supabase
    .from('sesiones')
    .select('id, fecha, dias(nombre)')
    .eq('cliente_id', clienteActual.id)
    .eq('completada', true)
    .order('fecha', { ascending: false })
    .limit(30);

  app.className = 'page';
  app.innerHTML = `
    <div class="topbar">
      <button class="btn btn-ghost btn-sm" id="btn-volver-historial">← Volver</button>
    </div>
    <h1>Historial</h1>
    <div class="stack mt-16" id="lista-historial"></div>
  `;
  document.getElementById('btn-volver-historial').addEventListener('click', renderDiasView);

  const cont = document.getElementById('lista-historial');

  if (error) {
    cont.innerHTML = `<div class="alert alert-error">${escapeHtml(error.message)}</div>`;
    return;
  }
  if (!sesiones || !sesiones.length) {
    cont.innerHTML = `<div class="empty-state">Todavía no tienes sesiones terminadas.</div>`;
    return;
  }

  sesiones.forEach((s) => {
    const el = document.createElement('div');
    el.className = 'card';
    el.innerHTML = `
      <div class="row" style="cursor:pointer">
        <div>
          <strong>${escapeHtml(s.dias?.nombre || 'Sesión')}</strong>
          <div class="faint">${formatFecha(s.fecha)}</div>
        </div>
        <span class="muted toggle-icon">▾</span>
      </div>
      <div class="stack mt-16 oculto" data-detalle="${s.id}"></div>
    `;
    el.querySelector('.row').addEventListener('click', () => toggleDetalleHistorial(s.id, el));
    cont.appendChild(el);
  });
}

async function toggleDetalleHistorial(sesionId, cardEl) {
  const slot = cardEl.querySelector(`[data-detalle="${sesionId}"]`);
  const icon = cardEl.querySelector('.toggle-icon');
  const estabaOculto = slot.classList.contains('oculto');

  if (!estabaOculto) {
    slot.classList.add('oculto');
    icon.textContent = '▾';
    return;
  }

  slot.classList.remove('oculto');
  icon.textContent = '▴';

  if (detalleHistorialCache[sesionId]) {
    slot.innerHTML = detalleHistorialCache[sesionId];
    return;
  }

  slot.innerHTML = `<div class="text-center"><span class="spinner"></span></div>`;
  const html = await obtenerDetalleSesionHtml(sesionId);
  detalleHistorialCache[sesionId] = html;
  slot.innerHTML = html;
}

init();
