import 'package:flutter/material.dart';
import 'package:prompt_master/utils/app_colors.dart';
import 'package:prompt_master/services/user_service.dart';

class BadgesTabContent extends StatefulWidget {
  const BadgesTabContent({super.key});

  @override
  State<BadgesTabContent> createState() => _BadgesTabContentState();
}

class _BadgesTabContentState extends State<BadgesTabContent> {
  late Future<List<String>> _badgesFuture;

  @override
  void initState() {
    super.initState();
    _badgesFuture = UserService.fetchUserBadges();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _badgesFuture,
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
          final badges = snapshot.data!;

          if (badges.isEmpty) {
            return const Center(
              child: Text(
                "Du hast noch keine Abzeichen.",
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: badges.length,
            itemBuilder: (context, index) {
              return Card(
                color: AppColors.accent.withOpacity(0.1),
                child: ListTile(
                  leading: const Icon(Icons.emoji_events, color: Colors.amber),
                  title: Text(
                    badges[index],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}
