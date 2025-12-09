import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobile_app_presentation/toy.dart';
import 'package:get_it/get_it.dart';
import 'package:vibes_only/src/data/commodities_store.dart';
import 'package:vibes_only/src/feature/toy/cubit/toy_cubit.dart';

extension ToyExtension on ToyState {
  /// - [fallbackWidget] is used when an image url is not found.
  Widget toyImage({
    double width = 50,
    double height = 50,
    Widget fallbackWidget = const SizedBox.shrink(),
  }) {
    final String? toyImageUrl = GetIt.I<CommoditiesStore>()
        .toyWithName(connectedDevice?.bluetoothName)
        ?.controllerPagePicture;
    if (toyImageUrl != null) {
      return CachedNetworkImage(
        width: width,
        height: height,
        imageUrl: toyImageUrl,
      );
    } else {
      return fallbackWidget;
    }
  }
}
