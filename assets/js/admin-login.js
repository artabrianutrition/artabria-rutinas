import { supabase } from './supabaseClient.js';
import { qs } from './utils.js';

const form = document.getElementById('form-login');
const btnModo = document.getElementById('btn-modo');
const alertBox = document.getElementById('alert');
const btnSubmit = document.getElementById('btn-submit');
const tituloModo = document.getElementById('titulo-modo');

let modo = 'login';

if (qs('no_autorizado')) {
  mostrarAlerta('Esa cuenta no tiene permisos de administrador todavía.', 'error');
}

btnModo.addEventListener('click', () => {
  modo = modo === 'login' ? 'signup' : 'login';
  actualizarModo();
});

function actualizarModo() {
  if (modo === 'login') {
    tituloModo.textContent = 'Acceso entrenador';
    btnSubmit.textContent = 'Entrar';
    btnModo.textContent = '¿Primera vez? Crear cuenta';
  } else {
    tituloModo.textContent = 'Crear cuenta';
    btnSubmit.textContent = 'Crear cuenta';
    btnModo.textContent = '¿Ya tienes cuenta? Entrar';
  }
}

function mostrarAlerta(msg, tipo) {
  alertBox.innerHTML = `<div class="alert alert-${tipo}">${msg}</div>`;
}

form.addEventListener('submit', async (e) => {
  e.preventDefault();
  const email = document.getElementById('email').value.trim();
  const password = document.getElementById('password').value;
  btnSubmit.disabled = true;
  alertBox.innerHTML = '';

  try {
    if (modo === 'signup') {
      const { error } = await supabase.auth.signUp({ email, password });
      if (error) throw error;
      mostrarAlerta(
        'Cuenta creada. Un administrador debe darte de alta en la tabla "admins" (ver README) antes de que puedas entrar.',
        'success'
      );
      modo = 'login';
      actualizarModo();
    } else {
      const { error } = await supabase.auth.signInWithPassword({ email, password });
      if (error) throw error;
      const { data: esAdmin } = await supabase.rpc('is_admin');
      if (!esAdmin) {
        await supabase.auth.signOut();
        mostrarAlerta('Esta cuenta no tiene permisos de administrador todavía.', 'error');
      } else {
        location.href = '/admin/index.html';
      }
    }
  } catch (err) {
    mostrarAlerta(err.message, 'error');
  } finally {
    btnSubmit.disabled = false;
  }
});
