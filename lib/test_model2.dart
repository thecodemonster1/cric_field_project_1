import 'package:flutter/widgets.dart';
import 'package:cric_field_project_1/Services/Service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    print('🔄 Loading model...');
    await FieldPlacementService.loadModel();
    print('✅ Model loaded.');

    // Sample input
    const String batsman = 'Babar Azam';
    const String overRange = 'Powerplay';
    const String pitchType = 'Batting-Friendly';
    const String bowlerVariation = 'Pace';

    // Run prediction
    print('🧠 Running prediction...');
    List<int> top9Predictions = FieldPlacementService.predictFieldPlacements(
      batsman: batsman,
      overRange: overRange,
      pitchType: pitchType,
      bowlerVariation: bowlerVariation,
    );

    print('🎯 Top 9 Predicted Shot Placements: $top9Predictions');
  } catch (e) {
    print('❌ Error occurred: $e');
  }
}
