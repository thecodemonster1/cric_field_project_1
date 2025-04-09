import 'package:tflite_flutter/tflite_flutter.dart';

class FieldPlacementService {
  static Interpreter? _interpreter;

  // Mapping shot placement indices to fielder positions
  static final Map<int, String> fieldingPositionMap = {
    0: 'Keeper',
    1: 'Slip',
    2: 'Square Leg',
    3: 'Mid-wicket',
    4: 'Mid-on',
    5: 'Mid-off',
    6: 'Cover',
    7: 'Point',
    8: 'Fine Leg',
    9: 'Deep Square Leg',
    10: 'Deep Mid-Wicket',
    11: 'Long-On',
    12: 'Long-Off',
    13: 'Deep Cover',
    14: 'Deep Point',
    15: 'Third Man',
    16: 'Bowler'
  };

  static final Map<String, int> batsmanEncoding = {
    "Babar Azam - Pakistan": 0,
    "Jos Buttler - England": 1,
  };

  static final Map<String, int> overRangeEncoding = {
    "death": 0,
    "middle": 1,
    "Powerplay": 2,
  };

  static final Map<String, int> pitchTypeEncoding = {
    "Batting-Friendly": 0,
    "Bowler-Friendly": 1,
    "Neutral": 2,
  };

  static final Map<String, int> bowlerVariationEncoding = {
    "Pace": 0,
    "Spin": 1,
  };

  // Replace these with the exact values from your StandardScaler (Python output)
  static final List<double> means = [0.5, 1.0, 1.0, 0.5];
  static final List<double> stds = [0.5, 0.82, 0.82, 0.5];

  static Future<void> loadModel() async {
    if (_interpreter != null) return; // Prevent reloading the model
    try {
      print('Loading TFLite model...');
      _interpreter =
          await Interpreter.fromAsset('model/cricfield_model.tflite');
      print('Model loaded successfully');
    } catch (e) {
      print('Error loading model: $e');
    }
  }

  static Future<List<int>> predictFieldPlacements({
    required String batsman,
    required String overRange,
    required String pitchType,
    required String bowlerVariation,
  }) async {
    try {
      // Prepare input data
      final input = [
        _prepareInputData(
          batsman: batsman,
          overRange: overRange,
          pitchType: pitchType,
          bowlerVariation: bowlerVariation,
        )
      ];

      // Load the model
      _interpreter ??=
          await Interpreter.fromAsset('assets/model/cricfield_model.tflite');

      // Prepare output buffer
      final output = List.filled(1 * 15, 0.0).reshape([1, 15]);

      // Run inference
      _interpreter!.run(input, output);

      // Extract top 9 predictions
      final rawOutput = output[0];
      final top9Indices = List.generate(rawOutput.length, (index) => index)
        ..sort((a, b) => rawOutput[b].compareTo(rawOutput[a]));

      return top9Indices.sublist(0, 9);
    } catch (e) {
      print("Prediction Error: $e");
      return [];
    }
  }

  static List<double> _prepareInputData({
    required String batsman,
    required String overRange,
    required String pitchType,
    required String bowlerVariation,
  }) {
    // Encode inputs
    final encodedInput = [
      batsmanEncoding[batsman] ?? 0,
      overRangeEncoding[overRange] ?? 0,
      pitchTypeEncoding[pitchType] ?? 0,
      bowlerVariationEncoding[bowlerVariation] ?? 0,
    ];

    // Scale inputs
    final scaledInput = List.generate(encodedInput.length, (i) {
      return (encodedInput[i] - means[i]) / stds[i];
    });

    return scaledInput;
  }
}
