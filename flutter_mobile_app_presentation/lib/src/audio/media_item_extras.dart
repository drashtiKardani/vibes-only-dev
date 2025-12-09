import 'package:audio_service/audio_service.dart';
import 'package:flutter_mobile_app_presentation/src/feature/story_player/story_transcript.dart';

extension MediaItemExtras on MediaItem {
  static const premiumKey = 'premium';

  bool get isPremium => extras?[premiumKey] ?? false;

  static const storyIdKey = 'storyId';

  int get storyId => extras?[storyIdKey] ?? -1;

  static const storyTranscriptKey = 'storyTranscript';

  StoryTranscript get storyTranscript => StoryTranscript(extras?[storyTranscriptKey] ?? '');
}
