// InputPage.dart
import 'package:flutter/material.dart';

class InputPage extends StatefulWidget {
  const InputPage({super.key});

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  String? selectedShot = 'Cover Drive';
  String? selectedZone = 'Zone 1';

  final List<String> shots = [
    'Cover Drive',
    'Straight Drive',
    'Square Cut',
    'Pull Shot',
    'Hook Shot',
    'Leg Glance',
    'Sweep'
  ];

  final List<String> zones = [
    'Zone 1',
    'Zone 2',
    'Zone 3',
    'Zone 4',
    'Zone 5',
    'Zone 6'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shot Input'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedShot,
              decoration: const InputDecoration(labelText: 'Select Shot'),
              items: shots.map((shot) {
                return DropdownMenuItem(
                  value: shot,
                  child: Text(shot),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedShot = value;
                });
              },
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedZone,
              decoration: const InputDecoration(labelText: 'Select Zone'),
              items: zones.map((zone) {
                return DropdownMenuItem(
                  value: zone,
                  child: Text(zone),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedZone = value;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Save the shot data
                Navigator.pushNamed(context, '/wagonWheel');
              },
              child: const Text('Record Shot'),
            ),
          ],
        ),
      ),
    );
  }
}