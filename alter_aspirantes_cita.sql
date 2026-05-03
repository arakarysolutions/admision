-- Añadir columna de confirmación de cita a la tabla de aspirantes
ALTER TABLE aspirantes 
ADD COLUMN IF NOT EXISTS cita_confirmada BOOLEAN DEFAULT false;
