import 'package:auto_route/auto_route.dart';
import 'package:flutter_panel/src/route/router.gr.dart';

const _basePath = 'video_creators';

var videoCreatorsRoutes = [
  AutoRoute(path: _basePath, page: VideoCreatorsRoute.page),
  CustomRoute(
      path: '$_basePath/add',
      page: AddVideoCreatorRoute.page,
      //TransitionsBuilders class contains a preset of common transitions builders.
      transitionsBuilder: TransitionsBuilders.slideLeft,
      durationInMilliseconds: 200),
  CustomRoute(
      path: '$_basePath/:id',
      page: UpdateVideoCreatorRoute.page,
      //TransitionsBuilders class contains a preset of common transitions builders.
      transitionsBuilder: TransitionsBuilders.slideLeft,
      durationInMilliseconds: 200),
];
