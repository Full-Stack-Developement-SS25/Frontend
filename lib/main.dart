import 'package:flutter/material.dart';
import 'screens/main_navigation.dart'; // <- Datei muss existieren!

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PromptMaster',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: MainNavigation(), // <- wichtig!
    );
  }
}
