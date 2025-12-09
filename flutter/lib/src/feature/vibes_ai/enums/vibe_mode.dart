enum VibeMode {
  /// User selects from pre-defined mood options
  chooseFromPreDefinedMoods,

  /// User manually describes their current mood
  describeYourMood,
}

extension VibeModeEx on VibeMode {
  String get displayName {
    return switch (this) {
      VibeMode.chooseFromPreDefinedMoods => 'Choose from Pre-Defined Moods',
      VibeMode.describeYourMood => 'Describe your Mood',
    };
  }
}
