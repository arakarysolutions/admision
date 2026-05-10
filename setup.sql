-- ==========================================
-- SCRIPT DE CONFIGURACIÓN COMPLETA - VOCA ADMISIONES (REFATORIZADO V2)
-- Prefijo de tablas: admisiones_
-- ==========================================

-- 0. Extensiones necesarias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Tabla de Aspirantes
CREATE TABLE IF NOT EXISTS admisiones_aspirantes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    password VARCHAR(255) NOT NULL,
    identificacion VARCHAR(50) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    apellido2 VARCHAR(100),
    fecha_nacimiento DATE,
    pin VARCHAR(6),
    estado VARCHAR(50) DEFAULT 'Pendiente',
    
    -- Columnas de Citas
    cita_fecha TEXT,
    cita_hora TEXT,
    cita_aula TEXT,
    cita_confirmada BOOLEAN DEFAULT false,
    
    -- Columnas de Perfil Completo (Paso 2)
    foto_url TEXT,
    centro_procedencia VARCHAR(255),
    registro_completado BOOLEAN DEFAULT false,
    cambio_clave_requerido BOOLEAN DEFAULT false,
    numero_sobre VARCHAR(20),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- Habilitar RLS y permitir inserción pública para registro
ALTER TABLE admisiones_aspirantes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Permitir registro público" ON admisiones_aspirantes FOR INSERT WITH CHECK (true);
CREATE POLICY "Permitir lectura propia" ON admisiones_aspirantes FOR SELECT USING (true);
CREATE POLICY "Permitir actualización propia" ON admisiones_aspirantes FOR UPDATE USING (true);

-- 2. Tabla de Administradores
CREATE TABLE IF NOT EXISTS admisiones_administradores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    rol VARCHAR(50) DEFAULT 'Administrador',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- 3. Tabla de Mensajería (Chat)
CREATE TABLE IF NOT EXISTS admisiones_mensajes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    aspirante_id UUID REFERENCES admisiones_aspirantes(id) ON DELETE CASCADE,
    remitente VARCHAR(20) CHECK (remitente IN ('admin', 'estudiante')),
    mensaje TEXT NOT NULL,
    leido BOOLEAN DEFAULT false,
    adjunto_url TEXT,
    adjunto_nombre TEXT,
    fecha_hora TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- 4. Tabla de Avisos/Comunicados
CREATE TABLE IF NOT EXISTS admisiones_avisos (
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
CREATE TABLE IF NOT EXISTS admisiones_historial_admin (
    id SERIAL PRIMARY KEY,
    fecha_hora TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
    accion TEXT NOT NULL,
    detalle TEXT NOT NULL,
    admin_nombre VARCHAR(100) DEFAULT 'Admin Principal'
);

-- 6. Tabla de Sobres (Registro Manual)
CREATE TABLE IF NOT EXISTS admisiones_sobres (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    numero_sobre VARCHAR(20) UNIQUE,
    cedula VARCHAR(50) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido1 VARCHAR(100) NOT NULL,
    apellido2 VARCHAR(100),
    admin_registra VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- ==========================================
-- SEGURIDAD (RLS)
-- ==========================================

ALTER TABLE admisiones_aspirantes ENABLE ROW LEVEL SECURITY;
ALTER TABLE admisiones_administradores ENABLE ROW LEVEL SECURITY;
ALTER TABLE admisiones_mensajes ENABLE ROW LEVEL SECURITY;
ALTER TABLE admisiones_avisos ENABLE ROW LEVEL SECURITY;
ALTER TABLE admisiones_historial_admin ENABLE ROW LEVEL SECURITY;
ALTER TABLE admisiones_sobres ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Acceso público" ON admisiones_aspirantes;
CREATE POLICY "Acceso público" ON admisiones_aspirantes FOR ALL TO public USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Acceso público" ON admisiones_administradores;
CREATE POLICY "Acceso público" ON admisiones_administradores FOR ALL TO public USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Acceso público" ON admisiones_mensajes;
CREATE POLICY "Acceso público" ON admisiones_mensajes FOR ALL TO public USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Acceso público" ON admisiones_avisos;
CREATE POLICY "Acceso público" ON admisiones_avisos FOR ALL TO public USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Acceso público" ON admisiones_historial_admin;
CREATE POLICY "Acceso público" ON admisiones_historial_admin FOR ALL TO public USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Acceso público" ON admisiones_sobres;
CREATE POLICY "Acceso público" ON admisiones_sobres FOR ALL TO public USING (true) WITH CHECK (true);

-- ==========================================
-- REALTIME
-- ==========================================

BEGIN;
  DROP PUBLICATION IF EXISTS admisiones_realtime;
  CREATE PUBLICATION admisiones_realtime FOR TABLE admisiones_mensajes, admisiones_avisos, admisiones_aspirantes;
COMMIT;

-- ==========================================
-- DATOS INICIALES
-- ==========================================

INSERT INTO admisiones_administradores (nombre, correo, password) 
VALUES ('Admin Principal', 'admin', 'admin2026')
ON CONFLICT (correo) DO NOTHING;
-- ==========================================
-- STORAGE (Configuración de Buckets)
-- ==========================================

-- 1. Crear los Buckets si no existen
INSERT INTO storage.buckets (id, name, public) 
VALUES ('admisiones_avisos_adjuntos', 'admisiones_avisos_adjuntos', true)
ON CONFLICT (id) DO NOTHING;

INSERT INTO storage.buckets (id, name, public) 
VALUES ('admisiones_chat_adjuntos', 'admisiones_chat_adjuntos', true)
ON CONFLICT (id) DO NOTHING;

INSERT INTO storage.buckets (id, name, public) 
VALUES ('admisiones_fotos_aspirantes', 'admisiones_fotos_aspirantes', true)
ON CONFLICT (id) DO NOTHING;

-- 2. Políticas de acceso para los Buckets
-- Avisos
DROP POLICY IF EXISTS "Acceso público avisos" ON storage.objects;
CREATE POLICY "Acceso público avisos" ON storage.objects FOR ALL TO public USING (bucket_id = 'admisiones_avisos_adjuntos') WITH CHECK (bucket_id = 'admisiones_avisos_adjuntos');

-- Chat
DROP POLICY IF EXISTS "Acceso público chat" ON storage.objects;
CREATE POLICY "Acceso público chat" ON storage.objects FOR ALL TO public USING (bucket_id = 'admisiones_chat_adjuntos') WITH CHECK (bucket_id = 'admisiones_chat_adjuntos');

-- Fotos Aspirantes
DROP POLICY IF EXISTS "Acceso público fotos" ON storage.objects;
CREATE POLICY "Acceso público fotos" ON storage.objects FOR ALL TO public USING (bucket_id = 'admisiones_fotos_aspirantes') WITH CHECK (bucket_id = 'admisiones_fotos_aspirantes');
