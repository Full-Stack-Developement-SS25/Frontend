import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/task_list_screen.dart'; // Wichtig: importieren

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
      theme: ThemeData(),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/taskList':
            (context) =>
                const TaskListScreen(), // <- Diese Route ist entscheidend
      },
    );
  }
}
