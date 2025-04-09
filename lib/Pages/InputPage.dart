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

  // Added batsman images for enhanced UI
  final Map<String, String> batsmanImages = {
    'Babar Azam - Pakistan': 'assets/images/babar_azam.jpg',
    'Jos Buttler - England': 'assets/images/jos_buttler.jpg',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: const Text(
          'Cricket Shot Analysis',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        // backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Shot Analysis Parameters',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Configure the parameters to analyze batting patterns',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Batsman Selection Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Select Batsman',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: batsman,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                              icon: const Icon(Icons.arrow_drop_down_circle),
                              isExpanded: true,
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
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Match Conditions Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Match Conditions',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Over Range
                            const Text(
                              'Over Range',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SegmentedButton<String>(
                              segments: const [
                                ButtonSegment(
                                  value: 'Powerplay',
                                  label: Text('Powerplay'),
                                  icon: Icon(Icons.flash_on),
                                ),
                                ButtonSegment(
                                  value: 'Middle',
                                  label: Text('Middle'),
                                  icon: Icon(Icons.hourglass_empty),
                                ),
                                ButtonSegment(
                                  value: 'Death',
                                  label: Text('Death'),
                                  icon: Icon(Icons.sports_cricket),
                                ),
                              ],
                              selected: {overRange},
                              onSelectionChanged: (Set<String> newSelection) {
                                setState(() {
                                  overRange = newSelection.first;
                                });
                              },
                            ),

                            const SizedBox(height: 20),

                            // Pitch Type
                            const Text(
                              'Pitch Type',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: pitchType,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                              icon: const Icon(Icons.landscape),
                              isExpanded: true,
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
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Bowler Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Bowler Details',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Bowler Variation
                            const Text(
                              'Bowler Type',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        bowlerVariation = 'Pace';
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      decoration: BoxDecoration(
                                        color: bowlerVariation == 'Pace'
                                            ? Theme.of(context).primaryColor
                                            : Colors.grey[200],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.speed,
                                            color: bowlerVariation == 'Pace'
                                                ? Colors.white
                                                : Colors.grey[700],
                                            size: 32,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Pace',
                                            style: TextStyle(
                                              color: bowlerVariation == 'Pace'
                                                  ? Colors.white
                                                  : Colors.grey[700],
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        bowlerVariation = 'Spin';
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      decoration: BoxDecoration(
                                        color: bowlerVariation == 'Spin'
                                            ? Theme.of(context).primaryColor
                                            : Colors.grey[200],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.rotate_left,
                                            color: bowlerVariation == 'Spin'
                                                ? Colors.white
                                                : Colors.grey[700],
                                            size: 32,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Spin',
                                            style: TextStyle(
                                              color: bowlerVariation == 'Spin'
                                                  ? Colors.white
                                                  : Colors.grey[700],
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Analyze Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Generate Wagon Wheel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
