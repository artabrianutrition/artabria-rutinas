import { supabase } from './supabaseClient.js';

const ALPHABET = 'abcdefghijkmnpqrstuvwxyz23456789'; // sin caracteres ambiguos (l, 0, 1, o)

export function generarCodigo(longitud = 6) {
  const arr = new Uint8Array(longitud);
  crypto.getRandomValues(arr);
  let out = '';
  for (let i = 0; i < longitud; i++) {
    out += ALPHABET[arr[i] % ALPHABET.length];
  }
  return out;
}

export function escapeHtml(str) {
  if (str == null) return '';
  return String(str)
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;');
}

export function formatFecha(iso) {
  const d = new Date(iso);
  return d.toLocaleDateString('es-ES', { day: '2-digit', month: 'short', year: 'numeric' });
}

export function formatFechaHora(iso) {
  const d = new Date(iso);
  return d.toLocaleString('es-ES', { day: '2-digit', month: 'short', hour: '2-digit', minute: '2-digit' });
}

export function qs(name) {
  return new URLSearchParams(window.location.search).get(name);
}

export function linkCliente(codigo) {
  return `${window.location.origin}/c/${codigo}`;
}

function renderDetalleSesionHtml(registros, sesionMeta) {
  const porEjercicio = {};
  (registros || []).forEach((r) => {
    const nombre = r.ejercicios?.nombre || 'Ejercicio';
    const orden = r.ejercicios?.orden ?? 0;
    if (!porEjercicio[nombre]) porEjercicio[nombre] = { orden, series: [] };
    porEjercicio[nombre].series.push(r);
  });

  const ejerciciosOrdenados = Object.entries(porEjercicio).sort((a, b) => a[1].orden - b[1].orden);

  const metaHtml = [];
  if (sesionMeta?.fatiga != null) {
    metaHtml.push(
      `<div class="card card-tight"><strong>Fatiga</strong><div class="faint">${sesionMeta.fatiga} / 10</div></div>`
    );
  }
  if (sesionMeta?.notas) {
    metaHtml.push(
      `<div class="card card-tight"><strong>Anotaciones</strong><div class="faint">${escapeHtml(sesionMeta.notas)}</div></div>`
    );
  }

  if (!ejerciciosOrdenados.length) {
    return metaHtml.join('') || '<p class="hint">Sin datos registrados en esta sesión.</p>';
  }

  const ejerciciosHtml = ejerciciosOrdenados
    .map(([nombre, info]) => {
      const seriesTxt = info.series
        .sort((a, b) => a.numero_serie - b.numero_serie)
        .map((r) => {
          const rirTxt = r.rir ? ` · RIR ${r.rir}` : '';
          return `${r.peso ?? '–'} kg × ${r.reps ?? '–'} reps${rirTxt}${r.completada ? '' : ' (sin marcar)'}`;
        })
        .join(' · ');
      return `<div class="card card-tight"><strong>${escapeHtml(nombre)}</strong><div class="faint">${seriesTxt}</div></div>`;
    })
    .join('');

  return metaHtml.join('') + ejerciciosHtml;
}

export async function obtenerDetalleSesionHtml(sesionId) {
  const [{ data: registros, error }, { data: sesionMeta }] = await Promise.all([
    supabase
      .from('registros_series')
      .select('numero_serie, peso, reps, rir, completada, ejercicios(nombre, orden)')
      .eq('sesion_id', sesionId),
    supabase.from('sesiones').select('fatiga, notas').eq('id', sesionId).single(),
  ]);

  if (error) {
    return `<div class="alert alert-error">${escapeHtml(error.message)}</div>`;
  }
  return renderDetalleSesionHtml(registros, sesionMeta);
}

function claseComparacion(actual, anterior) {
  if (actual == null || anterior == null) return '';
  if (actual > anterior) return 'valor-mejora';
  if (actual < anterior) return 'valor-empeora';
  return '';
}

function renderProgresoEjercicioHtml(registros) {
  if (!registros || !registros.length) {
    return '<p class="hint">Todavía no hay sesiones terminadas registradas para este ejercicio.</p>';
  }

  const porSesion = {};
  registros.forEach((r) => {
    if (!porSesion[r.sesion_id]) {
      porSesion[r.sesion_id] = { fecha: r.sesiones?.fecha, series: {} };
    }
    porSesion[r.sesion_id].series[r.numero_serie] = r;
  });

  const sesiones = Object.values(porSesion).sort((a, b) => new Date(a.fecha) - new Date(b.fecha));

  return sesiones
    .map((s, idx) => {
      const anterior = idx > 0 ? sesiones[idx - 1] : null;
      const numerosSerie = Object.keys(s.series)
        .map(Number)
        .sort((a, b) => a - b);

      const seriesTxt = numerosSerie
        .map((n) => {
          const actual = s.series[n];
          const previa = anterior?.series[n];
          const pesoClase = claseComparacion(actual.peso, previa?.peso);
          const repsClase = claseComparacion(actual.reps, previa?.reps);
          return `<span class="${pesoClase}">${actual.peso ?? '–'} kg</span> × <span class="${repsClase}">${actual.reps ?? '–'}</span>`;
        })
        .join(' · ');

      return `<div class="card card-tight"><div class="faint">${formatFecha(s.fecha)}</div><div class="mt-8">${seriesTxt}</div></div>`;
    })
    .join('');
}

export async function obtenerProgresoEjercicioHtml(ejercicioId) {
  const { data: registros, error } = await supabase
    .from('registros_series')
    .select('sesion_id, numero_serie, peso, reps, sesiones!inner(fecha, completada)')
    .eq('ejercicio_id', ejercicioId)
    .eq('sesiones.completada', true);

  if (error) {
    return `<div class="alert alert-error">${escapeHtml(error.message)}</div>`;
  }
  return renderProgresoEjercicioHtml(registros);
}
