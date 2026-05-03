-- Ejecuta este script en el SQL Editor de Supabase para permitir subir fotos

CREATE POLICY "Permitir subidas publicas"
ON storage.objects FOR INSERT
TO public
WITH CHECK (bucket_id = 'fotos_aspirantes');
