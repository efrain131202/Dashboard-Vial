import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ForgotPasswordPageState createState() => ForgotPasswordPageState();
}

class ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final logger = Logger();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _showCustomDialogReset(String title, String message, bool isSuccess) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 340),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSuccess ? Icons.check_circle_rounded : Icons.error,
                  color: isSuccess ? Colors.green : Colors.red,
                  size: 64,
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (isSuccess) {
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF05A7A7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('OK'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _sendResetLink() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text;
      try {
        await FirebaseAuth.instance.setLanguageCode("es");

        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

        logger.i('Solicitud de restablecimiento enviada para: $email');

        if (mounted) {
          _showCustomDialogReset(
            'Solicitud enviada',
            'Si existe una cuenta asociada a este correo electrónico, recibirás un enlace para restablecer tu contraseña.',
            true,
          );
        }
      } catch (e) {
        String errorMessage;

        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'invalid-email':
              errorMessage = 'El correo electrónico ingresado no es válido.';
              break;
            case 'too-many-requests':
              errorMessage =
                  'Demasiados intentos. Por favor, inténtalo más tarde.';
              break;
            default:
              errorMessage =
                  'Hubo un problema al procesar tu solicitud. Por favor, verifica tu conexión e inténtalo de nuevo.';
              break;
          }
        } else {
          errorMessage =
              'Ocurrió un error inesperado. Por favor, intenta de nuevo.';
        }
        logger.e('Error al procesar la solicitud de restablecimiento: $e');
        if (mounted) {
          _showCustomDialogReset('Error', errorMessage, false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2C3E50),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 400,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '¿Olvidaste tu contraseña?',
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Ingresa tu email para recibir el enlace de restablecimiento.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Correo Electrónico',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, ingrese su correo electrónico';
                            }
                            final emailRegex = RegExp(
                                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                            if (!emailRegex.hasMatch(value)) {
                              return 'Por favor, ingrese un correo electrónico válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _sendResetLink,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFF05A7A7),
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Enviar Enlace'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
