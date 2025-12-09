import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/gen/assets.gen.dart' as assets;
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:vibes_only/src/data/commodities_store.dart';
import 'package:vibes_only/src/dialog/new_name_dialog.dart';
import 'package:vibes_only/src/feature/toy/remote_control/motor_selector/motor_selector.dart';
import 'package:vibes_only/src/feature/toy/remote_control/motor_selector/motor_selector_cubit.dart';
import 'package:vibes_only/src/feature/vibes_tab/vibes_studio/choose_pattern_screen.dart';
import 'package:vibes_only/src/feature/vibes_tab/vibes_studio/data/new_vibe_store.dart';
import 'package:vibes_only/src/feature/vibes_tab/vibes_studio/data/vibe_bar_data.dart';
import 'package:vibes_only/src/feature/vibes_tab/vibes_studio/data/vibe_player.dart';
import 'package:vibes_only/src/feature/vibes_tab/vibes_studio/data/vibe_timeline.dart';
import 'package:vibes_only/src/feature/vibes_tab/vibes_studio/vibe_bar.dart';
import 'package:vibes_only/src/feature/vibes_tab/vibes_studio/vibe_bar_ruler.dart';
import 'package:vibes_only/src/feature/vibes_tab/vibes_studio/vibe_extension.dart';
import 'package:vibes_only/src/widget/back_button_app_bar.dart';
import 'package:vibes_only/src/widget/vibes_elevated_button.dart';

import '../../toy/toy_search_dialog.dart';
import 'config.dart';

/// Lets user create or modify a custom vibe.
/// Returns the created/edited [NewVibeStore] to the previous route on "Save".
/// If [existingVibe] is given, its [toyBluetoothName] is set inside it and hence it must be null;
/// Otherwise [toyBluetoothName] must be given.
class NewVibeScreen extends StatefulWidget {
  const NewVibeScreen({
    super.key,
    this.existingVibe,
    this.toyBluetoothName,
    required this.vibePlayer,
  }) : assert((existingVibe == null) ^ (toyBluetoothName == null));
  final NewVibeStore? existingVibe;
  final String? toyBluetoothName;
  final VibePlayer vibePlayer;

  @override
  State<NewVibeScreen> createState() => _NewVibeScreenState();
}

class _NewVibeScreenState extends State<NewVibeScreen> {
  late final NewVibeStore newVibeStore =
      widget.existingVibe ??
      NewVibeStore('My Vibe', toyBluetoothName: widget.toyBluetoothName!);

  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        return BlocProvider(
          create: (_) => MotorSelectorCubit(),
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            extendBodyBehindAppBar: true,
            appBar: BackButtonAppBar(
              context,
              title: 'Vibe Studio/${newVibeStore.toyName}',
              onPressed: () => Navigator.pop(context),
            ),
            body: Stack(
              children: [
                Positioned.fill(
                  child: assets.Assets.images.background.image(
                    filterQuality: FilterQuality.high,
                    package: 'flutter_mobile_app_presentation',
                  ),
                ),
                BlocBuilder<MotorSelectorCubit, ToyMotor>(
                  builder: (c, selectedMotor) {
                    final VibeTimeline timeline = switch (selectedMotor) {
                      ToyMotor.mainMotor => newVibeStore.timeline1,
                      ToyMotor.subMotor => newVibeStore.timeline2,
                      ToyMotor.thirdMotor => newVibeStore.timeline3,
                    };

                    return Observer(
                      builder: (c) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14)
                              .copyWith(
                                top:
                                    context.viewPadding.top +
                                    kToolbarHeight +
                                    10,
                                bottom: context.viewPadding.bottom + 10,
                              ),
                          child: Column(
                            spacing: 20,
                            children: [
                              MotorSelector(
                                userCustomTabSelectorUI: true,
                                toyAsCommodity: GetIt.I<CommoditiesStore>()
                                    .toyWithName(newVibeStore.toyBluetoothName),
                              ),
                              Expanded(
                                child: Theme(
                                  // For removing white background of "bar"s when reordering.
                                  data: context.theme.copyWith(
                                    canvasColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                  ),
                                  child: Column(
                                    children: [
                                      const VibeBarRuler(),
                                      SizedBox(height: 20),
                                      Expanded(
                                        child: _VibeTimelinesListView(
                                          scrollController: scrollController,
                                          timeline: timeline,
                                          onReorder: (oldIndex, newIndex) {
                                            setState(() {
                                              if (oldIndex < newIndex) {
                                                newIndex -= 1;
                                              }
                                              final VibeBarData item = timeline
                                                  .data
                                                  .removeAt(oldIndex);
                                              timeline.data.insert(
                                                newIndex,
                                                item,
                                              );
                                            });
                                          },
                                          onAddBar: () {
                                            Navigator.of(context)
                                                .push<int?>(
                                                  MaterialPageRoute(
                                                    builder: (_) {
                                                      return const ChoosePatternScreen();
                                                    },
                                                  ),
                                                )
                                                .then((patternIndex) {
                                                  if (patternIndex == null) {
                                                    // Do nothing; user has closed it without choosing a pattern.
                                                  } else {
                                                    setState(() {
                                                      timeline.addBar(
                                                        patternIndex:
                                                            patternIndex,
                                                      );
                                                    });
                                                    WidgetsBinding.instance
                                                        .addPostFrameCallback((
                                                          _,
                                                        ) {
                                                          scrollController.animateTo(
                                                            scrollController
                                                                .position
                                                                .maxScrollExtent,
                                                            duration: Durations
                                                                .medium3,
                                                            curve: Curves
                                                                .fastOutSlowIn,
                                                          );
                                                        });
                                                  }
                                                });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  switch (selectedMotor) {
                                    case ToyMotor.mainMotor:
                                      if (widget
                                              .vibePlayer
                                              .currentlyPlayingOnMotor1 ==
                                          newVibeStore) {
                                        widget.vibePlayer.stopMotor1();
                                      } else {
                                        showToyConnectDialogIfNecessary(
                                          context,
                                        ).then((connected) {
                                          if (connected) {
                                            widget.vibePlayer.playOnMotor1(
                                              newVibeStore,
                                            );
                                          }
                                        });
                                      }
                                    case ToyMotor.subMotor:
                                      if (widget
                                              .vibePlayer
                                              .currentlyPlayingOnMotor2 ==
                                          newVibeStore) {
                                        widget.vibePlayer.stopMotor2();
                                      } else {
                                        showToyConnectDialogIfNecessary(
                                          context,
                                        ).then((connected) {
                                          if (connected) {
                                            widget.vibePlayer.playOnMotor2(
                                              newVibeStore,
                                            );
                                          }
                                        });
                                      }
                                    case ToyMotor.thirdMotor:
                                      if (widget
                                              .vibePlayer
                                              .currentlyPlayingOnMotor3 ==
                                          newVibeStore) {
                                        widget.vibePlayer.stopMotor3();
                                      } else {
                                        showToyConnectDialogIfNecessary(
                                          context,
                                        ).then((connected) {
                                          if (connected) {
                                            widget.vibePlayer.playOnMotor3(
                                              newVibeStore,
                                            );
                                          }
                                        });
                                      }
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: context.colorScheme.onSurface
                                        .withValues(alpha: 0.1),
                                  ),
                                  child: HugeIcon(
                                    icon: switch (selectedMotor) {
                                      ToyMotor.mainMotor =>
                                        widget
                                                    .vibePlayer
                                                    .currentlyPlayingOnMotor1 ==
                                                newVibeStore
                                            ? HugeIcons.strokeRoundedPause
                                            : HugeIcons.strokeRoundedPlay,
                                      ToyMotor.subMotor =>
                                        widget
                                                    .vibePlayer
                                                    .currentlyPlayingOnMotor2 ==
                                                newVibeStore
                                            ? HugeIcons.strokeRoundedPause
                                            : HugeIcons.strokeRoundedPlay,
                                      ToyMotor.thirdMotor =>
                                        widget
                                                    .vibePlayer
                                                    .currentlyPlayingOnMotor3 ==
                                                newVibeStore
                                            ? HugeIcons.strokeRoundedPause
                                            : HugeIcons.strokeRoundedPlay,
                                    },
                                    size: 40,
                                    color: context.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              VibesElevatedButton(
                                onPressed: () {
                                  showNewNameBottomSheet(
                                    context,
                                    oldName: newVibeStore.name,
                                  ).then((newName) {
                                    if (newName != null && newName.isNotEmpty) {
                                      newVibeStore.name = newName;
                                      Navigator.pop(context, newVibeStore);
                                    }
                                  });
                                },
                                text: 'Save',
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _VibeTimelinesListView extends StatelessWidget {
  final ScrollController scrollController;
  final ReorderCallback onReorder;
  final VoidCallback onAddBar;
  final VibeTimeline timeline;

  const _VibeTimelinesListView({
    required this.scrollController,
    required this.onReorder,
    required this.onAddBar,
    required this.timeline,
  });

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (c) {
        return ReorderableListView(
          scrollController: scrollController,
          physics: timeline.aBarIsBeingResized
              ? const NeverScrollableScrollPhysics()
              : null,
          onReorder: onReorder,
          footer: Align(
            alignment: Alignment.centerLeft,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: onAddBar,
              child: Container(
                height:
                    VibeStudioConfig.heightOfOneSecondBar *
                    VibeStudioConfig.initialDuration,
                width: 250,
                margin: EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: context.colorScheme.onSurface.withValues(alpha: 0.05),
                  border: Border.all(
                    color: context.colorScheme.onSurface.withValues(alpha: 0.2),
                  ),
                ),
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 7),
                child: Container(
                  width: VibeStudioConfig.vibeBarTimeBoxDim,
                  height: VibeStudioConfig.vibeBarTimeBoxDim,
                  decoration: BoxDecoration(
                    color: context.colorScheme.onSurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedAdd01,
                    size: 26,
                    color: context.colorScheme.surface,
                  ),
                ),
              ),
            ),
          ),
          children: timeline.data.mapIndexed((index, data) {
            return Padding(
              key: Key('$index'),
              padding: EdgeInsets.symmetric(vertical: 4),
              child: VibeBar(data: data, store: timeline),
            );
          }).toList(),
        );
      },
    );
  }
}
