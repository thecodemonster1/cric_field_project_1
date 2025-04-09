import 'package:flutter/material.dart';
import 'package:cric_field_project_1/Services/Service.dart';
import 'package:cric_field_project_1/theme/app_theme.dart';

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
  bool showFielderNames = false; // Add this state variable
  bool isContextExpanded = true; // Track if context card is expanded

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
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Context Card with Expand/Collapse functionality
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Header row with title and expand/collapse button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Match Context",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        IconButton(
                          icon: Icon(
                            isContextExpanded
                                ? Icons.expand_less
                                : Icons.expand_more,
                            color: AppColors.primary,
                          ),
                          onPressed: () {
                            setState(() {
                              isContextExpanded = !isContextExpanded;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  // Animated container for content
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: isContextExpanded ? null : 0,
                    child: isContextExpanded
                        ? Padding(
                            padding: const EdgeInsets.fromLTRB(
                                12.0, 0.0, 12.0, 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Divider(),
                                Text("Batsman: ${widget.inputData['batsman']}",
                                    style: TextStyle(fontSize: 16)),
                                Text(
                                    "Over Range: ${widget.inputData['overRange']}",
                                    style: TextStyle(fontSize: 16)),
                                Text(
                                    "Pitch Type: ${widget.inputData['pitchType']}",
                                    style: TextStyle(fontSize: 16)),
                                Text(
                                    "Bowler Variation: ${widget.inputData['bowlerVariation']}",
                                    style: TextStyle(fontSize: 16)),
                                // const SizedBox(height: 8),
                                // Row(
                                //   children: [
                                //     Icon(Icons.assessment,
                                //         color: AppColors.primary),
                                //     const SizedBox(width: 8),
                                //     Text(
                                //       "Model Accuracy: ${(modelAccuracy * 100).toStringAsFixed(1)}%",
                                //       style: TextStyle(
                                //           fontWeight: FontWeight.bold),
                                //     ),
                                //   ],
                                // ),
                              ],
                            ),
                          )
                        : Container(), // Empty container when collapsed
                  ),
                ],
              ),
            ),
            // const SizedBox(height: 20),
            // Add toggle switch for fielder names
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Show fielder names"),
                Switch(
                  value: showFielderNames,
                  onChanged: (value) {
                    setState(() {
                      showFielderNames = value;
                    });
                  },
                  activeColor: Colors.green[700],
                ),
              ],
            ),
            // const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  // flex: 1,
                  child: Center(
                    child: CustomPaint(
                      size: const Size(350, 350),
                      painter: WagonWheelPainter(
                        topFielders, // Pass the complete list with name and rank
                        showFielderNames, // Pass the state to the painter
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Card(
              margin: const EdgeInsets.only(top: 8, bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Fielding Position Priority",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 40,
                      child: Row(
                        children: [
                          Expanded(
                            child: CustomPaint(
                              painter: HeatmapBarPainter(),
                              size: Size(double.infinity, 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Higher Priority",
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          "Lower Priority",
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
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
  final List<Map<String, dynamic>> rankedFielders; // Change parameter type
  final bool showNames;

  WagonWheelPainter(this.rankedFielders, this.showNames);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw field (existing code)
    final Paint ground = Paint()..color = AppColors.fieldGreen;
    final Paint boundary = Paint()
      ..color = AppColors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, ground);
    canvas.drawCircle(center, radius, boundary);
    canvas.drawCircle(center, radius * 0.6, boundary);

    // Draw pitch
    final Paint pitchPaint = Paint()..color = Colors.brown;
    canvas.drawRect(
        Rect.fromCenter(center: center, width: 20, height: 80), pitchPaint);

    // Extract the highlighted position names
    List<String> highlightedPositions =
        rankedFielders.map((e) => e['name'] as String).toList();

    // Create a map of name to rank for quick lookup
    Map<String, int> positionRanks = {};
    for (var fielder in rankedFielders) {
      positionRanks[fielder['name']] = fielder['rank'];
    }

    final positions = {
      'Slips': Offset(0.38, 0.3),
      'Point': Offset(0.25, 0.4),
      'Square Leg': Offset(0.75, 0.4),
      'Cover': Offset(0.25, 0.57),
      'Mid-Wicket': Offset(0.75, 0.57),
      'Mid-Off': Offset(0.35, 0.7),
      'Mid-On': Offset(0.65, 0.7),
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

    // Draw the fixed positions (keeper and bowler)
    for (var entry in positions.entries) {
      final isActive = highlightedPositions.contains(entry.key) ||
          entry.key == 'Wicket Keeper' ||
          entry.key == 'Bowler';
      final offset =
          Offset(entry.value.dx * size.width, entry.value.dy * size.height);

      // Different colors based on rank or default positions
      Color dotColor;
      if (entry.key == 'Wicket Keeper' || entry.key == 'Bowler') {
        dotColor = Colors.white; // Always white for keeper and bowler
      } else if (highlightedPositions.contains(entry.key)) {
        // Gradient colors based on rank (1=green, 9=yellow)
        int rank = positionRanks[entry.key] ?? 5;
        double rankRatio = (rank - 1) / 8.0; // From 0.0 to 1.0
        dotColor = Color.lerp(
            AppColors.fieldingHotspot, AppColors.secondary, rankRatio)!;
      } else {
        dotColor = Colors.grey.withOpacity(0.4); // Inactive positions
      }

      // Draw fielder dot
      canvas.drawCircle(offset, 8, Paint()..color = dotColor);

      // Draw rank number on top of the fielder dot if it's a highlighted position
      if (highlightedPositions.contains(entry.key)) {
        final rankSpan = TextSpan(
          text: '${positionRanks[entry.key]}',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        );

        final rankPainter = TextPainter(
          text: rankSpan,
          textDirection: TextDirection.ltr,
        );

        rankPainter.layout();
        rankPainter.paint(
          canvas,
          Offset(offset.dx - rankPainter.width / 2,
              offset.dy - rankPainter.height / 2),
        );
      }

      // Draw fielder name if enabled
      if (showNames) {
        final textSpan = TextSpan(
          text: entry.key,
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            shadows: [
              Shadow(
                blurRadius: 2.0,
                color: Colors.black,
                offset: Offset(1.0, 1.0),
              ),
            ],
          ),
        );

        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );

        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(offset.dx - (textPainter.width / 2), offset.dy + 10),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant WagonWheelPainter oldDelegate) {
    return oldDelegate.rankedFielders != rankedFielders ||
        oldDelegate.showNames != showNames;
  }
}

// Add this class at the end of the file, after WagonWheelPainter

class HeatmapBarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Create gradient from red (high priority) to yellow (low priority)
    final gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        AppColors.fieldingHotspot, // Red for high priority
        AppColors.secondary, // Yellow/amber for low priority
      ],
    );

    // Apply the gradient to a paint object
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    // Draw rounded rectangle for the heatmap bar
    canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(4.0)), paint);

    // Add border
    final borderPaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(4.0)), borderPaint);

    // Add tick marks if desired
    for (int i = 0; i <= 4; i++) {
      final x = size.width * i / 4;
      canvas.drawLine(
          Offset(x, 0),
          Offset(x, 4),
          Paint()
            ..color = Colors.white
            ..strokeWidth = 1);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
