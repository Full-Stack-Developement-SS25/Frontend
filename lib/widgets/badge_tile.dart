import 'package:flutter/material.dart';
import 'package:prompt_master/models/badge.dart' as model;
import 'package:prompt_master/utils/app_colors.dart';

class BadgeTile extends StatelessWidget {
  final model.Badge badge;

  const BadgeTile({super.key, required this.badge});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Image.network(badge.iconUrl, width: 40, height: 40),
        title: Text(
          badge.title,
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          badge.description,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        trailing: Text(
          badge.awardedAt.split('T').first,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ),
    );
  }
}
