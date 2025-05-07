import 'package:flutter/material.dart';
import 'task_screen.dart'; // für Detailnavigation

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
      backgroundColor: const Color.fromARGB(255, 34, 21, 53),
      appBar: AppBar(
        title: const Text("Aufgaben"),
        backgroundColor: const Color.fromARGB(255, 34, 21, 53),
        foregroundColor: const Color.fromARGB(255, 221, 115, 45),
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return Card(
            color: const Color.fromARGB(255, 221, 115, 45),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(
                task["title"]!,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                "Schwierigkeit: ${task["difficulty"]}",
                style: const TextStyle(color: Colors.white70),
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
