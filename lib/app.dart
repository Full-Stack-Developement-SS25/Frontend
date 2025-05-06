import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PromptMaster',
      theme: ThemeData(primarySwatch: Colors.purple),
      home: const DashboardScreen(), // vorerst direkt Dashboard zum Start
    );
  }
}
