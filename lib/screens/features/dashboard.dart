import 'package:flutter/material.dart';
import 'package:vial_dashboard/screens/components/create_user_form.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

const double kPadding = 32.0;
const double kSmallPadding = 15.0;
const Color primaryColor = Color(0xFF05A7A7);
const Color secondaryColor = Color(0xFFF2877C);
const Color adminColor = Color(0xFF5AED9D);

class UserData {
  final String uid;
  final String displayName;
  final String email;
  final String role;
  final DateTime createdTime;
  final String? photoUrl;

  UserData({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.role,
    required this.createdTime,
    this.photoUrl,
  });

  factory UserData.fromDocument(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return UserData(
      uid: doc.id,
      displayName: data['display_name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? '',
      createdTime: (data['created_time'] as Timestamp).toDate(),
      photoUrl: data['photo_url'],
    );
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late Future<List<UserData>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = fetchUsers();
  }

  Future<List<UserData>> fetchUsers() async {
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').get();
    return snapshot.docs.map((doc) => UserData.fromDocument(doc)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(kPadding),
            child: FutureBuilder<List<UserData>>(
              future: _usersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('No hay usuarios disponibles'));
                } else {
                  final users = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: kPadding),
                      _buildSubtitle(context),
                      const SizedBox(height: kPadding),
                      _buildSearchField(),
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
    );
  }

  Widget _buildWideLayout(List<UserData> users) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _buildPieChartCard(users),
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
        _buildPieChartCard(users),
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

  Widget _buildSearchField() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Buscar...',
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        border: InputBorder.none,
        fillColor: Colors.white,
        filled: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: kSmallPadding),
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

  Widget _buildPieChartCard(List<UserData> users) {
    int userCount = users.where((user) => user.role == 'Usuario').length;
    int collaboratorCount =
        users.where((user) => user.role == 'Colaborador').length;
    int adminCount = users.where((user) => user.role == 'Administrador').length;
    double userPercentage =
        users.isNotEmpty ? userCount / users.length * 100 : 0;
    double collaboratorPercentage =
        users.isNotEmpty ? collaboratorCount / users.length * 100 : 0;
    double adminPercentage =
        users.isNotEmpty ? adminCount / users.length * 100 : 0;

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
              'Porcentaje de usuarios',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 315,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      color: primaryColor,
                      value: userPercentage,
                      title: 'Usuarios\n${userPercentage.toStringAsFixed(1)}%',
                      radius: 100,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      color: secondaryColor,
                      value: collaboratorPercentage,
                      title:
                          'Colaboradores\n${collaboratorPercentage.toStringAsFixed(1)}%',
                      radius: 100,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      color: adminColor,
                      value: adminPercentage,
                      title:
                          'Administradores\n${adminPercentage.toStringAsFixed(1)}%',
                      radius: 100,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                  sectionsSpace: 0,
                  centerSpaceRadius: 50,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildColorLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildColorLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLegendItem(primaryColor, 'Usuarios'),
        const SizedBox(height: 10),
        _buildLegendItem(secondaryColor, 'Colaboradores'),
        const SizedBox(height: 10),
        _buildLegendItem(adminColor, 'Administradores'),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentUsersCard(List<UserData> users) {
    List<UserData> recentUsers = List.from(users)
      ..sort((a, b) => b.createdTime.compareTo(a.createdTime));
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
                return _buildUserListTile(recentUsers[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserListTile(UserData user) {
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
                  errorWidget: (context, url, error) => const Icon(Icons.error),
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
      trailing: IconButton(
        icon: const Icon(Icons.more_vert_rounded),
        onPressed: () {},
      ),
    );
  }
}
