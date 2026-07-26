import { supabase } from './supabaseClient.js';
import { requireAdmin, logout } from './admin-guard.js';
import { generarCodigo, escapeHtml, linkCliente } from './utils.js';

await requireAdmin();

const lista = document.getElementById('lista-clientes');
const btnNuevo = document.getElementById('btn-nuevo');
const formNuevo = document.getElementById('form-nuevo');
const inputCodigo = document.getElementById('nuevo-codigo');
const alertBox = document.getElementById('alert');

document.getElementById('btn-logout').addEventListener('click', logout);

inputCodigo.value = generarCodigo();
document.getElementById('btn-regenerar').addEventListener('click', () => {
  inputCodigo.value = generarCodigo();
});

btnNuevo.addEventListener('click', () => {
  formNuevo.classList.toggle('oculto');
});

formNuevo.addEventListener('submit', async (e) => {
  e.preventDefault();
  const nombre = document.getElementById('nuevo-nombre').value.trim();
  const codigo = inputCodigo.value.trim();
  if (!nombre || !codigo) return;

  const { data, error } = await supabase.from('clientes').insert({ nombre, codigo }).select().single();
  if (error) {
    alertBox.innerHTML = `<div class="alert alert-error">${escapeHtml(error.message)}</div>`;
    return;
  }
  location.href = `/admin/cliente.html?id=${data.id}`;
});

async function cargarClientes() {
  const { data: clientes, error } = await supabase
    .from('clientes')
    .select('*')
    .order('created_at', { ascending: false });

  if (error) {
    lista.innerHTML = `<div class="alert alert-error">${escapeHtml(error.message)}</div>`;
    return;
  }
  if (!clientes.length) {
    lista.innerHTML = `<div class="empty-state">Aún no has dado de alta a ningún cliente.</div>`;
    return;
  }

  lista.innerHTML = '';
  clientes.forEach((c) => {
    const el = document.createElement('div');
    el.className = 'card';
    el.innerHTML = `
      <div class="row">
        <a href="/admin/cliente.html?id=${c.id}"><h3 style="margin:0">${escapeHtml(c.nombre)}</h3></a>
        <label class="switch">
          <input type="checkbox" ${c.activo ? 'checked' : ''}>
          <span class="slider"></span>
        </label>
      </div>
      <div class="copy-link mt-8">
        <span class="grow">${linkCliente(c.codigo)}</span>
        <button class="btn btn-ghost btn-sm btn-copiar">Copiar</button>
      </div>
    `;
    el.querySelector('input[type=checkbox]').addEventListener('change', async (e) => {
      await supabase.from('clientes').update({ activo: e.target.checked }).eq('id', c.id);
    });
    el.querySelector('.btn-copiar').addEventListener('click', async (e) => {
      await navigator.clipboard.writeText(linkCliente(c.codigo));
      e.target.textContent = 'Copiado';
      setTimeout(() => (e.target.textContent = 'Copiar'), 1500);
    });
    lista.appendChild(el);
  });
}

cargarClientes();
