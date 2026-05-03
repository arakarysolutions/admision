-- Crear la tabla de administradores
CREATE TABLE administradores (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    rol VARCHAR(50) DEFAULT 'Administrador'
);

-- Habilitar RLS (Row Level Security)
ALTER TABLE administradores ENABLE ROW LEVEL SECURITY;

-- Crear política de acceso público
CREATE POLICY "Acceso publico para administradores" 
ON administradores 
FOR ALL 
TO public 
USING (true) 
WITH CHECK (true);

-- Opcional: Insertar un administrador por defecto
INSERT INTO administradores (nombre, correo, password) 
VALUES ('Admin Principal', 'admin', 'admin2026')
ON CONFLICT (correo) DO NOTHING;
