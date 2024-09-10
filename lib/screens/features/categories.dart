import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vial_dashboard/screens/components/create_user_form.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vial_dashboard/screens/components/search_field.dart';
import 'package:vial_dashboard/screens/components/user_actions.dart';
import 'package:vial_dashboard/screens/components/user_data.dart';

const double kPadding = 32.0;
const double kSmallPadding = 15.0;
const Color primaryColor = Color(0xFF05A7A7);
const Color secondaryColor = Color(0xFFF2877C);

class Categories extends StatefulWidget {
  const Categories({super.key});

  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  Map<String, int> serviceCount = {};
  int totalCollaborators = 0;
  bool _isLoading = true;

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
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser?.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(
                  child: Text('No se encontraron datos del usuario'));
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>?;
            final userRole = userData?['role'];

            if (userRole != 'Administrador') {
              return const Center(
                child: Text(
                  'Acceso denegado. Solo los administradores pueden ver el contenido de la página',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: primaryColor,
                  ),
                ),
              );
            }

            return SingleChildScrollView(
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
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : LayoutBuilder(
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
            );
          },
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
          child: _buildCategoriesList(),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _buildCategoryStats(),
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
        _buildCategoriesList(),
        const SizedBox(height: 20),
        _buildCategoryStats(),
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

  Widget _buildCategoriesList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Categorías Recientes',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Ver todas las categorías
                  },
                  child: const Text('Ver todas',
                      style: TextStyle(color: primaryColor)),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: serviceCount.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final service = serviceCount.keys.toList()[index];
              final count = serviceCount[service]!;
              return _buildCategoryListTile({
                'name': service,
                'icon': _getIconForService(service),
                'userCount': count,
              });
            },
          ),
        ],
      ),
    );
  }

  IconData _getIconForService(String service) {
    switch (service.toLowerCase()) {
      case 'bateria':
        return Icons.battery_full_rounded;
      case 'talachería':
        return Icons.build_rounded;
      case 'grua':
        return Icons.local_shipping_rounded;
      case 'mecanico':
        return Icons.engineering_rounded;
      case 'cerrajero':
        return Icons.vpn_key_rounded;
      case 'gasolina':
        return Icons.local_gas_station_rounded;
      default:
        return Icons.miscellaneous_services_rounded;
    }
  }

  Widget _buildCategoryListTile(Map<String, dynamic> category) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(category['icon'], color: primaryColor),
      ),
      title: Text(
        category['name'],
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Text('${category['userCount']} usuarios',
          style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      trailing: IconButton(
        icon: const Icon(Icons.arrow_forward_ios_rounded, size: 15),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CategoryUsersScreen(category: category['name']),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryStats() {
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
            _buildStatItem('Total Categorías', serviceCount.length.toString(),
                Icons.business_rounded),
            _buildStatItem('Usuarios Totales', totalCollaborators.toString(),
                Icons.people_alt_rounded),
            _buildStatItem(
                'Categoría Popular',
                serviceCount.isEmpty
                    ? 'N/A'
                    : serviceCount.entries
                        .reduce((a, b) => a.value > b.value ? a : b)
                        .key,
                Icons.star_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGraphCard() {
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
              'Distribución de Categorías',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            _buildFunctionalGraph(),
          ],
        ),
      ),
    );
  }

  Widget _buildFunctionalGraph() {
    return SizedBox(
      height: 195,
      child: CustomPaint(
        size: Size.infinite,
        painter: FunctionalGraphPainter(serviceCount),
      ),
    );
  }
}

class FunctionalGraphPainter extends CustomPainter {
  final Map<String, int> serviceCount;

  FunctionalGraphPainter(this.serviceCount);

  @override
  void paint(Canvas canvas, Size size) {
    if (serviceCount.isEmpty) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final maxCount = serviceCount.values.reduce((a, b) => a > b ? a : b);
    final categories = serviceCount.keys.toList();
    final stepX = size.width / (categories.length - 1);

    final path = Path();
    for (int i = 0; i < categories.length; i++) {
      final x = i * stepX;
      final y =
          size.height - (serviceCount[categories[i]]! / maxCount) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    paint.color = primaryColor;
    canvas.drawPath(path, paint);

    final dotPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < categories.length; i++) {
      final x = i * stepX;
      final y =
          size.height - (serviceCount[categories[i]]! / maxCount) * size.height;
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < categories.length; i++) {
      final x = i * stepX;
      textPainter.text = TextSpan(
        text: categories[i],
        style: const TextStyle(color: Colors.black, fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(
          canvas, Offset(x - textPainter.width / 2, size.height + 5));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
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
            return const Center(child: CircularProgressIndicator());
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
