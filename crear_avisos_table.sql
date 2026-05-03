-- Crea la tabla para almacenar los comunicados/avisos globales
CREATE TABLE IF NOT EXISTS avisos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    titulo VARCHAR(255) NOT NULL,
    mensaje TEXT NOT NULL,
    tipo VARCHAR(50) DEFAULT 'general', -- 'general', 'urgente', 'informativo'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- Habilitar Políticas de Seguridad (RLS)
ALTER TABLE avisos ENABLE ROW LEVEL SECURITY;

-- Cualquiera (incluso no autenticados en este caso, o solo autenticados) puede ver los avisos
CREATE POLICY "Permitir lectura de avisos a todos" ON avisos
    FOR SELECT USING (true);

-- Solo administradores pueden insertar/actualizar (por simplicidad, permitimos todo por ahora si no hay auth fuerte)
CREATE POLICY "Permitir insertar avisos a todos (temporal)" ON avisos
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Permitir actualizar avisos a todos (temporal)" ON avisos
    FOR UPDATE USING (true);

CREATE POLICY "Permitir eliminar avisos a todos (temporal)" ON avisos
    FOR DELETE USING (true);
