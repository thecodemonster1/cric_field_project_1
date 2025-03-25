// InputPage.dart
import 'package:flutter/material.dart';

class InputPage extends StatefulWidget {
  const InputPage({super.key});

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  String? selectedBatsman = 'Babar Azam';
  String? selectedOverRange = 'Powerplay';
  String? selectedPitchType = 'Batting-Friendly';
  String? selectedBowlerVariation = 'Pace';

  final List<String> batsmen = ['Babar Azam', 'Jos Buttler'];

  final List<String> overRanges = ['Powerplay', 'Middle', 'Death'];

  final List<String> pitchTypes = [
    'Batting-Friendly',
    'Bowler-Friendly',
    'Neutral'
  ];

  final List<String> bowlerVariations = ['Pace', 'Spin'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cricket Analysis Input'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDropdown('Batsman', selectedBatsman, batsmen),
            const SizedBox(height: 16),
            _buildDropdown('Over Range', selectedOverRange, overRanges),
            const SizedBox(height: 16),
            _buildDropdown('Pitch Type', selectedPitchType, pitchTypes),
            const SizedBox(height: 16),
            _buildDropdown(
                'Bowler Variation', selectedBowlerVariation, bowlerVariations),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/wagonWheel',
                  arguments: {
                    'batsman': selectedBatsman,
                    'overRange': selectedOverRange,
                    'pitchType': selectedPitchType,
                    'bowlerVariation': selectedBowlerVariation,
                  },
                );
              },
              child: const Text('Continue to Analysis'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
      onChanged: (newValue) => setState(() {
        switch (label) {
          case 'Batsman':
            selectedBatsman = newValue;
            break;
          case 'Over Range':
            selectedOverRange = newValue;
            break;
          case 'Pitch Type':
            selectedPitchType = newValue;
            break;
          case 'Bowler Variation':
            selectedBowlerVariation = newValue;
            break;
        }
      }),
    );
  }
}
