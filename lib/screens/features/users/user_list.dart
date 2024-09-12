import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vial_dashboard/screens/components/constants.dart';
import 'package:vial_dashboard/screens/components/user_data.dart';
import 'package:vial_dashboard/screens/components/user_actions.dart';

class UserList extends StatefulWidget {
  final String currentUserRole;

  const UserList({super.key, required this.currentUserRole});

  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<Map<String, dynamic>>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _usersFuture = _fetchUsers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _fetchUsers() async {
    if (widget.currentUserRole != 'Administrador') {
      return [];
    }
    final usersSnapshot =
        await FirebaseFirestore.instance.collection('users').get();
    return usersSnapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      if (data['created_time'] == null) {
        data['created_time'] = Timestamp.now();
      }
      return data;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentUserRole != 'Administrador') {
      return const Center(child: Text('Acceso denegado.'));
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          _buildTabBar(),
          SizedBox(
            height: 467,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUserListView('Recientes'),
                _buildUserListView('Usuarios'),
                _buildUserListView('Colaboradores'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      labelColor: Colors.black,
      unselectedLabelColor: Colors.grey,
      indicatorColor: primaryColor,
      tabs: const [
        Tab(text: 'Recientes'),
        Tab(text: 'Usuarios'),
        Tab(text: 'Colaboradores'),
      ],
    );
  }

  Widget _buildUserListView(String userType) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _usersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No se encontraron usuarios.'));
        }

        final allUsers = snapshot.data!;
        List<Map<String, dynamic>> filteredUsers;

        switch (userType) {
          case 'Recientes':
            filteredUsers = List.from(allUsers)
              ..sort((a, b) {
                final aTime = a['created_time'] as Timestamp?;
                final bTime = b['created_time'] as Timestamp?;
                if (aTime == null && bTime == null) return 0;
                if (aTime == null) return 1;
                if (bTime == null) return -1;
                return bTime.compareTo(aTime);
              });
            filteredUsers = filteredUsers.take(5).toList();
            break;
          case 'Usuarios':
            filteredUsers =
                allUsers.where((user) => user['role'] == 'Usuario').toList();
            break;
          case 'Colaboradores':
            filteredUsers = allUsers
                .where((user) => user['role'] == 'Colaborador')
                .toList();
            break;
          default:
            filteredUsers = allUsers;
        }

        if (filteredUsers.isEmpty) {
          return Center(
              child: Text('No se encontraron ${userType.toLowerCase()}.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: filteredUsers.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            return _buildUserListTile(filteredUsers[index]);
          },
        );
      },
    );
  }

  Widget _buildUserListTile(Map<String, dynamic> user) {
    Color borderColor;
    switch (user['role']) {
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

    UserData userData = UserData(
      uid: user['id'] ?? '',
      displayName: user['display_name'] ?? '',
      email: user['email'] ?? '',
      role: user['role'] ?? '',
      createdTime:
          (user['created_time'] as Timestamp?)?.toDate() ?? DateTime.now(),
      photoUrl: user['photo_url'],
    );

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 2),
        ),
        child: ClipOval(
          child: user['photo_url'] != null
              ? CachedNetworkImage(
                  imageUrl: user['photo_url'],
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.error_rounded),
                )
              : CircleAvatar(
                  backgroundColor: borderColor,
                  child: Text(
                    (user['display_name'] ?? '').isNotEmpty
                        ? (user['display_name'] ?? '')[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
        ),
      ),
      title: Text(
        user['display_name'] ?? 'Nombre desconocido',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user['email'] ?? 'Email desconocido',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          Text(
            user['role'] ?? 'Rol desconocido',
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
              viewUser(context, userData);
              break;
            case 'editar':
              editUser(context, userData);
              break;
            case 'eliminar':
              deleteUser(context, userData);
              break;
          }
        },
      ),
    );
  }
}
