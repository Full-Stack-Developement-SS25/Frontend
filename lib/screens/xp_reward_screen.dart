import 'package:flutter/material.dart';
import 'package:prompt_master/utils/app_colors.dart';
import 'package:prompt_master/services/badge_service.dart';
import 'package:prompt_master/utils/xp_logic.dart';
import 'main_navigation.dart';

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
  late final int maxXP;

  @override
  void initState() {
    super.initState();

    maxXP = XPLogic.xpForLevel(widget.level);

    final double start = (widget.oldXP / maxXP).clamp(0.0, 1.0);
    final double end = (widget.newXP / maxXP).clamp(0.0, 1.0);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _xpAnimation = Tween<double>(
      begin: start,
      end: end,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showNewBadgeInfo();
    });
  }


  Future<void> _showNewBadgeInfo() async {
    final newBadges = await BadgeService.checkForNewBadges();
    if (!mounted || newBadges.isEmpty) return;

    for (final badge in newBadges) {
      await showDialog(
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
                  const Icon(Icons.emoji_events, size: 60, color: Colors.amber),
                  const SizedBox(height: 16),
                  const Text(
                    "Neues Badge!",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '🎉 Du hast das Badge "${badge.title}" freigeschaltet!',
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
                      backgroundColor: AppColors.accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Cool!"),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }



  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      "${widget.newXP.clamp(0, maxXP)} / $maxXP XP",
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
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MainNavigation(initialIndex: 1),
                    ),
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
