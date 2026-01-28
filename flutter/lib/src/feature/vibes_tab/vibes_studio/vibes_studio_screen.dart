import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/gen/assets.gen.dart' as assets;
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:flutter_mobile_app_presentation/toy.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:vibes_only/src/feature/vibes_tab/vibes_studio/data/new_vibe_store.dart';
import 'package:vibes_only/src/feature/vibes_tab/vibes_studio/data/vibe_player.dart';
import 'package:vibes_only/src/feature/vibes_tab/vibes_studio/data/vibe_studio_storage.dart';
import 'package:vibes_only/src/feature/vibes_tab/vibes_studio/routines.dart';
import 'package:vibes_only/src/feature/vibes_tab/vibes_studio/vibe_card.dart';
import 'package:vibes_only/src/widget/back_button_app_bar.dart';

class VibesStudioScreen extends StatefulWidget {
  const VibesStudioScreen({super.key});

  @override
  State<VibesStudioScreen> createState() => _VibesStudioScreenState();
}

class _VibesStudioScreenState extends State<VibesStudioScreen> {
  final VibeStudioStorage storage = VibeStudioStorage();
  late final VibePlayer vibePlayer;

  @override
  void initState() {
    super.initState();
    vibePlayer = VibePlayer(BlocProvider.of<ToyCubit>(context));
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        List<NewVibeStore>? listOfVibes = storage.listOfVibes?.toList();

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: BackButtonAppBar(
            context,
            onPressed: () => Navigator.pop(context),
          ),
          floatingActionButton: (listOfVibes?.isNotEmpty ?? false)
              ? _addVibeButton()
              : null,
          body: Stack(
            children: [
              Positioned.fill(
                child: assets.Assets.images.background.image(
                  filterQuality: FilterQuality.high,
                  package: 'flutter_mobile_app_presentation',
                ),
              ),
              Builder(
                builder: (_) {
                  if (listOfVibes == null) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (listOfVibes.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Customize your vibe for a unique, personalized experience',
                              textAlign: TextAlign.center,
                              style: context.textTheme.displaySmall?.copyWith(
                                fontSize: 24,
                              ),
                            ),
                            const Gap(20),
                            Text(
                              'Pick and combine patterns to create the ideal Vibe for you.\n\nEdit your Vibe by adjusting duration and intensity of each pattern.',
                              textAlign: TextAlign.center,
                              style: context.textTheme.titleMedium?.copyWith(
                                color: context.colorScheme.onSurface.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                            ),
                            const Gap(40),
                            _addVibeButton(),
                          ],
                        ),
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16)
                        .copyWith(
                          top: context.viewPadding.top + kToolbarHeight + 10,
                          bottom: context.viewPadding.bottom + 10,
                        ),
                    child: Column(
                      spacing: 20,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Vibes',
                          style: context.textTheme.displaySmall?.copyWith(
                            fontSize: 24,
                            color: context.colorScheme.onSurface.withValues(
                              alpha: 0.8,
                            ),
                            letterSpacing: 0.5,
                          ),
                        ),
                        Expanded(
                          child: ListView.separated(
                            itemCount: listOfVibes.length,
                            padding: EdgeInsets.zero,
                            physics: ClampingScrollPhysics(),
                            separatorBuilder: (context, index) => const Gap(14),
                            itemBuilder: (context, index) {
                              return VibeCard(
                                vibe: listOfVibes[index],
                                vibePlayer: vibePlayer,
                                storage: storage,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _addVibeButton() {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        letUserCreateAVibeThenStoreTheResult(
          context,
          storage: storage,
          vibePlayer: vibePlayer,
        );
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.colorScheme.onSurface,
        ),
        child: HugeIcon(
          icon: HugeIcons.strokeRoundedAdd01,
          color: context.colorScheme.surface,
          size: 26,
        ),
      ),
    );
  }
}
