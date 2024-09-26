import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:vial_dashboard/screens/utils/constants.dart';
import 'package:vial_dashboard/screens/utils/user_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserDetailsScreen extends StatelessWidget {
  final UserData user;

  const UserDetailsScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2C3E50),
        title: const Text(
          'Detalles del usuario',
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
              _buildProfileImage(user),
              const SizedBox(height: kPadding),
              _buildUserInfo(
                  user.displayName, 'Sin nombre', 22, FontWeight.bold),
              const SizedBox(height: 4),
              _buildUserInfo(
                  user.email, 'Email no disponible', 16, FontWeight.normal,
                  color: Colors.grey[600]),
              const SizedBox(height: kPadding),
              _buildInfoBox(
                  'Rol', user.role.isNotEmpty ? user.role : 'Sin rol'),
              _buildInfoBox(
                  'Teléfono',
                  user.phoneNumber.isNotEmpty
                      ? user.phoneNumber
                      : 'No disponible'),
              _buildInfoBox('Creado', _formatDate(user.createdTime)),
              if (user.role.toLowerCase() == 'usuario')
                _buildVehiclesList(user.uid),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage(UserData user) {
    return Container(
      width: 104,
      height: 104,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: primaryColor, width: 2),
      ),
      child: ClipOval(
        child: user.photoUrl != null && user.photoUrl!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: user.photoUrl!,
                fit: BoxFit.cover,
                width: 100,
                height: 100,
                placeholder: (context, url) => const Text('Cargando...'),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.error, size: 50),
              )
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

  String _formatDate(DateTime? date) {
    if (date == null) return 'Fecha desconocida';
    return DateFormat('dd/MM/yyyy HH:mm').format(date.toLocal());
  }

  Widget _buildVehiclesList(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('vehicles')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildInfoBox('Vehículos', 'Error al cargar vehículos');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        final vehicles = snapshot.data?.docs ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: kPadding),
            const Text(
              'Vehículos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: kPadding / 2),
            if (vehicles.isEmpty)
              _buildInfoBox('Vehículos', 'No hay vehículos registrados')
            else
              ...vehicles.map((vehicle) => _buildVehicleCard(vehicle)),
          ],
        );
      },
    );
  }

  Widget _buildVehicleCard(DocumentSnapshot vehicle) {
    final data = vehicle.data() as Map<String, dynamic>;
    return Container(
      width: 250,
      margin: const EdgeInsets.only(bottom: kPadding / 2),
      padding: const EdgeInsets.all(kPadding / 2),
      decoration: BoxDecoration(
        border: Border.all(color: primaryColor.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVehicleInfo('Marca', data['make']),
          _buildVehicleInfo('Modelo', data['model']),
          _buildVehicleInfo('Año', data['year']),
          _buildVehicleInfo('Color', data['color']),
          _buildVehicleInfo('Placa', data['plate']),
        ],
      ),
    );
  }

  Widget _buildVehicleInfo(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          Text(
            value?.toString() ?? 'N/A',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
