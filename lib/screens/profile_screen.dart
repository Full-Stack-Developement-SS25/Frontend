import 'package:flutter/material.dart';
import './/utils/app_colors.dart';
import 'login_screen.dart'; // Importiere die Login-Seite

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Später: dynamische Daten vom User-Model
    final String username = "mattis_dev";
    final int level = 1;
    final int xp = 30;
    final int completedTasks = 3;
    final int badges = 1;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: const Text("Profil"),
        backgroundColor: AppColors.primaryBackground,
        foregroundColor: AppColors.accent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.accent,
                  child: const Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  username,
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 30),
            _profileStat("Level", "$level"),
            _profileStat("XP", "$xp"),
            _profileStat("Abgeschlossene Aufgaben", "$completedTasks"),
            _profileStat("Abzeichen", "$badges"),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Upgrade logik
              },
              icon: const Icon(Icons.upgrade),
              label: const Text("Upgrade auf Pro"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Backend-Logout-Logik
                _logout(context); // Zum Login-Screen navigieren
              },
              icon: const Icon(Icons.exit_to_app),
              label: const Text("Logout"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileStat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.white70)),
          ),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  // Logout-Logik: Benutzer ausloggen und zurück zur Login-Seite
  void _logout(BuildContext context) {
    // Hier wird die Backend-Logout-Logik eingefügt (z.B. JWT-Token löschen)
    // Zum Beispiel:
    // AuthService.logout();

    // Nach dem Logout zurück zur Login-Seite
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }
}
