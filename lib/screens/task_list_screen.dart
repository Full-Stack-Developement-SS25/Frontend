import 'package:flutter/material.dart';
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
      backgroundColor:
          AppColors.primaryBackground, 
      appBar: AppBar(
        title: const Text("Aufgaben"),
        backgroundColor:
            AppColors
                .primaryBackground, 
        foregroundColor:
            AppColors.accent, 
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return Card(
            color: AppColors.accent, 
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(
                task["title"]!,
                style: TextStyle(
                  color: AppColors.textPrimary, 
                ),
              ),
              subtitle: Text(
                "Schwierigkeit: ${task["difficulty"]}",
                style: TextStyle(
                  color:
                      AppColors.textSecondary, 
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white, 
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => TaskScreen(
                          title: task["title"]!,
                          difficulty: task["difficulty"]!,
                        ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
