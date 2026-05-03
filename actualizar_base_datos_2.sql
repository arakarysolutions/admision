-- Script para agregar columnas del Paso 2 (Onboarding)

ALTER TABLE aspirantes 
ADD COLUMN foto_url text,
ADD COLUMN encargado_nombre text,
ADD COLUMN encargado_telefono text,
ADD COLUMN encargado_correo text,
ADD COLUMN registro_completado boolean DEFAULT false;
