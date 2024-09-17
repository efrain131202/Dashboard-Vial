import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    builder: (context) => AlertDialog(
      title: const Text('Eliminar usuario'),
      content:
          Text('¿Estás seguro de que deseas eliminar a ${user.displayName}?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );

  if (confirmed ?? false) {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario eliminado correctamente'),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar al usuario: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
