import 'package:flutter/material.dart';
import 'package:prompt_master/utils/app_colors.dart';
import 'package:prompt_master/services/user_service.dart';
import 'package:prompt_master/models/badge.dart' as model;
import 'package:prompt_master/widgets/badge_tile.dart';

class BadgesTabContent extends StatefulWidget {
  const BadgesTabContent({super.key});

  @override
  State<BadgesTabContent> createState() => _BadgesTabContentState();
}

class _BadgesTabContentState extends State<BadgesTabContent> {
  late Future<List<model.Badge>> _badgesFuture;

  @override
  void initState() {
    super.initState();
    _badgesFuture = UserService.fetchUserBadges();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<model.Badge>>(
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
          final List<model.Badge> badges = snapshot.data!;

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
              final badge = badges[index];
              return Card(
                color: AppColors.accent.withAlpha(26),
                child: BadgeTile(badge: badge),
              );
            },
          );
        }
      },
    );
  }
}
