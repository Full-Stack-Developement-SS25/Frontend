import 'package:flutter/material.dart';
import 'package:prompt_master/utils/app_colors.dart';

class XPRewardScreen extends StatefulWidget {
  final int xpGained;
  final int oldXP;
  final int newXP;
  final int level;

  const XPRewardScreen({
    super.key,
    required this.xpGained,
    required this.oldXP,
    required this.newXP,
    required this.level,
  });

  @override
  State<XPRewardScreen> createState() => _XPRewardScreenState();
}

class _XPRewardScreenState extends State<XPRewardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _xpAnimation;

  final int maxXP = 100; // Beispielwert für XP bis nächstes Level

  @override
  void initState() {
    super.initState();

    final double start = widget.oldXP / maxXP;
    final double end = widget.newXP / maxXP;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _xpAnimation = Tween<double>(
      begin: start,
      end: end,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int progressXP = widget.newXP % maxXP;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        foregroundColor: AppColors.accent,
        title: const Text("XP-Belohnung"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            Text(
              "🎉 +${widget.xpGained} XP erhalten!",
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.accent,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              "Level ${widget.level}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: _xpAnimation,
              builder: (context, child) {
                return Column(
                  children: [
                    LinearProgressIndicator(
                      value: _xpAnimation.value.clamp(0.0, 1.0),
                      minHeight: 20,
                      color: AppColors.accent,
                      backgroundColor: AppColors.fillColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${(progressXP).clamp(0, maxXP)} / $maxXP XP",
                      style: const TextStyle(color: AppColors.white),
                    ),
                  ],
                );
              },
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home',
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Zurück zur Aufgabenliste",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
