import 'package:flutter/material.dart';
import 'package:vial_dashboard/screens/utils/constants.dart';

class GraphCard extends StatelessWidget {
  const GraphCard({super.key});

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
              'Actividad de Mensajería',
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
