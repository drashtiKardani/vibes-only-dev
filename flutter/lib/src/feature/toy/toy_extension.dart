import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:vibes_common/vibes.dart';

extension ToyImage on Commodity {
  Widget get toyImage {
    if (controllerPagePicture != null) {
      return CachedNetworkImage(
        imageUrl: controllerPagePicture!,
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
