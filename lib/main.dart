import 'package:cric_field_project_1/Pages/DashboardPage.dart';
import 'package:cric_field_project_1/Pages/InputPage.dart';
import 'package:cric_field_project_1/Pages/WagonWheelPage.dart';
import 'package:cric_field_project_1/Pages/LoginPage.dart';
import 'package:cric_field_project_1/Pages/RegisterPage.dart';
import 'package:cric_field_project_1/Pages/SettingsPage.dart';
import 'package:cric_field_project_1/Pages/ProfilePage.dart';
import 'package:cric_field_project_1/Services/Service.dart';
import 'package:cric_field_project_1/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  await FieldPlacementService.loadModel();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cricket Shot Analysis',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: FirebaseAuth.instance.currentUser == null ? '/login' : '/',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/': (context) => const DashboardPage(),
        '/input': (context) => const InputPage(),
        '/wagonWheel': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          return WagonWheelPage(inputData: args ?? {});
        },
        '/settings': (context) => const SettingsPage(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}
