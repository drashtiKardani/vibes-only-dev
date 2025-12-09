import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/story.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:flutter_mobile_app_presentation/toy.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vibes_only/src/feature/toy/cubit/toy_cubit.dart';
import 'package:vibes_only/src/feature/toy/remote_control/toy_remote_control.dart';
import 'package:vibes_only/src/feature/toy/toy_search_dialog.dart';
import 'package:vibes_only/src/widget/blend_mask.dart';

class EnabledToyControlInStoryPlayer extends ToyControlButtonsProvider {
  @override
  Widget provideUtilizing(playerStore) => ToyControlButtons(store: playerStore);
}

class ToyControlButtons extends StatelessWidget {
  const ToyControlButtons({super.key, required this.store});

  final PlayerStore store;

  @override
  Widget build(BuildContext context) {
    final ToyCubit toyCubit = BlocProvider.of<ToyCubit>(context);
    final ToyCommandService toyCommandService =
        BlocProvider.of<ToyCommandService>(context);

    return Align(
      alignment: Alignment.topRight,
      child: BlocConsumer<ToyCubit, ToyState>(
        listenWhen: (previous, current) =>
            previous.connectedDevice?.bluetoothName !=
            current.connectedDevice?.bluetoothName,
        listener: (context, state) {
          Future.delayed(const Duration(milliseconds: 500), () {
            toyCommandService.toyStateChanged(state, toyCubit);
          });
        },
        builder: (context, state) {
          bool toyIsConnected = state.connectedDevice != null;

          return BlocBuilder<ToyCommandService, ToyCommandServiceState>(
            builder: (context, state) {
              final toyIsConnectedAndActive =
                  toyIsConnected && ToyCommandServiceState.active == state;
              final toyIsConnectedInManualMode =
                  toyIsConnected && ToyCommandServiceState.inactive == state;
              return Column(
                children: [
                  OutlinedButton(
                    onPressed: toyCommandService.currentStoryContainsVibes
                        ? () {
                            if (toyIsConnected) {
                              toyCommandService.resume();
                            } else {
                              // resume the service, in case it had been remained paused from previous session
                              toyCommandService.resume();
                              showToySearchDialog(context);
                            }
                          }
                        : null,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: toyIsConnectedAndActive &&
                              toyCommandService.currentStoryContainsVibes
                          ? context.colorScheme.onSurface
                              .withValues(alpha: 0.25)
                          : context.colorScheme.onSurface
                              .withValues(alpha: 0.1),
                      side: BorderSide(
                        color: toyIsConnectedAndActive &&
                                toyCommandService.currentStoryContainsVibes
                            ? context.colorScheme.onSurface
                            : context.colorScheme.onSurface
                                .withValues(alpha: 0.2),
                      ),
                      shape: const CircleBorder(),
                      padding: EdgeInsets.zero,
                    ),
                    child: Container(
                      width: 60,
                      height: 60,
                      alignment: Alignment.center,
                      child: toyIsConnectedAndActive &&
                              toyCommandService.currentStoryContainsVibes
                          ? Image.asset(
                              'assets/images/toy.gif',
                              package: 'flutter_mobile_app_presentation',
                              height: 30,
                              width: 30,
                            )
                          : const Icon(VibesV2.vibes, size: 32),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Automatic',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: 5),
                  Observer(
                    warnWhenNoObservables: false,
                    builder: (_) {
                      return toyIsConnectedAndActive &&
                              toyCommandService.currentStoryContainsVibes &&
                              store.playing
                          ? ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(90)),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                child: BlendMask(
                                  blendMode: BlendMode.screen,
                                  child: Image.asset(
                                    'assets/images/vibe_signal.gif',
                                    height: 18,
                                    width: 50,
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox(height: 18);
                    },
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: () {
                      if (toyIsConnected) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ToyRemoteControl(),
                          ),
                        );
                      } else {
                        showToySearchDialog(context).then(
                          (deviceIsConnected) {
                            if (deviceIsConnected) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) {
                                    return const ToyRemoteControl();
                                  },
                                ),
                              );
                            }
                          },
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: toyIsConnectedInManualMode
                          ? context.colorScheme.onSurface
                              .withValues(alpha: 0.25)
                          : context.colorScheme.onSurface
                              .withValues(alpha: 0.1),
                      side: BorderSide(
                        color: toyIsConnectedInManualMode
                            ? context.colorScheme.onSurface
                            : context.colorScheme.onSurface
                                .withValues(alpha: 0.2),
                      ),
                      shape: const CircleBorder(),
                      padding: EdgeInsets.zero,
                    ),
                    child: Container(
                      width: 60,
                      height: 60,
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        'assets/images/icon_toy_manual.svg',
                        height: 24,
                        width: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Manual', style: Theme.of(context).textTheme.labelSmall),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
