import 'package:flutter/material.dart';
import 'package:vial_dashboard/screens/utils/access_denied_page.dart';
import 'package:vial_dashboard/screens/utils/constants.dart';
import 'package:vial_dashboard/screens/components/create_user_form.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vial_dashboard/screens/components/search_field.dart';
import 'package:vial_dashboard/screens/utils/user_data.dart';
import 'package:vial_dashboard/screens/features/dashboard/recent_users_card.dart';
import 'package:vial_dashboard/screens/features/dashboard/user_percentage_card.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late Future<List<UserData>> _usersFuture;
  List<UserData> _allUsers = [];
  List<UserData> _filteredUsers = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _usersFuture = fetchUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<UserData>> fetchUsers() async {
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').get();
    _allUsers = snapshot.docs.map((doc) => UserData.fromDocument(doc)).toList();
    _filteredUsers = List.from(_allUsers);
    return _allUsers;
  }

  List<Map<String, dynamic>> get usersMaps {
    return _filteredUsers.map((user) {
      return {
        'uid': user.uid,
        'display_name': user.displayName,
        'email': user.email,
        'role': user.role,
        'created_time': user.createdTime,
        'photo_url': user.photoUrl,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return withAdminAccess(
      Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(kPadding),
              child: FutureBuilder<List<UserData>>(
                future: _usersFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData) {
                    return Container();
                  } else {
                    final users = snapshot.data!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context),
                        const SizedBox(height: kPadding),
                        _buildSubtitle(context),
                        const SizedBox(height: kPadding),
                        const SearchableUserList(),
                        const SizedBox(height: kPadding),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth > 900) {
                              return _buildWideLayout(users);
                            } else {
                              return _buildNarrowLayout(users);
                            }
                          },
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWideLayout(List<UserData> users) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: UserPercentageCard(users: users),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 1,
          child: _buildRecentUsersCard(users),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(List<UserData> users) {
    return Column(
      children: [
        UserPercentageCard(users: users),
        const SizedBox(height: 20),
        _buildRecentUsersCard(users),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Dashboard',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateUserForm(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(kSmallPadding),
            backgroundColor: primaryColor,
          ),
          child: const Text(
            'Nuevo Usuario',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    return Text(
      'A continuación se presenta un resumen de la actividad del equipo.',
      style: TextStyle(color: Colors.grey[600]),
    );
  }

  Widget _buildRecentUsersCard(List<UserData> users) {
    return RecentUsersCard(users: users);
  }
}
