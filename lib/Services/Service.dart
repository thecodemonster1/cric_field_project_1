import 'package:tflite_flutter/tflite_flutter.dart';

class FieldPlacementService {
  static late Interpreter _interpreter;
  static bool _isModelLoaded = false;

  // Label mapping (if needed)
  static Map<int, String> fieldingPositionMap = {
    1: 'Slips',
    2: 'Square Leg',
    3: 'Mid-Wicket',
    4: 'Mid-On',
    5: 'Mid-Off',
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
  };

  static Map<int, String> shotTypeMap = {
    0: 'Missed',
    1: 'Drive',
    2: 'Cut',
    3: 'Glance',
    4: 'Sweep',
    5: 'Defend',
    6: 'Pull',
  };

  // Example scaler values (replace with actual mean and std from your Colab scaler)
  static final List<double> _mean = [0.5, 1.2, 0.8, 1.0];
  static final List<double> _std = [0.7, 0.5, 1.1, 0.6];

  static Future<void> loadModel() async {
    try {
      _interpreter =
          await Interpreter.fromAsset('model/cricfield_dual_model.tflite');
      _isModelLoaded = true;

      // Print model input and output shapes
      print("✅ TFLite dual-output model loaded.");
      // print(
      //     "Model input shape: ${_interpreter.getInputTensors().map((t) => t.shape).toList()}");
      // print(
      //     "Model output shape: ${_interpreter.getOutputTensors().map((t) => t.shape).toList()}");
    } catch (e) {
      print("❌ Failed to load model: $e");
    }
  }

  static List<double> _standardize(List<double> input) {
    return List.generate(input.length, (i) => (input[i] - _mean[i]) / _std[i]);
  }

  static Future<Map<String, List<int>>> predictFieldPlacements({
    required String batsman,
    required String overRange,
    required String pitchType,
    required String bowlerVariation,
  }) async {
    if (!_isModelLoaded) {
      print("Model not loaded.");
      return {'placement': [], 'shotType': []};
    }

    // Encode inputs (replace with your actual encoding)
    double batsmanCode = batsman == "Babar Azam - Pakistan" ? 0 : 1;
    double overCode = overRange == "death"
        ? 0
        : overRange == "middle"
            ? 1
            : 2;
    double pitchCode = pitchType == "Batting-Friendly"
        ? 0
        : pitchType == "Bowler-Friendly"
            ? 1
            : 2;
    double variationCode = bowlerVariation == "Pace" ? 0 : 1;

    List<double> input = [batsmanCode, overCode, pitchCode, variationCode];
    List<double> inputNormalized = _standardize(input);

    // TFLite input/output
    var inputBuffer = [inputNormalized];
    var outputPlacement = List.filled(15, 0.0).reshape([1, 15]);
    var outputShotType = List.filled(7, 0.0).reshape([1, 7]);

    _interpreter.runForMultipleInputs([
      inputBuffer
    ], {
      0: outputShotType,
      1: outputPlacement,
    });

    List<double> placementProbs = outputPlacement[0];
    List<double> shotTypeProbs = outputShotType[0];

    // Top 9 shot placements (excluding Keeper [0] and Bowler [16])
    List<int> placementIndices = List.generate(placementProbs.length, (i) => i);
    placementIndices.removeWhere((i) => i == 0 || i == 16);
    placementIndices
        .sort((a, b) => placementProbs[b].compareTo(placementProbs[a]));
    List<int> top9Placement = placementIndices.take(9).toList();

    // Top 3 shot types
    List<int> shotIndices = List.generate(shotTypeProbs.length, (i) => i);
    shotIndices.sort((a, b) => shotTypeProbs[b].compareTo(shotTypeProbs[a]));
    List<int> top3ShotType = shotIndices.take(3).toList();

    // Debug output
    print("\nInput: [$batsmanCode, $overCode, $pitchCode, $variationCode]");
    print("Top 9 Placements: $top9Placement");
    print("Top 3 Shot Types: $top3ShotType\n");

    return {
      'placement': top9Placement,
      'shotType': top3ShotType,
    };
  }
}
