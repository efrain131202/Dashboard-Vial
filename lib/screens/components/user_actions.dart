import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vial_dashboard/screens/components/user_details_screen.dart';
import 'package:vial_dashboard/screens/components/user_edit_screen.dart';
import 'package:vial_dashboard/screens/features/dashboard.dart';

void viewUser(BuildContext context, UserData user) {
  // Navegar a la pantalla de detalles del usuario
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => UserDetailsScreen(user: user),
    ),
  );
}

Future<void> editUser(BuildContext context, UserData user) async {
  // Navegar a la pantalla de edición del usuario
  final updatedUser = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => UserEditScreen(user: user),
    ),
  );

  if (updatedUser != null) {
    // Actualizar los datos del usuario en Firestore
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
  // Mostrar un diálogo de confirmación
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
      // Eliminar al usuario de Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .delete();
      // Mostrar una notificación de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario eliminado correctamente'),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      // Mostrar un mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar al usuario: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

Future<void> createUser(BuildContext context) async {
  // Navegar a la pantalla de creación de usuario
  final newUser = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const UserEditScreen(user: null),
    ),
  );

  if (newUser != null) {
    try {
      // Agregar al usuario a Firestore
      await FirebaseFirestore.instance.collection('users').add({
        'display_name': newUser.displayName,
        'email': newUser.email,
        'role': newUser.role,
        'photo_url': newUser.photoUrl,
        'created_time': FieldValue.serverTimestamp(),
      });
      // Mostrar una notificación de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario creado correctamente'),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      // Mostrar un mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear al usuario: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
