import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:math';

class FieldPlacementService {
  static Interpreter? _interpreter;

  // Mapping shot placement indices to fielder positions
  static final Map<int, String> fieldingPositionMap = {
    0: 'Slip',
    1: 'Point',
    2: 'Cover',
    3: 'Mid-off',
    4: 'Mid-on',
    5: 'Mid-wicket',
    6: 'Square Leg',
    7: 'Fine Leg',
    8: 'Third Man',
    9: 'Deep Point',
    10: 'Deep Cover',
    11: 'Long-Off',
    12: 'Long-On',
    13: 'Deep Mid-Wicket',
    14: 'Deep Square Leg',
  };

  static Future<void> loadModel() async {
    try {
      print('Loading TFLite model...');
      _interpreter =
          await Interpreter.fromAsset('lib/Assets/cricfield_model.tflite');
      print('Model loaded successfully');
    } catch (e) {
      print('Error loading model: $e');
    }
  }

  static List<int> predictFieldPlacements({
    required String batsman,
    required String overRange,
    required String pitchType,
    required String bowlerVariation,
  }) {
    if (_interpreter == null) {
      print('Interpreter is null - model not loaded');
      return [];
    }

    print('Making prediction with inputs:');
    print('Batsman: $batsman');
    print('Over Range: $overRange');
    print('Pitch Type: $pitchType');
    print('Bowler Variation: $bowlerVariation');

    // Prepare input data
    final List<double> input = _prepareInputData(
      batsman: batsman,
      overRange: overRange,
      pitchType: pitchType,
      bowlerVariation: bowlerVariation,
    );

    // Create output buffer to match the model's output shape
    var output = List.filled(15, 0.0); // Adjust to match [15]

    // Run inference
    try {
      _interpreter!.run([input], [output]);
      print('Raw model output: $output');

      // Get indices sorted by probability (highest first)
      List<int> sortedIndices = List.generate(output.length, (i) => i)
        ..sort((a, b) => output[b].compareTo(output[a]));

      print('Sorted indices: $sortedIndices');

      // Return top 9 indices
      return sortedIndices.take(9).toList();
    } catch (e) {
      print('Error during inference: $e');
      return [];
    }
  }

  static List<double> _prepareInputData({
    required String batsman,
    required String overRange,
    required String pitchType,
    required String bowlerVariation,
  }) {
    // Convert categorical variables to numerical format as in your Python code
    List<double> input = [];

    // Batsman encoding (0 for Babar Azam, 1 for Jos Buttler)
    input.add(batsman == 'Babar Azam' ? 0.0 : 1.0);

    // Over range encoding (One-hot: [Powerplay, Middle, Death])
    input.add(overRange == 'Powerplay' ? 1.0 : 0.0);
    input.add(overRange == 'Middle' ? 1.0 : 0.0);
    input.add(overRange == 'Death' ? 1.0 : 0.0);

    // Pitch type encoding (One-hot: [Batting-Friendly, Bowler-Friendly, Neutral])
    input.add(pitchType == 'Batting-Friendly' ? 1.0 : 0.0);
    input.add(pitchType == 'Bowler-Friendly' ? 1.0 : 0.0);
    input.add(pitchType == 'Neutral' ? 1.0 : 0.0);

    // Bowler variation encoding (0 for Pace, 1 for Spin)
    input.add(bowlerVariation == 'Pace' ? 0.0 : 1.0);

    print('Prepared input: $input');
    return input;
  }
}
