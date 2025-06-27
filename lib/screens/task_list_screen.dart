import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/task_service.dart';
import '../screens/task_screen.dart';
import '../widgets/task_card.dart';
import '../widgets/section_header.dart';
import 'choose_join_method_screen.dart';
import 'prompt_history_screen.dart';
import '../services/user_service.dart';
import '../utils/app_colors.dart';
import '../utils/premium_required_dialog.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  Future<List<Map<String, dynamic>>>? _tasksFuture;
  bool _isPremiumUser = false;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _checkPremium();
  }

  Future<void> _loadTasks() async {
    final userId = await AuthService.getUserId();
    if (!mounted) return;

    if (userId != null) {
      setState(() {
        _tasksFuture = TaskService.fetchTasks();
      });
    }
  }

  Future<void> _checkPremium() async {
    final premium = await UserService.isPremiumUser();
    if (!mounted) return;
    setState(() {
      _isPremiumUser = premium;
    });
  }

  Future<void> _generateTask() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      await TaskService.generateNewTask();
      await _loadTasks();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: const SectionHeader("Aufgaben"),
        backgroundColor: AppColors.primaryBackground,
        foregroundColor: AppColors.accent,
        elevation: 0,
        actions: [
          if (_isPremiumUser)
            IconButton(
              onPressed: _isGenerating ? null : _generateTask,
              tooltip: 'Neue Challenge generieren',
              icon: _isGenerating
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: AppColors.accent,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.add_circle_outline),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child:
                  _tasksFuture == null
                      ? const Center(child: CircularProgressIndicator())
                      : FutureBuilder<List<Map<String, dynamic>>>(
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

                          final tasks = snapshot.data!;
                          return ListView.builder(
                            itemCount: tasks.length,
                            itemBuilder: (context, index) {
                              final task = tasks[index];
                              return TaskCard(
                                title: task['title'],
                                difficulty: task['difficulty'].toString(),
                                onTap: () async {
                                  final difficulty =
                                      task['difficulty']
                                          ?.toString()
                                          .toLowerCase();
                                  if (difficulty == 'schwer') {
                                    final premium =
                                        await UserService.isPremiumUser();
                                    if (!premium) {
                                      if (!mounted) return;
                                      showPremiumRequiredDialog(context);
                                      return;
                                    }
                                  }
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => TaskScreen(
                                            taskId: task['id'],
                                            title: task['title'],
                                            difficulty:
                                                task['difficulty'].toString(),
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
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.qr_code_scanner, size: 30),
                label: const Text(
                  "Event beitreten",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChooseJoinMethodScreen(),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.history, size: 30),
                label: const Text(
                  "Prompt-Historie",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  final premium = await UserService.isPremiumUser();
                  if (!premium) {
                    if (!mounted) return;
                    showPremiumRequiredDialog(context);
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PromptHistoryScreen(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
