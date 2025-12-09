import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/gen/assets.gen.dart' as assets;
import 'package:flutter_mobile_app_presentation/src/cubit/iap/in_app_purchase_state.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:flutter_mobile_app_presentation/src/cubit/iap/in_app_purchase_cubit.dart';
import 'package:flutter_mobile_app_presentation/src/cubit/story/story_cubit.dart';
import 'package:flutter_mobile_app_presentation/src/cubit/story/story_state.dart';
import 'package:flutter_mobile_app_presentation/src/feature/section_item_click_handler.dart';
import 'package:vibes_common/vibes.dart';
import 'package:hugeicons/hugeicons.dart';

class DetailListScreen extends StatefulWidget {
  const DetailListScreen(this.item, this.type, {super.key});

  final SectionItem item;
  final SectionType type;

  @override
  State createState() => _DetailListScreenState();
}

class _DetailListScreenState extends State<DetailListScreen> {
  late StoryCubit _cubit;
  late final ScrollController _controller = ScrollController();

  final ValueNotifier<bool> _isCollapsedNotifier = ValueNotifier(false);

  void _handleScroll() {
    final bool isCollapsed = _controller.offset >= 30;

    if (_isCollapsedNotifier.value != isCollapsed) {
      _isCollapsedNotifier.value = isCollapsed;
    }
  }

  @override
  void initState() {
    super.initState();

    _controller.addListener(_handleScroll);

    _cubit = StoryCubit();
    switch (widget.type) {
      case SectionType.character:
        _cubit.getStories(characterId: widget.item.id);
        break;
      case SectionType.category:
        _cubit.getStories(categoryId: widget.item.id);
        break;
      default:
        throw Exception(
          "Unknown type - must be either 'Character' or 'Category'",
        );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _isCollapsedNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isCollapsedNotifier,
      builder: (context, isCollapsed, _) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: AnimatedSwitcher(
              duration: Durations.medium1,
              child: isCollapsed
                  ? AppBar(
                      key: const ValueKey('1'),
                      automaticallyImplyLeading: false,
                      scrolledUnderElevation: 0,
                      backgroundColor: context.colorScheme.surface,
                      leading: _buildBackButton(),
                    )
                  : AppBar(
                      key: const ValueKey('0'),
                      automaticallyImplyLeading: false,
                      scrolledUnderElevation: 0,
                      leading: _buildBackButton(),
                    ),
            ),
          ),
          body: Stack(
            children: [
              Positioned.fill(
                child: assets.Assets.images.background.image(
                  filterQuality: FilterQuality.high,
                  package: 'flutter_mobile_app_presentation',
                ),
              ),
              SingleChildScrollView(
                controller: _controller,
                padding: const EdgeInsets.symmetric(horizontal: 14).copyWith(
                  top: context.mediaQuery.viewPadding.top + kToolbarHeight + 10,
                  bottom: context.mediaQuery.viewPadding.bottom + 10,
                ),
                child: Column(
                  spacing: 20,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.title,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontSize: 32,
                        color: context.colorScheme.onSurface.withValues(
                          alpha: 0.8,
                        ),
                      ),
                    ),
                    BlocBuilder<StoryCubit, StoryState>(
                      bloc: _cubit,
                      builder: (context, state) {
                        return state.maybeWhen(
                          allStoriesRetrieved: (stories) {
                            return ListView.separated(
                              itemCount: stories.length,
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              physics: const NeverScrollableScrollPhysics(),
                              separatorBuilder: (context, index) {
                                return const SizedBox(height: 20);
                              },
                              itemBuilder: (context, index) {
                                return BlocBuilder<
                                  InAppPurchaseCubit,
                                  InAppPurchaseState
                                >(
                                  builder: (context, subscription) {
                                    return SectionListItem(
                                      sectionItem: stories[index].toSectionItem(
                                        'detail-${widget.item.title}',
                                        Style.showcaseMedium,
                                      ),
                                      onItemClicked: onSectionItemClickHandler,
                                      shouldShowPremiumBadge: subscription
                                          .isNotActive(),
                                    );
                                  },
                                );
                              },
                            );
                          },
                          loading: () {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  top: context.mediaQuery.size.height * 0.3,
                                ),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                          orElse: (s) => const SizedBox.shrink(),
                        );
                      },
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

  Widget _buildBackButton() {
    return Transform.scale(
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
            color: Colors.white,
          ),
          iconSize: 30,
        ),
      ),
    );
  }
}
