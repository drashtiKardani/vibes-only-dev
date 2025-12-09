import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_panel/generated/l10n.dart';
import 'package:flutter_panel/src/cubit/login/login_cubit.dart';
import 'package:flutter_panel/src/di/di.dart';
import 'package:flutter_panel/src/widget/widgets.dart';
import 'package:iconly/iconly.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../route/router.gr.dart';

@RoutePage()
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 1; // stories list is the initial route
  final _innerRouterKey = GlobalKey<AutoRouterState>();

  final serverType = getIt<Dio>().options.baseUrl.contains('vo-api.6thsolution.com')
      ? ServerType.staging
      : getIt<Dio>().options.baseUrl.contains('app.vibesonly.com')
          ? ServerType.production
          : ServerType.unknown;

  @override
  Widget build(BuildContext context) {
    var s = S.of(context);
    return AdaptiveDrawer(
      header: DrawerHeader(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                serverType == ServerType.staging
                    ? 'Staging Server'
                    : serverType == ServerType.production
                        ? 'Production Server'
                        : 'Unknown Server',
                style: const TextStyle(fontSize: 24),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  launchUrl(Uri.parse(
                    serverType == ServerType.production
                        ? 'https://staging787.vibesonly.com/'
                        : 'http://admin78.vibesonly.com',
                  ));
                },
                child: Text(
                  serverType == ServerType.production ? 'Go to Staging server' : 'Go to Production server',
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      ),
      currentIndex: _currentIndex,
      items: [
        DrawerTitle(
          title: s.simulator,
          icon: IconlyLight.home,
          destinationTo: const HomeRoute(),
        ),
        DrawerTitle(
          title: s.stories,
          icon: IconlyLight.paper_plus,
          destinationTo: const StoriesRoute(),
        ),
        DrawerTitle(
          title: s.categories,
          icon: IconlyLight.category,
          destinationTo: const CategoriesRoute(),
        ),
        DrawerTitle(
          title: s.characters,
          icon: IconlyLight.profile,
          destinationTo: const CharactersRoute(),
        ),
        DrawerTitle(
          title: s.videoCreators,
          icon: Icons.video_camera_front_outlined,
          destinationTo: const VideoCreatorsRoute(),
        ),
        DrawerTitle(
          title: s.videos,
          icon: IconlyBroken.play,
          destinationTo: const VideoRoute(),
        ),
        DrawerTitle(
          title: s.channels,
          icon: IconlyBroken.folder,
          destinationTo: const ChannelRoute(),
        ),
        DrawerTitle(
          title: s.staffManagement,
          icon: IconlyLight.user_1,
          destinationTo: const StaffRoute(),
        ),
        DrawerTitle(
          title: s.pushNotification,
          icon: IconlyLight.notification,
          destinationTo: const PushNotificationsRoute(),
        ),
        DrawerTitle(
          title: s.promotions,
          icon: IconlyLight.discount,
          destinationTo: const PromotionsRoute(),
        ),
        DrawerTitle(
          title: s.devicesAndCommodities,
          icon: Icons.smart_toy_outlined,
          destinationTo: const DevicesAndCommoditiesRoute(),
        ),
        DrawerTitle(
          title: s.miscellaneous,
          icon: Icons.build,
          destinationTo: const MiscellaneousRoute(),
        ),
        DrawerTitle(
          title: s.signOut,
          icon: IconlyLight.logout,
          destinationTo: const AppEntryRoute(),
        ),
      ],
      body: AutoRouter(key: _innerRouterKey),
      onTitleItemClicked: (item, newIndex) {
        if (item.title == s.signOut) {
          BlocProvider.of<LoginCubit>(context).logout().then((_) => context.replaceRoute(item.destinationTo));
          return;
        }
        setState(
          () {
            _currentIndex = newIndex;
          },
        );
        final router = _innerRouterKey.currentState?.controller;
        router?.push(item.destinationTo);
      },
    );
  }
}

enum ServerType { production, staging, unknown }
