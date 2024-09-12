import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vial_dashboard/screens/components/constants.dart';

class UserStatsCard extends StatelessWidget {
  final List<Map<String, dynamic>> users;

  const UserStatsCard({Key? key, required this.users}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalUsers = users.length;
    final newUsersThisMonth = _calculateNewUsersThisMonth();
    final activeUsersPercentage = _calculateActiveUsersPercentage();
    final lastMonthActiveUsersPercentage =
        _calculateLastMonthActiveUsersPercentage();
    final activeUsersChange =
        activeUsersPercentage - lastMonthActiveUsersPercentage;
    final activeUsersChangeString =
        activeUsersChange >= 0 ? '+$activeUsersChange%' : '$activeUsersChange%';

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
                Icons.people_alt_rounded),
            _buildStatItem('Nuevos este mes', newUsersThisMonth.toString(),
                Icons.person_add_rounded),
            _buildStatItem('Usuarios activos', '$activeUsersPercentage%',
                Icons.check_circle_rounded,
                change: activeUsersChangeString),
          ],
        ),
      ),
    );
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

  int _calculateNewUsersThisMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    return users.where((user) {
      final createdTime = user['created_time'] as Timestamp?;
      if (createdTime == null) return false;
      return createdTime.toDate().isAfter(startOfMonth);
    }).length;
  }

  int _calculateActiveUsersPercentage() {
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

  int _calculateLastMonthActiveUsersPercentage() {
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
}
