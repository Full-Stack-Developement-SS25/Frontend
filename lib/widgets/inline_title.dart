import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class InlineTitle extends StatelessWidget {
  final String text;

  const InlineTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.accent,
      ),
    );
  }
}
