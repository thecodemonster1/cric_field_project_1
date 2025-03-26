import 'package:tflite_flutter/tflite_flutter.dart';

class FieldPlacementService {
  static Interpreter? _interpreter;

  static Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/your_model.tflite');
    } catch (e) {
      print('Error loading model: $e');
    }
  }

  static List<bool> predictFieldPlacements({
    required String batsman,
    required String overRange,
    required String pitchType,
    required String bowlerVariation,
  }) {
    if (_interpreter == null) {
      return List.filled(13, false); // Default all disabled
    }

    // Prepare input data
    var input = _prepareInputData(
      batsman: batsman,
      overRange: overRange,
      pitchType: pitchType,
      bowlerVariation: bowlerVariation,
    );

    // Output buffer
    var output = List.filled(13, 0.0);

    // Run inference
    _interpreter!.run(input, output);

    // Convert probabilities to boolean decisions (threshold at 0.5)
    return output.map((prob) => prob > 0.5).toList();
  }

  static List<double> _prepareInputData({
    required String batsman,
    required String overRange,
    required String pitchType,
    required String bowlerVariation,
  }) {
    // Convert categorical variables to numerical format
    // This should match your model's training data preprocessing
    List<double> input = [];

    // Batsman encoding (0 for Babar, 1 for Buttler)
    input.add(batsman == 'Babar Azam' ? 0.0 : 1.0);

    // Over range encoding
    input.addAll([
      overRange == 'Powerplay' ? 1.0 : 0.0,
      overRange == 'Middle' ? 1.0 : 0.0,
      overRange == 'Death' ? 1.0 : 0.0,
    ]);

    // Pitch type encoding
    input.addAll([
      pitchType == 'Batting-Friendly' ? 1.0 : 0.0,
      pitchType == 'Bowler-Friendly' ? 1.0 : 0.0,
      pitchType == 'Neutral' ? 1.0 : 0.0,
    ]);

    // Bowler variation encoding
    input.add(bowlerVariation == 'Pace' ? 0.0 : 1.0);

    return input;
  }
}
