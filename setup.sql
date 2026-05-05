-- ==========================================
-- SCRIPT DE CONFIGURACIÓN COMPLETA - VOCA ADMISIONES
-- Ejecuta este script en el Editor SQL de Supabase
-- ==========================================

-- 0. Extensiones necesarias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Tabla de Aspirantes (Corazón del sistema)
CREATE TABLE IF NOT EXISTS aspirantes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    identificacion VARCHAR(50) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE,
    telefono VARCHAR(20),
    pin VARCHAR(6),
    estado VARCHAR(50) DEFAULT 'Pendiente',
    
    -- Columnas de Citas
    cita_fecha TEXT,
    cita_hora TEXT,
    cita_aula TEXT,
    cita_confirmada BOOLEAN DEFAULT false,
    
    -- Columnas de Perfil Completo (Paso 2)
    foto_url TEXT,
    encargado_nombre TEXT,
    encargado_telefono TEXT,
    encargado_correo TEXT,
    centro_procedencia VARCHAR(255),
    registro_completado BOOLEAN DEFAULT false,
    cambio_clave_requerido BOOLEAN DEFAULT false,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- 2. Tabla de Administradores
CREATE TABLE IF NOT EXISTS administradores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    rol VARCHAR(50) DEFAULT 'Administrador',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- 3. Tabla de Mensajería (Chat)
CREATE TABLE IF NOT EXISTS mensajes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    aspirante_id UUID REFERENCES aspirantes(id) ON DELETE CASCADE,
    remitente VARCHAR(20) CHECK (remitente IN ('admin', 'estudiante')),
    mensaje TEXT NOT NULL,
    leido BOOLEAN DEFAULT false,
    adjunto_url TEXT,
    adjunto_nombre TEXT,
    fecha_hora TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- 4. Tabla de Avisos/Comunicados
CREATE TABLE IF NOT EXISTS avisos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    titulo VARCHAR(255) NOT NULL,
    mensaje TEXT NOT NULL,
    tipo VARCHAR(50) DEFAULT 'general', -- 'general', 'urgente', 'informativo'
    adjunto_url TEXT,
    adjunto_nombre VARCHAR(255),
    is_pinned BOOLEAN DEFAULT false,
    is_hidden BOOLEAN DEFAULT false,
    liked_by JSONB DEFAULT '[]'::jsonb,
    fecha_publicacion TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- 5. Tabla de Historial/Auditoría
CREATE TABLE IF NOT EXISTS historial_admin (
    id SERIAL PRIMARY KEY,
    fecha_hora TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
    accion TEXT NOT NULL,
    detalle TEXT NOT NULL,
    admin_nombre VARCHAR(100) DEFAULT 'Admin Principal'
);

-- ==========================================
-- SEGURIDAD (RLS)
-- ==========================================

-- Habilitar RLS en todas las tablas
ALTER TABLE aspirantes ENABLE ROW LEVEL SECURITY;
ALTER TABLE administradores ENABLE ROW LEVEL SECURITY;
ALTER TABLE mensajes ENABLE ROW LEVEL SECURITY;
ALTER TABLE avisos ENABLE ROW LEVEL SECURITY;
ALTER TABLE historial_admin ENABLE ROW LEVEL SECURITY;

-- Políticas de acceso simplificadas (Acceso Público para desarrollo)
-- Nota: En producción, se recomienda restringir esto a usuarios autenticados.

CREATE POLICY "Acceso público aspirantes" ON aspirantes FOR ALL TO public USING (true) WITH CHECK (true);
CREATE POLICY "Acceso público administradores" ON administradores FOR ALL TO public USING (true) WITH CHECK (true);
CREATE POLICY "Acceso público mensajes" ON mensajes FOR ALL TO public USING (true) WITH CHECK (true);
CREATE POLICY "Acceso público avisos" ON avisos FOR ALL TO public USING (true) WITH CHECK (true);
CREATE POLICY "Acceso público historial" ON historial_admin FOR ALL TO public USING (true) WITH CHECK (true);

-- ==========================================
-- REALTIME
-- ==========================================

-- Habilitar Realtime para las tablas que lo necesitan (Mensajes y Avisos)
BEGIN;
  -- Eliminar si ya existen para evitar duplicados
  DROP PUBLICATION IF EXISTS supabase_realtime;
  
  CREATE PUBLICATION supabase_realtime FOR TABLE mensajes, avisos, aspirantes;
COMMIT;

-- ==========================================
-- DATOS INICIALES
-- ==========================================

-- Insertar un administrador por defecto si no existe
INSERT INTO administradores (nombre, correo, password) 
VALUES ('Admin Principal', 'admin', 'admin2026')
ON CONFLICT (correo) DO NOTHING;

-- ==========================================
-- STORAGE (Políticas de Cubetas)
-- ==========================================
-- NOTA: Debes crear manualmente los buckets 'chat_adjuntos' y 'avisos_adjuntos' en Supabase Storage.
-- Las siguientes políticas permiten el acceso público a esos buckets una vez creados:

/* 
-- Políticas para el Bucket de Chat
CREATE POLICY "Permitir subidas públicas a chat_adjuntos" ON storage.objects FOR INSERT TO public WITH CHECK (bucket_id = 'chat_adjuntos');
CREATE POLICY "Permitir lectura pública a chat_adjuntos" ON storage.objects FOR SELECT TO public USING (bucket_id = 'chat_adjuntos');

-- Políticas para el Bucket de Avisos
CREATE POLICY "Permitir subidas públicas a avisos_adjuntos" ON storage.objects FOR INSERT TO public WITH CHECK (bucket_id = 'avisos_adjuntos');
CREATE POLICY "Permitir lectura pública a avisos_adjuntos" ON storage.objects FOR SELECT TO public USING (bucket_id = 'avisos_adjuntos');
*/
