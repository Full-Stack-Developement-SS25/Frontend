import 'package:flutter/material.dart';
import 'package:prompt_master/utils/app_colors.dart';
import '../widgets/section_header.dart';
import '../widgets/inline_title.dart';
import '../services/ai_service.dart';
import '../services/config.dart';
import '../services/user_service.dart';
import '../utils/premium_required_dialog.dart'; // 🔥 NEU
import 'evaluation_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TaskScreen extends StatefulWidget {
  final String taskId;
  final String title;
  final String difficulty;
  final String taskText;

  const TaskScreen({
    super.key,
    required this.taskId,
    required this.title,
    required this.difficulty,
    required this.taskText,
  });

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final TextEditingController _controller = TextEditingController();
  bool isLoading = false;
  List<String> _models = ['gpt4o mini'];
  String _selectedModel = 'gpt4o mini';

  @override
  void initState() {
    super.initState();
    _fetchModels();
  }

  Future<void> _fetchModels() async {
    try {
      final response = await http.get(Uri.parse('${Config.baseUrl}/models'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          _models = data.keys.cast<String>().toList();
          if (!_models.contains(_selectedModel)) {
            _selectedModel = _models.isNotEmpty ? _models.first : 'gpt4o mini';
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _showModelSelection(BuildContext context) async {
    final isPremium = await UserService.isPremiumUser();
    if (!isPremium) {
      if (!mounted) return;
      showPremiumRequiredDialog(context);
      return;
    }

    showModalBottomSheet(
      backgroundColor: AppColors.accent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      context: context,
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children:
              _models.map((model) {
                return ListTile(
                  title: Text(
                    model,
                    style: const TextStyle(color: AppColors.white),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedModel = model;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: SectionHeader(widget.difficulty),
        automaticallyImplyLeading: true,
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

            // Zentraler Bereich (Aufgabenstellung + Prompt)
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Aufgabenstellung:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.taskText,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),

                      const Text(
                        "Dein Prompt:",
                        style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _controller,
                        style: const TextStyle(color: AppColors.white),
                        minLines: 3,
                        maxLines: 6,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.fillColor,
                          hintText: "Dein Prompt...",
                          hintStyle: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Model Auswahl als Modal
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "KI-Modell auswählen",
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _showModelSelection(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.fillColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.textSecondary),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedModel,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
                          ),
                        ),
                        const Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Senden Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    isLoading
                        ? null
                        : () async {
                          final prompt = _controller.text.trim();
                          if (prompt.isNotEmpty) {
                            setState(() {
                              isLoading = true;
                            });

                            final result = await AIService.evaluatePrompt(
                              widget.taskText,
                              prompt,
                              widget.taskId,
                              _selectedModel,
                            );
                            if (!mounted) return;

                            setState(() {
                              isLoading = false;
                            });

                            if (result != null && result['stars'] != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => EvaluationScreen(
                                        score: result['stars'],
                                        explanation:
                                            result['explanation'] ?? '',
                                        taskText: widget.taskText,
                                        userPrompt: prompt,
                                        bestPractices: result['bestPractices'],
                                        improvementSuggestions:
                                            result['improvementSuggestions'],
                                        taskId: widget.taskId,
                                        taskDifficulty: widget.difficulty,
                                      ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Fehler bei der Bewertung"),
                                ),
                              );
                            }
                          }
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    isLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                        : const Text(
                          "Senden",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
