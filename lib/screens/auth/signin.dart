import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vial_dashboard/screens/home.dart';
import 'package:vial_dashboard/screens/auth/reset.dart';
import 'package:vial_dashboard/screens/auth/signup.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Login',
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final logger = Logger();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showCustomDialogSignIn(String title, String message, bool isSuccess) {
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
                  isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
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
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomePage()),
                      );
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

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text;
      final password = _passwordController.text;

      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user?.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic>? userData =
              userDoc.data() as Map<String, dynamic>?;
          String? role = userData?['role'];

          if (role == 'Administrador') {
            if (mounted) {
              _showCustomDialogSignIn(
                  '¡Bienvenido!', 'Has iniciado sesión correctamente.', true);
            }
          } else {
            await FirebaseAuth.instance.signOut();
            _showCustomDialogSignIn(
                'Acceso denegado',
                'Solo los usuarios con rol de Administrador pueden iniciar sesión.',
                false);
          }
        } else {
          await FirebaseAuth.instance.signOut();
          _showCustomDialogSignIn('Error',
              'No se pudo encontrar la información del usuario.', false);
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        if (e.code == 'user-not-found' || e.code == 'invalid-email') {
          errorMessage =
              'Por favor, verifica que tu correo electrónico sea correcto.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Por favor, verifica que tu contraseña sea correcta.';
        } else {
          errorMessage =
              'Por favor, verifica tu correo electrónico y contraseña.';
        }
        logger.e('Error de inicio de sesión: ${e.code}');
        _showCustomDialogSignIn(
            'Error de inicio de sesión', errorMessage, false);
      }
    }
  }

  void _goToSignUpPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignUpPage()),
    );
  }

  void _goToForgotPasswordPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    bool obscureText = false,
    Widget? suffixIcon,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        suffixIcon: suffixIcon,
      ),
      obscureText: obscureText,
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                          'Bienvenido',
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        _buildTextField(
                          controller: _emailController,
                          labelText: 'Correo Electrónico',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, ingrese su correo electrónico';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),
                        _buildTextField(
                          controller: _passwordController,
                          labelText: 'Contraseña',
                          obscureText: !_isPasswordVisible,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, ingrese su contraseña';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFF05A7A7),
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Iniciar Sesión'),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('¿No tienes cuenta?'),
                            TextButton(
                              onPressed: _goToSignUpPage,
                              child: const Text(
                                'Crear cuenta',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: _goToForgotPasswordPage,
                          child: const Text(
                            '¿Olvidaste tu contraseña?',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
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
