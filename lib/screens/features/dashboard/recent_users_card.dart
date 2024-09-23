import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vial_dashboard/screens/utils/constants.dart';
import 'package:vial_dashboard/screens/utils/user_data.dart';
import 'package:vial_dashboard/screens/components/user_actions.dart';

class RecentUsersCard extends StatelessWidget {
  final List<UserData> users;

  const RecentUsersCard({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    List<UserData> recentUsers = List.from(users)
      ..sort((a, b) {
        if (a.createdTime == null && b.createdTime == null) return 0;
        if (a.createdTime == null) return 1;
        if (b.createdTime == null) return -1;
        return b.createdTime!.compareTo(a.createdTime!);
      });
    recentUsers = recentUsers.take(5).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Usuarios Recientes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentUsers.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return _buildUserListTile(context, recentUsers[index]);
              },
            ),
          ],
        ),
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
