import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:vibes_common/vibes.dart';

import '../../../flavors/flavor_config.dart';
import '../../../flavors/server_swapper.dart';
import '../../cubit/iap/in_app_purchase_cubit.dart';
import '../../cubit/iap/in_app_purchase_state.dart';
import '../../cubit/video/video_cubit.dart';
import '../advice/advice_screen.dart';
import '../discovery/loading_shimmer.dart';
import 'channel_screen.dart';

class AllChannelsScreen extends StatefulWidget {
  const AllChannelsScreen({super.key});

  @override
  State<AllChannelsScreen> createState() => _AllChannelsScreenState();
}

class _AllChannelsScreenState extends State<AllChannelsScreen>
    with AutomaticKeepAliveClientMixin {
  late VideoCubit _cubit;

  void refreshOnServerSwap() => _cubit.getChannelVideos();

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<VideoCubit>(context);
    _cubit.getChannelVideos();
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
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
      child: RefreshIndicator(
        backgroundColor: context.colorScheme.surface,
        edgeOffset: 0,
        onRefresh: () async => _cubit.getChannelVideos(),
        child: CustomScrollView(
          slivers: [
            // _VibeAppBar(),
            const SliverAppBar(
              title: Text('Channels'),
            ),
            BlocBuilder<VideoCubit, VideoState>(
              builder: (context, state) {
                return state.maybeMap(channels: (state) {
                  var channels = state.channels;
                  for (Channel c in channels) {
                    c.videoList.sort((a, b) =>
                        (b.publishDate ?? DateTime(1970, 1, 1))
                            .compareTo(a.publishDate ?? DateTime(1970, 1, 1)));
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 34.0),
                        child:
                            BlocBuilder<InAppPurchaseCubit, InAppPurchaseState>(
                                builder: (context, subscription) {
                          return ChannelCard(channel: channels[index]);
                        }),
                      );
                    }, childCount: channels.length),
                  );
                }, orElse: (state) {
                  return const SliverFillRemaining(
                    child: DiscoveryLoadingShimmer(),
                  );
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ChannelCard extends StatelessWidget {
  const ChannelCard({super.key, required this.channel});

  final Channel channel;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      const gapBtwnThumbs = 13;
      const firstThumbAspectRatio = 1.0;
      const theOtherTwoAspectRatio = 82 / 146;
      final height = (constraints.maxWidth - 2 * gapBtwnThumbs) /
          (firstThumbAspectRatio + 2 * theOtherTwoAspectRatio);

      final visibleVideos = channel.videoList.take(3);
      final thumbs = <Widget>[];
      for (int i = 0; i < visibleVideos.length; i++) {
        double width;
        if (i == 0) {
          width = height;
        } else {
          width = height * theOtherTwoAspectRatio;
        }
        final video = channel.videoList[i];
        thumbs.add(ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AdviceScreen(
                        channel.id.toString(),
                        video.id.toString(),
                      )),
            ),
            child: CachedNetworkImage(
              imageUrl: video.thumbnail ?? '',
              height: height,
              width: width,
              fit: BoxFit.cover,
            ),
          ),
        ));
      }

      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: thumbs,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(channel.title, style: context.textTheme.bodyLarge),
              const Spacer(),
              SizedBox(
                height: 34,
                child: FilledButton(
                    onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChannelScreen(channel)),
                        ),
                    child: const Text('Explore')),
              ),
            ],
          )
        ],
      );
    });
  }
}

// class _VibeAppBar extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return SliverAppBar(
//       backgroundColor: Colors.transparent,
//       titleSpacing: 0,
//       title: Image(
//         height: 30,
//         width: 116,
//         image: Assets.images.logo.provider(),
//       ),
//       actions: const [],
//       centerTitle: false,
//       elevation: 0,
//       floating: false,
//       pinned: false,
//     );
//   }
// }
