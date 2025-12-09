import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/gen/assets.gen.dart' as assets;
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:flutter_mobile_app_presentation/toy.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:vibes_only/gen/assets.gen.dart';
import 'package:vibes_only/src/feature/toy/remote_control/toy_remote_control.dart';
import 'package:vibes_only/src/feature/toy/toy_state_extension.dart';
import 'package:vibes_only/src/widget/back_button_app_bar.dart';
import 'package:vibes_only/src/widget/grey_container.dart';

class ToyConnectedScreen extends StatefulWidget {
  const ToyConnectedScreen({super.key});

  @override
  State createState() => _ToyConnectedScreenState();
}

class _ToyConnectedScreenState extends State<ToyConnectedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: BackButtonAppBar(context, onPressed: () => context.pop()),
      body: BlocConsumer<ToyCubit, ToyState>(
        listener: (c, state) {
          if (deviceNotConnected(state)) {
            Navigator.pop(context);
          }
        },
        builder: (c, state) {
          return Stack(
            children: [
              Positioned.fill(
                child: assets.Assets.images.background.image(
                  filterQuality: FilterQuality.high,
                  package: 'flutter_mobile_app_presentation',
                ),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 14).copyWith(
                    top: context.mediaQuery.viewPadding.top +
                        kToolbarHeight +
                        20,
                    bottom: context.mediaQuery.viewPadding.bottom),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: _openRemoteControlScreen,
                      child: GreyContainer(
                        color: context.colorScheme.onSurface
                            .withValues(alpha: 0.05),
                        child: Column(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: Assets.images.circle.provider(),
                                ),
                              ),
                              child: state.toyImage(height: 80, width: 80),
                            ),
                            Gap(40),
                            Text(
                              'Tap that\n(to control your vibe)',
                              textAlign: TextAlign.center,
                              style: context.textTheme.headlineLarge
                                  ?.copyWith(fontSize: 18, height: 1.2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    OutlinedButton(
                      onPressed: _disconnectDevice,
                      style: OutlinedButton.styleFrom(
                        fixedSize: Size(context.mediaQuery.size.width, 48),
                      ),
                      child: const Text('Disconnect'),
                    ),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }

  bool deviceNotConnected(ToyState state) => state.connectedDevice == null;

  Future<void> _disconnectDevice() async {
    BlocProvider.of<ToyCubit>(context).disconnect();
  }

  void _openRemoteControlScreen() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => const ToyRemoteControl()));
  }
}
