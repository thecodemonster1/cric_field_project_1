import 'package:flutter/widgets.dart';
import 'package:cric_field_project_1/Services/Service.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load the model
  await FieldPlacementService.loadModel();

  // Sample input
  String batsman = 'Babar Azam';
  String overRange = 'Powerplay';
  String pitchType = 'Batting-Friendly';
  String bowlerVariation = 'Pace';

  // Predict shot placements
  List<int> top9Predictions = FieldPlacementService.predictFieldPlacements(
    batsman: batsman,
    overRange: overRange,
    pitchType: pitchType,
    bowlerVariation: bowlerVariation,
  );

  print('Top 9 Predicted Shot Placements: $top9Predictions');
}
