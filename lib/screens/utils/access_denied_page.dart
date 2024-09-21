import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vial_dashboard/screens/utils/constants.dart';
import 'package:vial_dashboard/screens/utils/loading_screen.dart';

class AdminAccessControl extends StatelessWidget {
  final Widget child;

  const AdminAccessControl({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        return _buildContent(snapshot);
      },
    );
  }

  Widget _buildContent(AsyncSnapshot<DocumentSnapshot> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const LoadingScreen();
    }

    if (!snapshot.hasData || snapshot.data == null) {
      return _buildErrorScreen('No se encontraron datos del usuario');
    }

    final userData = snapshot.data!.data() as Map<String, dynamic>?;
    final userRole = userData?['role'];

    if (userRole != 'Administrador') {
      return _buildAccessDeniedScreen();
    }

    return child;
  }

  Widget _buildErrorScreen(String message) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_rounded, size: 80, color: Colors.red[300]),
              const SizedBox(height: 20),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccessDeniedScreen() {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_rounded, size: 100, color: primaryColor),
                SizedBox(height: 30),
                Text(
                  'Acceso Denegado',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: primaryColor,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Lo sentimos, solo los administradores pueden ver el contenido de esta página.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget withAdminAccess(Widget child) {
  return AdminAccessControl(
    child: child,
  );
}
