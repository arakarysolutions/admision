document.addEventListener('DOMContentLoaded', () => {
    // Evitar que el navegador restaure la posición de scroll al recargar
    if ('scrollRestoration' in history) {
        history.scrollRestoration = 'manual';
    }
    window.scrollTo(0, 0);

    const form = document.getElementById('registrationForm');
    const emailInput = document.getElementById('email');
    const passwordInput = document.getElementById('password');
    const identificationInput = document.getElementById('identification');
    const firstNameInput = document.getElementById('firstName');
    const lastName1Input = document.getElementById('lastName1');
    const birthDateInput = document.getElementById('birthDate');
    const phoneInput = document.getElementById('phone');

    // Validation functions
    const isRequired = value => value.trim() !== '';
    const isGmail = email => {
        const re = /^[a-zA-Z0-9._%+-]+@gmail\.com$/;
        return re.test(String(email).toLowerCase());
    };
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

    // Live validation on input
    const inputs = [emailInput, passwordInput, identificationInput, firstNameInput, lastName1Input, birthDateInput, phoneInput];
    
    inputs.forEach(input => {
        input.addEventListener('input', () => {
            if (isRequired(input.value)) {
                removeError(input);
            }
        });
    });

    emailInput.addEventListener('input', () => {
        if (isGmail(emailInput.value)) {
            removeError(emailInput);
        } else {
            showError(emailInput, 'emailError');
        }
    });

    passwordInput.addEventListener('input', () => {
        if (isLengthValid(passwordInput.value, 8)) {
            removeError(passwordInput);
        } else {
            showError(passwordInput, 'passwordError');
        }
    });

    // Form submission
    form.addEventListener('submit', async (e) => {
        e.preventDefault();
        
        let isValid = true;

        // Reset errors
        inputs.forEach(removeError);

        // Validations
        if (!isRequired(emailInput.value) || !isGmail(emailInput.value)) {
            showError(emailInput, 'emailError');
            isValid = false;
        }

        if (!isRequired(passwordInput.value) || !isLengthValid(passwordInput.value, 8)) {
            showError(passwordInput, 'passwordError');
            isValid = false;
        }

        if (!isRequired(identificationInput.value)) {
            showError(identificationInput, 'idError');
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

        if (!isRequired(birthDateInput.value)) {
            showError(birthDateInput, 'birthDateError');
            isValid = false;
        }

        if (!isRequired(phoneInput.value)) {
            showError(phoneInput, 'phoneError');
            isValid = false;
        }

        if (isValid) {
            // Mostrar carga
            Swal.fire({
                title: 'Procesando registro...',
                allowEscapeKey: false,
                allowOutsideClick: false,
                didOpen: () => Swal.showLoading()
            });

            // Generar PIN de 6 dígitos
            const pin = Math.floor(100000 + Math.random() * 900000).toString();

            const { data, error } = await supabaseClient
                .from('aspirantes')
                .insert([
                    {
                        email: emailInput.value.toLowerCase(),
                        password: passwordInput.value,
                        identificacion: identificationInput.value,
                        nombre: firstNameInput.value,
                        apellido: lastName1Input.value,
                        fecha_nacimiento: birthDateInput.value,
                        telefono: phoneInput.value,
                        pin: pin,
                        estado: 'Pendiente'
                    }
                ]);

            if (error) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error de Registro',
                    text: error.message.includes('unique constraint') || error.code === '23505' ? 'Este correo ya está registrado.' : 'Hubo un error al guardar los datos en el servidor.',
                    confirmButtonColor: '#cc0000'
                });
                return;
            }

            // Capturar el email antes de resetear el formulario
            const userEmailToVerify = emailInput.value.toLowerCase();

            // Enviar correo con EmailJS
            Swal.fire({
                title: 'Enviando correo...',
                text: 'Estamos enviando tu código de verificación.',
                allowOutsideClick: false,
                didOpen: () => Swal.showLoading()
            });

            const templateParams = {
                to_email: userEmailToVerify,
                subject: 'Tu PIN de Activación - Vocacional Monseñor Sanabria',
                message: `Hola,\n\nTu PIN de activación de 6 dígitos es: ${pin}\n\nIngresa este código en la pantalla de verificación para completar tu registro.\n\nSaludos,\nVocacional Monseñor Sanabria`
            };

            try {
                await emailjs.send('service_ykdsgde', 'template_wml65va', templateParams);
            } catch (emailErr) {
                console.error('Error al enviar correo:', emailErr);
                Swal.fire('Error', 'No se pudo enviar el correo con el PIN. Inténtalo de nuevo más tarde.', 'error');
                return;
            }

            // Pedir el PIN de verificación
            Swal.fire({
                icon: 'info',
                title: '¡Revisa tu correo!',
                html: `<p>Hemos enviado un código PIN a tu dirección de correo electrónico.</p>
                       <br>
                       <p>Ingresa el PIN de 6 dígitos para activar tu cuenta:</p>`,
                input: 'text',
                inputAttributes: {
                    maxlength: 6,
                    autocapitalize: 'off',
                    autocorrect: 'off'
                },
                showCancelButton: true,
                confirmButtonText: 'Verificar',
                cancelButtonText: 'Más tarde',
                confirmButtonColor: '#003366',
                showLoaderOnConfirm: true,
                preConfirm: async (enteredPin) => {
                    if (enteredPin !== pin) {
                        Swal.showValidationMessage('El PIN ingresado es incorrecto.');
                        return false;
                    }
                    
                    // Actualizar estado a Verificado usando el correo capturado
                    const { error: updateError } = await supabaseClient
                        .from('aspirantes')
                        .update({ estado: 'Verificado' })
                        .eq('email', userEmailToVerify);
                        
                    if (updateError) {
                        Swal.showValidationMessage('Error al activar la cuenta. Inténtalo de nuevo.');
                        return false;
                    }
                    return true;
                },
                allowOutsideClick: () => !Swal.isLoading()
            }).then((result) => {
                form.reset(); // Ahora sí reseteamos el formulario
                if (result.isConfirmed) {
                    Swal.fire({
                        icon: 'success',
                        title: '¡Cuenta Activada!',
                        text: 'Tu registro ha sido completado. Serás redirigido para iniciar sesión.',
                        confirmButtonColor: '#cc0000'
                    }).then(() => {
                        window.location.href = 'login.html';
                    });
                } else {
                    Swal.fire({
                        title: 'Registro Pendiente',
                        text: 'Puedes activar tu cuenta más tarde iniciando sesión.',
                        icon: 'warning'
                    });
                }
            });
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
});
