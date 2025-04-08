import 'package:cric_field_project_1/Pages/LoginPage.dart';
import 'package:cric_field_project_1/Pages/RegisterPage.dart';
import 'package:cric_field_project_1/Pages/InputPage.dart';
import 'package:cric_field_project_1/Pages/WagonWheelPage.dart';
import 'package:cric_field_project_1/Services/Service.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/login', // Set LoginPage as the initial route
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/': (context) => const InputPage(),
        '/wagonWheel': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          return WagonWheelPage(inputData: args ?? {});
        },
      },
    );
  }
}
