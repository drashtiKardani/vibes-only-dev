import 'package:flutter_panel/src/di/di.dart';
import 'package:flutter_panel/src/enum/view_count_mode.dart';

enum StoryOrdering {
  publishDateDESC,
  dateCreatedDESC,
  dateCreatedASC,
  titleASC,
  titleDESC,
  statusSimulator,
  statusProduction,
  viewCountDESC,
  viewCountASC,
}

extension OrderingExtension on StoryOrdering {
  String get value {
    switch (this) {
      case StoryOrdering.titleASC:
        return 'title';
      case StoryOrdering.titleDESC:
        return '-title';
      case StoryOrdering.dateCreatedASC:
        return 'date_created';
      case StoryOrdering.dateCreatedDESC:
        return '-date_created';
      case StoryOrdering.statusSimulator:
        return 'state';
      case StoryOrdering.statusProduction:
        return '-state';
      case StoryOrdering.publishDateDESC:
        return '-published_date';
      case StoryOrdering.viewCountDESC:
        return viewCountOrderingDESC;
      case StoryOrdering.viewCountASC:
        return viewCountOrderingASC;
    }
  }

  String get name {
    switch (this) {
      case StoryOrdering.titleASC:
        return strings.a2z;
      case StoryOrdering.titleDESC:
        return strings.z2a;
      case StoryOrdering.dateCreatedASC:
        return strings.dateCreatedASC;
      case StoryOrdering.dateCreatedDESC:
        return strings.dateCreatedDESC;
      case StoryOrdering.statusSimulator:
        return strings.statusSimulator;
      case StoryOrdering.statusProduction:
        return strings.statusProduction;
      case StoryOrdering.publishDateDESC:
        return strings.publishDateDESC;
      case StoryOrdering.viewCountDESC:
        return 'View Count (highest views first)';
      case StoryOrdering.viewCountASC:
        return 'View Count (lowest views first)';
    }
  }
}
