import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:vibes_only/src/feature/vibes_tab/vibes_studio/data/new_vibe_store.dart';

import '../../../data/commodities_store.dart';

extension ToyInfo on NewVibeStore {
  Widget toyImage({double width = 42, double height = 55}) {
    final toyImage = GetIt.I<CommoditiesStore>().toyWithName(toyBluetoothName)?.controllerPagePicture;
    if (toyImage != null) {
      return CachedNetworkImage(
        imageUrl: toyImage,
        width: width,
        height: height,
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  String get toyName => GetIt.I<CommoditiesStore>().toyWithName(toyBluetoothName)?.name ?? toyBluetoothName;
}
