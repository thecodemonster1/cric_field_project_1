import 'package:flutter/material.dart';
import 'Pages/InputPage.dart';
import 'Pages/WagonWheelPage.dart';

void main() {
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
      initialRoute: '/',
      routes: {
        '/': (context) => const InputPage(),
        '/wagonWheel': (context) => const WagonWheelPage(),
      },
    );
  }
}