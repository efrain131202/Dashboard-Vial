import 'package:flutter/material.dart';
import 'package:vial_dashboard/screens/utils/access_denied_page.dart';
import 'package:vial_dashboard/screens/utils/constants.dart';
import 'package:vial_dashboard/screens/components/create_user_form.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vial_dashboard/screens/components/search_field.dart';
import 'package:vial_dashboard/screens/features/categories/category_distribution_card.dart';
import 'package:vial_dashboard/screens/features/categories/recent_categories_card.dart';
import 'package:vial_dashboard/screens/features/categories/statistics_card.dart';
import 'package:vial_dashboard/screens/features/categories/category_users_screen.dart';

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
