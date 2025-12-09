import 'package:flutter/widgets.dart';
import 'package:flutter_card_swiper/src/enums.dart';

extension DirectionExtension on CardSwiperDirection {
  Axis get axis => switch (this) {
        CardSwiperDirection.left ||
        CardSwiperDirection.right =>
          Axis.horizontal,
        CardSwiperDirection.top || CardSwiperDirection.bottom => Axis.vertical,
        CardSwiperDirection.none => throw Exception('Direction is none'),
      };

  bool get isNone => this == CardSwiperDirection.none;

  bool get isTop => this == CardSwiperDirection.top;

  bool get isRight => this == CardSwiperDirection.right;
}
