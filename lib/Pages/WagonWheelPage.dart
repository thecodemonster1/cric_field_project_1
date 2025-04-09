import 'package:flutter/material.dart';
import 'package:cric_field_project_1/Services/Service.dart';

class WagonWheelPage extends StatefulWidget {
  final Map<String, dynamic> inputData;
  const WagonWheelPage({super.key, required this.inputData});

  @override
  State<WagonWheelPage> createState() => _WagonWheelPageState();
}

class _WagonWheelPageState extends State<WagonWheelPage> {
  List<Map<String, dynamic>> topFielders = [];
  List<String> topShotTypes = [];
  double modelAccuracy = 0.2; // Static display, can be dynamic if needed

  @override
  void initState() {
    super.initState();
    _initializePrediction();
  }

  Future<void> _initializePrediction() async {
    await FieldPlacementService.loadModel();

    final result = await FieldPlacementService.predictFieldPlacements(
      batsman: widget.inputData['batsman'],
      overRange: widget.inputData['overRange'],
      pitchType: widget.inputData['pitchType'],
      bowlerVariation: widget.inputData['bowlerVariation'],
    );

    final placements = result['placement'];
    final shots = result['shotType'];

    final fieldingPositionMap = FieldPlacementService.fieldingPositionMap;
    final shotTypeMap = FieldPlacementService.shotTypeMap;

    setState(() {
      topFielders = placements
              ?.asMap()
              .entries
              .map((e) => {
                    'name': fieldingPositionMap[e.value] ?? 'Unknown',
                    'rank': e.key + 1
                  })
              .toList() ??
          [];

      topShotTypes =
          shots?.map((i) => shotTypeMap[i] ?? 'Unknown').toList() ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CricField Analyzer'),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Match Context",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text("Batsman: ${widget.inputData['batsman']}",
                        style: TextStyle(fontSize: 16)),
                    Text("Over Range: ${widget.inputData['overRange']}",
                        style: TextStyle(fontSize: 16)),
                    Text("Pitch Type: ${widget.inputData['pitchType']}",
                        style: TextStyle(fontSize: 16)),
                    Text(
                        "Bowler Variation: ${widget.inputData['bowlerVariation']}",
                        style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.assessment, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                            "Model Accuracy: ${(modelAccuracy * 100).toStringAsFixed(1)}%",
                            style: TextStyle(fontWeight: FontWeight.bold))
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 60),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: CustomPaint(
                    size: const Size(300, 300),
                    painter: WagonWheelPainter(
                        topFielders.map((e) => e['name'] as String).toList()),
                  ),
                ),
              ],
              // ),
            ),
            const SizedBox(height: 60),
            Expanded(
              child: ListView(
                children: [
                  const Text("Top Fielding Positions (Ranked)",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ...topFielders.map((fielder) => ListTile(
                        leading: CircleAvatar(
                            child: Text(fielder['rank'].toString())),
                        title: Text(fielder['name']),
                      )),
                  const Divider(),
                  const Text("Top Shot Types",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ...topShotTypes.map((shot) => ListTile(
                        leading: Icon(Icons.sports_cricket),
                        title: Text(shot),
                      )),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class WagonWheelPainter extends CustomPainter {
  final List<String> highlightedPositions;
  WagonWheelPainter(this.highlightedPositions);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final Paint ground = Paint()..color = Colors.green;
    final Paint boundary = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, ground);
    canvas.drawCircle(center, radius, boundary);
    canvas.drawCircle(center, radius * 0.6, boundary);

    // Dummy pitch
    final Paint pitchPaint = Paint()..color = Colors.brown;
    canvas.drawRect(
        Rect.fromCenter(center: center, width: 20, height: 80), pitchPaint);

    final positions = {
      'Slip': Offset(0.38, 0.3),
      'Point': Offset(0.25, 0.4),
      'Square Leg': Offset(0.75, 0.4),
      'Cover': Offset(0.25, 0.57),
      'Mid-Wicket': Offset(0.75, 0.57),
      'Mid-off': Offset(0.35, 0.7),
      'Mid-on': Offset(0.65, 0.7),
      'Third Man': Offset(0.25, 0.12),
      'Fine Leg': Offset(0.75, 0.12),
      'Deep Point': Offset(0.05, 0.5),
      'Deep Square Leg': Offset(0.95, 0.5),
      'Deep Cover': Offset(0.18, 0.75),
      'Deep Mid-Wicket': Offset(0.82, 0.75),
      'Long-Off': Offset(0.43, 0.93),
      'Long-On': Offset(0.57, 0.93),
      'Wicket Keeper': Offset(0.5, 0.3),
      'Bowler': Offset(0.5, 0.7),
    };

    for (var entry in positions.entries) {
      final isActive = highlightedPositions.contains(entry.key);
      final offset =
          Offset(entry.value.dx * size.width, entry.value.dy * size.height);
      final color = isActive ? Colors.white : Colors.grey.withOpacity(0.4);
      canvas.drawCircle(offset, 6, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant WagonWheelPainter oldDelegate) {
    return oldDelegate.highlightedPositions != highlightedPositions;
  }
}
