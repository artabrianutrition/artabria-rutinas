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
