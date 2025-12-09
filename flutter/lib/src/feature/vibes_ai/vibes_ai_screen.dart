import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/controllers.dart';
import 'package:flutter_mobile_app_presentation/gen/assets.gen.dart' as assets;
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibes_common/vibes.dart';
import 'package:vibes_only/gen/assets.gen.dart';
import 'package:vibes_only/src/data/commodities_store.dart';
import 'package:vibes_only/src/feature/vibes_ai/components/known_toys_grid_view.dart';
import 'package:vibes_only/src/feature/vibes_ai/components/ai_option_selector.dart';
import 'package:vibes_only/src/feature/vibes_ai/enums/pre_defined_mood.dart';
import 'package:vibes_only/src/feature/vibes_ai/enums/vibe_mode.dart';
import 'package:vibes_only/src/feature/vibes_ai/extensions/extensions.dart';

const EdgeInsets _defaultPadding = EdgeInsets.symmetric(
  horizontal: 16,
  vertical: 8,
);

class VibesAiScreen extends StatefulWidget {
  const VibesAiScreen({super.key});

  @override
  State<VibesAiScreen> createState() => _VibesAiScreenState();
}

class _VibesAiScreenState extends State<VibesAiScreen> {
  late final VibesAiCubit _vibesAiCubit = context.read<VibesAiCubit>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      List<Commodity> knownToys = GetIt.I<CommoditiesStore>().knownToys;

      _vibesAiCubit.startChat(
        startContent: _ContentWrapper(
          fromAI: true,
          child: Text(
            'Nice to meet you. Here are the things I can do for you:',
            style: context.textTheme.titleMedium,
          ),
        ),
        suggestionsForYouContent: _ContentWrapper(
          fromAI: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                [
                  _SuggestionListItem(
                    icon: VibesV3.vibesLined,
                    title: 'Tell me about products.',
                    onPressed: () {
                      _vibesAiCubit.sentChat(
                        content: Column(
                          spacing: 10,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ContentWrapper(
                              fromAI: true,
                              child: Text(
                                'Select the Products you have.',
                                style: context.textTheme.titleMedium,
                              ),
                            ),
                            BlocBuilder<VibesAiCubit, VibesAiState>(
                              bloc: _vibesAiCubit,
                              builder: (context, state) {
                                return KnownToysGridView(
                                  toy: state.toy,
                                  knownToys: knownToys,
                                  onToySelected: (toy) {
                                    _vibesAiCubit.onToySelected(toy);

                                    String? shopUrl = toy.shopUrl;
                                    if (shopUrl == null) return;

                                    final Uri shopUri = Uri.parse(shopUrl);

                                    launchUrl(shopUri);
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  _SuggestionListItem(
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedPlay,
                      color: context.colorScheme.onSurface,
                    ),
                    title: 'Design a vibe for me based on how I feel.',
                    onPressed: () {
                      _vibesAiCubit.sentChat(
                        content: Column(
                          spacing: 10,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ContentWrapper(
                              fromAI: true,
                              child: Text(
                                'Choose how you want to create your vibe.',
                                style: context.textTheme.titleMedium,
                              ),
                            ),
                            _ContentWrapper(
                              fromAI: true,
                              child: AiOptionSelector<VibeMode>(
                                options: VibeMode.values,
                                titleOf: (option) => option.displayName,
                                onSelected: _onVibeModeSelected,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  _SuggestionListItem(
                    icon: VibesV3.searchLined,
                    title: 'Pick a story for me.',
                  ),
                  _SuggestionListItem(
                    icon: VibesV3.shop,
                    title: 'Help me shop for a new product.',
                  ),
                  _SuggestionListItem(
                    icon: VibesV3.sound,
                    title: 'Design a Vibe for me',
                  ),
                ].separateBuilder(() {
                  return Divider(
                    color: context.colorScheme.onSurface.withValues(
                      alpha: 0.06,
                    ),
                  );
                }),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VibesAiCubit, VibesAiState>(
      bloc: _vibesAiCubit,
      builder: (context, state) {
        return Scaffold(
          extendBodyBehindAppBar: true,

          appBar: AppBar(
            automaticallyImplyLeading: false,
            scrolledUnderElevation: 0,
            leading: Transform.scale(
              scale: 0.7,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.colorScheme.onSurface.withValues(alpha: 0.1),
                ),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedArrowLeft02,
                    color: context.colorScheme.onSurface,
                  ),
                  iconSize: 30,
                ),
              ),
            ),
            title: Row(
              spacing: 8,
              children: [Text('Whitney'), Assets.svg.vibesAi.svg()],
            ),
            titleTextStyle: context.textTheme.displaySmall,
          ),
          body: Stack(
            children: [
              Positioned.fill(
                child: assets.Assets.images.background.image(
                  filterQuality: FilterQuality.high,
                  package: 'flutter_mobile_app_presentation',
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14).copyWith(
                  top: context.mediaQuery.viewPadding.top + kToolbarHeight + 10,
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        itemCount: state.chats.length,
                        separatorBuilder: (context, index) => Gap(20),
                        padding: EdgeInsets.only(
                          bottom: context.mediaQuery.viewPadding.bottom + 10,
                        ),
                        itemBuilder: (context, index) {
                          ChatWithAI chat = state.chats[index];
                          return chat.content;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 18.0),
                      child: TextField(
                        autofocus: false,
                        controller: TextEditingController(),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromRGBO(255, 255, 255, 0.2),
                            ),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          hintText: 'Type here',
                          hintStyle: context.textTheme.titleMedium?.copyWith(
                            fontSize: 14,
                            color: context.colorScheme.onSurface.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onVibeModeSelected(VibeMode mode) {
    switch (mode) {
      case VibeMode.chooseFromPreDefinedMoods:
        _vibesAiCubit.sentChat(
          content: Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ContentWrapper(
                fromAI: true,
                child: Text(
                  'Choose from Pre-Defined Mood:',
                  style: context.textTheme.titleMedium,
                ),
              ),
              _ContentWrapper(
                fromAI: true,
                child: AiOptionSelector<PreDefinedMood>(
                  options: PreDefinedMood.values,
                  titleOf: (option) => option.displayName,
                  onSelected: (option) {},
                ),
              ),
            ],
          ),
        );
        break;
      case VibeMode.describeYourMood:
        _vibesAiCubit.sentChat(
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ContentWrapper(
                fromAI: true,
                child: Text(
                  'Tell me how you feel in one line.',
                  style: context.textTheme.titleMedium,
                ),
              ),
            ],
          ),
        );
    }
  }
}

class _ContentWrapper extends StatelessWidget {
  final Widget child;
  final bool fromAI;

  const _ContentWrapper({required this.child, required this.fromAI});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: _defaultPadding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          topLeft: Radius.circular(16),
          bottomLeft: fromAI ? Radius.zero : Radius.circular(16),
          bottomRight: fromAI ? Radius.circular(16) : Radius.zero,
        ),
        color: context.colorScheme.onSurface.withValues(alpha: 0.05),
      ),
      child: child,
    );
  }
}

class _SuggestionListItem extends StatelessWidget {
  final dynamic icon;
  final String title;
  final VoidCallback? onPressed;

  const _SuggestionListItem({
    required this.icon,
    required this.title,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = SizedBox.shrink();

    if (icon is IconData) {
      iconWidget = Icon(icon, color: context.colorScheme.onSurface);
    } else {
      iconWidget = icon;
    }
    return ListTile(
      minTileHeight: 30,
      onTap: onPressed,
      leading: iconWidget,
      title: Text(title),
      titleTextStyle: context.textTheme.titleMedium?.copyWith(fontSize: 14),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: context.colorScheme.onSurface,
      ),
    );
  }
}
