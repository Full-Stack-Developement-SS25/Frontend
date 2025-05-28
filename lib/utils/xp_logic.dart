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
}
