-- Script para crear el sistema de mensajería interna

CREATE TABLE mensajes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    aspirante_id UUID REFERENCES aspirantes(id) ON DELETE CASCADE,
    remitente TEXT CHECK (remitente IN ('admin', 'estudiante')),
    mensaje TEXT NOT NULL,
    leido BOOLEAN DEFAULT false,
    fecha_hora TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Configuración opcional para que los mensajes sean accesibles si se usan políticas RLS
-- Por ahora la dejamos pública o basada en el cliente sin autenticación fuerte si no la tienes activada globalmente.

-- Índice para acelerar búsquedas de mensajes por estudiante
CREATE INDEX idx_mensajes_aspirante ON mensajes(aspirante_id);
