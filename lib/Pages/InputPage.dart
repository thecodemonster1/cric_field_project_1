// InputPage.dart
import 'package:flutter/material.dart';
import 'package:cric_field_project_1/theme/app_theme.dart';
import 'package:flutter/services.dart';

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
  String bowlerArmType = 'Right-Arm'; // Add this line

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/',
          (route) => false,
        );
        return false; // Prevents the default back behavior
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Cricket Shot Analysis',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                (route) => false,
              );
            },
          ),
        ),
        floatingActionButton: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 800),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: child,
            );
          },
          child: GestureDetector(
            onTap: () {
              if (_formKey.currentState!.validate()) {
                // Add button press animation
                ScaffoldMessenger.of(context).clearSnackBars();

                // Small vibration feedback
                HapticFeedback.mediumImpact();

                Navigator.pushNamed(
                  context,
                  '/wagonWheel',
                  arguments: {
                    'batsman': batsman,
                    'overRange': overRange,
                    'pitchType': pitchType,
                    'bowlerVariation': bowlerVariation,
                    'bowlerArmType': bowlerArmType,
                  },
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 8, 110, 12).withOpacity(0.8),
                    const Color.fromARGB(255, 8, 110, 12).withOpacity(0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Color.fromARGB(255, 8, 110, 12).withOpacity(0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.sports_cricket,
                    color: Color.fromARGB(255, 212, 212, 212),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Generate Wagon Wheel',
                    style: TextStyle(
                      color: Color.fromARGB(255, 212, 212, 212),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary.withOpacity(0.05),
                AppColors.white,
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
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                                          borderRadius:
                                              BorderRadius.circular(10),
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

                              const SizedBox(height: 20),

                              // Bowler Arm Type
                              const Text(
                                'Bowler Arm Type',
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
                                          bowlerArmType = 'Right-Arm';
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        decoration: BoxDecoration(
                                          color: bowlerArmType == 'Right-Arm'
                                              ? Theme.of(context).primaryColor
                                              : Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.arrow_forward,
                                              color:
                                                  bowlerArmType == 'Right-Arm'
                                                      ? Colors.white
                                                      : Colors.grey[700],
                                              size: 32,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Right-Arm',
                                              style: TextStyle(
                                                color:
                                                    bowlerArmType == 'Right-Arm'
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
                                          bowlerArmType = 'Left-Arm';
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        decoration: BoxDecoration(
                                          color: bowlerArmType == 'Left-Arm'
                                              ? Theme.of(context).primaryColor
                                              : Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.arrow_back,
                                              color: bowlerArmType == 'Left-Arm'
                                                  ? Colors.white
                                                  : Colors.grey[700],
                                              size: 32,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Left-Arm',
                                              style: TextStyle(
                                                color:
                                                    bowlerArmType == 'Left-Arm'
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

                      // This pushes content up to account for the floating button
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
