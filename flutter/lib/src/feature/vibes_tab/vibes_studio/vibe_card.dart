import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter_mobile_app_presentation/dialogs.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:vibes_only/src/feature/toy/toy_search_dialog.dart';
import 'package:vibes_only/src/feature/toy/toy_visual_elements.dart';
import 'package:vibes_only/src/feature/vibes_tab/spotify/spotify_playlists_screen.dart';
import 'package:vibes_only/src/feature/vibes_tab/vibes_studio/data/new_vibe_store.dart';
import 'package:vibes_only/src/feature/vibes_tab/vibes_studio/data/vibe_player.dart';
import 'package:vibes_only/src/feature/vibes_tab/vibes_studio/data/vibe_studio_storage.dart';
import 'package:vibes_only/src/feature/vibes_tab/vibes_studio/routines.dart';
import 'package:vibes_only/src/feature/vibes_tab/vibes_studio/vibe_extension.dart';

class VibeCard extends StatelessWidget {
  const VibeCard({
    super.key,
    required this.vibe,
    required this.vibePlayer,
    required this.storage,
  });

  final NewVibeStore vibe;
  final VibePlayer vibePlayer;
  final VibeStudioStorage storage;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            vertical: 14,
          ).copyWith(left: 14, right: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: context.colorScheme.onSurface.withValues(alpha: 0.05),
            border: Border.all(
              color: context.colorScheme.onSurface.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 14,
            children: [
              Observer(
                builder: (context) {
                  return Row(
                    spacing: 12,
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          if (vibePlayer.currentlyPlayingOnMotor1 == vibe) {
                            vibePlayer.stopMotor1();
                          } else {
                            showToyConnectDialogIfNecessary(context).then((
                              connected,
                            ) {
                              if (connected) vibePlayer.playOnMotor1(vibe);
                            });
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: context.colorScheme.onSurface.withValues(
                              alpha: 0.1,
                            ),
                          ),
                          child: HugeIcon(
                            icon: vibePlayer.currentlyPlayingOnMotor1 == vibe
                                ? HugeIcons.strokeRoundedPause
                                : HugeIcons.strokeRoundedPlay,
                            color: context.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 2,
                          children: [
                            Text(
                              vibe.name,
                              style: context.textTheme.headlineMedium?.copyWith(
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              vibe.timeline1.durationString,
                              style: context.textTheme.titleLarge?.copyWith(
                                fontSize: 12,
                                color: context.colorScheme.onSurface.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Icon(
                          Icons.more_vert,
                          color: context.colorScheme.onSurface,
                        ),
                        onPressed: () async {
                          _Action? action =
                              await showBlurredBackgroundBottomSheet<_Action?>(
                                context: context,
                                barrierDismissible: true,
                                builder: (context) {
                                  return _VibesActionSheet();
                                },
                              );

                          switch (action) {
                            case _Action.edit:
                              letUserCreateAVibeThenStoreTheResult(
                                context,
                                storage: storage,
                                existingVibe: vibe,
                                vibePlayer: vibePlayer,
                              );
                            case _Action.delete:
                              storage.delete(vibe);
                            case null:
                          }
                        },
                      ),
                    ],
                  );
                },
              ),
              Padding(
                padding: EdgeInsets.only(right: 10),
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: Observer(
                    builder: (context) {
                      return Row(
                        spacing: 8,
                        children: [
                          if (defaultTargetPlatform != TargetPlatform.android)
                            vibe.toyImage(),
                          ...vibe.timeline1.data.map((e) {
                            return Container(
                              width: 100,
                              height: 50,
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: context.colorScheme.onSurface.withValues(
                                  alpha: 0.08,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: VibePatters.getByIndex(
                                e.patternIndex,
                                color: context.colorScheme.onSurface,
                              ),
                            );
                          }),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        // Positioned(
        //   top: 0,
        //   right: 0,
        //   child: PopupMenuButton(
        //     icon: Icon(Icons.more_vert, color: context.colorScheme.onSurface),
        //     elevation: 0,
        //     color: context.colorScheme.surface,
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(10),
        //     ),
        //     onSelected: (action) {
        //       switch (action) {
        //         case _Action.edit:
        //           letUserCreateAVibeThenStoreTheResult(
        //             context,
        //             storage: storage,
        //             existingVibe: vibe,
        //             vibePlayer: vibePlayer,
        //           );
        //         case _Action.delete:
        //           storage.delete(vibe);
        //       }
        //     },
        //     itemBuilder: (context) {
        //       return _Action.values.map((action) {
        //         return PopupMenuItem(
        //           value: action,
        //           child: Text(action.title),
        //         );
        //       }).toList();
        //     },
        //   ),
        // ),
      ],
    );
  }
}

enum _Action { edit, delete }

extension on _Action {
  List<List<dynamic>> get icon {
    return switch (this) {
      _Action.edit => HugeIcons.strokeRoundedEdit02,
      _Action.delete => HugeIcons.strokeRoundedDelete02,
    };
  }
}

class _VibesActionSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10,
      children: _Action.values.map((e) {
        return CupertinoButton(
          onPressed: () => Navigator.pop(context, e),
          padding: const EdgeInsets.all(8),
          child: Row(
            spacing: 20,
            children: [
              HugeIcon(
                icon: e.icon,
                size: 24,
                color: context.colorScheme.onSurface,
              ),
              Expanded(
                child: Text(
                  e.name.capitalize(),
                  style: context.textTheme.titleMedium?.copyWith(fontSize: 18),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
