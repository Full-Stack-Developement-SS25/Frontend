import 'package:flutter/material.dart';
import '../widgets/task_card.dart';
import 'choose_join_method_screen.dart';
import '../widgets/section_header.dart';

import 'task_screen.dart'; // für Detailnavigation
import './/utils/app_colors.dart'; // Achte darauf, den richtigen Pfad zu verwenden

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> tasks = [
      {"title": "Produktbeschreibung-Prompt schreiben", "difficulty": "Leicht"},
      {"title": "KI-Chat mit Stilvorgabe erstellen", "difficulty": "Mittel"},
      {
        "title": "Argumentatives Streitgespräch prompten",
        "difficulty": "Schwer",
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: const SectionHeader("Aufgaben"),
        backgroundColor: const Color.fromARGB(255, 34, 21, 53),
        foregroundColor: const Color.fromARGB(255, 221, 115, 45),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return TaskCard(
                    title: task["title"]!,
                    difficulty: task["difficulty"]!,
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 221, 115, 45),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.qr_code_scanner, size: 30),
                label: const Text(
                  "Event beitreten",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChooseJoinMethodScreen(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
