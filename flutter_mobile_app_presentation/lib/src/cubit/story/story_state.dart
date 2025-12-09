import 'package:sealed_annotations/sealed_annotations.dart';
import 'package:vibes_common/vibes.dart';

part 'story_state.sealed.dart';

@Sealed()
abstract class _StoryState {
  void initial();

  void loading();

  void detailRetrieved(Story storyDetail);

  void allStoriesRetrieved(List<Story> stories);

  void failure(@WithType('VibeError') error);
}
