import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vial_dashboard/screens/utils/constants.dart';
import 'package:vial_dashboard/screens/utils/user_data.dart';
import 'package:vial_dashboard/screens/components/user_details_screen.dart';
import 'package:vial_dashboard/screens/components/user_edit_screen.dart';

void viewUser(BuildContext context, UserData user) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => UserDetailsScreen(user: user),
    ),
  );
}

Future<void> editUser(BuildContext context, UserData user) async {
  final updatedUser = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => UserEditScreen(user: user),
    ),
  );

  if (updatedUser != null) {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(updatedUser.uid)
        .update({
      'display_name': updatedUser.displayName,
      'email': updatedUser.email,
      'role': updatedUser.role,
      'photo_url': updatedUser.photoUrl,
    });
  }
}

Future<void> deleteUser(BuildContext context, UserData user) async {
  bool? confirmed = await showDialog<bool>(
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
              Icons.delete_forever_rounded,
              color: primaryColor, // Sustituido
              size: 72,
            ),
            const SizedBox(height: 24),
            Text(
              'Eliminar usuario',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              '¿Estás seguro de que deseas eliminar a ${user.displayName}?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Esta acción no se puede deshacer.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.red[400],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: primaryColor, // Sustituido
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Eliminar', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );

  if (confirmed ?? false) {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text('Usuario eliminado correctamente'),
            ],
          ),
          backgroundColor: primaryColor, // Sustituido
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Error al eliminar al usuario: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }
}
