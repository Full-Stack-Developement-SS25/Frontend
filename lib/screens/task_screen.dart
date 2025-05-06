import 'package:flutter/material.dart';

class TaskScreen extends StatelessWidget {
  final String title;
  final String difficulty;

  const TaskScreen({super.key, required this.title, required this.difficulty});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 34, 21, 53),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color.fromARGB(255, 34, 21, 53),
        foregroundColor: const Color.fromARGB(255, 221, 115, 45),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Schwierigkeit: $difficulty",
              style: const TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 221, 115, 45),
              ),
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
                fillColor: Color.fromARGB(60, 255, 255, 255),
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
                backgroundColor: Color.fromARGB(255, 221, 115, 45),
              ),
              child: const Text("Senden"),
            ),
          ],
        ),
      ),
    );
  }
}
