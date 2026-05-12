/**
 * Alpha Phase Warning System
 * Displays a professional modal to users when they enter the site.
 */

const showAlphaWarning = () => {
    // Check if the user has already seen the warning in this session
    if (sessionStorage.getItem('voca_alpha_warning_seen')) return;

    Swal.fire({
        title: '<div class="flex items-center gap-3 justify-center mb-2"><span class="bg-red-600 text-white text-[10px] px-2 py-0.5 rounded font-bold tracking-widest uppercase">Fase Alpha</span></div><span style="color: #003366; font-family: Outfit, sans-serif; font-weight: 800;">AVISO DE DESARROLLO</span>',
        html: `
            <div style="text-align: left; font-family: Inter, sans-serif; color: #4b5563; line-height: 1.6;">
                <p style="margin-bottom: 15px; font-size: 1.05rem;">
                    Bienvenido al <strong>Portal de Admisiones 2026</strong>. 
                </p>
                <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 12px; padding: 20px; margin-bottom: 20px; border-left: 5px solid #cc0000;">
                    <p style="margin-bottom: 10px; color: #1f2937; font-weight: 500;">
                        <i class="fa-solid fa-flask-vial mr-2 text-red-600"></i> Estado del Proyecto: <strong>Alpha v1.0.4</strong>
                    </p>
                    <p style="font-size: 0.9rem;">
                        Actualmente nos encontramos en una etapa temprana de desarrollo. Esto implica que:
                    </p>
                    <ul style="font-size: 0.85rem; margin-top: 10px; padding-left: 20px; list-style-type: disc;">
                        <li style="margin-bottom: 5px;">Algunas secciones del portal podrían estar incompletas.</li>
                        <li style="margin-bottom: 5px;">Pueden ocurrir errores visuales o de funcionamiento (bugs).</li>
                        <li style="margin-bottom: 5px;">Se realizan mantenimientos y actualizaciones constantes sin previo aviso.</li>
                    </ul>
                </div>
                <p style="font-size: 0.9rem; text-align: center; font-style: italic;">
                    Agradecemos tu paciencia y reporte de cualquier anomalía al departamento técnico.
                </p>
            </div>
        `,
        icon: undefined, // Custom icon in title
        confirmButtonText: 'ENTIENDO Y DESEO CONTINUAR',
        confirmButtonColor: '#003366',
        allowOutsideClick: false,
        allowEscapeKey: false,
        width: '550px',
        padding: '2em',
        background: '#fff',
        backdrop: 'rgba(0,51,102,0.6)',
        showClass: {
            popup: 'animate__animated animate__fadeInDown'
        },
        hideClass: {
            popup: 'animate__animated animate__fadeOutUp'
        }
    }).then((result) => {
        if (result.isConfirmed) {
            sessionStorage.setItem('voca_alpha_warning_seen', 'true');
        }
    });
};

// Auto-init on script load
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', showAlphaWarning);
} else {
    showAlphaWarning();
}
