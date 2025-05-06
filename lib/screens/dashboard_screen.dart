import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Level: 1", style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text("XP: 0 / 100"),
            SizedBox(height: 20),
            Text(
              "Heutige Aufgaben:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            // Hier später Liste von Aufgaben einfügen
          ],
        ),
      ),
    );
  }
}
