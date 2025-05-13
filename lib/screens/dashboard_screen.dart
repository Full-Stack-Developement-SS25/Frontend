import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:prompt_master/services/user_service.dart';
import 'package:prompt_master/utils/app_colors.dart';
import '../widgets/task_card.dart';
import '../widgets/section_header.dart';

// Temporär: später dynamisch laden z. B. aus SharedPreferences
const String userId = 'deine-user-id-hier';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<Map<String, dynamic>> _userStats;

  @override
  void initState() {
    super.initState();
    _userStats = UserService.fetchUserStats(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: const SectionHeader("Startseite"),
        backgroundColor: AppColors.primaryBackground,
        foregroundColor: AppColors.accent,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userStats,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Fehler: ${snapshot.error}'));
          } else {
            final xp = snapshot.data!['xp'] as int;
            final level = snapshot.data!['level'] as int;
            final int xpNeeded = 100; // später dynamisch berechenbar
            final double progress = (xp / xpNeeded).clamp(0.0, 1.0);

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 📊 XP & Level Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Level $level",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 40,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(height: 10),
                        LinearPercentIndicator(
                          animation: true,
                          animationDuration: 500,
                          lineHeight: 50.0,
                          percent: progress,
                          backgroundColor: Colors.white24,
                          progressColor: AppColors.accent,
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
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ✅ Aufgabenliste
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
                              color: AppColors.accent,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: ListView(
                              children: [
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
            );
          }
        },
      ),
    );
  }
}
