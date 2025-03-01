// WagonWheelPage.dart
import 'dart:math';

import 'package:flutter/material.dart';

class WagonWheelPage extends StatelessWidget {
  const WagonWheelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wagon Wheel'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: CustomPaint(
          size: const Size(300, 300),
          painter: WagonWheelPainter(),
        ),
      ),
    );
  }
}

class WagonWheelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw cricket field boundary
    canvas.drawCircle(center, radius, paint);

    // Draw dividing lines for zones
    for (var i = 0; i < 6; i++) {
      final angle = (i * 60) * pi / 180;
      final dx = radius * cos(angle);
      final dy = radius * sin(angle);
      canvas.drawLine(
        center,
        Offset(center.dx + dx, center.dy + dy),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}