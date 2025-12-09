import 'dart:async';
import 'dart:math';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:flutter_mobile_app_presentation/toy.dart';

import '../../toy/cubit/toy_cubit.dart';
import '../../toy/toy_search_dialog.dart';

class SpotifyToyControlButtons extends StatefulWidget {
  const SpotifyToyControlButtons({super.key});

  @override
  State<SpotifyToyControlButtons> createState() =>
      _SpotifyToyControlButtonsState();
}

class _SpotifyToyControlButtonsState extends State<SpotifyToyControlButtons> {
  bool autoVibeIsActive = false;
  Timer? autoVibeTimer;

  void startAutoVibe() {
    autoVibeTimer = Timer(
      Duration(seconds: Random().nextInt(3) + 3),
      () {
        BlocProvider.of<ToyCubit>(context)
            .vibrate(Random().nextInt(40) + 30, Random().nextInt(40) + 30);
        startAutoVibe();
      },
    );
    setState(() => autoVibeIsActive = true);
  }

  void stopAutoVibe() {
    autoVibeTimer?.cancel();
    BlocProvider.of<ToyCubit>(context).stop(0);
    BlocProvider.of<ToyCubit>(context).stop(1);
    setState(() => autoVibeIsActive = false);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: BlocConsumer<ToyCubit, ToyState>(
          listenWhen: (previous, current) =>
              previous.connectedDevice?.bluetoothName !=
              current.connectedDevice?.bluetoothName,
          listener: (context, state) {
            Future.delayed(const Duration(milliseconds: 500), () {
              // toyCommandService.toyStateChanged(state, toyCubit);
            });
          },
          builder: (context, state) {
            var toyIsConnected = state.connectedDevice != null;
            final toyIsConnectedAndActive = toyIsConnected && autoVibeIsActive;

            return Column(
              children: [
                OutlinedButton(
                  onPressed: () async {
                    if (autoVibeIsActive) {
                      stopAutoVibe();
                    } else if (toyIsConnected ||
                        await showToySearchDialog(context)) {
                      startAutoVibe();
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: toyIsConnectedAndActive
                        ? const Color(0xffce4c68).withValues(alpha: 0.5)
                        : const Color(0xff9e9e9e).withValues(alpha: 0.1),
                    side: BorderSide(
                      color: toyIsConnectedAndActive
                          ? const Color(0xffce4c68)
                          : const Color(0xff9e9e9e),
                    ),
                    shape: const CircleBorder(),
                    padding: EdgeInsets.zero,
                  ),
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: toyIsConnectedAndActive
                        ? const FlareActor(
                            'assets/toy.flr',
                            alignment: Alignment.center,
                            fit: BoxFit.cover,
                            animation: "Untitled",
                          )
                        : const Icon(VibesV2.vibes, size: 32),
                  ),
                ),
                // const SizedBox(height: 2),
                // Text('Automatic', style: Theme.of(context).textTheme.labelSmall),
                // const SizedBox(height: 5),
                // toyIsConnectedAndActive && widget.isPlaying
                //     ? ClipRRect(
                //         borderRadius: const BorderRadius.all(Radius.circular(90)),
                //         child: BackdropFilter(
                //           filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                //           child: BlendMask(
                //             blendMode: BlendMode.screen,
                //             child: Image.asset(
                //               "assets/images/vibe_signal.gif",
                //               height: 18,
                //               width: 50,
                //             ),
                //           ),
                //         ),
                //       )
                //     : const SizedBox(height: 18),
                // const SizedBox(height: 24),
                // OutlinedButton(
                //   onPressed: () async {
                //     if (toyIsConnected || await showToySearchDialog(context)) {
                //       stopAutoVibe();
                //       if (context.mounted) {
                //         Navigator.push(context, MaterialPageRoute(builder: (_) => const ToyRemoteControl()));
                //       }
                //     }
                //   },
                //   style: OutlinedButton.styleFrom(
                //     backgroundColor: toyIsConnectedInManualMode
                //         ? const Color(0xffce4c68).withValues(alpha:0.5)
                //         : const Color(0xff9e9e9e).withValues(alpha:0.1),
                //     side: BorderSide(
                //       color: toyIsConnectedInManualMode ? const Color(0xffce4c68) : const Color(0xff9e9e9e),
                //     ),
                //     shape: const CircleBorder(),
                //     padding: EdgeInsets.zero,
                //   ),
                //   child: Container(
                //     width: 60,
                //     height: 60,
                //     alignment: Alignment.center,
                //     child: SvgPicture.asset(
                //       "assets/images/icon_toy_manual.svg",
                //       height: 24,
                //       width: 24,
                //     ),
                //   ),
                // ),
                // const SizedBox(height: 4),
                // Text('Manual', style: Theme.of(context).textTheme.labelSmall),
              ],
            );
          }),
    );
  }
}
