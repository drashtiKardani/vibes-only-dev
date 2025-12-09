import 'package:flutter/material.dart';
import 'package:vibes_only/src/feature/vibes_tab/vibes_studio/data/vibe_player.dart';
import 'package:vibes_only/src/feature/vibes_tab/vibes_studio/select_toy_screen.dart';

import 'data/new_vibe_store.dart';
import 'data/vibe_studio_storage.dart';
import 'new_vibe_screen.dart';

void letUserCreateAVibeThenStoreTheResult(
  BuildContext context, {
  NewVibeStore? existingVibe,
  required VibeStudioStorage storage,
  required VibePlayer vibePlayer,
}) {
  if (existingVibe != null) {
    Navigator.push<NewVibeStore>(
      context,
      MaterialPageRoute(
        builder: (context) => NewVibeScreen(
          existingVibe: existingVibe,
          toyBluetoothName: null,
          vibePlayer: vibePlayer,
        ),
      ),
    ).then((toBeSavedVibeData) => _save(toBeSavedVibeData, storage));
  } else {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelectToyScreen(
          onToySelected: (toy) {
            Navigator.pushReplacement<NewVibeStore, void>(
              context,
              MaterialPageRoute(
                builder: (context) => NewVibeScreen(
                  existingVibe: null,
                  toyBluetoothName: toy.bluetoothName,
                  vibePlayer: vibePlayer,
                ),
              ),
            ).then((toBeSavedVibeData) => _save(toBeSavedVibeData, storage));
          },
        ),
      ),
    );
  }
}

void _save(NewVibeStore? data, VibeStudioStorage storage) {
  if (data != null) {
    storage.addNewOrModifyExisting(data);
  }
}
