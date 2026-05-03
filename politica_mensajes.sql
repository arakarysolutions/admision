-- Ejecuta este script en el SQL Editor de Supabase para arreglar el error de permisos

-- Como estamos utilizando un sistema de login propio y no la autenticación nativa de Supabase,
-- necesitamos deshabilitar el "Row Level Security" (RLS) en la tabla mensajes para permitir 
-- que los estudiantes (que para Supabase son "usuarios anónimos") puedan enviar mensajes.

ALTER TABLE mensajes DISABLE ROW LEVEL SECURITY;

-- Si por alguna razón la interfaz de Supabase vuelve a activarlo, 
-- la siguiente política garantizará que funcione siempre:
DROP POLICY IF EXISTS "Permitir todo en mensajes" ON mensajes;
CREATE POLICY "Permitir todo en mensajes" ON mensajes FOR ALL TO public USING (true) WITH CHECK (true);
