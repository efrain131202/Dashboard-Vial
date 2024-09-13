import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vial_dashboard/screens/components/constants.dart';

class RecentCategoriesCard extends StatefulWidget {
  final Function(String) onCategoryTap;

  const RecentCategoriesCard({
    super.key,
    required this.onCategoryTap,
  });

  @override
  _RecentCategoriesCardState createState() => _RecentCategoriesCardState();
}

class _RecentCategoriesCardState extends State<RecentCategoriesCard> {
  Map<String, int> serviceCount = {};
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
      for (final doc in snapshot.docs) {
        final List<dynamic>? titles = doc.data()['title'] as List<dynamic>?;
        if (titles != null) {
          for (final title in titles.cast<String>()) {
            counts[title] = (counts[title] ?? 0) + 1;
          }
        }
      }
      setState(() {
        serviceCount = counts;
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
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
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
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
        onPressed: () => widget.onCategoryTap(category['name']),
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
}
