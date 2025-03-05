// WagonWheelPage.dart

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

// class WagonWheelPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final Paint paint = Paint()
//       ..color = const Color.fromARGB(255, 70, 185, 74)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 2.0;

//     final center = Offset(size.width / 2, size.height / 2);
//     final radius = size.width / 2;

//     // Draw cricket field boundary
//     canvas.drawCircle(center, radius, paint);

//     // Draw dividing lines for zones
//     for (var i = 0; i < 6; i++) {
//       final angle = (i * 60) * pi / 180;
//       final dx = radius * cos(angle);
//       final dy = radius * sin(angle);
//       canvas.drawLine(
//         center,
//         Offset(center.dx + dx, center.dy + dy),
//         paint,
//       );
//     }
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => false;
// }

class WagonWheelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw grass background
    final groundPaint = Paint()
      ..color = const Color.fromARGB(255, 69, 168, 73)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, groundPaint);

    // Draw 30-yard circle (approximately 0.6 of the boundary radius)
    final thirtyYardPaint = Paint()
      ..color = const Color.fromARGB(255, 255, 255, 255)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius * 0.6, thirtyYardPaint);

    // Draw boundary line
    final boundaryPaint = Paint()
      ..color = const Color.fromARGB(255, 195, 195, 195)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius, boundaryPaint);

    // Draw pitch rectangle in the center
    final pitchPaint = Paint()
      ..color = const Color.fromARGB(255, 194, 157, 121)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromCenter(
        center: center,
        width: 20,
        height: 80,
      ),
      pitchPaint,
    );

    // Draw fielder positions
    final fielderPaint = Paint()
      ..color = const Color.fromARGB(255, 255, 255, 255)
      ..style = PaintingStyle.fill;

    // Define fielder positions (normalized coordinates from 0 to 1)
    final fielderPositions = [
      // Close-in fielders
      {'name': 'Wicket Keeper', 'x': 0.5, 'y': 0.33}, // Wicket Keeper
      {'name': 'Slip', 'x': 0.38, 'y': 0.3}, // Slip
      {'name': 'Point', 'x': 0.25, 'y': 0.4}, // Point
      {'name': 'Square Leg', 'x': (1 - 0.25), 'y': 0.4}, // Square leg
      {'name': 'Cover', 'x': 0.25, 'y': 0.57}, // Cover
      {'name': 'Mid-wicket', 'x': (1 - 0.25), 'y': 0.57}, // Mid-wicket
      {'name': 'Mid-off', 'x': 0.35, 'y': 0.7}, // Mid-off
      {'name': 'Mid-on', 'x': (1 - 0.35), 'y': 0.7}, // Mid-on
      {'name': 'Bowler', 'x': 0.5, 'y': 0.65}, // Bowler

      // Deep fielders
      {'name': 'Third Man', 'x': 0.25, 'y': 0.12}, // Third Man
      {'name': 'Fine Leg', 'x': (1 - 0.25), 'y': 0.12}, // Fine leg
      {'name': 'Deep \nPoint', 'x': 0.05, 'y': 0.5}, // Deep Point
      {
        'name': 'Deep \nSquare \nLeg',
        'x': (1 - 0.05),
        'y': 0.5
      }, // Deep Square Leg
      {'name': 'Deep \nCover', 'x': 0.18, 'y': 0.75}, // Deep Cover
      {
        'name': 'Deep \nMid-\nWicket',
        'x': (1 - 0.18),
        'y': 0.75
      }, // Deep Mid-Wicket
      {'name': 'Long-Off', 'x': 0.43, 'y': 0.93}, // Long-Off
      {'name': 'Long-On', 'x': (1 - 0.43), 'y': 0.93}, // Long-On
    ];

    // Adjust the fielder visualization

    // Draw fielders with smaller text for better visibility
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (var fielder in fielderPositions) {
      final position = Offset(
        (fielder['x']! as double) * size.width,
        (fielder['y']! as double) * size.height,
      );

      // Draw fielder circle
      canvas.drawCircle(position, 6, fielderPaint);

      // Draw fielder label with smaller font
      textPainter.text = TextSpan(
        text: fielder['name'] as String,
        style: const TextStyle(
          color: Color.fromARGB(255, 0, 0, 0),
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        position.translate(-textPainter.width / 2, 8),
      );
    }

    // // Draw zone lines
    // final zonePaint = Paint()
    //   ..color = Colors.white.withOpacity(0.5)
    //   ..style = PaintingStyle.stroke
    //   ..strokeWidth = 1.0;

    // for (var i = 0; i < 12; i++) {
    //   final angle = (i * 30) * pi / 180;
    //   final dx = radius * cos(angle);
    //   final dy = radius * sin(angle);
    //   canvas.drawLine(
    //     center,
    //     Offset(center.dx + dx, center.dy + dy),
    //     zonePaint,
    //   );
    // }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

