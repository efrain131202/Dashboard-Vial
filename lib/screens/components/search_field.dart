import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vial_dashboard/screens/components/user_actions.dart';
import 'package:vial_dashboard/screens/utils/user_data.dart';

class SearchableUserList extends StatefulWidget {
  const SearchableUserList({super.key});

  @override
  _SearchableUserListState createState() => _SearchableUserListState();
}

class _SearchableUserListState extends State<SearchableUserList> {
  final TextEditingController _searchController = TextEditingController();
  List<UserData> _allUsers = [];
  List<UserData> _filteredUsers = [];
  bool _showSuggestions = false;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _fetchUsers();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    if (!mounted) return;

    setState(() {
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userData.data()?['role'] != 'Administrador') {
        throw Exception('Usuario no autorizado');
      }

      final usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      if (!mounted) return;

      setState(() {
        _allUsers = usersSnapshot.docs
            .map((doc) => UserData.fromDocument(doc))
            .toList();
        _filteredUsers = List.from(_allUsers);
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _allUsers
          .where((user) =>
              user.displayName.toLowerCase().contains(query) ||
              user.email.toLowerCase().contains(query) ||
              user.role.toLowerCase().contains(query))
          .toList();
      _showSuggestions = query.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchField(),
        const SizedBox(height: 10),
        _buildContent(),
      ],
    );
  }

  Widget _buildContent() {
    if (_hasError) {
      return _buildErrorWidget();
    }
    if (_showSuggestions) {
      return _buildSuggestionsList();
    }
    return Container();
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Buscar...',
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        border: InputBorder.none,
        fillColor: Colors.white,
        filled: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
    );
  }

  Widget _buildSuggestionsList() {
    return Container(
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
      child: _filteredUsers.isEmpty
          ? const ListTile(
              title: Text('No se encontraron usuarios'),
            )
          : ListView.separated(
              shrinkWrap: true,
              itemCount: _filteredUsers.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                if (index >= _filteredUsers.length) {
                  return null;
                }
                final user = _filteredUsers[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: user.photoUrl != null
                        ? CachedNetworkImageProvider(user.photoUrl!)
                        : null,
                    child: user.photoUrl == null
                        ? Text(user.displayName.isNotEmpty
                            ? user.displayName[0].toUpperCase()
                            : '?')
                        : null,
                  ),
                  title: Text(user.displayName),
                  subtitle: Text(user.email),
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
                  onTap: () {
                    setState(() {
                      _searchController.text = user.displayName;
                      _showSuggestions = false;
                    });
                  },
                );
              },
            ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Ocurrió un error al cargar los usuarios: $_errorMessage'),
          ElevatedButton(
            onPressed: _fetchUsers,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
