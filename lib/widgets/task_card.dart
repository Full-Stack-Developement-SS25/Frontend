import 'package:flutter/material.dart';

class TaskCard extends StatelessWidget {
  final String title;
  final String difficulty;
  final VoidCallback onTap;

  const TaskCard({
    super.key,
    required this.title,
    required this.difficulty,
    required this.onTap,
  });

  Color _getDifficultyColor() {
    switch (difficulty.toLowerCase()) {
      case "leicht":
        return const Color.fromARGB(255, 76, 175, 80); // grün
      case "mittel":
        return const Color.fromARGB(255, 255, 193, 7); // gelb
      case "schwer":
        return const Color.fromARGB(255, 244, 67, 54); // rot
      default:
        return Colors.grey;
    }
  }

  IconData _getDifficultyIcon() {
    switch (difficulty.toLowerCase()) {
      case "leicht":
        return Icons.signal_cellular_alt_1_bar;
      case "mittel":
        return Icons.signal_cellular_alt_2_bar;
      case "schwer":
        return Icons.signal_cellular_alt_outlined;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 221, 115, 45),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: Icon(
          _getDifficultyIcon(),
          color: _getDifficultyColor(),
          size: 32,
        ),
        title: Text(
          difficulty,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          title,
          style: const TextStyle(color: Colors.white),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
        onTap: onTap,
      ),
    );
  }
}
