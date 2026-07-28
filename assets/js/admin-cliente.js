import { supabase } from './supabaseClient.js';
import { requireAdmin, logout } from './admin-guard.js';
import { escapeHtml, qs, linkCliente, formatFechaHora, obtenerDetalleSesionHtml, obtenerProgresoEjercicioHtml } from './utils.js';

const clienteId = qs('id');
if (!clienteId) {
  location.href = '/admin/index.html';
}

await requireAdmin();

document.getElementById('btn-logout').addEventListener('click', logout);
document.getElementById('btn-volver').addEventListener('click', () => {
  location.href = '/admin/index.html';
});

const state = { cliente: null, rutina: null, dias: [] };

async function cargarTodo() {
  const { data: cliente, error } = await supabase.from('clientes').select('*').eq('id', clienteId).single();
  if (error || !cliente) {
    document.getElementById('cabecera').innerHTML = `<div class="alert alert-error">No se encontró el cliente.</div>`;
    return;
  }
  state.cliente = cliente;

  const { data: rutina } = await supabase
    .from('rutinas')
    .select('*')
    .eq('cliente_id', clienteId)
    .eq('activa', true)
    .order('created_at', { ascending: false })
    .limit(1)
    .maybeSingle();
  state.rutina = rutina;

  state.dias = [];
  if (rutina) {
    const { data: dias } = await supabase.from('dias').select('*').eq('rutina_id', rutina.id).order('orden');
    for (const dia of dias || []) {
      const { data: ejercicios } = await supabase
        .from('ejercicios')
        .select('*')
        .eq('dia_id', dia.id)
        .order('orden');
      dia.ejercicios = ejercicios || [];
    }
    state.dias = dias || [];
  }

  render();
}

function render() {
  renderHeader();
  renderRutina();
}

function renderHeader() {
  const c = state.cliente;
  document.getElementById('cabecera').innerHTML = `
    <div class="row">
      <h1 style="margin:0">${escapeHtml(c.nombre)}</h1>
      <div class="flex gap-8">
        <button class="btn btn-ghost btn-sm" data-accion="renombrar-cliente">✎ Renombrar</button>
        <label class="switch">
          <input type="checkbox" id="toggle-activo" ${c.activo ? 'checked' : ''}>
          <span class="slider"></span>
        </label>
      </div>
    </div>
    <div class="copy-link mt-8">
      <span class="grow">${linkCliente(c.codigo)}</span>
      <button class="btn btn-ghost btn-sm" id="btn-copiar">Copiar</button>
    </div>
  `;
  document.getElementById('toggle-activo').addEventListener('change', async (e) => {
    await supabase.from('clientes').update({ activo: e.target.checked }).eq('id', clienteId);
  });
  document.getElementById('btn-copiar').addEventListener('click', async () => {
    await navigator.clipboard.writeText(linkCliente(c.codigo));
    const btn = document.getElementById('btn-copiar');
    btn.textContent = 'Copiado';
    setTimeout(() => (btn.textContent = 'Copiar'), 1500);
  });
}

function renderRutina() {
  const cont = document.getElementById('contenido-rutina');
  if (!state.rutina) {
    cont.innerHTML = `
      <div class="empty-state">
        <p>Este cliente todavía no tiene una rutina.</p>
        <button class="btn btn-primary" data-accion="crear-rutina">Crear rutina</button>
      </div>
    `;
    return;
  }

  const notasRutinaHtml = `
    <div class="card">
      <div class="row">
        <h3 style="margin:0">Notas de la rutina</h3>
        <button class="btn btn-ghost btn-sm" data-accion="editar-notas-rutina">✎ Editar</button>
      </div>
      ${state.rutina.notas ? `<p class="hint mt-8" style="white-space:pre-line">${escapeHtml(state.rutina.notas)}</p>` : '<p class="hint mt-8">Sin notas.</p>'}
      <div data-form-notas-rutina></div>
    </div>
  `;

  const diasHtml = state.dias.map((dia, idx) => renderDiaCard(dia, idx, state.dias.length)).join('');
  cont.innerHTML = `
    ${notasRutinaHtml}
    <div class="stack">${diasHtml}</div>
    <button class="btn btn-outline btn-block mt-16" data-accion="nuevo-dia">+ Añadir día</button>
  `;
}

function renderDiaCard(dia, idx, total) {
  const filas = dia.ejercicios
    .map((ej, i) => renderEjercicioRow(dia.id, ej, i, dia.ejercicios.length))
    .join('');
  return `
    <div class="card">
      <div class="row">
        <h3 style="margin:0">${escapeHtml(dia.nombre)}</h3>
        <div class="flex gap-8">
          <button class="btn btn-icon btn-ghost btn-sm" data-accion="subir-dia" data-id="${dia.id}" ${idx === 0 ? 'disabled' : ''}>↑</button>
          <button class="btn btn-icon btn-ghost btn-sm" data-accion="bajar-dia" data-id="${dia.id}" ${idx === total - 1 ? 'disabled' : ''}>↓</button>
          <button class="btn btn-icon btn-ghost btn-sm" data-accion="renombrar-dia" data-id="${dia.id}" data-nombre="${escapeHtml(dia.nombre)}">✎</button>
          <button class="btn btn-icon btn-ghost btn-sm" data-accion="editar-notas-dia" data-id="${dia.id}" title="Notas del día">📝</button>
          <button class="btn btn-icon btn-danger btn-sm" data-accion="eliminar-dia" data-id="${dia.id}">✕</button>
        </div>
      </div>
      ${dia.notas ? `<p class="hint mt-8" style="white-space:pre-line">${escapeHtml(dia.notas)}</p>` : ''}
      <div data-form-notas-dia="${dia.id}"></div>
      <div class="stack mt-16">${filas || '<p class="hint">Sin ejercicios todavía.</p>'}</div>
      <button class="btn btn-outline btn-sm mt-16" data-accion="nuevo-ejercicio" data-dia="${dia.id}">+ Ejercicio</button>
      <div data-form-ejercicio="${dia.id}"></div>
    </div>
  `;
}

function formNotasHTML(valorActual) {
  return `
    <form class="card mt-8" data-form-notas-real="1">
      <div class="field">
        <label>Notas</label>
        <textarea name="notas" rows="6">${escapeHtml(valorActual || '')}</textarea>
      </div>
      <div class="flex gap-8">
        <button type="submit" class="btn btn-primary grow">Guardar</button>
        <button type="button" class="btn btn-ghost" data-accion="cancelar-notas">Cancelar</button>
      </div>
    </form>
  `;
}

function renderEjercicioRow(diaId, ej, idx, total) {
  return `
    <div class="card card-tight">
      <div class="row">
        <div>
          <strong>${escapeHtml(ej.nombre)}</strong>
          <div class="faint">${ej.series} × ${escapeHtml(ej.reps_objetivo)}${ej.notas ? ' · ' + escapeHtml(ej.notas) : ''}</div>
        </div>
        <div class="flex gap-8">
          <button class="btn btn-icon btn-ghost btn-sm" data-accion="subir-ejercicio" data-dia="${diaId}" data-id="${ej.id}" ${idx === 0 ? 'disabled' : ''}>↑</button>
          <button class="btn btn-icon btn-ghost btn-sm" data-accion="bajar-ejercicio" data-dia="${diaId}" data-id="${ej.id}" ${idx === total - 1 ? 'disabled' : ''}>↓</button>
          <button class="btn btn-icon btn-ghost btn-sm" data-accion="ver-progreso" data-id="${ej.id}" title="Progreso">📈</button>
          <button class="btn btn-icon btn-ghost btn-sm" data-accion="editar-ejercicio" data-dia="${diaId}" data-id="${ej.id}">✎</button>
          <button class="btn btn-icon btn-danger btn-sm" data-accion="eliminar-ejercicio" data-id="${ej.id}">✕</button>
        </div>
      </div>
      <div class="stack mt-8 oculto" data-progreso-ejercicio="${ej.id}"></div>
    </div>
  `;
}

const progresoCache = {};

async function toggleProgresoEjercicio(ejercicioId, btn) {
  const card = btn.closest('.card');
  const slot = card.querySelector(`[data-progreso-ejercicio="${ejercicioId}"]`);
  const estabaOculto = slot.classList.contains('oculto');

  if (!estabaOculto) {
    slot.classList.add('oculto');
    return;
  }

  slot.classList.remove('oculto');

  if (progresoCache[ejercicioId]) {
    slot.innerHTML = progresoCache[ejercicioId];
    return;
  }

  slot.innerHTML = `<div class="text-center"><span class="spinner"></span></div>`;
  const html = await obtenerProgresoEjercicioHtml(ejercicioId);
  progresoCache[ejercicioId] = html;
  slot.innerHTML = html;
}

function formEjercicioHTML(ej) {
  return `
    <form class="card mt-8" data-form-ejercicio-real="1">
      <div class="field">
        <label>Nombre del ejercicio</label>
        <input type="text" name="nombre" required value="${escapeHtml(ej?.nombre || '')}">
      </div>
      <div class="field-row">
        <div class="field">
          <label>Series</label>
          <input type="number" name="series" min="1" required value="${ej?.series ?? ''}">
        </div>
        <div class="field">
          <label>Reps objetivo</label>
          <input type="text" name="reps_objetivo" placeholder="8-10, al fallo..." required value="${escapeHtml(ej?.reps_objetivo || '')}">
        </div>
      </div>
      <div class="field">
        <label>Notas (opcional)</label>
        <textarea name="notas" rows="2">${escapeHtml(ej?.notas || '')}</textarea>
      </div>
      <div class="flex gap-8">
        <button type="submit" class="btn btn-primary grow">Guardar</button>
        <button type="button" class="btn btn-ghost" data-accion="cancelar-ejercicio">Cancelar</button>
      </div>
    </form>
  `;
}

function mostrarFormEjercicio(diaId, ej) {
  document.querySelectorAll('[data-form-ejercicio]').forEach((el) => (el.innerHTML = ''));
  const slot = document.querySelector(`[data-form-ejercicio="${diaId}"]`);
  if (!slot) return;
  slot.innerHTML = formEjercicioHTML(ej);
  const form = slot.querySelector('form');
  form.dataset.diaId = diaId;
  if (ej) form.dataset.ejercicioId = ej.id;
  slot.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
}

const detalleHistorialCache = {};

async function cargarHistorial() {
  const cont = document.getElementById('contenido-historial');
  const { data: sesiones, error } = await supabase
    .from('sesiones')
    .select('id, fecha, completada, dias(nombre)')
    .eq('cliente_id', clienteId)
    .order('fecha', { ascending: false })
    .limit(30);

  if (error) {
    cont.innerHTML = `<div class="alert alert-error">${escapeHtml(error.message)}</div>`;
    return;
  }
  if (!sesiones.length) {
    cont.innerHTML = `<div class="empty-state">Este cliente todavía no ha registrado ninguna sesión.</div>`;
    return;
  }

  cont.innerHTML = '<div class="stack" id="lista-historial"></div>';
  const lista = document.getElementById('lista-historial');
  sesiones.forEach((s) => {
    const el = document.createElement('div');
    el.className = 'card';
    el.innerHTML = `
      <div class="row" style="cursor:pointer" data-accion="toggle-historial" data-id="${s.id}">
        <div>
          <strong>${escapeHtml(s.dias?.nombre || 'Sesión')}</strong>
          <div class="faint">${formatFechaHora(s.fecha)}</div>
        </div>
        <span class="badge ${s.completada ? 'badge-success' : ''}">${s.completada ? 'Completada' : 'Sin terminar'}</span>
      </div>
      <div class="stack mt-16 oculto" data-detalle-historial="${s.id}"></div>
    `;
    lista.appendChild(el);
  });
}

async function toggleDetalleHistorial(sesionId, filaEl) {
  const card = filaEl.closest('.card');
  const slot = card.querySelector(`[data-detalle-historial="${sesionId}"]`);
  const estabaOculto = slot.classList.contains('oculto');

  if (!estabaOculto) {
    slot.classList.add('oculto');
    return;
  }

  slot.classList.remove('oculto');

  if (detalleHistorialCache[sesionId]) {
    slot.innerHTML = detalleHistorialCache[sesionId];
    return;
  }

  slot.innerHTML = `<div class="text-center"><span class="spinner"></span></div>`;
  const html = await obtenerDetalleSesionHtml(sesionId);
  detalleHistorialCache[sesionId] = html;
  slot.innerHTML = html;
}

async function moverDia(diaId, dir) {
  const idx = state.dias.findIndex((d) => d.id === diaId);
  const otherIdx = idx + dir;
  if (otherIdx < 0 || otherIdx >= state.dias.length) return;
  const a = state.dias[idx];
  const b = state.dias[otherIdx];
  await supabase.from('dias').update({ orden: b.orden }).eq('id', a.id);
  await supabase.from('dias').update({ orden: a.orden }).eq('id', b.id);
  await cargarTodo();
}

async function moverEjercicio(diaId, ejercicioId, dir) {
  const dia = state.dias.find((d) => d.id === diaId);
  const idx = dia.ejercicios.findIndex((x) => x.id === ejercicioId);
  const otherIdx = idx + dir;
  if (otherIdx < 0 || otherIdx >= dia.ejercicios.length) return;
  const a = dia.ejercicios[idx];
  const b = dia.ejercicios[otherIdx];
  await supabase.from('ejercicios').update({ orden: b.orden }).eq('id', a.id);
  await supabase.from('ejercicios').update({ orden: a.orden }).eq('id', b.id);
  await cargarTodo();
}

document.addEventListener('click', async (e) => {
  const btn = e.target.closest('[data-accion]');
  if (!btn) return;
  const accion = btn.dataset.accion;

  if (accion === 'crear-rutina') {
    await supabase.from('rutinas').insert({ cliente_id: clienteId, nombre: 'Rutina' });
    await cargarTodo();
  }

  if (accion === 'nuevo-dia') {
    const nombre = prompt('Nombre del nuevo día (ej. "Día 3 - Full body")');
    if (!nombre) return;
    const maxOrden = state.dias.reduce((m, d) => Math.max(m, d.orden), 0);
    await supabase.from('dias').insert({ rutina_id: state.rutina.id, nombre, orden: maxOrden + 1 });
    await cargarTodo();
  }

  if (accion === 'renombrar-dia') {
    const nombre = prompt('Nuevo nombre del día', btn.dataset.nombre);
    if (!nombre) return;
    await supabase.from('dias').update({ nombre }).eq('id', btn.dataset.id);
    await cargarTodo();
  }

  if (accion === 'eliminar-dia') {
    if (!confirm('¿Eliminar este día y todos sus ejercicios? Esta acción no se puede deshacer.')) return;
    await supabase.from('dias').delete().eq('id', btn.dataset.id);
    await cargarTodo();
  }

  if (accion === 'subir-dia' || accion === 'bajar-dia') {
    await moverDia(btn.dataset.id, accion === 'subir-dia' ? -1 : 1);
  }

  if (accion === 'nuevo-ejercicio') {
    mostrarFormEjercicio(btn.dataset.dia, null);
  }

  if (accion === 'editar-ejercicio') {
    const dia = state.dias.find((d) => d.id === btn.dataset.dia);
    const ej = dia?.ejercicios.find((x) => x.id === btn.dataset.id);
    mostrarFormEjercicio(btn.dataset.dia, ej);
  }

  if (accion === 'cancelar-ejercicio') {
    render();
  }

  if (accion === 'eliminar-ejercicio') {
    if (!confirm('¿Eliminar este ejercicio?')) return;
    await supabase.from('ejercicios').delete().eq('id', btn.dataset.id);
    await cargarTodo();
  }

  if (accion === 'subir-ejercicio' || accion === 'bajar-ejercicio') {
    await moverEjercicio(btn.dataset.dia, btn.dataset.id, accion === 'subir-ejercicio' ? -1 : 1);
  }

  if (accion === 'renombrar-cliente') {
    const nombre = prompt('Nombre del cliente', state.cliente.nombre);
    if (!nombre) return;
    await supabase.from('clientes').update({ nombre }).eq('id', clienteId);
    await cargarTodo();
  }

  if (accion === 'toggle-historial') {
    await toggleDetalleHistorial(btn.dataset.id, btn);
  }

  if (accion === 'ver-progreso') {
    await toggleProgresoEjercicio(btn.dataset.id, btn);
  }

  if (accion === 'editar-notas-rutina') {
    document.querySelectorAll('[data-form-notas-dia], [data-form-notas-rutina]').forEach((el) => (el.innerHTML = ''));
    const slot = document.querySelector('[data-form-notas-rutina]');
    slot.innerHTML = formNotasHTML(state.rutina.notas);
    slot.querySelector('form').dataset.tipo = 'rutina';
    slot.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
  }

  if (accion === 'editar-notas-dia') {
    document.querySelectorAll('[data-form-notas-dia], [data-form-notas-rutina]').forEach((el) => (el.innerHTML = ''));
    const dia = state.dias.find((d) => d.id === btn.dataset.id);
    const slot = document.querySelector(`[data-form-notas-dia="${btn.dataset.id}"]`);
    slot.innerHTML = formNotasHTML(dia?.notas);
    const form = slot.querySelector('form');
    form.dataset.tipo = 'dia';
    form.dataset.id = btn.dataset.id;
    slot.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
  }

  if (accion === 'cancelar-notas') {
    render();
  }
});

document.addEventListener('submit', async (e) => {
  const formNotas = e.target.closest('[data-form-notas-real]');
  if (formNotas) {
    e.preventDefault();
    const fd = new FormData(formNotas);
    const notas = fd.get('notas').trim() || null;
    if (formNotas.dataset.tipo === 'rutina') {
      await supabase.from('rutinas').update({ notas }).eq('id', state.rutina.id);
    } else {
      await supabase.from('dias').update({ notas }).eq('id', formNotas.dataset.id);
    }
    await cargarTodo();
  }
});

document.addEventListener('submit', async (e) => {
  const form = e.target.closest('[data-form-ejercicio-real]');
  if (!form) return;
  e.preventDefault();

  const diaId = form.dataset.diaId;
  const ejercicioId = form.dataset.ejercicioId || null;
  const fd = new FormData(form);
  const payload = {
    nombre: fd.get('nombre').trim(),
    series: Number(fd.get('series')),
    reps_objetivo: fd.get('reps_objetivo').trim(),
    notas: fd.get('notas').trim() || null,
  };

  if (ejercicioId) {
    await supabase.from('ejercicios').update(payload).eq('id', ejercicioId);
  } else {
    const dia = state.dias.find((d) => d.id === diaId);
    const maxOrden = (dia?.ejercicios || []).reduce((m, x) => Math.max(m, x.orden), 0);
    await supabase.from('ejercicios').insert({ ...payload, dia_id: diaId, orden: maxOrden + 1 });
  }
  await cargarTodo();
});

cargarTodo();
cargarHistorial();
