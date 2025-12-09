import 'dart:async';
import 'dart:ui' as ui;

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:flutter_mobile_app_presentation/src/audio/audio_handler.dart';
import 'package:flutter_mobile_app_presentation/src/cubit/advice/advice_cubit.dart';
import 'package:flutter_mobile_app_presentation/src/cubit/advice/advice_state.dart';
import 'package:flutter_mobile_app_presentation/src/cubit/favorites/favorites_cubit.dart';
import 'package:flutter_mobile_app_presentation/src/cubit/iap/in_app_purchase_cubit.dart';
import 'package:flutter_mobile_app_presentation/src/cubit/net_speed/net_speed_cubit.dart';
import 'package:flutter_mobile_app_presentation/src/data/local_storage/sync_shared_preferences.dart';
import 'package:flutter_mobile_app_presentation/src/dialog/go_premium_dialog.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:rive/rive.dart' as rive;
import 'package:share_plus/share_plus.dart';
import 'package:subtitle_wrapper_package/subtitle_wrapper_package.dart';
import 'package:vibes_common/vibes.dart';
import 'package:video_player/video_player.dart';

import '../../cubit/iap/in_app_purchase_state.dart';
import 'custom_scroll_phyics.dart';
import 'expandable_text.dart';
import 'video_widget.dart';

class AdviceScreen extends StatefulWidget {
  const AdviceScreen(this.channelId, this.id, {super.key});

  final String? channelId;
  final String id;

  @override
  State createState() => _AdviceScreenState();
}

class _AdviceScreenState extends State<AdviceScreen>
    with AutomaticKeepAliveClientMixin {
  late Size _constraintSize;
  late ScrollController scrollController;
  late ScrollPhysics _physics;
  late StreamSubscription<PlaybackState> _listener;
  bool miniPlayerIsShown = false;
  late String _inViewVideoId;
  final ValueNotifier<bool> _likeChangeNotifier = ValueNotifier(false);
  final ValueNotifier<String> _captionChangeNotifier = ValueNotifier('');
  final ValueNotifier<bool> _subtitleChangeNotifier =
      ValueNotifier(SyncSharedPreferences.isSubtitleOn.value);
  String _currentTitle = '';
  String _currentThumbnail = '';
  String _currentCaption = '';

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    _controller = rive.OneShotAnimation('Pressed', autoplay: false);

    if (widget.channelId != null) {
      BlocProvider.of<AdviceCubit>(context).getVideos(widget.channelId!);
    } else {
      BlocProvider.of<AdviceCubit>(context).getVideoDetail(widget.id);
    }

    var state = VibesAudioHandler.instance.playbackState.value;
    _handleMiniPlayerPadding(state);
    _listener = VibesAudioHandler.instance.playbackState.listen((state) {
      _handleMiniPlayerPadding(state);
    });
    // initial in-view video is the video which has been clicked.
    _inViewVideoId = widget.id;
    _likeChangeNotifier.value = _isCurrentVideoLiked();
  }

  @override
  void dispose() {
    _listener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: /*94*/ 0),
      child: SafeArea(
        child: Scaffold(
          body: BlocBuilder<AdviceCubit, AdviceState>(
            builder: (context, state) {
              return state.maybeWhen(
                  success: (videos) {
                    _captionChangeNotifier.value =
                        videos.results[_scrollIndex(videos.results)].caption ??
                            '';
                    double miniPlayerExtraPadding = 0.0;
                    if (miniPlayerIsShown) miniPlayerExtraPadding = 54.0;
                    return Stack(children: [
                      LayoutBuilder(
                        builder:
                            (BuildContext context, BoxConstraints constraints) {
                          _constraintSize = constraints.biggest;
                          var clickedIndex = _scrollIndex(videos.results);
                          debugPrint('${videos.results.length} $clickedIndex');
                          WidgetsBinding.instance
                              .addPostFrameCallback((timeStamp) {
                            scrollController
                                .jumpTo(_constraintSize.height * clickedIndex);

                            scrollController.position.isScrollingNotifier
                                .addListener(() {
                              if (!scrollController
                                  .position.isScrollingNotifier.value) {
                                // scrolling is finished. redraw like button.
                                _likeChangeNotifier.value =
                                    _isCurrentVideoLiked();
                                _captionChangeNotifier.value = _currentCaption;
                              }
                            });
                          });

                          _physics = CustomScrollPhysics(
                              itemDimension: _constraintSize.height);
                          return InViewNotifierList(
                            controller: scrollController,
                            physics: _physics,
                            initialInViewIds: ['$clickedIndex'],
                            isInViewPortCondition: (double deltaTop,
                                double deltaBottom, double vpHeight) {
                              var result = deltaTop < (0.5 * vpHeight) &&
                                  deltaBottom > (0.5 * vpHeight);
                              return result;
                            },
                            itemCount: videos.results.length,
                            builder: (BuildContext context, int index) {
                              return inViewNotifierVideoWidget(
                                  index, videos, miniPlayerExtraPadding);
                            },
                          );
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 16.0,
                            right: 16,
                            top: 16,
                            bottom: miniPlayerExtraPadding + 36),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              subtitleToggle(),
                              const SizedBox(height: 5),
                              blurFab(VibesV2.send, "video#share"),
                              const SizedBox(height: 5),
                              blurRiv('assets/like.riv'),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            bottom: 96 + miniPlayerExtraPadding,
                            left: 20,
                            right: 96),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: ValueListenableBuilder(
                              valueListenable: _captionChangeNotifier,
                              builder: (context, String caption, widget) {
                                // caption = "A sample instagram id: @instagram\n"
                                //     "A sample twitter id: @@twitter\n"
                                //     "@playboy @@playboy";
                                return blurText(caption);
                              }),
                        ),
                      ),
                      backButton(),
                    ]);
                  },
                  orElse: (s) =>
                      const Center(child: CircularProgressIndicator()));
            },
          ),
        ),
      ),
    );
  }

  Widget backButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 25, left: 25),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: FloatingActionButton(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            mini: true,
            onPressed: () => Navigator.of(context).pop(),
            backgroundColor: Colors.black38,
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget inViewNotifierVideoWidget(
      int index, AllVideo videos, double miniPlayerExtraPadding) {
    return BlocBuilder<InAppPurchaseCubit, InAppPurchaseState>(
        builder: (context, subscription) {
      return BlocBuilder<NetSpeedCubit, double>(
          builder: (context, netSpeedInMbps) {
        return InViewNotifierWidget(
          id: '$index',
          builder: (BuildContext context, bool isInView, Widget? child) {
            final video = videos.results[index];
            if (subscription.isNotActive() && (video.paid ?? false)) {
              return SizedBox(
                width: _constraintSize.width,
                height: _constraintSize.height,
                child: Center(
                  child: InkWell(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        border: Border.all(
                            color: const Color(0xffC4C4C4), width: 1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Image.asset('assets/images/icon_premium.png',
                            width: 34),
                      ),
                    ),
                    onTap: () => showGoPremiumBottomSheet(context),
                  ),
                ),
              );
            }

            if (isInView) {
              _inViewVideoId = video.id.toString();
              _currentTitle = video.title;
              _currentCaption = video.caption ?? '';
              _currentThumbnail = video.thumbnail ?? '';
            }
            var subtitleController = SubtitleController(
              // Without final \n, last line of subtitle won't show
              subtitlesContent:
                  video.transcript == null ? null : '${video.transcript!}\n',
              subtitleType: SubtitleType.srt,
            );

            String? videoUrl = netSpeedInMbps > 2
                ? video.processedFiles?.finalVideo1080
                : netSpeedInMbps < 0.512
                    ? video.processedFiles?.finalVideo360
                    : video.processedFiles?.finalVideo576;
            videoUrl ??= video.processedFiles?.finalVideo;

            debugPrint(
                'Net Speed: $netSpeedInMbps Mbps :: video_url=$videoUrl');

            var videoController =
                VideoPlayerController.networkUrl(Uri.parse(videoUrl ?? ''));
            // videoController = VideoPlayerController.network(
            //     'https://assets.mixkit.co/videos/preview/mixkit-a-girl-blowing-a-bubble-gum-at-an-amusement-park-1226-large.mp4');

            return SizedBox(
              width: _constraintSize.width,
              height: _constraintSize.height,
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _constraintSize.width,
                  height: _constraintSize.height,
                  child: ValueListenableBuilder(
                    valueListenable: _subtitleChangeNotifier,
                    builder: (BuildContext context, bool subOn, Widget? child) {
                      return SubtitleWrapper(
                        subtitleController: subtitleController,
                        videoPlayerController: videoController,
                        subtitleStyle: SubtitleStyle(
                          position: SubtitlePosition(
                            left: 20,
                            right: 96,
                            bottom: 162 + miniPlayerExtraPadding,
                          ),
                          textColor: subOn ? Colors.white : Colors.transparent,
                          hasBorder: subOn ? true : false,
                        ),
                        videoChild: VideoWidget(
                          index: index,
                          play: isInView,
                          controller: videoController,
                          premium: video.paid,
                          videoId: video.id,
                          videoTitle: video.title,
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      });
    });
  }

  int _scrollIndex(List<Video> videos) {
    var index = 0;
    for (var video in videos) {
      if (video.id.toString() == widget.id) {
        return index;
      }
      index++;
    }
    return 0;
  }

  Widget subtitleToggle() {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(27)),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: FloatingActionButton(
          onPressed: () {
            _subtitleChangeNotifier.value = !_subtitleChangeNotifier.value;
            SyncSharedPreferences.isSubtitleOn.value =
                _subtitleChangeNotifier.value;
          },
          backgroundColor: Colors.black26,
          child: ValueListenableBuilder(
            valueListenable: _subtitleChangeNotifier,
            builder: (BuildContext context, bool subOn, Widget? child) {
              return Icon(
                subOn ? Icons.closed_caption : Icons.closed_caption_off,
                color: Colors.white,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget blurFab(IconData icon, String heroTag) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(27)),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: FloatingActionButton(
          onPressed: () {
            SharePlus.instance.share(ShareParams(
              text: 'https://share.vibesonly.com/video?id=$_inViewVideoId',
              subject: 'Check out this video',
            ));
          },
          backgroundColor: Colors.black26,
          // heroTag: heroTag,
          child: Icon(
            icon,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget blurRiv(String name) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(27)),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: FloatingActionButton(
          // heroTag: "video#riv",
          onPressed: () {
            if (!_likeChangeNotifier.value) {
              _addCurrentVideoToFavorites();
              _likeChangeNotifier.value = true;
              _controller.isActive = true; // TODO what's this?
            } else {
              _removeCurrentVideoFromFavorites();
              _likeChangeNotifier.value = false;
            }
          },
          backgroundColor: Colors.black26,
          child: ValueListenableBuilder(
            valueListenable: _likeChangeNotifier,
            builder: (BuildContext context, bool liked, Widget? child) {
              return !liked
                  ? const Icon(
                      Icons.favorite_border,
                      color: Colors.white,
                    )
                  : rive.RiveAnimation.asset(
                      name,
                      animations: const ['Hover', 'Pressed'],
                      fit: BoxFit.scaleDown,
                      controllers: [_controller],
                    );
            },
          ),
        ),
      ),
    );
  }

  Widget blurText(String text) {
    return ExpandableText(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w300,
        color: Colors.white,
        fontSize: 14,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  late rive.RiveAnimationController _controller;

  void _handleMiniPlayerPadding(PlaybackState state) {
    if (state.processingState == AudioProcessingState.idle ||
        state.processingState == AudioProcessingState.error ||
        state.processingState == AudioProcessingState.completed) {
      if (miniPlayerIsShown) {
        setState(() {
          miniPlayerIsShown = false;
        });
      }
    } else {
      if (!miniPlayerIsShown) {
        setState(() {
          miniPlayerIsShown = true;
        });
      }
    }
  }

  bool _isCurrentVideoLiked() {
    return BlocProvider.of<FavoritesCubit>(context)
        .isFavoriteVideo(_inViewVideoId);
  }

  void _addCurrentVideoToFavorites() {
    BlocProvider.of<FavoritesCubit>(context)
        .addFavoriteVideo(_inViewVideoId, _currentTitle, _currentThumbnail);
  }

  void _removeCurrentVideoFromFavorites() {
    BlocProvider.of<FavoritesCubit>(context)
        .removeFavoriteVideo(_inViewVideoId);
  }
}
