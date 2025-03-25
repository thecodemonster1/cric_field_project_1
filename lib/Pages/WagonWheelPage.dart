import 'package:flutter/material.dart';
import 'dart:math' show pi;

class WagonWheelPage extends StatefulWidget {
  const WagonWheelPage({super.key});

  @override
  State<WagonWheelPage> createState() => _WagonWheelPageState();
}

class _WagonWheelPageState extends State<WagonWheelPage> {
  final Map<String, bool> enabledFielders = {
    'Slip': true,
    'Point': true,
    'Square Leg': true,
    'Cover': true,
    'Mid-wicket': true,
    'Mid-off': true,
    'Mid-on': true,
    'Third Man': true,
    'Fine Leg': true,
    'Deep Point': false,
    'Deep Square Leg': false,
    'Deep Cover': false,
    'Deep Mid-Wicket': false,
    'Long-Off': false,
    'Long-On': false,
  };

  int activeFielderCount = 9; // Track number of active fielders

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Field Placement'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Center(
              child: CustomPaint(
                size: const Size(300, 300),
                painter: WagonWheelPainter(enabledFielders),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    'Active Fielders: $activeFielderCount/9',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: enabledFielders.keys
                          .where((key) =>
                              key != 'Wicket Keeper' && key != 'Bowler')
                          .map((fielder) {
                        return CheckboxListTile(
                          title: Text(fielder),
                          value: enabledFielders[fielder],
                          onChanged: (activeFielderCount < 9 ||
                                  enabledFielders[fielder] == true)
                              ? (bool? value) {
                                  setState(() {
                                    if (value == true) {
                                      activeFielderCount++;
                                    } else {
                                      activeFielderCount--;
                                    }
                                    enabledFielders[fielder] = value!;
                                  });
                                }
                              : null,
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WagonWheelPainter extends CustomPainter {
  final Map<String, bool> enabledFielders;

  WagonWheelPainter(this.enabledFielders);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw grass background
    final groundPaint = Paint()
      ..color = const Color.fromARGB(255, 69, 168, 73)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, groundPaint);

    // Draw 30-yard circle
    final thirtyYardPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius * 0.6, thirtyYardPaint);

    // Draw boundary
    final boundaryPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius, boundaryPaint);

    // Draw pitch
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

    // Define fielder positions
    final fielderPositions = [
      // Close-in fielders
      {'name': 'Wicket Keeper', 'x': 0.5, 'y': 0.33, 'fixed': true},
      {'name': 'Bowler', 'x': 0.5, 'y': 0.65, 'fixed': true},
      {'name': 'Slip', 'x': 0.38, 'y': 0.3, 'fixed': false}, // Slip
      {'name': 'Point', 'x': 0.25, 'y': 0.4, 'fixed': false}, // Point
      {
        'name': 'Square Leg',
        'x': (1 - 0.25),
        'y': 0.4,
        'fixed': false
      }, // Square leg
      {'name': 'Cover', 'x': 0.25, 'y': 0.57, 'fixed': false}, // Cover
      {
        'name': 'Mid-wicket',
        'x': (1 - 0.25),
        'y': 0.57,
        'fixed': false
      }, // Mid-wicket
      {'name': 'Mid-off', 'x': 0.35, 'y': 0.7, 'fixed': false}, // Mid-off
      {'name': 'Mid-on', 'x': (1 - 0.35), 'y': 0.7, 'fixed': false}, // Mid-on

      // Deep fielders
      {'name': 'Third Man', 'x': 0.25, 'y': 0.12, 'fixed': false}, // Third Man
      {
        'name': 'Fine Leg',
        'x': (1 - 0.25),
        'y': 0.12,
        'fixed': false
      }, // Fine leg
      {
        'name': 'Deep \nPoint',
        'x': 0.05,
        'y': 0.5,
        'fixed': false
      }, // Deep Point
      {
        'name': 'Deep \nSquare \nLeg',
        'x': (1 - 0.05),
        'y': 0.5,
        'fixed': false
      }, // Deep Square Leg
      {
        'name': 'Deep \nCover',
        'x': 0.18,
        'y': 0.75,
        'fixed': false
      }, // Deep Cover
      {
        'name': 'Deep \nMid-\nWicket',
        'x': (1 - 0.18),
        'y': 0.75,
        'fixed': false
      }, // Deep Mid-Wicket
      {'name': 'Long-Off', 'x': 0.43, 'y': 0.93, 'fixed': false}, // Long-Off
      {
        'name': 'Long-On',
        'x': (1 - 0.43),
        'y': 0.93,
        'fixed': false
      }, // Long-On
    ];

    // Draw fielders
    for (var fielder in fielderPositions) {
      final position = Offset(
        (fielder['x']! as double) * size.width,
        (fielder['y']! as double) * size.height,
      );

      final isFixed = fielder['fixed'] as bool;
      final isEnabled = isFixed || enabledFielders[fielder['name']] == true;

      final fielderPaint = Paint()
        ..color = isEnabled ? Colors.white : Colors.grey.withOpacity(0.0)
        ..style = PaintingStyle.fill;

      // Draw fielder circle
      canvas.drawCircle(position, 6, fielderPaint);

      // Draw fielder label
      final textPainter = TextPainter(
        text: TextSpan(
          text: fielder['name'] as String,
          style: TextStyle(
            color: isEnabled ? Colors.black : Colors.grey.withOpacity(0.0),
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        position.translate(-textPainter.width / 2, 8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant WagonWheelPainter oldDelegate) {
    return oldDelegate.enabledFielders != enabledFielders;
  }
}
