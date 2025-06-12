import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class SectionHeader extends StatelessWidget {
  final String text;

  const SectionHeader(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        backgroundColor: AppColors.primaryBackground,
        fontWeight: FontWeight.bold,
        fontSize: 40,
        color: AppColors.accent,
      ),
    );
  }
}
