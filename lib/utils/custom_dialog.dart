import 'package:flutter/material.dart';
import 'app_colors.dart';

void showCustomDialog({
  required BuildContext context,
  required String title,
  required String description,
  required IconData icon,
  required Color iconColor,
  required String buttonText,
}) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: AppColors.primaryBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 60, color: iconColor),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: iconColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(buttonText),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void showSuccessDialog(
  BuildContext context,
  String title,
  String description, {
  String buttonText = 'Okay',
}) {
  showCustomDialog(
    context: context,
    title: title,
    description: description,
    icon: Icons.check_circle_outline,
    iconColor: Colors.green,
    buttonText: buttonText,
  );
}

void showErrorDialog(
  BuildContext context,
  String title,
  String description, {
  String buttonText = 'Schließen',
}) {
  showCustomDialog(
    context: context,
    title: title,
    description: description,
    icon: Icons.error_outline,
    iconColor: Colors.red,
    buttonText: buttonText,
  );
}

void showInfoDialog(
  BuildContext context,
  String title,
  String description, {
  String buttonText = 'Okay',
}) {
  showCustomDialog(
    context: context,
    title: title,
    description: description,
    icon: Icons.info_outline,
    iconColor: AppColors.accent,
    buttonText: buttonText,
  );
}

void showBadgeDialog(
  BuildContext context,
  String title,
  String description, {
  String buttonText = 'Cool!',
}) {
  showCustomDialog(
    context: context,
    title: title,
    description: description,
    icon: Icons.emoji_events,
    iconColor: Colors.amber,
    buttonText: buttonText,
  );
}
