-- Script para crear la tabla de auditoría del administrador

CREATE TABLE historial_admin (
    id SERIAL PRIMARY KEY,
    fecha_hora TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
    accion TEXT NOT NULL,
    detalle TEXT NOT NULL
);

-- Habilitar permisos de lectura/escritura (para simplificar en desarrollo)
ALTER TABLE historial_admin ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Permitir todo a todos" ON historial_admin FOR ALL USING (true) WITH CHECK (true);
