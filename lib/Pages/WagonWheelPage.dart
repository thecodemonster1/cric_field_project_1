import 'package:cric_field_project_1/Services/Service.dart';
import 'package:flutter/material.dart';

class WagonWheelPage extends StatefulWidget {
  final Map<String, dynamic> inputData;
  const WagonWheelPage({super.key, required this.inputData});

  @override
  State<WagonWheelPage> createState() => _WagonWheelPageState();
}

class _WagonWheelPageState extends State<WagonWheelPage> {
  final Map<String, bool> enabledFielders = {
    'Slip': false,
    'Point': false,
    'Square Leg': false,
    'Cover': false,
    'Mid-wicket': false,
    'Mid-off': false,
    'Mid-on': false,
    'Third Man': false,
    'Fine Leg': false,
    'Deep Point': false,
    'Deep Square Leg': false,
    'Deep Cover': false,
    'Deep Mid-Wicket': false,
    'Long-Off': false,
    'Long-On': false,
  };

  int activeFielderCount = 0; // Track number of active fielders

  @override
  void initState() {
    super.initState();
    _initializeFielders();
  }

  void _initializeFielders() async {
    await FieldPlacementService.loadModel();

    // Get predictions from the model
    final predictions = FieldPlacementService.predictFieldPlacements(
      batsman: widget.inputData['batsman'],
      overRange: widget.inputData['overRange'],
      pitchType: widget.inputData['pitchType'],
      bowlerVariation: widget.inputData['bowlerVariation'],
    );

    // Print raw predictions
    print('Raw model predictions (indices): $predictions');

    // Map predictions to fielding positions
    final predictedPositions = predictions
        .map((index) =>
            FieldPlacementService.fieldingPositionMap[index] ?? 'Unknown')
        .toList();

    // Print mapped fielding positions
    print('Predicted fielding positions: $predictedPositions');

    setState(() {
      // Clear existing positions
      enabledFielders.clear();

      // Add standard fixed fielders
      enabledFielders['Wicket Keeper'] = true;
      enabledFielders['Bowler'] = true;

      // Enable top 9 predicted fielding positions
      for (var index in predictions) {
        String position =
            FieldPlacementService.fieldingPositionMap[index] ?? 'Unknown';
        enabledFielders[position] = true;
      }

      // Update active fielder count (excluding bowler and wicket keeper)
      activeFielderCount = enabledFielders.values.where((v) => v).length - 2;
    });
  }

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
      {'name': 'Slip', 'x': 0.38, 'y': 0.3},
      {'name': 'Point', 'x': 0.25, 'y': 0.4},
      {'name': 'Square Leg', 'x': (1 - 0.25), 'y': 0.4},
      {'name': 'Cover', 'x': 0.25, 'y': 0.57},
      {'name': 'Mid-wicket', 'x': (1 - 0.25), 'y': 0.57},
      {'name': 'Mid-off', 'x': 0.35, 'y': 0.7},
      {'name': 'Mid-on', 'x': (1 - 0.35), 'y': 0.7},
      {'name': 'Third Man', 'x': 0.25, 'y': 0.12},
      {'name': 'Fine Leg', 'x': (1 - 0.25), 'y': 0.12},
      {'name': 'Deep Point', 'x': 0.05, 'y': 0.5},
      {'name': 'Deep Square Leg', 'x': (1 - 0.05), 'y': 0.5},
      {'name': 'Deep Cover', 'x': 0.18, 'y': 0.75},
      {'name': 'Deep Mid-Wicket', 'x': (1 - 0.18), 'y': 0.75},
      {'name': 'Long-Off', 'x': 0.43, 'y': 0.93},
      {'name': 'Long-On', 'x': (1 - 0.43), 'y': 0.93},
    ];

    // Draw fielders
    for (var fielder in fielderPositions) {
      final position = Offset(
        (fielder['x']! as double) * size.width,
        (fielder['y']! as double) * size.height,
      );

      final isEnabled = enabledFielders[fielder['name']] ?? false;

      final fielderPaint = Paint()
        ..color = isEnabled ? Colors.white : Colors.grey.withOpacity(0.5)
        ..style = PaintingStyle.fill;

      // Draw fielder circle
      canvas.drawCircle(position, 6, fielderPaint);

      // Draw fielder label
      final textPainter = TextPainter(
        text: TextSpan(
          text: fielder['name'] as String,
          style: TextStyle(
            color: isEnabled ? Colors.black : Colors.grey,
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
