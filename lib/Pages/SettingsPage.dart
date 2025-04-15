import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cric_field_project_1/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  final bool firebaseInitialized;

  const SettingsPage({super.key, this.firebaseInitialized = false});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;
  bool darkModeEnabled = false;
  String selectedAnalysisPeriod = '7 days';

  @override
  Widget build(BuildContext context) {
    // Safe Firebase access
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
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          if (user != null) _buildAccountSection(user),

          _buildSectionTitle('App Preferences'),

          // Notifications setting
          SwitchListTile(
            title: const Text('Notifications'),
            subtitle: const Text('Enable push notifications'),
            value: notificationsEnabled,
            activeColor: AppColors.primary,
            onChanged: (value) {
              setState(() {
                notificationsEnabled = value;
              });
            },
          ),

          // Dark mode setting
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Enable dark theme'),
            value: darkModeEnabled,
            activeColor: AppColors.primary,
            onChanged: (value) {
              setState(() {
                darkModeEnabled = value;
              });
            },
          ),

          // Analysis period setting
          // ListTile(
          //   title: const Text('Default Analysis Period'),
          //   subtitle: Text(selectedAnalysisPeriod),
          //   trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          //   onTap: () {
          //     // _showAnalysisPeriodDialog();
          //   },
          // ),

          const Divider(),

          _buildSectionTitle('About'),

          ListTile(
            title: const Text('App Version'),
            subtitle: const Text('1.0.0 (Beta)'),
          ),

          ListTile(
            title: const Text('Developer'),
            subtitle: const Text('theCodeMonster'),
            leading: Icon(Icons.code, color: AppColors.primary),
          ),

          ListTile(
            title: const Text('GitHub'),
            subtitle: const Text('Follow us for updates'),
            leading: Icon(Icons.link, color: AppColors.primary),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _launchUrl('https://github.com/thecodemonster1'),
          ),

          ListTile(
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to Terms of Service
            },
          ),

          ListTile(
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to Privacy Policy
            },
          ),

          const SizedBox(height: 20),

          if (widget.firebaseInitialized)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton.icon(
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            ),
        ],
      ),
    );
  }

  Widget _buildAccountSection(User user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Account'),
        ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.person, color: Colors.white),
          ),
          title: Text(user.email ?? 'No email'),
          subtitle: const Text('View Profile'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.pushNamed(context, '/profile');
          },
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  void _showAnalysisPeriodDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Analysis Period'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('7 days'),
                value: '7 days',
                groupValue: selectedAnalysisPeriod,
                onChanged: (value) {
                  setState(() {
                    selectedAnalysisPeriod = value!;
                    Navigator.pop(context);
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text('14 days'),
                value: '14 days',
                groupValue: selectedAnalysisPeriod,
                onChanged: (value) {
                  setState(() {
                    selectedAnalysisPeriod = value!;
                    Navigator.pop(context);
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text('30 days'),
                value: '30 days',
                groupValue: selectedAnalysisPeriod,
                onChanged: (value) {
                  setState(() {
                    selectedAnalysisPeriod = value!;
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch URL')),
      );
    }
  }
}
