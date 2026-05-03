-- Habilitar Row Level Security (RLS) en las tablas
ALTER TABLE aspirantes ENABLE ROW LEVEL SECURITY;
ALTER TABLE mensajes ENABLE ROW LEVEL SECURITY;

-- Crear políticas de acceso público (emulando el comportamiento actual)
-- Esto quitará el aviso de "UNRESTRICTED" (cambiándolo por el ícono del mundo)
-- y permitirá que tu aplicación siga funcionando sin problemas.

-- Política para la tabla aspirantes
CREATE POLICY "Acceso publico para aspirantes" 
ON aspirantes 
FOR ALL 
TO public 
USING (true) 
WITH CHECK (true);

-- Política para la tabla mensajes
CREATE POLICY "Acceso publico para mensajes" 
ON mensajes 
FOR ALL 
TO public 
USING (true) 
WITH CHECK (true);
