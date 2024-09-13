import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vial_dashboard/screens/components/constants.dart';

class StatisticsCard extends StatefulWidget {
  const StatisticsCard({super.key});

  @override
  _StatisticsCardState createState() => _StatisticsCardState();
}

class _StatisticsCardState extends State<StatisticsCard> {
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
}
