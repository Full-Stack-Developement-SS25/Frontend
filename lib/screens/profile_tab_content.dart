import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/user_service.dart';

class ProfileTabContent extends StatefulWidget {
  const ProfileTabContent({super.key});

  @override
  State<ProfileTabContent> createState() => _ProfileTabContentState();
}

class _ProfileTabContentState extends State<ProfileTabContent> {
  late Future<Map<String, dynamic>> _userStatsFuture;

  @override
  void initState() {
    super.initState();
    _userStatsFuture = UserService.getFreshUserStats();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _userStatsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              "Fehler: ${snapshot.error}",
              style: const TextStyle(color: Colors.white),
            ),
          );
        } else {
          final data = snapshot.data!;
          final username = data["username"] ?? "Unbekannt";
          final level = data["level"];
          final xp = data["xp"];
          final completedTasks = 3; // Optional dynamisch machen
          final badgeCount = 2; // Optional dynamisch machen

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
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  username,
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
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
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
