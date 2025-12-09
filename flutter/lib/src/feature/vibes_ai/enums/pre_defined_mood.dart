enum PreDefinedMood { playful, romantic, relaxed, adventurous }

extension PreDefinedMoodEx on PreDefinedMood {
  String get displayName {
    return switch (this) {
      PreDefinedMood.playful => 'Playful',
      PreDefinedMood.romantic => 'Romantic',
      PreDefinedMood.relaxed => 'Relaxed',
      PreDefinedMood.adventurous => 'Adventurous',
    };
  }
}
