-- Ejecuta este script en el SQL Editor de Supabase para activar el Tiempo Real

-- Activar REPLICA IDENTITY (opcional pero recomendado para realtime completo)
ALTER TABLE mensajes REPLICA IDENTITY FULL;

-- Añadir la tabla mensajes a la publicación de Supabase Realtime
DO $$
BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE mensajes;
EXCEPTION
  WHEN OTHERS THEN
    -- Ignorar el error si la tabla ya está en la publicación
    NULL;
END $$;
