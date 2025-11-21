enum GenderTheme {
  boy,
  girl,
  general; // For guest mode

  /// Convert from integer (0 = boy, 1 = girl)
  static GenderTheme fromInt(int value) {
    return value == 1 ? GenderTheme.girl : GenderTheme.boy;
  }

  /// Convert to integer (0 = boy, 1 = girl)
  int toInt() {
    return this == GenderTheme.girl ? 1 : 0;
  }
}
