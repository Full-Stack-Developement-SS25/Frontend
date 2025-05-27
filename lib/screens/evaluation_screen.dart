import 'package:flutter/material.dart';
import 'package:prompt_master/utils/app_colors.dart';
import '../services/task_service.dart';
import '../widgets/section_header.dart';

class EvaluationScreen extends StatefulWidget {
  final int score;
  final String explanation;
  final String taskText;
  final String userPrompt;
  final String taskId;
  final List<dynamic>? bestPractices;
  final List<dynamic>? improvementSuggestions;

  const EvaluationScreen({
    super.key,
    required this.score,
    required this.explanation,
    required this.taskText,
    required this.userPrompt,
    required this.taskId,
    this.bestPractices,
    this.improvementSuggestions,
  });

  @override
  State<EvaluationScreen> createState() => _EvaluationScreenState();
}

class _EvaluationScreenState extends State<EvaluationScreen> {
  Widget _buildStars(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return Icon(
          index < count ? Icons.star : Icons.star_border,
          color: AppColors.accent,
          size: 32,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: const SectionHeader("Bewertung"),
        backgroundColor: AppColors.primaryBackground,
        foregroundColor: AppColors.accent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: _buildStars(widget.score)),
            const SizedBox(height: 20),

            ExpansionTile(
              title: const Text(
                "Aufgabenstellung anzeigen",
                style: TextStyle(color: AppColors.white),
              ),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.fillColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.taskText,
                    style: const TextStyle(color: AppColors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            ExpansionTile(
              title: const Text(
                "Deine Antwort anzeigen",
                style: TextStyle(color: AppColors.white),
              ),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.fillColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.userPrompt,
                    style: const TextStyle(color: AppColors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Text(
              "Begründung:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.explanation,
              style: const TextStyle(color: AppColors.white),
            ),

            if (widget.improvementSuggestions != null &&
                widget.improvementSuggestions!.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text(
                "Verbesserungsvorschläge:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 8),
              ...widget.improvementSuggestions!.map(
                (s) => Text(
                  "- $s",
                  style: const TextStyle(color: AppColors.white),
                ),
              ),
            ],

            if (widget.bestPractices != null &&
                widget.bestPractices!.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text(
                "Best Practices:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 8),
              ...widget.bestPractices!.map(
                (s) => Text(
                  "- $s",
                  style: const TextStyle(color: AppColors.white),
                ),
              ),
            ],

            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Erneut versuchen',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await TaskService.markAsDone(widget.taskId);
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/taskList',
                          (route) => false,
                        );

                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Fehler beim Markieren: $e')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Als erledigt markieren',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
