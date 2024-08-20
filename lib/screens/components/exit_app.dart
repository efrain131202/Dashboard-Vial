import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

void exitApp(BuildContext context) {
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
              const Icon(
                Icons.exit_to_app_rounded,
                color: Colors.red,
                size: 64,
              ),
              const SizedBox(height: 24),
              Text(
                '¿Confirmar salida?',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                '¿Estás seguro de que quieres cerrar sesión y salir de la aplicación?',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context).pop();
                    if (Platform.isWindows) {
                      exit(0);
                    }
                  } catch (e) {
                    print("Error al cerrar sesión: $e");
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF05A7A7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Cerrar sesión y Salir'),
              ),
            ],
          ),
        ),
      );
    },
  );
}
