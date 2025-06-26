import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/user_service.dart';
import '../services/badge_service.dart';

class ProfileTabContent extends StatefulWidget {
  const ProfileTabContent({super.key});

  @override
  State<ProfileTabContent> createState() => _ProfileTabContentState();
}

class _ProfileTabContentState extends State<ProfileTabContent> {
  late Future<Map<String, dynamic>> _profileDataFuture;

  @override
  void initState() {
    super.initState();
    _profileDataFuture = _loadProfileData();
  }

  Future<Map<String, dynamic>> _loadProfileData() async {
    final stats = await UserService.getFreshUserStats();
    final summary = await UserService.fetchUserStatsSummary();
    return {
      ...stats,
      'badgeCount': summary['badgeCount'],
      'completedTasks': summary['completedTasks'],
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _profileDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              "Fehler: ${snapshot.error}",
              style: const TextStyle(color: AppColors.white),
            ),
          );
        } else {
          final data = snapshot.data!;
          final username = data["username"] ?? "Unbekannt";
          final level = data["level"];
          final xp = data["xp"];
          final completedTasks = data["completedTasks"] ?? 0;
          final badgeCount = data["badgeCount"] ?? 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.accent,
                  child: const Icon(
                    Icons.person,
                    size: 50,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  username,
                  style: const TextStyle(
                    fontSize: 24,
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                _infoCard("Level", "$level"),
                _infoCard("XP", "$xp"),
                _infoCard("Abgeschlossene Aufgaben", "$completedTasks"),
                _infoCard("Abzeichen", "$badgeCount"),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _infoCard(String title, String value) {
    return Card(
      color: Colors.white10,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(title, style: const TextStyle(color: Colors.white70)),
        trailing: Text(
          value,
          style: const TextStyle(color: AppColors.white, fontSize: 16),
        ),
      ),
    );
  }
}
