import 'package:flutter/material.dart';
import './/utils/app_colors.dart';

class TaskScreen extends StatelessWidget {
  final String title;
  final String difficulty;

  const TaskScreen({super.key, required this.title, required this.difficulty});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.primaryBackground,
        foregroundColor: AppColors.accent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Schwierigkeit: $difficulty",
              style: TextStyle(fontSize: 16, color: AppColors.accent),
            ),
            const SizedBox(height: 20),
            const Text(
              "Aufgabenstellung:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Formuliere einen Prompt, mit dem die KI ein Produkt kreativ beschreiben kann.",
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 30),
            const TextField(
              style: TextStyle(color: Colors.white),
              maxLines: 5,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.fillColor,
                hintText: "Dein Prompt...",
                hintStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Prompt bewerten
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
              ),
              child: const Text("Senden"),
            ),
          ],
        ),
      ),
    );
  }
}
