import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreateUserForm extends StatefulWidget {
  const CreateUserForm({super.key});

  @override
  State<CreateUserForm> createState() => _CreateUserFormState();
}

class _CreateUserFormState extends State<CreateUserForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {
    'displayName': TextEditingController(),
    'email': TextEditingController(),
    'password': TextEditingController(),
    'confirmPassword': TextEditingController(),
    'phoneNumber': TextEditingController(),
    'shortDescription': TextEditingController(),
    'role': TextEditingController(),
  };

  bool _isLoading = false;
  File? _image;
  final List<String> _selectedOptions = [];
  final List<String> _options = [
    'Batería',
    'Talachería',
    'Grua',
    'Mecánica',
    'Cerrajero',
    'Gasolina'
  ];
  int _currentStep = 0;

  static const Color primaryColor = Color(0xFF05A7A7);
  static const Color secondaryColor = Color(0xFFF2877C);

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _createUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _controllers['email']!.text,
          password: _controllers['password']!.text,
        );

        print("Usuario creado con ID: ${userCredential.user?.uid}");

        String? photoUrl;
        if (_image != null) {
          photoUrl = await _uploadImage(_image!);
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user?.uid)
            .set({
          'uid': userCredential.user?.uid,
          'photo_url': photoUrl,
          'display_name': _controllers['displayName']!.text,
          'email': _controllers['email']!.text,
          'phone_number': _controllers['phoneNumber']!.text,
          'short_description': _controllers['shortDescription']!.text,
          'role': _controllers['role']!.text,
          'created_time': FieldValue.serverTimestamp(),
          'last_active_time': FieldValue.serverTimestamp(),
          'title': _selectedOptions,
        });

        print("Datos del usuario guardados en Firestore");

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Usuario creado exitosamente. Por favor, inicia sesión.'),
            ),
          );
          Navigator.of(context).pushReplacementNamed('/signin');
        }
      } catch (e) {
        print("Error detallado al crear usuario: $e");
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref =
          FirebaseStorage.instance.ref().child('profile_images/$fileName');
      final taskSnapshot = await ref.putFile(imageFile);
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error al subir la imagen: $e');
      return null;
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) _image = File(pickedFile.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2C3E50),
        title: const Text(
          'Crear Cuenta',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.7,
                    ),
                    child: DecoratedBox(
                      decoration: const BoxDecoration(color: Colors.white),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: primaryColor,
                          ),
                        ),
                        child: Stepper(
                          type: StepperType.horizontal,
                          currentStep: _currentStep,
                          onStepContinue: () => setState(
                              () => _currentStep < 4 ? _currentStep++ : null),
                          onStepCancel: () => setState(
                              () => _currentStep > 0 ? _currentStep-- : null),
                          controlsBuilder: (context, details) => Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Row(
                              children: [
                                if (_currentStep > 0)
                                  TextButton(
                                    onPressed: details.onStepCancel,
                                    child: const Text('ATRÁS',
                                        style:
                                            TextStyle(color: secondaryColor)),
                                  ),
                                if (_currentStep < 4)
                                  TextButton(
                                    onPressed: details.onStepContinue,
                                    child: const Text('SIGUIENTE',
                                        style: TextStyle(color: primaryColor)),
                                  ),
                              ],
                            ),
                          ),
                          steps: _buildSteps(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _createUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                    ),
                    child: _isLoading
                        ? const Text(
                            'Creando...') // Mensaje en lugar de animación
                        : const Text('Crear Cuenta',
                            style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Step> _buildSteps() {
    return [
      _buildStep(0, [
        _buildTextField('displayName', 'Nombre de Usuario'),
        _buildTextField('email', 'Correo Electrónico'),
      ]),
      _buildStep(1, [
        _buildTextField('password', 'Contraseña', obscureText: true),
        _buildTextField('confirmPassword', 'Confirmar Contraseña',
            obscureText: true),
      ]),
      _buildStep(2, [
        _buildTextField('phoneNumber', 'Número de Teléfono'),
        _buildTextField('shortDescription', 'Breve Descripción'),
      ]),
      _buildStep(3, [
        _buildDropdownField(
            'role', 'Rol', ['Usuario', 'Colaborador', 'Administrador']),
        if (_controllers['role']!.text == 'Colaborador')
          ..._options.map((option) => CheckboxListTile(
                title: Text(option),
                value: _selectedOptions.contains(option),
                onChanged: (bool? value) {
                  setState(() {
                    value == true
                        ? _selectedOptions.add(option)
                        : _selectedOptions.remove(option);
                  });
                },
              )),
      ]),
      _buildStep(4, [
        ElevatedButton(
          onPressed: _pickImage,
          style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
          child: const Text(
            'Seleccionar imagen',
            style: TextStyle(color: Colors.white),
          ),
        ),
        if (_image != null) Image.file(_image!, height: 100, width: 100),
      ]),
    ];
  }

  Step _buildStep(int index, List<Widget> content) {
    return Step(
      title: const Text(''),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: content,
        ),
      ),
      isActive: _currentStep >= index,
      state: _currentStep > index ? StepState.complete : StepState.indexed,
      label: Text('${index + 1}'),
    );
  }

  Widget _buildTextField(String key, String label, {bool obscureText = false}) {
    return TextFormField(
      controller: _controllers[key],
      decoration: InputDecoration(labelText: label),
      obscureText: obscureText,
      validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
    );
  }

  Widget _buildDropdownField(String key, String label, List<String> items) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: label),
      value: _controllers[key]!.text.isEmpty ? null : _controllers[key]!.text,
      items: items
          .map((value) => DropdownMenuItem(value: value, child: Text(value)))
          .toList(),
      onChanged: (newValue) =>
          setState(() => _controllers[key]!.text = newValue!),
      validator: (value) => value == null ? 'Campo requerido' : null,
    );
  }
}
