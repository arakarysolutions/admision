-- Actualizar la tabla de historial para guardar el nombre del administrador
ALTER TABLE historial_admin 
ADD COLUMN IF NOT EXISTS admin_nombre VARCHAR(100) DEFAULT 'Admin Principal';
