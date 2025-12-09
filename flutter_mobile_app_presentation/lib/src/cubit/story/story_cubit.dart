import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/src/data/network/vibe_api_new.dart';
import 'package:get_it/get_it.dart';
import 'package:vibes_common/vibes.dart';
import 'story_state.dart';

class StoryCubit extends Cubit<StoryState> {
  StoryCubit() : super(const StoryState.initial());

  Future<void> getStoryDetail(String id) async {
    emit(const StoryState.loading());
    final result = await GetIt.I.get<VibeApiNew>().getStoryDetail(id).sealed();
    if (result.isSuccessful) {
      emit(StoryState.detailRetrieved(storyDetail: result.data));
    } else {
      emit(StoryState.failure(error: result.error));
    }
  }

  Future<void> getStories({String? categoryId, String? characterId}) async {
    emit(const StoryState.loading());
    final result = await GetIt.I
        .get<VibeApiNew>()
        .getAllStories(100, 0, categoryId: categoryId, characterId: characterId)
        .sealed();
    if (result.isSuccessful) {
      emit(StoryState.allStoriesRetrieved(stories: result.data.results));
    } else {
      emit(StoryState.failure(error: result.error));
    }
  }
}
