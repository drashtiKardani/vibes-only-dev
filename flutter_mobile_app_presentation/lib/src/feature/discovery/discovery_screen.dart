import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/controllers.dart';
import 'package:flutter_mobile_app_presentation/flavors.dart';
import 'package:flutter_mobile_app_presentation/flavors/dialog_staging_options.dart';
import 'package:flutter_mobile_app_presentation/gen/assets.gen.dart';
import 'package:flutter_mobile_app_presentation/screens.dart';
import 'package:flutter_mobile_app_presentation/src/cubit/discovery/discovery_cubit.dart';
import 'package:flutter_mobile_app_presentation/src/cubit/discovery/discovery_state.dart';
import 'package:flutter_mobile_app_presentation/src/cubit/iap/in_app_purchase_cubit.dart';
import 'package:flutter_mobile_app_presentation/src/cubit/iap/in_app_purchase_state.dart';
import 'package:flutter_mobile_app_presentation/src/feature/section_item_click_handler.dart';
import 'package:flutter_mobile_app_presentation/story.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:vibes_common/vibes.dart';

class DiscoveryScreen extends StatefulWidget {
  final Widget? settingsScreen;
  final Widget? whitneyScreen;
  const DiscoveryScreen({super.key, this.settingsScreen, this.whitneyScreen});

  @override
  State createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen>
    with AutomaticKeepAliveClientMixin {
  late DiscoveryCubit _cubit;

  void refreshOnServerSwap() => _cubit.getHome();

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<DiscoveryCubit>(context);
    _cubit.getHome();
    if (Flavor.isStaging()) {
      ServerSwapper.notifier.addListener(refreshOnServerSwap);
    }
  }

  @override
  void dispose() {
    if (Flavor.isStaging()) {
      ServerSwapper.notifier.removeListener(refreshOnServerSwap);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Stack(
      children: [
        Positioned.fill(
          child: Assets.images.background.image(
            filterQuality: FilterQuality.high,
            package: 'flutter_mobile_app_presentation',
          ),
        ),
        Column(
          children: [
            _VibeAppBar(
              settingsScreen: widget.settingsScreen,
              whitneyScreen: widget.whitneyScreen,
            ),
            Expanded(
              child: BlocBuilder<DiscoveryCubit, DiscoveryState>(
                builder: (context, state) {
                  return state.maybeMap(
                    success: (state) {
                      List<Section> items = state.homeResult.sections;

                      return RefreshIndicator(
                        backgroundColor: context.colorScheme.surface,
                        elevation: 0,
                        color: Colors.white,
                        onRefresh: () async => _cubit.getHome(),
                        child: ListView.separated(
                          itemCount: items.length,
                          padding: const EdgeInsets.only(top: 10, bottom: 140),
                          physics: const ClampingScrollPhysics(),
                          separatorBuilder: (context, index) {
                            return const SizedBox(height: 20);
                          },
                          itemBuilder: (context, index) {
                            return BlocBuilder<
                              InAppPurchaseCubit,
                              InAppPurchaseState
                            >(
                              builder: (context, subscription) {
                                return BlocBuilder<
                                  HeardStoriesCubit,
                                  HeardStoriesState
                                >(
                                  builder: (context, heardStoriesState) {
                                    debugPrint(
                                      '${items[index].title} - ${items[index].style}',
                                    );
                                    return ShowcaseSection(
                                      section: items[index],
                                      onItemClicked:
                                          firstPageSectionItemClickHandler,
                                      shouldShowPremiumBadge: subscription
                                          .isNotActive(),
                                      shouldShowStoryReadIndicatorFor: (item) {
                                        return item.type == SectionType.story &&
                                            heardStoriesState.idsOfStories
                                                .contains(item.id);
                                      },
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
                    orElse: (state) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: DiscoveryLoadingShimmer(),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _VibeAppBar extends StatelessWidget {
  final Widget? settingsScreen;
  final Widget? whitneyScreen;

  const _VibeAppBar({this.settingsScreen, this.whitneyScreen});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      titleSpacing: 12,
      title: GestureDetector(
        onDoubleTap: Flavor.isStaging() ? showStagingOptionsDialog : null,
        child: Row(
          spacing: 2,
          children: [
            Assets.svgs.applogoIconOnlyBlackNWhite.svg(
              height: 34,
              width: 34,
              package: 'flutter_mobile_app_presentation',
            ),
            Assets.svgs.appLogoTextOnlyWhite.svg(
              width: 100,
              package: 'flutter_mobile_app_presentation',
            ),
          ],
        ),
      ),
      actions: [
        if (whitneyScreen != null)
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: Assets.svgs.vibesAi.svg(
              height: 28,
              width: 28,
              package: 'flutter_mobile_app_presentation',
              color: context.colorScheme.onSurface,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return BlocProvider(
                      create: (context) => VibesAiCubit(),
                      child: whitneyScreen!,
                    );
                  },
                ),
              );
            },
          ),
        if (settingsScreen != null)
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedSettings01,
              color: context.colorScheme.onSurface,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => settingsScreen!),
              );
            },
          ),
      ],
      centerTitle: false,
      elevation: 0,
    );
  }
}
