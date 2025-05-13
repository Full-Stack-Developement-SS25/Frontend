import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'task_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final int xp = 30;
    final int xpNeeded = 100;
    final double progress = xp / xpNeeded;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: const Color.fromARGB(255, 34, 21, 53),
        foregroundColor: const Color.fromARGB(255, 221, 115, 45),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 💡 NEU: Box für Level + XP + Fortschrittsanzeige
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Level  1",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
                      color: Color.fromARGB(255, 221, 115, 45),
                    ),
                  ),
                  const SizedBox(height: 10),
                  LinearPercentIndicator(
                    animation: true,
                    animationDuration: 500,
                    lineHeight: 50.0,
                    percent: progress.clamp(0.0, 1.0),
                    backgroundColor: Colors.white24,
                    progressColor: const Color.fromARGB(255, 221, 115, 45),
                    barRadius: const Radius.circular(1000),
                    center: Text(
                      "${(progress * 100).round()}%",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "XP: $xp / $xpNeeded",
                    style: const TextStyle(
                      fontSize: 20,
                      color: Color.fromARGB(255, 221, 115, 45),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Heutige Aufgaben:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 40,
                        color: Color.fromARGB(255, 221, 115, 45),
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
            ),
          ],
        ),
      ),
    );
  }
}
