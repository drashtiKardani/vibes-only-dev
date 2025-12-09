import 'package:vibes_common/vibes.dart';

enum ViewCountMode { hour, day, total }

/// The followings are just placeholder for [StoryOrdering] and not the sent parameter to the server.
/// The actual value will be created by adding the current [ViewCountMode] to these values.
const viewCountOrderingDESC = '-view_count_';
const viewCountOrderingASC = 'view_count_';

extension Name on ViewCountMode {
  String get displayName {
    switch (this) {
      case ViewCountMode.hour:
        return 'Hourly views';
      case ViewCountMode.day:
        return 'Daily views';
      case ViewCountMode.total:
        return 'Total views';
    }
  }
}

final List<Map<String, dynamic>> viewCountModesAsOptions =
    List.from(ViewCountMode.values.map((e) => {"display": e.displayName, "value": e.name}));

extension StoryViewCount on ViewCountMode {
  int? viewCountOf(Story story) {
    switch (this) {
      case ViewCountMode.hour:
        return story.view_count_hour;
      case ViewCountMode.day:
        return story.view_count_day;
      case ViewCountMode.total:
        return story.view_count_total;
    }
  }
}

extension VideoViewCount on ViewCountMode {
  int? viewCountOfVideo(Video video) {
    switch (this) {
      case ViewCountMode.hour:
        return video.view_count_hour;
      case ViewCountMode.day:
        return video.view_count_day;
      case ViewCountMode.total:
        return video.view_count_total;
    }
  }
}
