-- Ejecuta este script en el SQL Editor de Supabase para soportar adjuntos en el chat

-- 1. Añadir nuevas columnas a la tabla de mensajes
ALTER TABLE mensajes ADD COLUMN adjunto_url TEXT;
ALTER TABLE mensajes ADD COLUMN adjunto_nombre TEXT;

-- 2. Asegúrate de crear manualmente un nuevo Bucket llamado "chat_adjuntos" en Supabase Storage, 
-- o si Supabase lo permite mediante SQL (normalmente se hace por la interfaz).
-- Una vez creado, aplica esta política de seguridad:

CREATE POLICY "Permitir subidas publicas a chat_adjuntos"
ON storage.objects FOR INSERT
TO public
WITH CHECK (bucket_id = 'chat_adjuntos');

CREATE POLICY "Permitir lectura publica a chat_adjuntos"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'chat_adjuntos');
