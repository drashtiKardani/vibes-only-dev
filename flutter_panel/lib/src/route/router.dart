import 'package:auto_route/auto_route.dart';
import 'package:flutter_panel/src/feature/video_creators/routes.dart';

import 'router.gr.dart';

@AutoRouterConfig(
  replaceInRouteName: 'Page,Route',
)
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => const RouteType.material();

  @override
  final List<AutoRoute> routes = [
    AutoRoute(page: AppEntryRoute.page, path: '/', initial: true),
    AutoRoute(page: LoginRoute.page, path: '/login'),
    AutoRoute(page: TwoFactorAuthenticationRoute.page, path: '/2fa'),
    AutoRoute(
      page: DashboardRoute.page,
      path: '/dashboard',
      children: [
        AutoRoute(path: 'video_management/channels', page: ChannelRoute.page),
        CustomRoute(
            path: 'video_management/channels/add',
            page: AddChannelRoute.page,
            transitionsBuilder: TransitionsBuilders.slideLeft,
            durationInMilliseconds: 200),
        CustomRoute(
            path: 'video_management/channels/:id',
            page: UpdateChannelRoute.page,
            transitionsBuilder: TransitionsBuilders.slideLeft,
            durationInMilliseconds: 200),
        AutoRoute(path: 'video_management/videos', page: VideoRoute.page),
        CustomRoute(
            path: 'video_management/videos/add',
            page: AddVideoRoute.page,
            transitionsBuilder: TransitionsBuilders.slideLeft,
            durationInMilliseconds: 200),
        CustomRoute(
            path: 'video_management/videos/:id',
            page: UpdateVideoRoute.page,
            transitionsBuilder: TransitionsBuilders.slideLeft,
            durationInMilliseconds: 200),
        AutoRoute(path: 'story_management/stories', page: StoriesRoute.page, initial: true),
        CustomRoute(
            path: 'story_management/stories/add',
            page: AddStoryRoute.page,
            transitionsBuilder: TransitionsBuilders.slideLeft,
            durationInMilliseconds: 200),
        CustomRoute(
            path: 'story_management/stories/:id',
            page: UpdateStoryRoute.page,
            transitionsBuilder: TransitionsBuilders.slideLeft,
            durationInMilliseconds: 200),
        AutoRoute(path: 'story_management/characters', page: CharactersRoute.page),
        CustomRoute(
            path: 'story_management/characters/add',
            page: AddCharacterRoute.page,
            transitionsBuilder: TransitionsBuilders.slideLeft,
            durationInMilliseconds: 200),
        CustomRoute(
            path: 'story_management/characters/:id',
            page: UpdateCharacterRoute.page,
            transitionsBuilder: TransitionsBuilders.slideLeft,
            durationInMilliseconds: 200),
        AutoRoute(path: 'story_management/categories', page: CategoriesRoute.page),
        CustomRoute(
            path: 'story_management/categories/add',
            page: AddCategoryRoute.page,
            transitionsBuilder: TransitionsBuilders.slideLeft,
            durationInMilliseconds: 200),
        CustomRoute(
            path: 'story_management/categories/:id',
            page: UpdateCategoryRoute.page,
            transitionsBuilder: TransitionsBuilders.slideLeft,
            durationInMilliseconds: 200),
        AutoRoute(path: 'staff_management/staff', page: StaffRoute.page),
        CustomRoute(
            path: 'staff_management/staff/add',
            page: AddStaffRoute.page,
            transitionsBuilder: TransitionsBuilders.slideLeft,
            durationInMilliseconds: 200),
        CustomRoute(
            path: 'staff_management/staff/:id',
            page: UpdateStaffRoute.page,
            transitionsBuilder: TransitionsBuilders.slideLeft,
            durationInMilliseconds: 200),
        AutoRoute(path: 'section_management/homepage', page: HomeRoute.page),
        AutoRoute(path: 'push_notification', page: PushNotificationsRoute.page),
        CustomRoute(
            path: 'push_notification/send',
            page: SendPushNotificationRoute.page,
            transitionsBuilder: TransitionsBuilders.slideLeft,
            durationInMilliseconds: 200),
        AutoRoute(path: 'promotions', page: PromotionsRoute.page),
        CustomRoute(
            path: 'promotions/add',
            page: AddPromotionRoute.page,
            transitionsBuilder: TransitionsBuilders.slideLeft,
            durationInMilliseconds: 200),
        CustomRoute(
            path: 'promotions/:id',
            page: UpdatePromotionRoute.page,
            transitionsBuilder: TransitionsBuilders.slideLeft,
            durationInMilliseconds: 200),
        AutoRoute(path: 'devices_and_commodities', page: DevicesAndCommoditiesRoute.page),
        CustomRoute(
            path: 'devices_and_commodities/add',
            page: AddDeviceOrCommodityRoute.page,
            transitionsBuilder: TransitionsBuilders.slideLeft,
            durationInMilliseconds: 200),
        CustomRoute(
            path: 'devices_and_commodities/:id',
            page: UpdateDeviceOrCommodityRoute.page,
            transitionsBuilder: TransitionsBuilders.slideLeft,
            durationInMilliseconds: 200),
        ...videoCreatorsRoutes,
        AutoRoute(path: 'miscellaneous', page: MiscellaneousRoute.page),
        AutoRoute(path: '404', page: UnderConstructionRoute.page),
      ],
    )
  ];
}
