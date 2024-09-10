import 'package:flutter/material.dart';
import 'package:vial_dashboard/screens/components/user_data.dart';

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
  late TextEditingController _photoUrlController;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.user?.displayName ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _roleController = TextEditingController(text: widget.user?.role ?? '');
    _photoUrlController =
        TextEditingController(text: widget.user?.photoUrl ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _roleController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user == null ? 'Nuevo usuario' : 'Editar usuario'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _roleController,
              decoration: const InputDecoration(
                labelText: 'Rol',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _photoUrlController,
              decoration: const InputDecoration(
                labelText: 'URL de foto',
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                final updatedUser = UserData(
                  uid: widget.user?.uid ?? '',
                  displayName: _nameController.text,
                  email: _emailController.text,
                  role: _roleController.text,
                  createdTime: widget.user?.createdTime ?? DateTime.now(),
                  photoUrl: _photoUrlController.text,
                );
                Navigator.of(context).pop(updatedUser);
              },
              child: Text(widget.user == null ? 'Crear' : 'Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
