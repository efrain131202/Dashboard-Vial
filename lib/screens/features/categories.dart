import 'package:flutter/material.dart';
import 'package:vial_dashboard/screens/utils/access_denied_page.dart';
import 'package:vial_dashboard/screens/utils/constants.dart';
import 'package:vial_dashboard/screens/components/create_user_form.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vial_dashboard/screens/components/search_field.dart';
import 'package:vial_dashboard/screens/components/user_actions.dart';
import 'package:vial_dashboard/screens/utils/user_data.dart';
import 'package:vial_dashboard/screens/features/categories/category_distribution_card.dart';
import 'package:vial_dashboard/screens/features/categories/recent_categories_card.dart';
import 'package:vial_dashboard/screens/features/categories/statistics_card.dart';

class Categories extends StatefulWidget {
  const Categories({super.key});

  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  Map<String, int> serviceCount = {};
  int totalCollaborators = 0;

  @override
  void initState() {
    super.initState();
    _fetchServiceCounts();
  }

  Future<void> _fetchServiceCounts() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'Colaborador')
        .get();
    if (snapshot.docs.isNotEmpty) {
      Map<String, int> counts = {};
      int collaboratorCount = 0;
      for (final doc in snapshot.docs) {
        collaboratorCount++;
        final List<dynamic>? titles = doc.data()['title'] as List<dynamic>?;
        if (titles != null) {
          for (final title in titles.cast<String>()) {
            counts[title] = (counts[title] ?? 0) + 1;
          }
        }
      }
      setState(() {
        serviceCount = counts;
        totalCollaborators = collaboratorCount;
      });
    }
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
              child: Column(
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
      ),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: RecentCategoriesCard(
            onCategoryTap: (category) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryUsersScreen(category: category),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              const StatisticsCard(),
              const SizedBox(height: 20),
              CategoryDistributionCard(serviceCount: serviceCount),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return Column(
      children: [
        RecentCategoriesCard(
          onCategoryTap: (category) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategoryUsersScreen(category: category),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        const StatisticsCard(),
        const SizedBox(height: 20),
        CategoryDistributionCard(serviceCount: serviceCount),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Categorías',
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
      'Aquí puedes gestionar todas las categorías disponibles',
      style: TextStyle(color: Colors.grey[600]),
    );
  }
}

class CategoryUsersScreen extends StatelessWidget {
  final String category;

  const CategoryUsersScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Usuarios de $category'),
        backgroundColor: primaryColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'Colaborador')
            .where('title', arrayContains: category)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center();
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text('No se encontraron usuarios para esta categoría'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final userData =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: primaryColor,
                    child: Text(
                      userData['display_name']?.substring(0, 1).toUpperCase() ??
                          '?',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(userData['display_name'] ?? 'Usuario sin nombre'),
                  subtitle: Text(userData['email'] ?? 'Sin correo electrónico'),
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded, size: 15),
                    onSelected: (String result) {
                      final user = UserData(
                        uid: snapshot.data!.docs[index].id,
                        displayName: userData['display_name'] ?? '',
                        email: userData['email'] ?? '',
                        role: userData['role'] ?? '',
                        createdTime:
                            (userData['created_time'] as Timestamp).toDate(),
                        photoUrl: userData['photo_url'],
                      );
                      switch (result) {
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
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'ver',
                        child: Text('Ver'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'editar',
                        child: Text('Editar'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'eliminar',
                        child: Text('Eliminar'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
