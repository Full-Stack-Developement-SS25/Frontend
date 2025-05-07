import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'task_screen.dart';
import './/utils/app_colors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Später dynamisch setzen
    final int xp = 30;
    final int xpNeeded = 100;
    final double progress = xp / xpNeeded;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: AppColors.primaryBackground,
        foregroundColor: AppColors.accent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Level: 1",
              style: TextStyle(fontSize: 20, color: AppColors.accent),
            ),
            const SizedBox(height: 10),
            Text(
              "XP: $xp / $xpNeeded",
              style: const TextStyle(color: AppColors.accent),
            ),
            const SizedBox(height: 10),
            LinearPercentIndicator(
              animation: true,
              animationDuration: 500,
              lineHeight: 100.0,
              percent: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.white24,
              progressColor: AppColors.accent,
              barRadius: const Radius.circular(15),
              center: Text(
                "${(progress * 100).round()}%",
                style: const TextStyle(color: AppColors.accent),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Heutige Aufgaben:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: const [
                  TaskCard(
                    title: "Produktbeschreibung-Prompt schreiben",
                    difficulty: "Leicht",
                  ),
                  TaskCard(
                    title: "KI-Chat mit Stilvorgabe erstellen",
                    difficulty: "Mittel",
                  ),
                  TaskCard(
                    title: "Argumentatives Streitgespräch prompten",
                    difficulty: "Schwer",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final String title;
  final String difficulty;

  const TaskCard({super.key, required this.title, required this.difficulty});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.accent,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(title, style: TextStyle(color: AppColors.textPrimary)),
        subtitle: Text(
          "Schwierigkeit: $difficulty",
          style: TextStyle(color: AppColors.textSecondary),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => TaskScreen(title: title, difficulty: difficulty),
            ),
          );
        },
      ),
    );
  }
}
