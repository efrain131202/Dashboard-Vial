import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vial_dashboard/screens/components/constants.dart';

class UserActivityCard extends StatelessWidget {
  final List<Map<String, dynamic>> users;

  const UserActivityCard({Key? key, required this.users}) : super(key: key);

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
              child: LineChart(
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
                      spots: _calculateDailyActivity()
                          .asMap()
                          .entries
                          .map((entry) {
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<int> _calculateDailyActivity() {
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
