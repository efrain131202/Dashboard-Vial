import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vial_dashboard/screens/components/user_actions.dart';
import 'package:vial_dashboard/screens/features/dashboard.dart';

Widget buildSearchField({
  required TextEditingController searchController,
  required bool showSuggestions,
  required List<Map<String, dynamic>> filteredUsers,
  required void Function() onSearch,
  required Function(Map<String, dynamic>) onUserTap,
}) {
  return Column(
    children: [
      TextField(
        controller: searchController,
        onChanged: (_) => onSearch(),
        decoration: InputDecoration(
          hintText: 'Buscar...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          border: InputBorder.none,
          fillColor: Colors.white,
          filled: true,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 20, vertical: kSmallPadding),
          prefixIcon:
              Icon(Icons.search_rounded, color: Colors.grey[400], size: 20),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.grey[400]!, width: 1),
          ),
        ),
      ),
      if (showSuggestions)
        Container(
          margin: const EdgeInsets.only(top: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: filteredUsers.length > 5 ? 5 : filteredUsers.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final user = filteredUsers[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: user['photo_url'] != null
                      ? CachedNetworkImageProvider(user['photo_url'])
                      : null,
                  child: user['photo_url'] == null
                      ? Text(user['display_name'][0].toUpperCase())
                      : null,
                ),
                title: Text(user['display_name']),
                subtitle: Text(user['email']),
                trailing: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, size: 15),
                  itemBuilder: (context) => [
                    const PopupMenuItem<String>(
                      value: 'ver',
                      child: Row(
                        children: [
                          Icon(Icons.visibility, size: 20),
                          SizedBox(width: 8),
                          Text('Ver'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'editar',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'eliminar',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20),
                          SizedBox(width: 8),
                          Text('Eliminar'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'ver':
                        viewUser(
                            context,
                            UserData(
                              uid: user['id'],
                              displayName: user['display_name'] ?? '',
                              email: user['email'] ?? '',
                              role: user['role'] ?? '',
                              createdTime:
                                  (user['created_time'] as Timestamp).toDate(),
                              photoUrl: user['photo_url'],
                            ));
                        break;
                      case 'editar':
                        editUser(
                            context,
                            UserData(
                              uid: user['id'],
                              displayName: user['display_name'] ?? '',
                              email: user['email'] ?? '',
                              role: user['role'] ?? '',
                              createdTime:
                                  (user['created_time'] as Timestamp).toDate(),
                              photoUrl: user['photo_url'],
                            ));
                        break;
                      case 'eliminar':
                        deleteUser(
                            context,
                            UserData(
                              uid: user['id'],
                              displayName: user['display_name'] ?? '',
                              email: user['email'] ?? '',
                              role: user['role'] ?? '',
                              createdTime:
                                  (user['created_time'] as Timestamp).toDate(),
                              photoUrl: user['photo_url'],
                            ));
                        break;
                    }
                  },
                ),
                onTap: () => onUserTap(user),
              );
            },
          ),
        ),
    ],
  );
}
