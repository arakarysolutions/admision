-- Script para agregar las nuevas columnas a la tabla aspirantes

ALTER TABLE aspirantes 
ADD COLUMN cita_fecha text,
ADD COLUMN cita_hora text,
ADD COLUMN cita_aula text,
ADD COLUMN cambio_clave_requerido boolean DEFAULT false;
