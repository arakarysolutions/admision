// Configuración de Supabase
const SUPABASE_URL = 'https://erzalifaknfjbxtbzrqn.supabase.co';
const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVyemFsaWZha25mamJ4dGJ6cnFuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzcxNjU2NDgsImV4cCI6MjA5Mjc0MTY0OH0.x5bOFuk7Skf11gPlG-pFIdic6UkfC-RgWta6nBYmzUw';

// Inicializar el cliente
const supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_KEY);
