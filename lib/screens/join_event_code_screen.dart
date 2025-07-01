import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/section_header.dart';

class JoinEventCodeScreen extends StatefulWidget {
  const JoinEventCodeScreen({super.key});

  @override
  State<JoinEventCodeScreen> createState() => _JoinEventCodeScreenState();
}

class _JoinEventCodeScreenState extends State<JoinEventCodeScreen> {
  final TextEditingController _codeController = TextEditingController();
  String? _feedbackText;

  void _joinEvent() {
    final enteredCode = _codeController.text.trim();

    if (enteredCode.isEmpty) {
      setState(() {
        _feedbackText = "Bitte gib einen Code ein.";
      });
    } else {
      debugPrint("Beigetreten mit Code: $enteredCode");
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Beigetreten zu Event: $enteredCode ✅"),
          backgroundColor: const Color.fromARGB(255, 34, 150, 63),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const SectionHeader("Code eingeben"),
        backgroundColor: AppColors.primaryBackground,
        foregroundColor: AppColors.accent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 🔼 Inhalt oben
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Gib deinen Event-Code ein:",
                  style: TextStyle(fontSize: 18, color: AppColors.white),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _codeController,
                  style: const TextStyle(color: AppColors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white10,
                    hintText: "z. B. PROMPT2025",
                    hintStyle: const TextStyle(color: Colors.white38),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_feedbackText != null)
                  Text(
                    _feedbackText!,
                    style: const TextStyle(color: Colors.white70),
                  ),
              ],
            ),

            // 🔽 Button ganz unten
            ElevatedButton(
              onPressed: _joinEvent,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Beitreten",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
