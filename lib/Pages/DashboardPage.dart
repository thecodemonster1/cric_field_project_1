import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cric_field_project_1/theme/app_theme.dart';
import 'package:cric_field_project_1/Services/Service.dart';
import 'package:percent_indicator/percent_indicator.dart';
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
    // Safe Firebase access
    User? user;
    // final user = FirebaseAuth.instance.currentUser;
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
          setState(() {
            _selectedIndex = index;
          });
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
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        onPressed: () {
          Navigator.pushNamed(context, '/input');
        },
        icon: const Icon(Icons.add),
        label: const Text('New Analysis'),
      ),
    );
  }

  Widget _buildMainDashboard(BuildContext context, User? user) {
    // Don't call FirebaseAuth.instance directly here
    // Instead, use the user parameter that is already safely obtained

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

            // Recent analyses header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Analyses',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'View All',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Recent analyses list
            isDataLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recentAnalyses.length,
                    itemBuilder: (context, index) {
                      final analysis = recentAnalyses[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: Icon(
                              Icons.sports_cricket,
                              color: AppColors.primary,
                            ),
                          ),
                          title: Text(
                            analysis['batsman'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('Top shot: ${analysis['topShot']}'),
                              const SizedBox(height: 8),
                              LinearPercentIndicator(
                                lineHeight: 6,
                                percent: analysis['accuracy'],
                                backgroundColor: AppColors.grey200,
                                progressColor: AppColors.primary,
                                barRadius: const Radius.circular(8),
                              ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                analysis['date'],
                                style: TextStyle(
                                  color: AppColors.grey600,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 14,
                                color: AppColors.grey600,
                              ),
                            ],
                          ),
                          onTap: () {
                            // Navigate to WagonWheel with pre-filled data
                            Navigator.pushNamed(
                              context,
                              '/wagonWheel',
                              arguments: {
                                'batsman': analysis['batsman'],
                                'overRange': 'Middle', // Default
                                'pitchType': 'Batting-Friendly', // Default
                                'bowlerVariation': 'Pace', // Default
                                'bowlerArmType':
                                    'Right-Arm', // Add default arm type
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
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
            // tooltipColor: Colors.black.withOpacity(0.8),
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

  Widget _buildProfile(BuildContext context, User? user) {
    // This is a placeholder for the profile section
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primary,
            child: Icon(
              Icons.person,
              size: 50,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Coach Profile',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cricket Team Analyst',
            style: TextStyle(
              color: AppColors.grey600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
