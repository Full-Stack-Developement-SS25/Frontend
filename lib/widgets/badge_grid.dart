import 'package:flutter/material.dart';
import 'package:prompt_master/models/badge.dart' as model;
import 'package:prompt_master/utils/app_colors.dart';

class BadgeGrid extends StatelessWidget {
  final List<model.Badge> badges;

  const BadgeGrid({super.key, required this.badges});

  bool _isUnlocked(model.Badge badge) => badge.awardedAt.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final badge = badges[index];
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: _isUnlocked(badge) ? 1.0 : 0.3,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.network(
                  badge.iconUrl,
                  width: 50,
                  height: 50,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              badge.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.white,
              ),
            ),
          ],
        );
      },
    );
  }
}
