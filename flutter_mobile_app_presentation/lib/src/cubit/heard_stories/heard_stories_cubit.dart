import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/src/data/local_storage/sync_shared_preferences.dart';

class HeardStoriesCubit extends Cubit<HeardStoriesState> {
  HeardStoriesCubit() : super(HeardStoriesState(_loadListOfIdsFromStorage()));

  void add(String storyId) {
    final ids = state.idsOfStories;
    ids.add(storyId);
    _saveToLocalStorage(ids);
    emit(HeardStoriesState(ids));
  }

  bool contains(String storyId) => state.idsOfStories.contains(storyId);

  void removeAll() {
    _saveToLocalStorage([]);
    emit(HeardStoriesState([]));
  }

  static const _key = 'IDS_OF_HEARD_STORIES';

  static List<String> _loadListOfIdsFromStorage() {
    return SyncSharedPreferences.instance.getStringList(_key) ?? [];
  }

  static void _saveToLocalStorage(List<String> ids) {
    SyncSharedPreferences.instance.setStringList(_key, ids);
  }
}

class HeardStoriesState {
  final List<String> idsOfStories;

  HeardStoriesState(this.idsOfStories);
}
