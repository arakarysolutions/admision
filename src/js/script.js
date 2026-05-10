document.addEventListener('DOMContentLoaded', () => {
    // Evitar que el navegador restaure la posición de scroll al recargar
    if ('scrollRestoration' in history) {
        history.scrollRestoration = 'manual';
    }
    window.scrollTo(0, 0);

    const form = document.getElementById('registrationForm');
    const passwordInput = document.getElementById('password');
    const confirmPasswordInput = document.getElementById('confirmPassword');
    const identificationInput = document.getElementById('identification');
    const emailInput = document.getElementById('email');
    const firstNameInput = document.getElementById('firstName');
    const lastName1Input = document.getElementById('lastName1');
    const lastName2Input = document.getElementById('lastName2');
    const birthDateInput = document.getElementById('birthDate');
    const numeroSobreInput = document.getElementById('numeroSobre');
    const sobreWarning = document.getElementById('sobre-warning');
    const btnValidarSobre = document.getElementById('btnValidarSobre');

    // Validation functions
    const isRequired = value => value.trim() !== '';
    const isLengthValid = (value, min) => value.length >= min;

    // Error styling functions
    const showError = (input, messageId) => {
        const formGroup = input.parentElement.parentElement;
        formGroup.classList.add('error');
    };

    const removeError = (input) => {
        const formGroup = input.parentElement.parentElement;
        formGroup.classList.remove('error');
    };

    const clearFields = () => {
        firstNameInput.value = '';
        lastName1Input.value = '';
        lastName2Input.value = '';
        numeroSobreInput.value = '';
    };

    // Lógica de Autocompletado por Identificación
    const checkIdentification = async () => {
        const id = identificationInput.value.trim();
        
        if (!id) {
            Swal.fire('Atención', 'Por favor ingrese su número de identificación.', 'warning');
            return;
        }

        Swal.fire({
            title: 'Validando sobre...',
            didOpen: () => Swal.showLoading(),
            allowOutsideClick: false
        });

        const { data: sobre, error } = await supabaseClient
            .from('admisiones_sobres')
            .select('*')
            .eq('cedula', id)
            .maybeSingle();

        Swal.close();

        if (sobre) {
            firstNameInput.value = sobre.nombre;
            lastName1Input.value = sobre.apellido1;
            lastName2Input.value = sobre.apellido2 || '';
            numeroSobreInput.value = sobre.numero_sobre;
            
            [firstNameInput, lastName1Input].forEach(removeError);
            
            Swal.fire({
                icon: 'success',
                title: 'Sobre Validado',
                text: `Hola ${sobre.nombre}, hemos encontrado tu sobre #${sobre.numero_sobre}. Por favor completa los datos faltantes.`,
                confirmButtonColor: '#003366'
            });
        } else {
            clearFields();
            Swal.fire({
                icon: 'error',
                title: 'Identificación no encontrada',
                html: `<p style="font-size: 0.9rem;">No hay un sobre registrado para esta identificación.</p>
                       <p style="font-size: 0.9rem; margin-top: 10px; font-weight: bold; color: #cc0000;">Debe adquirir el Sobre de Matrícula en el Colegio para poder registrarse.</p>`,
                confirmButtonColor: '#cc0000'
            });
        }
    };

    if (btnValidarSobre) {
        btnValidarSobre.addEventListener('click', checkIdentification);
    }

    // Permitir Enter también en el botón o campo
    identificationInput.addEventListener('keydown', (e) => {
        if (e.key === 'Enter') {
            e.preventDefault();
            checkIdentification();
        }
    });

    // Mantener la limpieza inmediata si se borra todo el texto
    identificationInput.addEventListener('input', () => {
        if (!identificationInput.value.trim()) {
            clearFields();
        }
    });

    // Live validation on input
    const inputs = [passwordInput, confirmPasswordInput, identificationInput, emailInput, firstNameInput, lastName1Input, birthDateInput];
    
    inputs.forEach(input => {
        input.addEventListener('input', () => {
            if (isRequired(input.value)) {
                removeError(input);
            }
        });
    });

    passwordInput.addEventListener('input', () => {
        if (isLengthValid(passwordInput.value, 8)) {
            removeError(passwordInput);
        } else {
            showError(passwordInput, 'passwordError');
        }
    });

    confirmPasswordInput.addEventListener('input', () => {
        if (confirmPasswordInput.value === passwordInput.value) {
            removeError(confirmPasswordInput);
        } else {
            showError(confirmPasswordInput, 'confirmPasswordError');
        }
    });

    // Form submission
    form.addEventListener('submit', async (e) => {
        e.preventDefault();
        
        let isValid = true;

        // Reset errors
        inputs.forEach(removeError);

        // Validations
        if (!isRequired(passwordInput.value) || !isLengthValid(passwordInput.value, 8)) {
            showError(passwordInput, 'passwordError');
            isValid = false;
        }

        if (confirmPasswordInput.value !== passwordInput.value) {
            showError(confirmPasswordInput, 'confirmPasswordError');
            isValid = false;
        }

        if (!isRequired(identificationInput.value)) {
            showError(identificationInput, 'idError');
            isValid = false;
        }

        if (!isRequired(numeroSobreInput.value)) {
            Swal.fire('Sobre Requerido', 'Primero debes validar tu identificación para cargar el número de sobre.', 'warning');
            isValid = false;
        }

        if (!isRequired(firstNameInput.value)) {
            showError(firstNameInput, 'firstNameError');
            isValid = false;
        }

        if (!isRequired(lastName1Input.value)) {
            showError(lastName1Input, 'lastName1Error');
            isValid = false;
        }

        if (!isRequired(emailInput.value)) {
            showError(emailInput, 'emailError');
            isValid = false;
        }

        if (!isRequired(birthDateInput.value)) {
            showError(birthDateInput, 'birthDateError');
            isValid = false;
        }

        if (isValid) {
            // Generar PIN de 6 dígitos
            const generatedPin = Math.floor(100000 + Math.random() * 900000).toString();

            // Mostrar carga y enviar email
            Swal.fire({
                title: 'Verificando Correo...',
                text: 'Estamos enviando un código de seguridad a tu Gmail.',
                allowEscapeKey: false,
                allowOutsideClick: false,
                didOpen: () => Swal.showLoading()
            });

            const finalEmail = emailInput.value.trim() + "@gmail.com";

            try {
                // Envío con EmailJS (Mapeo exacto según tu plantilla + HTML para el PIN)
                await emailjs.send("service_ykdsgde", "template_wml65va", {
                    name: firstNameInput.value,
                    to_email: finalEmail,
                    subject: "Código de Verificación - VOCA Admisiones",
                    message: `Tu código de seguridad para activar la cuenta es: <br><br><b style="color: #cc0000; font-size: 24px; letter-spacing: 5px;">${generatedPin}</b>`
                });

                Swal.close();

                // Pedir el PIN al usuario
                const { value: userPin } = await Swal.fire({
                    title: 'Verifica tu cuenta',
                    text: `Ingresa el código de 6 dígitos que enviamos a ${finalEmail}`,
                    input: 'text',
                    inputAttributes: {
                        maxlength: 6,
                        autocapitalize: 'off',
                        autocorrect: 'off'
                    },
                    showCancelButton: true,
                    confirmButtonText: 'Verificar y Registrar',
                    cancelButtonText: 'Cancelar',
                    confirmButtonColor: '#003366',
                    inputValidator: (value) => {
                        if (!value || value.length !== 6) {
                            return 'Debes ingresar el código completo';
                        }
                        if (value !== generatedPin) {
                            return 'El código es incorrecto';
                        }
                    }
                });

                if (userPin) {
                    Swal.fire({
                        title: 'Creando cuenta...',
                        text: 'Estamos validando tus datos finales.',
                        allowOutsideClick: false,
                        didOpen: () => Swal.showLoading()
                    });

                    const { data, error: dbError } = await supabaseClient
                        .from('admisiones_aspirantes')
                        .insert([
                            {
                                password: passwordInput.value,
                                identificacion: identificationInput.value,
                                correo: finalEmail,
                                nombre: firstNameInput.value,
                                apellido: lastName1Input.value,
                                apellido2: lastName2Input.value,
                                fecha_nacimiento: birthDateInput.value,
                                numero_sobre: numeroSobreInput.value,
                                pin: generatedPin,
                                estado: 'Verificado'
                            }
                        ]);

                    if (dbError) {
                        console.error("Error en base de datos:", dbError);
                        throw new Error(dbError.message.includes('unique constraint') ? 'Esta identificación ya está registrada.' : `Error de base de datos: ${dbError.message}`);
                    }

                    form.reset();
                    Swal.fire({
                        icon: 'success',
                        title: '¡Registro Exitoso!',
                        text: 'Tu cuenta ha sido activada. Ahora puedes iniciar sesión.',
                        confirmButtonColor: '#003366'
                    }).then(() => {
                        window.location.href = 'login.html';
                    });
                }

            } catch (err) {
                console.error("Error en proceso:", err);
                Swal.fire({
                    icon: 'error',
                    title: 'Error en Registro',
                    text: err.message || 'Ocurrió un problema inesperado.',
                    confirmButtonColor: '#cc0000'
                });
            }
        }
    });

    // Lógica del botón flotante para volver arriba
    const backToTopBtn = document.getElementById('backToTopBtn');
    
    if (backToTopBtn) {
        window.addEventListener('scroll', () => {
            if (window.scrollY > 300) {
                backToTopBtn.classList.add('show');
            } else {
                backToTopBtn.classList.remove('show');
            }
        });

        backToTopBtn.addEventListener('click', () => {
            window.scrollTo({
                top: 0,
                behavior: 'smooth'
            });
        });
    }
    // Lógica del menú móvil
    const mobileMenuBtn = document.getElementById('mobileMenuBtn');
    const closeDrawerBtn = document.getElementById('closeDrawerBtn');
    const mobileMenuDrawer = document.getElementById('mobileMenuDrawer');
    const mobileMenuOverlay = document.getElementById('mobileMenuOverlay');

    const toggleMobileMenu = () => {
        mobileMenuDrawer.classList.toggle('active');
        mobileMenuOverlay.classList.toggle('active');
        document.body.style.overflow = mobileMenuDrawer.classList.contains('active') ? 'hidden' : '';
    };

    if (mobileMenuBtn) {
        mobileMenuBtn.addEventListener('click', toggleMobileMenu);
    }

    if (closeDrawerBtn) {
        closeDrawerBtn.addEventListener('click', toggleMobileMenu);
    }

    if (mobileMenuOverlay) {
        mobileMenuOverlay.addEventListener('click', toggleMobileMenu);
    }

    // Función global para cerrar el menú desde los enlaces
    window.closeMobileMenu = () => {
        mobileMenuDrawer.classList.remove('active');
        mobileMenuOverlay.classList.remove('active');
        document.body.style.overflow = '';
    };
});
