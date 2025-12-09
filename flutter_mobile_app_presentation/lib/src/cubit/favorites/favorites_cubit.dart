import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/src/data/local_storage/sync_shared_preferences.dart';
import 'package:vibes_common/vibes.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit() : super(FavoritesState(_loadFavoritesList()));

  void toggleFavoriteStory(String title, String imageUrl,
      List<Category> categories, SectionItem sectionItem) {
    final favorites = state.favorites;
    if (state.containsTitle(title)) {
      favorites.removeWhere((element) => element.title == title);
    } else {
      favorites.add(FavoriteStory(title, imageUrl, categories, sectionItem));
    }
    _writeToLocalStorage(favorites);
    emit(FavoritesState(favorites));
  }

  void toggleFavoriteVideo(String id, String title, String imageUrl) {
    if (isFavoriteVideo(id)) {
      removeFavoriteVideo(id);
    } else {
      addFavoriteVideo(id, title, imageUrl);
    }
  }

  void removeFavoriteStory(String title) {
    _removeFavoriteThing((element) => element.title == title);
  }

  bool isFavoriteVideo(String id) {
    return state.favorites
        .whereType<FavoriteVideo>()
        .any((element) => element.id == id);
  }

  void removeFavoriteVideo(String id) {
    _removeFavoriteThing(
        (element) => element is FavoriteVideo && element.id == id);
  }

  void addFavoriteVideo(String id, String title, String imageUrl) {
    final favorites = state.favorites;
    favorites.add(FavoriteVideo(id, title, imageUrl));
    _writeToLocalStorage(favorites);
    emit(FavoritesState(favorites));
  }

  void _removeFavoriteThing(bool Function(FavoriteThing) predicate) {
    final favorites = state.favorites;
    favorites.removeWhere(predicate);
    _writeToLocalStorage(favorites);
    emit(FavoritesState(favorites));
  }

  static const _favoriteStoriesKey = 'FAVORITE_STORIES_KEY';
  static const _favoriteVideosKey = 'FAVORITE_VIDEOS_KEY';

  void _writeToLocalStorage(List<FavoriteThing> favorites) {
    SyncSharedPreferences.instance.setStringList(
        _favoriteStoriesKey,
        favorites
            .whereType<FavoriteStory>()
            .map((e) => jsonEncode(e))
            .toList());

    SyncSharedPreferences.instance.setStringList(
        _favoriteVideosKey,
        favorites
            .whereType<FavoriteVideo>()
            .map((e) => jsonEncode(e))
            .toList());
  }

  static List<FavoriteThing> _loadFavoritesList() {
    final favoriteStories = SyncSharedPreferences.instance
        .getStringList(_favoriteStoriesKey)
        ?.map((e) => FavoriteStory.fromJson(jsonDecode(e)))
        .toList();

    final favoriteVideos = SyncSharedPreferences.instance
        .getStringList(_favoriteVideosKey)
        ?.map((e) => FavoriteVideo.fromJson(jsonDecode(e)))
        .toList();

    final favoriteThings = <FavoriteThing>[];
    favoriteThings.addAll(favoriteStories ?? []);
    favoriteThings.addAll(favoriteVideos ?? []);

    return favoriteThings;
  }
}

class FavoritesState {
  final List<FavoriteThing> favorites;

  FavoritesState(this.favorites);

  int count() {
    return favorites.length;
  }

  FavoriteThing get(int index) {
    return favorites[index];
  }

  bool containsTitle(String title) {
    return favorites.any((element) => element.title == title);
  }
}

abstract class FavoriteThing {
  final String title;
  final String imageUrl;

  String? get subtitle;

  FavoriteThing(this.title, this.imageUrl);

  FavoriteThing.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        imageUrl = json['imageUrl'];
}

class FavoriteVideo extends FavoriteThing {
  final String id;

  FavoriteVideo(this.id, String title, String imageUrl)
      : super(title, imageUrl);

  @override
  String? get subtitle => null;

  FavoriteVideo.fromJson(super.json)
      : id = json['id'],
        super.fromJson();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'imageUrl': imageUrl,
      };
}

class FavoriteStory extends FavoriteThing {
  late final List<String> categoriesTitles;

  final SectionItem sectionItem;

  @override
  String? get subtitle => categoriesTitles.join(' | ');

  FavoriteStory(super.title, super.imageUrl, List<Category> categories,
      this.sectionItem) {
    categoriesTitles = categories.map((e) => e.title).toList();
  }

  FavoriteStory.fromJson(Map<String, dynamic> json)
      : sectionItem = SectionItem.fromJson(json['sectionItem']),
        super.fromJson(json) {
    categoriesTitles = (json['categoriesTitles'] as List<dynamic>)
        .map((e) => e as String)
        .toList();
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'imageUrl': imageUrl,
        'categoriesTitles': categoriesTitles,
        'sectionItem': sectionItem,
      };
}
