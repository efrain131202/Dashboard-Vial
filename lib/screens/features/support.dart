import 'package:flutter/material.dart';
import 'package:vial_dashboard/screens/components/constants.dart';
import 'package:vial_dashboard/screens/components/search_field.dart';

class Support extends StatelessWidget {
  const Support({super.key});

  @override
  Widget build(BuildContext context) {
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
    );
  }

  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _buildSupportTicketsList(),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _buildSupportStats(),
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
        _buildSupportTicketsList(),
        const SizedBox(height: 20),
        _buildSupportStats(),
        const SizedBox(height: 20),
        _buildGraphCard(),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return const Text(
      'Soporte Técnico',
      style: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    return Text(
      'Mensajería instantánea con los usuarios',
      style: TextStyle(color: Colors.grey[600]),
    );
  }

  Widget _buildSupportTicketsList() {
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
                  'Tickets Recientes',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Ver todos',
                      style: TextStyle(color: primaryColor)),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return _buildTicketListTile(
                'Ticket #${1000 + index}',
                'Problema con la aplicación',
                'Abierto',
                'Media',
                index,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTicketListTile(String ticketId, String issue, String status,
      String priority, int index) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: _getPriorityColor(priority).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Icon(
            _getPriorityIcon(priority),
            color: _getPriorityColor(priority),
          ),
        ),
      ),
      title: Text(
        ticketId,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(issue, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  status,
                  style:
                      TextStyle(fontSize: 12, color: _getStatusColor(status)),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getPriorityColor(priority).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  priority,
                  style: TextStyle(
                      fontSize: 12, color: _getPriorityColor(priority)),
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.arrow_forward_ios_rounded, size: 15),
        onPressed: () {},
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'alta':
        return primaryColor;
      case 'media':
        return secondaryColor;
      case 'baja':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority.toLowerCase()) {
      case 'alta':
        return Icons.priority_high_rounded;
      case 'media':
        return Icons.remove_circle_outline_rounded;
      case 'baja':
        return Icons.arrow_downward_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'abierto':
        return primaryColor;
      case 'en progreso':
        return secondaryColor;
      case 'cerrado':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  Widget _buildSupportStats() {
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
            _buildStatItem('Tickets Abiertos', '15', Icons.open_in_new_rounded),
            _buildStatItem(
                'Tickets Resueltos', '45', Icons.check_circle_rounded),
            _buildStatItem(
                'Tiempo Promedio', '2h 30m', Icons.access_time_rounded),
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
              'Gráfica de Soporte',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            _buildSimpleGraph(),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleGraph() {
    return SizedBox(
      height: 230,
      child: CustomPaint(
        size: Size.infinite,
        painter: SimpleGraphPainter(),
      ),
    );
  }
}

class SimpleGraphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path1 = Path();
    final path2 = Path();

    path1.moveTo(0, size.height * 0.8);
    path1.quadraticBezierTo(size.width * 0.25, size.height * 0.3,
        size.width * 0.5, size.height * 0.5);
    path1.quadraticBezierTo(
        size.width * 0.75, size.height * 0.7, size.width, size.height * 0.2);

    path2.moveTo(0, size.height * 0.5);
    path2.quadraticBezierTo(size.width * 0.25, size.height * 0.7,
        size.width * 0.5, size.height * 0.3);
    path2.quadraticBezierTo(
        size.width * 0.75, size.height * 0.1, size.width, size.height * 0.4);

    paint.color = primaryColor;
    canvas.drawPath(path1, paint);

    paint.color = secondaryColor;
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
