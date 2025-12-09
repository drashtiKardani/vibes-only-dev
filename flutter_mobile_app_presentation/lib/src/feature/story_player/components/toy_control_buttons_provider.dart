import 'package:flutter/material.dart';
import 'package:flutter_mobile_app_presentation/src/feature/story_player/player_store.dart';

/// Provides two buttons for auto/manual mode of toy control, inside the story player.
/// This lets us to disable them completely in the admin simulator.
abstract class ToyControlButtonsProvider {
  Widget provideUtilizing(PlayerStore playerStore);
}

class DisabledToyControlInStoryPlayer extends ToyControlButtonsProvider {
  @override
  Widget provideUtilizing(PlayerStore playerStore) => const SizedBox.shrink();
}
