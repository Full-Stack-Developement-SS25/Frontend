import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:prompt_master/services/auth_service.dart';
import 'package:prompt_master/services/user_service.dart';
import 'package:prompt_master/services/task_service.dart';
import 'package:prompt_master/utils/app_colors.dart';
import 'package:prompt_master/utils/xp_logic.dart';
import '../widgets/task_card.dart';
import '../widgets/section_header.dart';
import 'task_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Future<Map<String, dynamic>>? _userStats;
  Future<List<Map<String, dynamic>>>? _tasksFuture;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final userId = await AuthService.getUserId();
    if (!mounted) return;

    if (userId != null) {
      setState(() {
        _userStats = UserService.fetchUserStats(userId);
        _tasksFuture = TaskService.fetchTasks(userId);
      });
    } else {
      debugPrint("❌ Kein userId gefunden");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Fehler: Nicht eingeloggt"),
          backgroundColor: Colors.red,
        ),
      );
    }
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
      body:
          _userStats == null || _tasksFuture == null
              ? const Center(child: CircularProgressIndicator())
              : FutureBuilder<Map<String, dynamic>>(
                future: _userStats,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Fehler: ${snapshot.error}'));
                  } else {
                    final xp = snapshot.data!['xp'] as int;
                    final level = snapshot.data!['level'] as int;
                    final int xpNeeded = XPLogic.xpForLevel(level);
                    final int progressXP = xp;
                    final double progress = (progressXP / xpNeeded).clamp(
                      0.0,
                      1.0,
                    );

                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                  "XP: $progressXP / $xpNeeded",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
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
                            child: FutureBuilder<List<Map<String, dynamic>>>(
                              future: _tasksFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.accent,
                                    ),
                                  );
                                } else if (snapshot.hasError) {
                                  return const Center(
                                    child: Text(
                                      "Fehler beim Laden der Aufgaben",
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  );
                                } else if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return const Center(
                                    child: Text(
                                      "Keine Aufgaben gefunden",
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  );
                                }

                                final tasks = snapshot.data!.take(3).toList();
                                return ListView.builder(
                                  itemCount: tasks.length,
                                  itemBuilder: (context, index) {
                                    final task = tasks[index];
                                    return TaskCard(
                                      title: task['title'],
                                      difficulty: task['difficulty'].toString(),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) => TaskScreen(
                                                  taskId: task['id'],
                                                  title: task['title'],
                                                  difficulty:
                                                      task['difficulty']
                                                          .toString(),
                                                  taskText: task['description'],
                                                ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
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
