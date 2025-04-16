import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cric_field_project_1/theme/app_theme.dart';
import 'package:cric_field_project_1/Services/Service.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardPage extends StatefulWidget {
  final bool firebaseInitialized;
  const DashboardPage({super.key, this.firebaseInitialized = false});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  bool isDataLoading = false;
  String selectedBatsman = 'Babar Azam - Pakistan';
  Map<String, List<double>> shotDistributionData = {};
  bool isChartLoading = false;
  int modelAccuracy = 0; // Add this line to store model accuracy

  // Available batsmen
  final List<String> availableBatsmen = [
    'Babar Azam - Pakistan',
    'Jos Buttler - England',
  ];

  // Mock recent analyses data
  final List<Map<String, dynamic>> recentAnalyses = [
    {
      'batsman': 'Babar Azam - Pakistan',
      'date': '3 Mar 2023',
      'topShot': 'Drive',
      'accuracy': 0.86,
    },
    {
      'batsman': 'Jos Buttler - England',
      'date': '27 Feb 2023',
      'topShot': 'Pull',
      'accuracy': 0.78,
    },
    {
      'batsman': 'Babar Azam - Pakistan',
      'date': '20 Feb 2023',
      'topShot': 'Cut',
      'accuracy': 0.72,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadModelData();
  }

  // Load shot distribution data from model
  Future<void> _loadModelData() async {
    setState(() {
      isChartLoading = true;
    });

    try {
      // Initialize data structure
      Map<String, List<double>> data = {};
      for (final batsman in availableBatsmen) {
        data[batsman] = List.filled(7, 0.0); // 7 shot types
      }

      int latestAccuracy = 0; // Track the latest model accuracy

      // Get prediction data for each batsman with limited combinations
      for (final batsman in availableBatsmen) {
        List<double> shotCounts = List.filled(7, 0.0);

        // Just run one prediction per batsman to speed up loading
        final result = await FieldPlacementService.predictFieldPlacements(
          batsman: batsman,
          overRange: 'Middle',
          pitchType: 'Batting-Friendly',
          bowlerVariation: 'Pace',
          bowlerArmType: 'Right-Arm',
        );

        // Store the latest accuracy
        if (result.containsKey('accuracy')) {
          latestAccuracy = result['accuracy'] as int;
        }

        // Process shot types
        if (result.containsKey('shotType')) {
          for (final shotIndex in result['shotType'] as List) {
            if (shotIndex is int &&
                shotIndex >= 0 &&
                shotIndex < shotCounts.length) {
              shotCounts[shotIndex] += 1;
            }
          }
        }

        // Normalize the data (0-100%)
        double total = shotCounts.reduce((a, b) => a + b);
        if (total > 0) {
          for (int i = 0; i < shotCounts.length; i++) {
            shotCounts[i] = (shotCounts[i] / total) * 100;
          }
        }

        data[batsman] = shotCounts;
      }

      setState(() {
        shotDistributionData = data;
        modelAccuracy = latestAccuracy; // Update the model accuracy
        isChartLoading = false;

        // Also update the first recentAnalysis with the new accuracy
        if (recentAnalyses.isNotEmpty) {
          recentAnalyses[0] = {
            ...recentAnalyses[0],
            'accuracy': modelAccuracy / 100.0,
          };
        }
      });
    } catch (e) {
      print("Error loading model data: $e");
      setState(() {
        isChartLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user;
    if (widget.firebaseInitialized) {
      try {
        user = FirebaseAuth.instance.currentUser;
      } catch (e) {
        print("Error accessing Firebase Auth: $e");
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CricField Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? _buildMainDashboard(context, user)
          : _buildProfile(context, user),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey600,
        onTap: (index) {
          // Just update the selected index, don't navigate
          setState(() {
            _selectedIndex = index;
          });

          // If it's the third tab (New Analysis), navigate to input page
          if (index == 2) {
            Navigator.pushNamed(context, '/input');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'New Analysis',
          ),
        ],
      ),
    );
  }

  Widget _buildMainDashboard(BuildContext context, User? user) {
    // Get insights from shot distribution data
    Map<String, dynamic> insights = _generateBatsmanInsights(selectedBatsman);

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          isDataLoading = true;
        });
        await _loadModelData();
        setState(() {
          isDataLoading = false;
        });
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${user?.email ?? 'Guest'}!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create a new shot analysis or view your recent analyses',
                          style: TextStyle(
                            color: AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primary,
                    child: Icon(
                      Icons.sports_cricket,
                      size: 30,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Stats cards row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Analytics Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'v1.0 Beta',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Analyses',
                    '12',
                    Icons.analytics,
                    AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Batsmen',
                    '2',
                    Icons.person,
                    AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Accuracy',
                    '$modelAccuracy%', // Use the dynamic model accuracy directly
                    Icons.check_circle,
                    AppColors.success,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Shot distribution with batsman selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Shot Distribution',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: selectedBatsman,
                    icon: const Icon(Icons.arrow_drop_down),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                    underline: Container(height: 0),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedBatsman = newValue;
                        });
                      }
                    },
                    items: availableBatsmen
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(value.split(' - ')[0]),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 220,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: isChartLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : _buildShotDistributionChart(),
            ),

            const SizedBox(height: 24),

            // NEW SECTION: Playing Style Analysis
            Text(
              'Playing Style Analysis',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildPlayingStyleCard(insights),

            const SizedBox(height: 24),

            // NEW SECTION: Field Placement Strategy
            Text(
              'Field Placement Strategy',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildFieldPlacementCard(insights),

            const SizedBox(height: 24),

            // NEW SECTION: Match Situation Analysis
            Text(
              'Match Situation Analysis',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildMatchSituationCard(insights),

            const SizedBox(height: 24),

            // NEW SECTION: Bowling Strategy Recommendations
            Text(
              'Bowling Strategy',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildBowlingStrategyCard(insights),

            const SizedBox(height: 24),

            // NEW SECTION: Shot Improvement Suggestions
            Text(
              'Performance Enhancement',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildPerformanceEnhancementCard(insights),

            const SizedBox(height: 24),

            // NEW SECTION: Batsman Insights

            Text(
              'Batsman Insights',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildBatsmanInsightsCard(insights),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _generateBatsmanInsights(String batsmanName) {
    final List<double> values =
        shotDistributionData[batsmanName] ?? List.filled(7, 0.0);
    const shots = [
      'Missed',
      'Drive',
      'Cut',
      'Glance',
      'Sweep',
      'Defend',
      'Pull'
    ];

    int favoriteIndex = 0;
    int leastFavoriteIndex = 0;
    double maxValue = 0;
    double minValue = double.infinity;

    for (int i = 1; i < values.length; i++) {
      if (values[i] > maxValue) {
        maxValue = values[i];
        favoriteIndex = i;
      }

      if (values[i] < minValue && values[i] > 0) {
        minValue = values[i];
        leastFavoriteIndex = i;
      }
    }

    String playingStyle = "Balanced";
    if (values[1] > 25 && values[6] > 25) {
      playingStyle = "Aggressive";
    } else if (values[5] > 30) {
      playingStyle = "Defensive";
    } else if (values[2] > 25) {
      playingStyle = "Technical";
    } else if (values[3] > 25 || values[4] > 25) {
      playingStyle = "Wristy";
    }

    double aggressionScore = ((values[1] + values[2] + values[6]) / 3) * 1.3;
    aggressionScore = aggressionScore.clamp(0, 100);

    double technicalScore = ((values[2] + values[5]) / 2) * 1.2;
    technicalScore = technicalScore.clamp(0, 100);

    String strengthZone = "Off side";
    if (values[3] > values[1] || values[4] > values[1]) {
      strengthZone = "Leg side";
    }

    List<String> fieldRecommendations = [];
    if (values[1] > 20) {
      fieldRecommendations.add("Extra cover");
    }
    if (values[2] > 20) {
      fieldRecommendations.add("Point");
    }
    if (values[3] > 20) {
      fieldRecommendations.add("Square leg");
    }
    if (values[4] > 20) {
      fieldRecommendations.add("Fine leg");
    }
    if (values[6] > 20) {
      fieldRecommendations.add("Deep midwicket");
    }

    String weakness = shots[leastFavoriteIndex];
    String weaknessExplanation =
        "The batsman rarely plays the ${shots[leastFavoriteIndex].toLowerCase()} shot, suggesting potential discomfort when forced to play this way.";

    return {
      'favoriteShot': shots[favoriteIndex],
      'favoriteShotPercentage': values[favoriteIndex],
      'leastFavoriteShot': shots[leastFavoriteIndex],
      'leastFavoriteShotPercentage': values[leastFavoriteIndex],
      'playingStyle': playingStyle,
      'aggressionScore': aggressionScore,
      'technicalScore': technicalScore,
      'strengthZone': strengthZone,
      'fieldRecommendations': fieldRecommendations,
      'weakness': weakness,
      'weaknessExplanation': weaknessExplanation,
    };
  }

  Widget _buildBatsmanInsightsCard(Map<String, dynamic> insights) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.insights, color: AppColors.primary),
                ),
                const SizedBox(width: 8),
                Text(
                  'Insights',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Favorite Shot: ${insights['favoriteShot']} (${insights['favoriteShotPercentage'].toStringAsFixed(1)}%)',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Least Favorite Shot: ${insights['leastFavoriteShot']} (${insights['leastFavoriteShotPercentage'].toStringAsFixed(1)}%)',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Weakness: ${insights['weakness']}',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Explanation: ${insights['weaknessExplanation']}',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayingStyleCard(Map<String, dynamic> insights) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.style, color: AppColors.secondary),
                ),
                const SizedBox(width: 8),
                Text(
                  'Playing Style',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Style: ${insights['playingStyle']}',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Aggression Score: ${insights['aggressionScore'].toStringAsFixed(1)}%',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Technical Proficiency: ${insights['technicalScore'].toStringAsFixed(1)}%',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldPlacementCard(Map<String, dynamic> insights) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.place, color: AppColors.success),
                ),
                const SizedBox(width: 8),
                Text(
                  'Field Placement',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Strength Zone: ${insights['strengthZone']}',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Recommendations:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            ...insights['fieldRecommendations']
                .map<Widget>((recommendation) => Text('- $recommendation'))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: AppColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShotDistributionChart() {
    final List<double> values =
        shotDistributionData[selectedBatsman] ?? List.filled(7, 0.0);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              const shots = [
                'Missed',
                'Drive',
                'Cut',
                'Glance',
                'Sweep',
                'Defend',
                'Pull'
              ];
              return BarTooltipItem(
                '${shots[group.x]} \n${rod.toY.toStringAsFixed(1)}%',
                TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                const titles = [
                  'Missed',
                  'Drive',
                  'Cut',
                  'Glance',
                  'Sweep',
                  'Defend',
                  'Pull'
                ];
                if (value >= 0 && value < titles.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      titles[value.toInt()],
                      style: TextStyle(
                        color: AppColors.grey600,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value % 20 == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(
                      '${value.toInt()}%',
                      style: TextStyle(
                        color: AppColors.grey600,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
              reservedSize: 30,
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          horizontalInterval: 20,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.grey200,
              strokeWidth: 1,
            );
          },
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(values.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: values[i],
                color: i == 0 ? AppColors.grey600 : AppColors.primary,
                width: 16,
                borderRadius: BorderRadius.circular(4),
              )
            ],
          );
        }),
      ),
    );
  }

  Widget _buildMatchSituationCard(Map<String, dynamic> insights) {
    final String batsmanName = selectedBatsman.split(' - ')[0];

    // Generate dynamic match situation insights
    Map<String, String> situations = {
      'Power Play': insights['aggressionScore'] > 70
          ? 'Excellent performer, attacks from the start'
          : 'Prefers to build innings, less aggressive initially',
      'Middle Overs': insights['technicalScore'] > 70
          ? 'Rotates strike well, maintains momentum'
          : 'May struggle to maintain scoring rate',
      'Death Overs':
          (insights['aggressionScore'] + insights['technicalScore']) / 2 > 70
              ? 'Strong finisher, can accelerate quickly'
              : 'Can struggle under pressure to increase scoring rate',
    };

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.sports_cricket, color: AppColors.primary),
                ),
                const SizedBox(width: 8),
                Text(
                  'Match Phases',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'How $batsmanName performs in different match situations:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            ...situations.entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entry.value,
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildBowlingStrategyCard(Map<String, dynamic> insights) {
    final String batsmanName = selectedBatsman.split(' - ')[0];

    // Generate dynamic bowling strategies based on insights
    List<Map<String, String>> strategies = [
      {
        'type': 'Pace Bowling',
        'strategy': insights['leastFavoriteShot'] == 'Pull'
            ? 'Use short-pitched deliveries aiming at the body'
            : 'Bowl full and straight, targeting the stumps',
      },
      {
        'type': 'Spin Bowling',
        'strategy': insights['leastFavoriteShot'] == 'Sweep'
            ? 'Bowl slightly quicker and flatter to prevent easy sweeping'
            : 'Flight the ball and aim for turn outside off stump',
      },
      {
        'type': 'Field Setting',
        'strategy':
            'Place fielders at ${insights['fieldRecommendations'].join(', ')}',
      },
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.sports, color: AppColors.secondary),
                ),
                const SizedBox(width: 8),
                Text(
                  'Bowling Strategies',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Recommended approaches against $batsmanName:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            ...strategies.map((strategy) => Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strategy['type']!,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        strategy['strategy']!,
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceEnhancementCard(Map<String, dynamic> insights) {
    final String batsmanName = selectedBatsman.split(' - ')[0];

    // Generate improvement suggestions based on insights
    List<Map<String, String>> improvements = [
      {
        'area': 'Technical Improvement',
        'suggestion':
            'Focus on ${insights['leastFavoriteShot']} shots in training sessions',
      },
      {
        'area': 'Scoring Rate',
        'suggestion': insights['aggressionScore'] < 70
            ? 'Practice aggressive shots against ${insights['strengthZone'] == "Off side" ? "leg side" : "off side"} bowling'
            : 'Work on defense and shot selection for longer innings',
      },
      {
        'area': 'Situational Awareness',
        'suggestion':
            'Practice different scoring approaches for power play, middle overs, and death overs',
      },
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.trending_up, color: AppColors.success),
                ),
                const SizedBox(width: 8),
                Text(
                  'Development Areas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Suggested improvement areas for $batsmanName:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            ...improvements.map((improvement) => Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        improvement['area']!,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        improvement['suggestion']!,
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildProfile(BuildContext context, User? user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 60,
            backgroundColor: AppColors.primary,
            child: Icon(
              Icons.person,
              size: 60,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            user?.email ?? 'Guest User',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cricket Analyst',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: 30),
          // Account Information section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Account Information',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Email'),
            subtitle: Text(user?.email ?? 'Not available'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Joined'),
            subtitle: Text(
                user?.metadata.creationTime?.toString().split(' ')[0] ??
                    'Not available'),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: widget.firebaseInitialized
                ? () async {
                    try {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (route) => false, // Remove all previous routes
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error signing out: $e')),
                      );
                    }
                  }
                : null,
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
