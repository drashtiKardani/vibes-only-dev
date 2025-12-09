import 'package:vibes_common/src/model/models.dart';

extension StyleExt on Style {
  double get height {
    switch (this) {
      case Style.showcaseExpanded:
        return 236;
      case Style.showcaseMedium:
        return 180;
      case Style.avatar:
        return 140;
      case Style.promotionFull:
        return 380;
      case Style.showcaseTall:
        return 258;
      case Style.card:
        return 160;
      case Style.showcaseSmall:
      case Style.wrappedChips:
        return 40;
      default:
        return 0;
    }
  }

  int get grids {
    switch (this) {
      case Style.avatar:
      case Style.card:
      case Style.promotionFull:
      case Style.showcaseExpanded:
      case Style.showcaseMedium:
      case Style.showcaseTall:
        return 1;
      case Style.showcaseSmall:
        return 4;
      case Style.wrappedChips:
        return -1;
      default:
        return 1;
    }
  }

  double get spacing {
    switch (this) {
      case Style.avatar:
        return 25;
      case Style.card:
      case Style.promotionFull:
      case Style.showcaseExpanded:
      case Style.showcaseMedium:
      case Style.showcaseTall:
      case Style.showcaseSmall:
        return 16;
      case Style.wrappedChips:
        return 8;
      default:
        return 20;
    }
  }
}
