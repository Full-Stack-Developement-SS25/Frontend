import 'package:flutter/material.dart';
import '../widgets/section_header.dart';
import '../widgets/inline_title.dart';
import './/utils/app_colors.dart';

class TaskScreen extends StatefulWidget {
  final String title;
  final String difficulty;

  const TaskScreen({super.key, required this.title, required this.difficulty});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: SectionHeader(widget.difficulty),
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.primaryBackground,
        foregroundColor: AppColors.accent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            InlineTitle(widget.title),
            const SizedBox(height: 20),
            // ❗️Expanded mit Column, um Mitte + Footer zu erreichen
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  // 🧠 Dynamisch wachsendes Textfeld
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: 50,
                      maxHeight: 200,
                    ),
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      minLines: 1,
                      maxLines: null, // macht es "auto-grow"
                      expands: false,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white10,
                        hintText: "Dein Prompt...",
                        hintStyle: const TextStyle(color: Colors.white54),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 📤 Senden-Button ganz unten, volle Breite
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final prompt = _controller.text.trim();
                  debugPrint("Prompt gesendet: $prompt");
                  // TODO: Bewertung auslösen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 221, 115, 45),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Senden",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
