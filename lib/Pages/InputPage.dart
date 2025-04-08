// InputPage.dart
import 'package:flutter/material.dart';

class InputPage extends StatefulWidget {
  const InputPage({super.key});

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  final _formKey = GlobalKey<FormState>();
  String batsman = 'Babar Azam - Pakistan';
  String overRange = 'Middle';
  String pitchType = 'Batting-Friendly';
  String bowlerVariation = 'Pace';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: batsman,
                items: const [
                  DropdownMenuItem(
                    value: 'Babar Azam - Pakistan',
                    child: Text('Babar Azam - Pakistan'),
                  ),
                  DropdownMenuItem(
                    value: 'Jos Buttler - England',
                    child: Text('Jos Buttler - England'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    batsman = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Batsman'),
              ),
              DropdownButtonFormField<String>(
                value: overRange,
                items: const [
                  DropdownMenuItem(
                    value: 'Powerplay',
                    child: Text('Powerplay'),
                  ),
                  DropdownMenuItem(
                    value: 'Middle',
                    child: Text('Middle'),
                  ),
                  DropdownMenuItem(
                    value: 'Death',
                    child: Text('Death'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    overRange = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Over Range'),
              ),
              DropdownButtonFormField<String>(
                value: pitchType,
                items: const [
                  DropdownMenuItem(
                    value: 'Batting-Friendly',
                    child: Text('Batting-Friendly'),
                  ),
                  DropdownMenuItem(
                    value: 'Bowler-Friendly',
                    child: Text('Bowler-Friendly'),
                  ),
                  DropdownMenuItem(
                    value: 'Neutral',
                    child: Text('Neutral'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    pitchType = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Pitch Type'),
              ),
              DropdownButtonFormField<String>(
                value: bowlerVariation,
                items: const [
                  DropdownMenuItem(
                    value: 'Pace',
                    child: Text('Pace'),
                  ),
                  DropdownMenuItem(
                    value: 'Spin',
                    child: Text('Spin'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    bowlerVariation = value!;
                  });
                },
                decoration:
                    const InputDecoration(labelText: 'Bowler Variation'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pushNamed(
                      context,
                      '/wagonWheel',
                      arguments: {
                        'batsman': batsman,
                        'overRange': overRange,
                        'pitchType': pitchType,
                        'bowlerVariation': bowlerVariation,
                      },
                    );
                  }
                },
                child: const Text('Analyze'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
