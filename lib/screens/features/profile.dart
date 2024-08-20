import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const double kPadding = 16.0;
const Color primaryColor = Color(0xFF05A7A7);

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser?.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(
                  child: Text('No se encontraron datos del usuario'));
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>?;
            final userRole = userData?['role'];

            if (userRole != 'Administrador') {
              return const Center(
                  child: Text(
                      'Acceso denegado. Solo los usuarios administradores pueden ver el perfil.'));
            }

            return Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(kPadding),
                  child: _buildUserProfile(userData),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildUserProfile(Map<String, dynamic>? userData) {
    if (userData == null) {
      return const Center(child: Text('No se ha encontrado usuario'));
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Mi Perfil',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: kPadding),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: primaryColor, width: 2),
          ),
          child: CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(
                userData['photo_url'] ?? 'https://via.placeholder.com/150'),
          ),
        ),
        const SizedBox(height: kPadding),
        Text(
          userData['display_name'] ?? 'Sin nombre',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          userData['role'] ?? 'Sin rol',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: kPadding * 1.5),
        _buildInfoBox('Email', userData['email'] ?? 'No disponible'),
        _buildInfoBox('Teléfono', userData['phone_number'] ?? 'No disponible'),
        _buildInfoBox(
            'Descripción', userData['short_description'] ?? 'Sin descripción'),
        const SizedBox(height: kPadding),
        SizedBox(
          width: 200,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Editar Perfil',
                style: TextStyle(fontSize: 14, color: Colors.white)),
          ),
        ),
      ],
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
