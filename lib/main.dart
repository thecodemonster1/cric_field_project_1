import 'package:cric_field_project_1/Services/Service.dart';
import 'package:flutter/material.dart';
import 'Pages/InputPage.dart';
import 'Pages/WagonWheelPage.dart';


// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Load the model
//   await FieldPlacementService.loadModel();

//   // Sample input
//   String batsman = 'Babar Azam - Pakistan';
//   String overRange = 'Middle';
//   String pitchType = 'Batting-Friendly';
//   String bowlerVariation = 'Pace';

//   // Predict shot placements
//   List<int> top9Predictions =
//       await FieldPlacementService.predictFieldPlacements(
//     batsman: batsman,
//     overRange: overRange,
//     pitchType: pitchType,
//     bowlerVariation: bowlerVariation,
//   );

//   print('Top 9 Predicted Shot Placements: $top9Predictions');
// }

// void main() {
//   runApp(const MyApp());
// }


// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Cricket Shot Analysis',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       initialRoute: '/',
//       routes: {
//         '/': (context) => const InputPage(),
//         '/wagonWheel': (context) {
//           final args = ModalRoute.of(context)?.settings.arguments
//               as Map<String, dynamic>?;
//           return WagonWheelPage(inputData: args ?? {});
//         },
//       },
//     );
//   }
// }

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
      initialRoute: '/',
      routes: {
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