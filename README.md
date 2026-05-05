# VOCA Admisiones 🎓

Sistema de gestión de admisiones escolares moderno, eficiente y fácil de usar, desarrollado para simplificar el proceso de inscripción y seguimiento de aspirantes.

## 🚀 Características

- **Panel de Administración:** Control total sobre las solicitudes, citas y verificación de documentos.
- **Panel del Estudiante:** Interfaz intuitiva para que los aspirantes completen su registro y sigan su estado.
- **Sistema de Mensajería:** Comunicación en tiempo real entre administradores y estudiantes.
- **Gestión de Citas:** Organización automatizada para exámenes y entrevistas.
- **Base de Datos en Tiempo Real:** Integración con Supabase para actualizaciones instantáneas.
- **Diseño Responsivo:** Optimizado para dispositivos móviles y escritorio.

## 🛠️ Tecnologías

- **Frontend:** HTML5, CSS3 (Vanilla), JavaScript (ES6+).
- **Backend/Base de Datos:** Supabase (PostgreSQL, Auth, Storage, Realtime).
- **Diseño:** Estética moderna con enfoque en la experiencia del usuario (UX).

## 📋 Requisitos e Instalación

### 1. Clonar el repositorio
```bash
git clone https://github.com/arakarysolutions/admision.git
cd admision
```

### 2. Configuración de Supabase
1. Crea un nuevo proyecto en [Supabase](https://supabase.com/).
2. Ejecuta los scripts SQL proporcionados en el Editor SQL de Supabase en el siguiente orden para configurar las tablas y políticas:
   - `crear_tabla_administradores.sql`
   - `crear_mensajeria.sql`
   - `crear_historial.sql`
   - `crear_avisos_table.sql`
   - (Y los archivos `actualizar_*.sql` y `politica_*.sql` según sea necesario).

### 3. Variables de Entorno
Actualiza el archivo `supabase-client.js` con tus credenciales de Supabase:
```javascript
const supabaseUrl = 'TU_SUPABASE_URL';
const supabaseKey = 'TU_SUPABASE_ANON_KEY';
```

## 📂 Estructura del Proyecto

- `index.html`: Página de inicio/bienvenida.
- `login.html`: Sistema de acceso.
- `dashboard-admin.html`: Interfaz para el personal administrativo.
- `dashboard-estudiante.html`: Interfaz para los aspirantes.
- `supabase-client.js`: Configuración y conexión con el backend.
- `scripts/`: Lógica de la aplicación.
- `styles.css`: Estilos globales y componentes.
- `src/`: Recursos multimedia (logos, imágenes).

## 📄 Licencia

Este proyecto está bajo la licencia de **Arakary Solutions**.

---
Desarrollado con ❤️ por [Arakary Solutions](https://github.com/arakarysolutions).
