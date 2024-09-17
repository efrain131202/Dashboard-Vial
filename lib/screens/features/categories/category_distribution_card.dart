import 'package:flutter/material.dart';
import 'package:vial_dashboard/screens/utils/constants.dart';

class CategoryDistributionCard extends StatelessWidget {
  final Map<String, int> serviceCount;

  const CategoryDistributionCard({super.key, required this.serviceCount});

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
