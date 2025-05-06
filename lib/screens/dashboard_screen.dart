import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(244, 39, 5, 99), // 💜 DEIN LILA
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: Color.fromARGB(244, 39, 5, 99),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Level: 1",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            SizedBox(height: 10),
            Text("XP: 0 / 100", style: TextStyle(color: Colors.white)),
            SizedBox(height: 20),
            Text(
              "Heutige Aufgaben:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
