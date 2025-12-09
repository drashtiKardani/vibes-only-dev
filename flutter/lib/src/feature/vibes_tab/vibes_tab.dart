import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/controllers.dart';
import 'package:flutter_mobile_app_presentation/gen/assets.gen.dart' as assets;
import 'package:flutter_mobile_app_presentation/preferences.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:flutter_mobile_app_presentation/toy.dart';
import 'package:vibes_only/gen/assets.gen.dart';
import 'package:vibes_only/src/feature/toy/remote_control/toy_remote_control.dart';
import 'package:vibes_only/src/feature/toy/toy_connected_screen.dart';
import 'package:vibes_only/src/feature/toy/toy_search_dialog.dart';
import 'package:vibes_only/src/feature/toy/toy_state_extension.dart';
import 'package:vibes_only/src/feature/vibes_ai/vibes_ai_screen.dart';
import 'package:vibes_only/src/feature/vibes_tab/four_way_controller/four_way_controller_screen.dart';
import 'package:vibes_only/src/feature/vibes_tab/four_way_controller/intro_screen.dart';
import 'package:vibes_only/src/feature/vibes_tab/magic_wand/intro_screen.dart';
import 'package:vibes_only/src/feature/vibes_tab/magic_wand/magic_wand_screen.dart';
import 'package:vibes_only/src/feature/vibes_tab/remote_lover_mode.dart';
import 'package:vibes_only/src/feature/vibes_tab/shop_screen.dart';
import 'package:vibes_only/src/feature/vibes_tab/toy_settings_dialog.dart';
import 'package:vibes_only/src/feature/vibes_tab/vibes_studio/intro_screen.dart';
import 'package:vibes_only/src/feature/vibes_tab/vibes_studio/vibes_studio_screen.dart';
import 'package:vibes_only/src/feature/vibes_tab/voice_toy_bridge/intro_screen.dart';
import 'package:vibes_only/src/feature/vibes_tab/voice_toy_bridge/voice_toy_bridge_screen.dart';
import 'package:vibes_only/src/service/analytics.dart';

class VibesTab extends StatelessWidget {
  const VibesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: assets.Assets.images.background.image(
            filterQuality: FilterQuality.high,
            package: 'flutter_mobile_app_presentation',
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ).copyWith(top: context.viewPadding.top),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: [
              Text(
                'Controls',
                style: context.textTheme.displaySmall?.copyWith(
                  fontSize: 24,
                  color: context.colorScheme.onSurface.withValues(alpha: 0.8),
                  letterSpacing: 0.5,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.only(
                    bottom: kBottomNavigationBarHeight + 90,
                  ),
                  child: Column(
                    spacing: 16,
                    children: [
                      BlocBuilder<ToyCubit, ToyState>(
                        builder: (context, state) {
                          return state.connectedDevice == null
                              ? _RowButton(
                                  icon: VibesV3.tapToConnect,
                                  title: 'Tap to Connect',
                                  onPressed: () {
                                    Analytics.logEvent(
                                      name: 'vibesConnect',
                                      context: context,
                                    );
                                    showToySearchDialog(context).then((
                                      connected,
                                    ) {
                                      if (connected) {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) {
                                              return const ToyConnectedScreen();
                                            },
                                          ),
                                        );
                                      }
                                    });
                                  },
                                )
                              : _RowButton(
                                  icon: Transform.scale(
                                    scale: 1.5,
                                    child: state.toyImage(
                                      height: 30,
                                      width: 30,
                                      fallbackWidget: Icon(
                                        VibesV3.tapToConnect,
                                      ),
                                    ),
                                  ),
                                  title: 'Connected',
                                  borderColor: context.colorScheme.onSurface,
                                  onPressed: () =>
                                      openToySettingsDialog(context),
                                );
                        },
                      ),
                      _RowButton(
                        icon: VibesV3.manualControl,
                        title: 'Manual Control',
                        onPressed: () {
                          showToyConnectDialogIfNecessary(context).then((
                            connected,
                          ) {
                            if (connected) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ToyRemoteControl(),
                                ),
                              );
                            }
                          });
                        },
                      ),
                      _RowButton(
                        icon: VibesV3.vibesStudio,
                        title: 'Vibes Studio',
                        onPressed: () {
                          if (SyncSharedPreferences
                              .doNotShowVibeStudioIntro
                              .value) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const VibesStudioScreen(),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const VibeStudioIntro(),
                              ),
                            );
                          }
                        },
                      ),
                      _RowButton(
                        icon: VibesV3.magicWand,
                        title: 'Magic Wand',
                        onPressed: () {
                          showToyConnectDialogIfNecessary(context).then((
                            connected,
                          ) {
                            if (connected) {
                              if (SyncSharedPreferences
                                  .doNotShowMagicWandIntro
                                  .value) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const MagicWandScreen(),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const MagicWandIntro(),
                                  ),
                                );
                              }
                            }
                          });
                        },
                      ),
                      _RowButton(
                        icon: VibesV3.fourWayController,
                        title: 'Four Way Controller',
                        onPressed: () =>
                            showToyConnectDialogIfNecessary(context).then((
                              connected,
                            ) {
                              if (connected) {
                                if (SyncSharedPreferences
                                    .doNotShowFourWayControllerIntro
                                    .value) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const FourWayController(),
                                    ),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const FourWayControllerIntro(),
                                    ),
                                  );
                                }
                              }
                            }),
                      ),
                      _RowButton(
                        icon: VibesV3.sound,
                        title: 'Sound',
                        onPressed: () {
                          showToyConnectDialogIfNecessary(context).then((
                            connected,
                          ) {
                            if (connected) {
                              if (SyncSharedPreferences
                                  .doNotShowToySoundControlIntro
                                  .value) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return const VoiceToyBridgeScreen();
                                    },
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return const SpeakToVibeIntro();
                                    },
                                  ),
                                );
                              }
                            }
                          });
                        },
                      ),
                      _RowButton(
                        icon: VibesV3.remoteControl,
                        title: 'Long Distance',
                        onPressed: () {
                          openRemoteLoverModeBottomSheet(context);
                        },
                      ),
                      _RowButton(
                        icon: Assets.svg.vibesAi.svg(height: 28, width: 28),
                        title: 'Whitney',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return BlocProvider(
                                  create: (context) => VibesAiCubit(),
                                  child: const VibesAiScreen(),
                                );
                              },
                            ),
                          );
                        },
                      ),
                      if (!Platform.isAndroid)
                        _RowButton(
                          icon: VibesV3.shop,
                          title: 'Shop',
                          onPressed: () => _openShop(context),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

void _openShop(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (context) => ShopScreen()));
}

class _RowButton extends StatelessWidget {
  final dynamic icon;
  final String title;
  final void Function()? onPressed;
  final Color? borderColor;

  const _RowButton({
    required this.icon,
    required this.title,
    this.onPressed,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    Color foregroundColor = context.colorScheme.onSurface;

    Widget iconWidget = SizedBox.shrink();

    if (icon is IconData) {
      iconWidget = Icon(icon, color: foregroundColor, size: 30);
    } else {
      iconWidget = icon;
    }

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: context.colorScheme.onSurface.withValues(alpha: 0.05),
          border: Border.all(
            color:
                borderColor ??
                context.colorScheme.onSurface.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          spacing: 20,
          children: [
            iconWidget,
            Expanded(
              child: Text(
                title,
                style: context.textTheme.titleMedium?.copyWith(
                  color: foregroundColor,
                ),
              ),
            ),
            Icon(VibesV3.arrowRight, color: foregroundColor, size: 28),
          ],
        ),
      ),
    );
  }
}
