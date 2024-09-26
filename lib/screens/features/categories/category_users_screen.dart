import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vial_dashboard/screens/utils/constants.dart';
import 'package:vial_dashboard/screens/utils/user_data.dart';
import 'package:vial_dashboard/screens/components/user_actions.dart';

class CategoryUsersScreen extends StatelessWidget {
  final String category;

  const CategoryUsersScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Usuarios de $category',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2C3E50),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'Colaborador')
            .where('title', arrayContains: category)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text('No se encontraron usuarios para esta categoría'));
          }

          return ListView.separated(
            itemCount: snapshot.data!.docs.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final userData =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              final user = UserData(
                uid: snapshot.data!.docs[index].id,
                displayName: userData['display_name'] ?? '',
                email: userData['email'] ?? '',
                role: userData['role'] ?? '',
                createdTime: (userData['created_time'] as Timestamp).toDate(),
                photoUrl: userData['photo_url'],
                phoneNumber: '',
              );
              return _buildUserListTile(context, user);
            },
          );
        },
      ),
    );
  }

  Widget _buildUserListTile(BuildContext context, UserData user) {
    Color borderColor;
    switch (user.role) {
      case 'Usuario':
        borderColor = primaryColor;
        break;
      case 'Colaborador':
        borderColor = secondaryColor;
        break;
      case 'Administrador':
        borderColor = adminColor;
        break;
      default:
        borderColor = Colors.grey;
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      leading: Container(
        padding: const EdgeInsets.all(2),
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 2),
        ),
        child: ClipOval(
          child: user.photoUrl != null
              ? CachedNetworkImage(
                  imageUrl: user.photoUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.error_rounded),
                )
              : CircleAvatar(
                  backgroundColor: borderColor,
                  child: Text(
                    user.displayName.isNotEmpty
                        ? user.displayName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
        ),
      ),
      title: Text(
        user.displayName,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user.email,
            style: const TextStyle(
                fontSize: 12, color: Color.fromARGB(255, 117, 117, 117)),
          ),
          Text(
            user.role,
            style: TextStyle(
                fontSize: 12, color: borderColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert_rounded, size: 15),
        itemBuilder: (context) => [
          const PopupMenuItem<String>(
            value: 'ver',
            child: Row(
              children: [
                Icon(Icons.visibility_rounded, size: 20),
                SizedBox(width: 8),
                Text('Ver'),
              ],
            ),
          ),
          const PopupMenuItem<String>(
            value: 'editar',
            child: Row(
              children: [
                Icon(Icons.edit_rounded, size: 20),
                SizedBox(width: 8),
                Text('Editar'),
              ],
            ),
          ),
          const PopupMenuItem<String>(
            value: 'eliminar',
            child: Row(
              children: [
                Icon(Icons.delete_rounded, size: 20),
                SizedBox(width: 8),
                Text('Eliminar'),
              ],
            ),
          ),
        ],
        onSelected: (value) {
          switch (value) {
            case 'ver':
              viewUser(context, user);
              break;
            case 'editar':
              editUser(context, user);
              break;
            case 'eliminar':
              deleteUser(context, user);
              break;
          }
        },
      ),
    );
  }
}
