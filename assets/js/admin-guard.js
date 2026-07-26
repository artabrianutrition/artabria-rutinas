import { supabase } from './supabaseClient.js';

export async function requireAdmin() {
  const { data: { session } } = await supabase.auth.getSession();
  if (!session) {
    location.href = '/admin/login.html';
    return null;
  }
  const { data: esAdmin } = await supabase.rpc('is_admin');
  if (!esAdmin) {
    await supabase.auth.signOut();
    location.href = '/admin/login.html?no_autorizado=1';
    return null;
  }
  return session;
}

export async function logout() {
  await supabase.auth.signOut();
  location.href = '/admin/login.html';
}
