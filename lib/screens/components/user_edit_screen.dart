import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vial_dashboard/screens/utils/constants.dart';
import 'package:vial_dashboard/screens/utils/user_data.dart';

class UserEditScreen extends StatefulWidget {
  final UserData? user;

  const UserEditScreen({super.key, this.user});

  @override
  _UserEditScreenState createState() => _UserEditScreenState();
}

class _UserEditScreenState extends State<UserEditScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _roleController;
  late TextEditingController _phoneController;
  File? _image;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.user?.displayName ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _roleController = TextEditingController(text: widget.user?.role ?? '');
    _phoneController =
        TextEditingController(text: widget.user?.phoneNumber ?? '');
    _photoUrl = widget.user?.photoUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _roleController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
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

  void _saveUser() async {
    if (_image != null) {
      _photoUrl = await _uploadImage(_image!);
    }

    final updatedUser = UserData(
      uid: widget.user?.uid ?? '',
      displayName: _nameController.text,
      email: _emailController.text,
      role: _roleController.text,
      phoneNumber: _phoneController.text,
      photoUrl: _photoUrl,
      createdTime: widget.user?.createdTime ?? DateTime.now(),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.save_rounded,
                color: primaryColor,
                size: 72,
              ),
              const SizedBox(height: 24),
              Text(
                '¿Confirmar cambios?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                '¿Estás seguro de que deseas guardar los cambios realizados?',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop(updatedUser);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child:
                        const Text('Guardar', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2C3E50),
        title: Text(
          widget.user == null ? 'Nuevo usuario' : 'Editar usuario',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Scrollbar(
        thumbVisibility: true,
        trackVisibility: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(kPadding),
          child: Center(
            child: Column(
              children: [
                _buildProfileImage(),
                const SizedBox(height: kPadding),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('Seleccionar imagen'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 16),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: kPadding),
                _buildTextField(_nameController, 'Nombre'),
                const SizedBox(height: kPadding),
                _buildTextField(_emailController, 'Correo electrónico'),
                const SizedBox(height: kPadding),
                _buildTextField(_roleController, 'Rol'),
                const SizedBox(height: kPadding),
                _buildTextField(_phoneController, 'Número de teléfono'),
                const SizedBox(height: kPadding * 2),
                ElevatedButton(
                  onPressed: _saveUser,
                  child: Text(widget.user == null ? 'Crear' : 'Guardar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 16),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Container(
      width: 104,
      height: 104,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: primaryColor, width: 2),
      ),
      child: ClipOval(
        child: _image != null
            ? Image.file(
                _image!,
                fit: BoxFit.cover,
                width: 100,
                height: 100,
              )
            : (_photoUrl != null && _photoUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: _photoUrl!,
                    fit: BoxFit.cover,
                    width: 100,
                    height: 100,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error, size: 50),
                  )
                : const Icon(Icons.person, size: 50, color: Colors.grey)),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(bottom: kPadding / 2),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: primaryColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: primaryColor),
          ),
        ),
      ),
    );
  }
}
