import 'package:flutter/material.dart';
import 'package:prompt_master/screens/xp_reward_screen.dart';
import 'package:prompt_master/utils/app_colors.dart';
import 'package:prompt_master/utils/xp_logic.dart';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_service.dart';
import '../services/task_service.dart';
import '../widgets/section_header.dart';
import '../services/auth_service.dart';
import '../utils/premium_required_dialog.dart';
import '../utils/custom_dialog.dart';

class EvaluationScreen extends StatefulWidget {
  final int score;
  final String explanation;
  final String taskText;
  final String userPrompt;
  final String taskId;
  final String taskDifficulty;
  final List<dynamic>? bestPractices;
  final List<dynamic>? improvementSuggestions;

  const EvaluationScreen({
    super.key,
    required this.score,
    required this.explanation,
    required this.taskText,
    required this.userPrompt,
    required this.taskId,
    required this.taskDifficulty,
    this.bestPractices,
    this.improvementSuggestions,
  });

  @override
  State<EvaluationScreen> createState() => _EvaluationScreenState();
}

class _EvaluationScreenState extends State<EvaluationScreen> {
  int? _oldXP;
  int? _newXP;
  int? _level;
  late int _xpGained;
  bool _isPremium = false;

  @override
  void initState() {
    super.initState();
    _xpGained = XPLogic.calculateTotalXP(widget.taskDifficulty, widget.score);
    _checkPremium();
  }

  Future<void> _checkPremium() async {
    _isPremium = await UserService.isPremiumUser();
    if (mounted) setState(() {});
  }

  Future<void> _updateXPAndLevel() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = await AuthService.getUserId();

      if (userId == null) {
        developer.log('Kein user_id gefunden', name: 'EvaluationScreen');
        return;
      }

      final before = await UserService.fetchUserStats(userId);
      _oldXP = before['xp'];
      int level = before['level'];

      await UserService.addXP(
        userId: userId,
        difficulty: widget.taskDifficulty,
        stars: widget.score,
      );

      final after = await UserService.fetchUserStats(userId);
      _newXP = after['xp'];
      level = after['level'];

      final int xpNeeded = XPLogic.xpForLevel(level);
      if (_newXP! >= xpNeeded) {
        level += 1;
        await UserService.updateLevel(userId, level);
      }

      _level = level;

      await prefs.setInt('xp', _newXP!);
      await prefs.setInt('level', _level!);
    } catch (e) {
      developer.log('Fehler bei XP-Vergabe: $e', name: 'EvaluationScreen');
    }
  }

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

            const SizedBox(height: 20),
            ListTile(
              title: const Text(
                "Best Practices anzeigen",
                style: TextStyle(color: AppColors.white),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.accent,
              ),
              tileColor: AppColors.fillColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onTap: () {
                if (_isPremium) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        backgroundColor: AppColors.primaryBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "Best Practices",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.accent,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ...widget.bestPractices!.map(
                                (e) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Text(
                                    "- $e",
                                    style: const TextStyle(
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text("Schließen"),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  showPremiumRequiredDialog(context);
                }
              },
            ),

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
                        await _updateXPAndLevel();
                        if (!mounted) return;

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => XPRewardScreen(
                                  xpGained: _xpGained,
                                  oldXP: _oldXP ?? 0,
                                  newXP: _newXP ?? 0,
                                  level: _level ?? 1,
                                ),
                          ),
                        );
                      } catch (e) {
                        showErrorDialog(
                          context,
                          'Fehler',
                          'Fehler beim Markieren: $e',
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
