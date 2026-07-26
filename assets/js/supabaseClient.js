import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.45.4';

const SUPABASE_URL = 'https://hfrlxvqumqoxapcvvxmi.supabase.co';
const SUPABASE_KEY = 'sb_publishable_U2pQAgNafdpUMCsqnHlLEQ_73KwHCHD';

export const supabase = createClient(SUPABASE_URL, SUPABASE_KEY, {
  auth: {
    persistSession: true,
    autoRefreshToken: true,
  },
});
