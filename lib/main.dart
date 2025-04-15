import 'package:cric_field_project_1/Pages/DashboardPage.dart';
import 'package:cric_field_project_1/Pages/InputPage.dart';
import 'package:cric_field_project_1/Pages/WagonWheelPage.dart';
import 'package:cric_field_project_1/Pages/LoginPage.dart';
import 'package:cric_field_project_1/Pages/RegisterPage.dart';
import 'package:cric_field_project_1/Pages/SettingsPage.dart';
import 'package:cric_field_project_1/Pages/ProfilePage.dart';
import 'package:cric_field_project_1/Services/Service.dart';
import 'package:cric_field_project_1/Services/firebase_options.dart';
import 'package:cric_field_project_1/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load TFLite models first
  await FieldPlacementService.loadModel();
  
  // Initialize Firebase with generated options
  bool firebaseInitialized = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully');
    firebaseInitialized = true;
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  // Pass the initialization status to MyApp
  runApp(MyApp(firebaseInitialized: firebaseInitialized));
}

class MyApp extends StatelessWidget {
  final bool firebaseInitialized;

  const MyApp({super.key, this.firebaseInitialized = false});

  @override
  Widget build(BuildContext context) {
    // Only check for current user if Firebase is initialized
    String initialRoute = '/login';
    if (firebaseInitialized) {
      try {
        if (FirebaseAuth.instance.currentUser != null) {
          initialRoute = '/';
        }
      } catch (e) {
        debugPrint('Error checking auth state: $e');
      }
    }

    return MaterialApp(
      title: 'Cricket Shot Analysis',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/': (context) =>
            DashboardPage(firebaseInitialized: firebaseInitialized),
        '/input': (context) => const InputPage(),
        '/wagonWheel': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          return WagonWheelPage(inputData: args ?? {});
        },
        '/settings': (context) =>
            SettingsPage(firebaseInitialized: firebaseInitialized),
        '/profile': (context) =>
            ProfilePage(firebaseInitialized: firebaseInitialized),
      },
    );
  }
}
