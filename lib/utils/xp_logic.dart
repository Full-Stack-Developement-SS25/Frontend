class XPLogic {
  static int calculateXP(String difficulty, int stars) {
    final int baseXP = switch (difficulty.toLowerCase()) {
      'leicht' => 5,
      'mittel' => 10,
      'schwer' => 15,
      _ => 0,
    };
    return baseXP * stars;
  }

  static int calculateBonusXP(int stars) {
    return stars == 5 ? 10 : 0;
  }

  static int calculateTotalXP(String difficulty, int stars) {
    return calculateXP(difficulty, stars) + calculateBonusXP(stars);
  }

  /// XP, die benötigt werden, um das [level] zu erreichen.
  static int xpForLevel(int level) {
    return 100 + (level - 1) * 50;
  }

  /// Gesamt-XP, die alle Level vor [level] erfordern.
  static int cumulativeXPForLevel(int level) {
    int total = 0;
    for (var i = 1; i < level; i++) {
      total += xpForLevel(i);
    }
    return total;
  }
}
