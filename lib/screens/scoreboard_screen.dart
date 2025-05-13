import 'package:flutter/material.dart';
import '../widgets/section_header.dart';

import './/utils/app_colors.dart';

class ScoreboardScreen extends StatelessWidget {
  const ScoreboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Später durch Daten vom Backend/API ersetzen
    final List<Map<String, dynamic>> scores = [
      {"name": "Lena", "level": 5, "xp": 420},
      {"name": "Jonas", "level": 4, "xp": 350},
      {"name": "Mira", "level": 3, "xp": 280},
      {"name": "Du", "level": 1, "xp": 30},
    ];

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: const Text("Scoreboard"),
        backgroundColor: AppColors.primaryBackground,
        foregroundColor: AppColors.accent,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: scores.length,
        separatorBuilder: (_, __) => Divider(color: AppColors.divider),
        itemBuilder: (context, index) {
          final user = scores[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.accent,
              child: Text(
                "${index + 1}",
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              user["name"],
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            subtitle: Text(
              "Level ${user["level"]} – ${user["xp"]} XP",
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: const Icon(Icons.emoji_events, color: Colors.amber),
          );
        },
      ),
    );
  }
}
