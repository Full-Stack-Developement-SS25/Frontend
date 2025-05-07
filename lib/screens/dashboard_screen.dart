import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'task_screen.dart';


class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Später dynamisch setzen
    final int xp = 30;
    final int xpNeeded = 100;
    final double progress = xp / xpNeeded;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 34, 21, 53),
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: const Color.fromARGB(255, 34, 21, 53),
        foregroundColor:  const Color.fromARGB(255, 221, 115, 45),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Level: 1",
              style: TextStyle(fontSize: 20, color:  const Color.fromARGB(255, 221, 115, 45),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "XP: $xp / $xpNeeded",
              style: const TextStyle(color:  const Color.fromARGB(255, 221, 115, 45),
              ),
            ),
            const SizedBox(height: 10),
            LinearPercentIndicator(
              animation: true,
              animationDuration: 500,
              lineHeight: 100.0,
              percent: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.white24,
              progressColor: const Color.fromARGB(255, 221, 115, 45),
              barRadius: const Radius.circular(15),
              center: Text(
                "${(progress * 100).round()}%",
                style: const TextStyle(color:  const Color.fromARGB(255, 221, 115, 45),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Heutige Aufgaben:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color:  const Color.fromARGB(255, 221, 115, 45),
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
      color:  const Color.fromARGB(255, 221, 115, 45),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(title),
        subtitle: Text("Schwierigkeit: $difficulty"),
        trailing: const Icon(Icons.arrow_forward_ios),
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
