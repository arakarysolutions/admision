-- Añadir la columna centro_procedencia a la tabla aspirantes
ALTER TABLE aspirantes ADD COLUMN IF NOT EXISTS centro_procedencia VARCHAR(255);
