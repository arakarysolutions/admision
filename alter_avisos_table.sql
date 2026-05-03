ALTER TABLE avisos
ADD COLUMN IF NOT EXISTS adjunto_url TEXT,
ADD COLUMN IF NOT EXISTS adjunto_nombre VARCHAR(255),
ADD COLUMN IF NOT EXISTS is_pinned BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS fecha_publicacion TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
ADD COLUMN IF NOT EXISTS is_hidden BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS liked_by JSONB DEFAULT '[]'::jsonb;

-- Opcional: Crear bucket para adjuntos de avisos si se requiere uno separado
-- INSERT INTO storage.buckets (id, name, public) VALUES ('avisos_adjuntos', 'avisos_adjuntos', true) ON CONFLICT DO NOTHING;

-- Las políticas ya fueron creadas en la primera ejecución, se comentan para evitar errores:
-- CREATE POLICY "Public Access" ON storage.objects FOR SELECT USING (bucket_id = 'avisos_adjuntos');
-- CREATE POLICY "Auth Insert" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'avisos_adjuntos');
