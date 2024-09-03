import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vial_dashboard/screens/components/create_user_form.dart';
import 'package:vial_dashboard/screens/components/user_actions.dart';
import 'package:vial_dashboard/screens/features/dashboard.dart';

const double kPadding = 32.0;
const double kSmallPadding = 15.0;
const Color primaryColor = Color(0xFF05A7A7);
const Color secondaryColor = Color(0xFFF2877C);
const Color adminColor = Color(0xFF5AED9D);

class Users extends StatefulWidget {
  const Users({super.key});

  @override
  State<Users> createState() => _UsersState();
}

class _UsersState extends State<Users> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<Map<String, dynamic>>> _usersFuture;
  String? _currentUserRole;
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  final TextEditingController _searchController = TextEditingController();
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _getCurrentUserRole();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        _currentUserRole = userData.data()?['role'];
        _usersFuture = _fetchUsers();
      });
    }
  }

  Future<List<Map<String, dynamic>>> _fetchUsers() async {
    if (_currentUserRole != 'Administrador') {
      return [];
    }
    final usersSnapshot =
        await FirebaseFirestore.instance.collection('users').get();
    _allUsers = usersSnapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
    _filteredUsers = List.from(_allUsers);
    return _allUsers;
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _allUsers
          .where((user) =>
              user['display_name'].toString().toLowerCase().contains(query) ||
              user['email'].toString().toLowerCase().contains(query) ||
              user['role'].toString().toLowerCase().contains(query))
          .toList();
      _showSuggestions = query.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserRole == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentUserRole != 'Administrador') {
      return const Scaffold(
        body: Center(
          child: Text(
            'Acceso denegado. Solo los administradores pueden ver el contenido de la pagina',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: primaryColor,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(kPadding),
            child: Column(
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
                      return _buildWideLayout();
                    } else {
                      return _buildNarrowLayout();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _buildUsersList(),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _buildUserStats(),
              const SizedBox(height: 20),
              _buildGraphCard(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return Column(
      children: [
        _buildUsersList(),
        const SizedBox(height: 20),
        _buildUserStats(),
        const SizedBox(height: 20),
        _buildGraphCard(),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Usuarios',
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
      'Aquí puedes gestionar todos los usuarios del sistema.',
      style: TextStyle(color: Colors.grey[600]),
    );
  }

  Widget _buildSearchField() {
    return Column(
      children: [
        TextField(
          controller: _searchController,
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
        if (_showSuggestions)
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
              itemCount: _filteredUsers.length > 5 ? 5 : _filteredUsers.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final user = _filteredUsers[index];
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
                      final userData = UserData(
                        uid: user['id'],
                        displayName: user['display_name'] ?? '',
                        email: user['email'] ?? '',
                        role: user['role'] ?? '',
                        createdTime:
                            (user['created_time'] as Timestamp).toDate(),
                        photoUrl: user['photo_url'],
                      );
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
                  onTap: () {
                    setState(() {
                      _searchController.text = user['display_name'];
                      _showSuggestions = false;
                    });
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildUsersList() {
    if (_currentUserRole != 'Administrador') {
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
    if (_currentUserRole != 'Administrador') {
      return const Center(child: Text('Acceso denegado.'));
    }
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
              ..sort((a, b) => (b['created_time'] as Timestamp)
                  .compareTo(a['created_time'] as Timestamp));
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
      uid: user['id'],
      displayName: user['display_name'] ?? '',
      email: user['email'] ?? '',
      role: user['role'] ?? '',
      createdTime: (user['created_time'] as Timestamp).toDate(),
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
                    user['display_name'].isNotEmpty
                        ? user['display_name'][0].toUpperCase()
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

  Widget _buildUserStats() {
    if (_currentUserRole != 'Administrador') {
      return const Center(child: Text('Acceso denegado.'));
    }
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _usersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay datos disponibles.'));
        }

        final users = snapshot.data!;
        final totalUsers = users.length;
        final newUsersThisMonth = _calculateNewUsersThisMonth(users);
        final activeUsersPercentage = _calculateActiveUsersPercentage(users);
        final lastMonthActiveUsersPercentage =
            _calculateLastMonthActiveUsersPercentage(users);
        final activeUsersChange =
            activeUsersPercentage - lastMonthActiveUsersPercentage;
        final activeUsersChangeString = activeUsersChange >= 0
            ? '+$activeUsersChange%'
            : '$activeUsersChange%';

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estadísticas',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                _buildStatItem('Total Usuarios', totalUsers.toString(),
                    Icons.people_rounded),
                _buildStatItem('Nuevos este mes', newUsersThisMonth.toString(),
                    Icons.person_add_rounded),
                _buildStatItem('Usuarios activos', '$activeUsersPercentage%',
                    Icons.check_circle_rounded,
                    change: activeUsersChangeString),
              ],
            ),
          ),
        );
      },
    );
  }

  int _calculateNewUsersThisMonth(List<Map<String, dynamic>> users) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    return users.where((user) {
      final createdTime = (user['created_time'] as Timestamp).toDate();
      return createdTime.isAfter(startOfMonth);
    }).length;
  }

  int _calculateActiveUsersPercentage(List<Map<String, dynamic>> users) {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    final activeUsers = users.where((user) {
      final lastActivityTime =
          (user['last_activity_time'] as Timestamp?)?.toDate();
      if (lastActivityTime == null) return false;
      return lastActivityTime.isAfter(thirtyDaysAgo);
    }).length;

    if (users.isEmpty) return 0;
    return (activeUsers / users.length * 100).round();
  }

  int _calculateLastMonthActiveUsersPercentage(
      List<Map<String, dynamic>> users) {
    final now = DateTime.now();
    final sixtyDaysAgo = now.subtract(const Duration(days: 60));
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    final activeUsers = users.where((user) {
      final lastActivityTime =
          (user['last_activity_time'] as Timestamp?)?.toDate();
      if (lastActivityTime == null) return false;
      return lastActivityTime.isAfter(sixtyDaysAgo) &&
          lastActivityTime.isBefore(thirtyDaysAgo);
    }).length;

    if (users.isEmpty) return 0;
    return (activeUsers / users.length * 100).round();
  }

  Widget _buildStatItem(String label, String value, IconData icon,
      {String? change}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: primaryColor, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    if (change != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        change,
                        style: TextStyle(
                          fontSize: 14,
                          color: change.startsWith('+')
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGraphCard() {
    if (_currentUserRole != 'Administrador') {
      return const Center(child: Text('Acceso denegado.'));
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Actividad de Usuarios',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 105,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _usersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('No hay datos disponibles.'));
                  }

                  final users = snapshot.data!;
                  final activityData = _calculateDailyActivity(users);

                  return LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() % 2 == 0) {
                                return Text(
                                  _getDayAbbreviation(value.toInt()),
                                  style: const TextStyle(fontSize: 10),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: activityData.asMap().entries.map((entry) {
                            return FlSpot(
                                entry.key.toDouble(), entry.value.toDouble());
                          }).toList(),
                          isCurved: true,
                          color: primaryColor,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: primaryColor.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<int> _calculateDailyActivity(List<Map<String, dynamic>> users) {
    final now = DateTime.now();
    final activityCounts = List.filled(7, 0);

    for (var i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: i));
      final startOfDay = DateTime(day.year, day.month, day.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      activityCounts[6 - i] = users.where((user) {
        final lastActivityTime =
            (user['last_activity_time'] as Timestamp?)?.toDate();
        return lastActivityTime != null &&
            lastActivityTime.isAfter(startOfDay) &&
            lastActivityTime.isBefore(endOfDay);
      }).length;
    }

    return activityCounts;
  }

  String _getDayAbbreviation(int daysAgo) {
    final date = DateTime.now().subtract(Duration(days: 6 - daysAgo));
    switch (date.weekday) {
      case DateTime.monday:
        return 'Lu';
      case DateTime.tuesday:
        return 'Ma';
      case DateTime.wednesday:
        return 'Mi';
      case DateTime.thursday:
        return 'Ju';
      case DateTime.friday:
        return 'Vi';
      case DateTime.saturday:
        return 'Sa';
      case DateTime.sunday:
        return 'Do';
      default:
        return '';
    }
  }
}
