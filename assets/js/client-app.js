import { supabase } from './supabaseClient.js';
import { escapeHtml, formatFecha } from './utils.js';

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
  app.className = 'page';
  app.innerHTML = `
    <div class="topbar">
      <div class="brand">Artabria</div>
    </div>
    <h1>Hola, ${escapeHtml(primerNombre(clienteActual.nombre))}</h1>
    <p class="muted">${rutina ? escapeHtml(rutina.nombre) : 'Aún no tienes una rutina asignada'}</p>
    <div class="stack mt-16" id="lista-dias"></div>
  `;

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

function renderEjercicioCard(ej, prevMap, curMap) {
  const filas = Array.from({ length: ej.series })
    .map((_, i) => {
      const n = i + 1;
      const prev = prevMap[`${ej.id}_${n}`];
      const cur = curMap[`${ej.id}_${n}`];
      const placeholderPeso = prev && prev.peso != null ? `${prev.peso} kg` : 'kg';
      const placeholderReps = prev && prev.reps != null ? `${prev.reps} reps` : 'reps';
      return `
        <div class="input-set" data-ejercicio="${ej.id}" data-serie="${n}">
          <span class="muted" style="width:16px;flex-shrink:0">${n}</span>
          <input type="number" step="0.5" inputmode="decimal" class="input-num campo-peso" placeholder="${placeholderPeso}" value="${cur?.peso ?? ''}">
          <input type="number" inputmode="numeric" class="input-num campo-reps" placeholder="${placeholderReps}" value="${cur?.reps ?? ''}">
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
    </div>`;
}

function renderSesion(dia, ejercicios, sesion, prevMap, curMap) {
  app.className = 'page';
  app.innerHTML = `
    <div class="topbar">
      <button class="btn btn-ghost btn-sm" id="btn-volver">← Volver</button>
      <span class="badge badge-gold">${formatFecha(sesion.fecha)}</span>
    </div>
    <h1>${escapeHtml(dia.nombre)}</h1>
    <div class="stack" id="lista-ejercicios"></div>
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
    row.querySelector('.campo-completada').addEventListener('change', guardar);
  });

  document.getElementById('btn-volver').addEventListener('click', renderDiasView);
  document.getElementById('btn-terminar').addEventListener('click', () => terminarSesion(sesion.id));
}

async function guardarSerie(sesionId, ejercicioId, numeroSerie, row) {
  const pesoVal = row.querySelector('.campo-peso').value;
  const repsVal = row.querySelector('.campo-reps').value;
  const completada = row.querySelector('.campo-completada').checked;

  await supabase.from('registros_series').upsert(
    {
      sesion_id: sesionId,
      ejercicio_id: ejercicioId,
      numero_serie: numeroSerie,
      peso: pesoVal === '' ? null : Number(pesoVal),
      reps: repsVal === '' ? null : Number(repsVal),
      completada,
    },
    { onConflict: 'sesion_id,ejercicio_id,numero_serie' }
  );
}

async function terminarSesion(sesionId) {
  await supabase.from('sesiones').update({ completada: true }).eq('id', sesionId);
  await renderDiasView();
}

init();
