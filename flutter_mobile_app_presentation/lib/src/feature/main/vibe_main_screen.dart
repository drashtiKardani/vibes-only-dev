import 'dart:async';
import 'dart:io' show Platform;
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/src/feature/manuals/manuals_tab.dart';
import 'package:flutter_mobile_app_presentation/src/feature/main/vibes_bottom_nav.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:get_it/get_it.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:vibes_common/vibes.dart';

import '../../../flutter_mobile_app_presentation.dart';
import '../../../generated/l10n.dart';
import '../../cubit/bottom_tab/bottom_tab_cubit.dart';
import '../../cubit/discovery/discovery_cubit.dart';
import '../../cubit/net_speed/net_speed_cubit.dart';
import '../../cubit/search/search_cubit.dart';
import '../../cubit/video/video_cubit.dart';
import '../advice/advice_screen.dart';
import '../discovery/discovery_screen.dart';
import '../search/search_screen.dart';
import '../story_detail/story_detail_screen.dart';
import '../story_player/player_screen.dart';

/// The **Main Container** of app screens.
/// This includes the nav bar which we *don't* show on ***Android***
/// Android only shows the *Control* page.
class VibeMainScreen extends StatefulWidget {
  /// Making "Vibes" tab a dependency lets us to exclude it from admin panel's simulator.
  final Widget? vibesTab;

  /// See comment of [vibesTab].
  final Widget? settingsScreen;

  /// See comment of [vibesTab].
  final VoidCallback? onStartCardGame;

  /// See comment of [vibesTab]. Simulator shows this screen, but lacks many of its functionalities.
  final void Function(BuildContext context)? fetchPromotionsAndShowPopup;

  const VibeMainScreen({
    super.key,
    this.vibesTab,
    this.settingsScreen,
    this.fetchPromotionsAndShowPopup,
    this.onStartCardGame,
  });

  @override
  State createState() => _VibeMainScreenState();
}

/// Don't forget to add `with AutomaticKeepAliveClientMixin` in child widgets
/// in order to keep them alive, also don't forget to call super.build(context);
class _VibeMainScreenState extends State<VibeMainScreen>
    with WidgetsBindingObserver {
  /// Simulator shows only the first three tabs. (Excludes toy tab)
  late final int _tabCounts = widget.vibesTab == null ? 3 : 4;

  /// Cache tab widgets to provide lazy loading
  late final Map<int, Widget> _pages = {};
  late int _selectedPageIndex;
  late PageController _pageController;

  late StreamSubscription<PlaybackState> _playerListener;
  late StreamSubscription<Duration> _playbackPositionSubscription;
  bool showMiniPlayer = false;
  String miniPlayerTitle = '';
  String miniPlayerIcon = '';
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _selectedPageIndex = Platform.isAndroid ? 3 : 0;
    _pages[0] = DiscoveryScreen(settingsScreen: widget.settingsScreen);
    _pageController = PageController(initialPage: _selectedPageIndex);
    WidgetsBinding.instance.addObserver(this);

    setupPushDestination();
    widget.fetchPromotionsAndShowPopup?.call(context);

    _playerListener = VibesAudioHandler.instance.playbackState.listen((state) {
      _preparePlayer(state);
    });

    // listen to playback position at top level to pause the playback and show 'go premium!' dialog
    _playbackPositionSubscription = AudioService.position.listen((position) {
      bool shouldPauseAfter30secondPreview =
          BlocProvider.of<InAppPurchaseCubit>(context).state.status !=
              InAppPurchaseStatus.active &&
          (VibesAudioHandler.instance.mediaItem.value?.isPremium ?? false);
      if (shouldPauseAfter30secondPreview && position.inSeconds > 30) {
        VibesAudioHandler.instance.pause();
        showGoPremiumBottomSheet(context);
      }
    });

    try {
      _preparePlayer(VibesAudioHandler.instance.playbackState.value);
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
    }
  }

  void _preparePlayer(PlaybackState state) {
    isPlaying = state.playing;
    if (state.processingState == AudioProcessingState.idle ||
        state.processingState == AudioProcessingState.error ||
        state.processingState == AudioProcessingState.completed) {
      showMiniPlayer = false;
    } else if (!isPlaying) {
      showMiniPlayer = true;
    } else {
      showMiniPlayer = true;
    }
    setState(() {
      try {
        var item = VibesAudioHandler.instance.mediaItem.value;
        miniPlayerTitle = item?.title ?? '';
        miniPlayerIcon = item?.artUri.toString() ?? '';
      } catch (e) {
        debugPrint(e.toString());
        FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      }
    });
  }

  Widget _createMiniPlayer() {
    return CupertinoButton(
      pressedOpacity: 1,
      padding: EdgeInsets.only(
        bottom: context.mediaQuery.viewPadding.bottom + 100,
      ),
      onPressed: () {
        MediaItem? item = VibesAudioHandler.instance.mediaItem.value;
        if (item != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PlayerScreen(item: item)),
          );
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.symmetric(
          vertical: 8,
        ).copyWith(left: 12, right: 8),
        decoration: BoxDecoration(
          color: context.colorScheme.onSurface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                spacing: 14,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: miniPlayerIcon,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      miniPlayerTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.headlineLarge?.copyWith(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              spacing: 4,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    setState(() {
                      if (isPlaying) {
                        VibesAudioHandler.instance.pause();
                      } else {
                        VibesAudioHandler.instance.play();
                      }
                    });
                  },
                  child: HugeIcon(
                    icon: isPlaying
                        ? HugeIcons.strokeRoundedPause
                        : HugeIcons.strokeRoundedPlay,
                    size: 30,
                    color: Colors.black,
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    setState(() {
                      showMiniPlayer = false;
                    });
                  },
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedCancel01,
                    size: 30,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      BlocProvider.of<NetSpeedCubit>(context).testSpeed();

      // User may have purchased a package outside the app flow
      BlocProvider.of<InAppPurchaseCubit>(context).checkUserSubscription();
    }
  }

  Future<void> setupPushDestination() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance
        .getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    if (message.data['tab'] == 'videos') {
      setState(() {
        _selectedPageIndex = 2; // VideoScreen
        BlocProvider.of<BottomTabCubit>(
          context,
        ).onTabClicked(_selectedPageIndex);
        _pageController.jumpToPage(_selectedPageIndex);
      });
    } else if (message.data['tab'] == 'home') {
      setState(() {
        _selectedPageIndex = 0; // Home/DiscoveryScreen
        BlocProvider.of<BottomTabCubit>(
          context,
        ).onTabClicked(_selectedPageIndex);
        _pageController.jumpToPage(_selectedPageIndex);
      });
    } else if (message.data['video'] != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AdviceScreen(null, message.data['video']),
        ),
      );
    } else if (message.data['story'] != null) {
      GetIt.I.get<VibeApiNew>().getStoryDetail(message.data['story']).then((
        story,
      ) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoryDetailScreen(
              story.toSectionItem('story', Style.showcaseSmall),
            ),
          ),
        );
      });
    }
  }

  Widget _pageBuilder(int index) {
    assert(index >= 0 && index < _tabCounts);
    if (index == 0) {
      return DiscoveryScreen(settingsScreen: widget.settingsScreen);
    } else if (index == 1) {
      return const SearchScreen();
    } else if (index == 2) {
      return const ManualsTab();
    } else if (index == 3) {
      // If we let index to be 3, vibesTab must not be null.
      return widget.vibesTab!;
    }
    return const SizedBox.square();
  }

  List<VibesBottomNavItem> _tabs() {
    S s = S.of(context);
    return [
      VibesBottomNavItem(
        title: s.experience,
        icon: VibesV3.homeLined,
        activeIcon: VibesV3.homeFilled,
      ),
      VibesBottomNavItem(
        title: s.explore,
        icon: VibesV3.searchLined,
        activeIcon: VibesV3.searchLined,
      ),
      VibesBottomNavItem(
        title: s.manuals,
        icon: VibesV3.manualsLined,
        activeIcon: VibesV3.manualFilled,
      ),
      VibesBottomNavItem(
        title: s.vibes,
        icon: VibesV3.vibesLined,
        activeIcon: VibesV3.vibesFilled,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    Widget miniPlayer = SizedBox.shrink();

    if (showMiniPlayer) {
      miniPlayer = _createMiniPlayer();
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => DiscoveryCubit()),
        BlocProvider(create: (context) => SearchCubit()),
        BlocProvider(create: (context) => VideoCubit()),
      ],
      child: Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        body: Stack(
          children: [
            PageView.builder(
              itemBuilder: (context, index) {
                if (!_pages.containsKey(index)) {
                  _pages[index] = _pageBuilder(index);
                }
                return _pages[index]!;
              },
              itemCount: _tabCounts,
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
            ),
            if (showMiniPlayer)
              Align(alignment: Alignment.bottomCenter, child: miniPlayer),
          ],
        ),
        floatingActionButton: Container(
          height: 65,
          width: 65,
          margin: const EdgeInsets.only(top: 34),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.theme.primaryColorDark,
          ),
          child: CupertinoButton(
            onPressed: widget.onStartCardGame,
            padding: EdgeInsets.zero,
            child: Icon(
              VibesV3.cardsGameLined,
              size: 32,
              color: context.colorScheme.onPrimary,
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: Platform.isAndroid
            ? null
            : _VibesBottomNav(
                onTap: (index) {
                  setState(() {
                    Analytics.logEvent(
                      name: '${_tabs()[index].title}_tab',
                      context: context,
                    );
                    BlocProvider.of<BottomTabCubit>(
                      context,
                    ).onTabClicked(index);
                    _selectedPageIndex = index;
                    _pageController.jumpToPage(_selectedPageIndex);
                  });
                },
                itemCount: _tabCounts,
                items: _tabs(),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _playerListener.cancel();
    _playbackPositionSubscription.cancel();
    VibesAudioHandler.instance.stop();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

class _VibesBottomNav extends StatefulWidget {
  final ValueChanged<int>? onTap;
  final int itemCount;
  final List<VibesBottomNavItem> items;

  const _VibesBottomNav({
    required this.itemCount,
    required this.items,
    this.onTap,
  });

  @override
  _VibesBottomNavState createState() => _VibesBottomNavState();
}

class _VibesBottomNavState extends State<_VibesBottomNav> {
  int _selectedIndex = 0;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BottomTabCubit, BottomTabState>(
      listener: (context, state) {
        setState(() {
          _selectedIndex = state.asTabSwitched.tab.index;
        });
      },
      child: VibesBottomNav(
        currentIndex: _selectedIndex,
        onItemChanged: _onItemTapped,
        items: widget.items,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      widget.onTap?.call(index);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
