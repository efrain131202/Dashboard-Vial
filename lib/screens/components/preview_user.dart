import 'package:flutter/material.dart';
import 'dart:io';
import 'package:vial_dashboard/screens/utils/constants.dart';

class UserPreviewScreen extends StatelessWidget {
  final Map<String, dynamic> userData;
  final File? imageFile;
  final List<String> selectedOptions;
  final VoidCallback onConfirm;
  final VoidCallback onEdit;

  const UserPreviewScreen({
    super.key,
    required this.userData,
    this.imageFile,
    required this.selectedOptions,
    required this.onConfirm,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2C3E50),
        title: const Text(
          'Vista Previa del Usuario',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(kPadding),
          child: Column(
            children: [
              _buildProfileImage(),
              const SizedBox(height: kPadding),
              _buildUserInfo(
                  userData['displayName'], 'Sin nombre', 22, FontWeight.bold),
              const SizedBox(height: 4),
              _buildUserInfo(userData['email'], 'Email no disponible', 16,
                  FontWeight.normal,
                  color: Colors.grey[600]),
              const SizedBox(height: kPadding),
              _buildInfoBox('Rol', userData['role']),
              _buildInfoBox('Teléfono', userData['phone_number']),
              _buildInfoBox('Descripción', userData['shortDescription']),
              if (userData['role'] == 'Colaborador')
                _buildInfoBox('Servicios', selectedOptions.join(', ')),
              const SizedBox(height: kPadding),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: onEdit,
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    child: const Text('Editar',
                        style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: onConfirm,
                    style:
                        ElevatedButton.styleFrom(backgroundColor: primaryColor),
                    child: const Text('Confirmar',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
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
        child: imageFile != null
            ? Image.file(imageFile!, fit: BoxFit.cover, width: 100, height: 100)
            : const Icon(Icons.person, size: 50, color: Colors.grey),
      ),
    );
  }

  Widget _buildUserInfo(
      String value, String placeholder, double fontSize, FontWeight fontWeight,
      {Color? color}) {
    return Text(
      value.isNotEmpty ? value : placeholder,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color ?? Colors.black,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildInfoBox(String title, String value) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(bottom: kPadding / 2),
      padding: const EdgeInsets.all(kPadding / 2),
      decoration: BoxDecoration(
        border: Border.all(color: primaryColor.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
