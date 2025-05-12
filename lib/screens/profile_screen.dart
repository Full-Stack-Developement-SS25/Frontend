import 'package:flutter/material.dart';
import '../widgets/section_header.dart';


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
      backgroundColor: const Color.fromARGB(255, 34, 21, 53),
      appBar: AppBar(
        title: const SectionHeader("Profil"),
        backgroundColor: const Color.fromARGB(255, 34, 21, 53),
        foregroundColor: const Color.fromARGB(255, 221, 115, 45),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Color.fromARGB(255, 221, 115, 45),
                  child: Icon(Icons.person, size: 30, color: Colors.white),
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
                backgroundColor: const Color.fromARGB(255, 221, 115, 45),
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
}
