import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:vial_dashboard/screens/utils/constants.dart';
import 'package:vial_dashboard/screens/utils/user_data.dart';

class UserPercentageCard extends StatelessWidget {
  final List<UserData> users;

  const UserPercentageCard({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
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
                      title: '${userPercentage.toStringAsFixed(1)}%',
                      radius: 110,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      color: secondaryColor,
                      value: collaboratorPercentage,
                      title: '${collaboratorPercentage.toStringAsFixed(1)}%',
                      radius: 110,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      color: adminColor,
                      value: adminPercentage,
                      title: '${adminPercentage.toStringAsFixed(1)}%',
                      radius: 110,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                  sectionsSpace: 4,
                  centerSpaceRadius: 40,
                  startDegreeOffset: 30,
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
}
