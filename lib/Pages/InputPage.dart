// InputPage.dart
import 'package:flutter/material.dart';

class InputPage extends StatefulWidget {
  const InputPage({super.key});

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  String? selectedBatsman = 'Babar Azam';
  String? selectedGround;
  String? selectedShot = 'Cover Drive';
  String? selectedBowlingStyle = 'Right Arm Fast';
  String? selectedBowler = 'James Anderson';

  final Map<String, List<String>> batsmanGrounds = {
    'Babar Azam': [
      'Karachi',
      'Lahore',
      'Rawalpindi',
      'Dubai',
      'Abu Dhabi',
      'Melbourne',
      'Sydney',
      'Lords',
    ],
    'Jos Buttler': [
      'Lords',
      'The Oval',
      'Old Trafford',
      'Edgbaston',
      'MCG',
      'SCG',
      'Adelaide',
    ],
  };

  final List<String> shots = [
    'Cover Drive',
    'Straight Drive',
    'Square Cut',
    'Pull Shot',
    'Hook Shot',
    'Leg Glance',
    'Sweep',
    'Reverse Sweep',
    'Scoop',
    'On Drive',
    'Flick',
  ];

  final List<String> bowlingStyles = [
    'Right Arm Fast',
    'Right Arm Medium',
    'Left Arm Fast',
    'Left Arm Medium',
    'Off Spin',
    'Leg Spin',
    'Left Arm Spin',
  ];

  final Map<String, List<String>> styleBowlers = {
    'Right Arm Fast': ['James Anderson', 'Pat Cummins', 'Mohammed Shami'],
    'Right Arm Medium': ['Harshal Patel', 'Bhuvneshwar Kumar'],
    'Left Arm Fast': ['Mitchell Starc', 'Trent Boult', 'Shaheen Afridi'],
    'Left Arm Medium': ['Sam Curran', 'Jason Behrendorff'],
    'Off Spin': ['R Ashwin', 'Nathan Lyon', 'Moeen Ali'],
    'Leg Spin': ['Rashid Khan', 'Adam Zampa', 'Yuzvendra Chahal'],
    'Left Arm Spin': ['Mitchell Santner', 'Axar Patel'],
  };

  @override
  void initState() {
    super.initState();
    selectedGround = batsmanGrounds[selectedBatsman]?.first;
    selectedBowler = styleBowlers[selectedBowlingStyle]?.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Details'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedBatsman,
              decoration: const InputDecoration(
                labelText: 'Select Batsman',
                border: OutlineInputBorder(),
              ),
              items: batsmanGrounds.keys.map((batsman) {
                return DropdownMenuItem(value: batsman, child: Text(batsman));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedBatsman = value;
                  selectedGround = batsmanGrounds[value]?.first;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedGround,
              decoration: const InputDecoration(
                labelText: 'Select Ground',
                border: OutlineInputBorder(),
              ),
              items: batsmanGrounds[selectedBatsman]?.map((ground) {
                return DropdownMenuItem(value: ground, child: Text(ground));
              }).toList(),
              onChanged: (value) => setState(() => selectedGround = value),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedShot,
              decoration: const InputDecoration(
                labelText: 'Select Shot',
                border: OutlineInputBorder(),
              ),
              items: shots.map((shot) {
                return DropdownMenuItem(value: shot, child: Text(shot));
              }).toList(),
              onChanged: (value) => setState(() => selectedShot = value),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedBowlingStyle,
              decoration: const InputDecoration(
                labelText: 'Select Bowling Style',
                border: OutlineInputBorder(),
              ),
              items: bowlingStyles.map((style) {
                return DropdownMenuItem(value: style, child: Text(style));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedBowlingStyle = value;
                  selectedBowler = styleBowlers[value]?.first;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedBowler,
              decoration: const InputDecoration(
                labelText: 'Select Bowler',
                border: OutlineInputBorder(),
              ),
              items: styleBowlers[selectedBowlingStyle]?.map((bowler) {
                return DropdownMenuItem(value: bowler, child: Text(bowler));
              }).toList(),
              onChanged: (value) => setState(() => selectedBowler = value),
            ),
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
                    'ground': selectedGround,
                    'shot': selectedShot,
                    'bowlingStyle': selectedBowlingStyle,
                    'bowler': selectedBowler,
                  },
                );
              },
              child: const Text('Continue to Shot Analysis'),
            ),
          ],
        ),
      ),
    );
  }
}