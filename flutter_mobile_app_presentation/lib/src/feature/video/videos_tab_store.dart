import 'package:flutter_mobile_app_presentation/src/data/network/vibe_api_new.dart';
import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:vibes_common/vibes.dart';

part 'videos_tab_store.g.dart';

// ignore: library_private_types_in_public_api
class VideosTabStore = _VideosTabStore with _$VideosTabStore;

abstract class _VideosTabStore with Store {
  _VideosTabStore() {
    _getAll();
  }

  Future<void> _getAll() async {
    isLoading = true;
    try {
      videoCreators = await GetIt.I<VibeApiNew>().getAllVideoCreators();
      videos = (await GetIt.I<VibeApiNew>().getVideos(limit: 10000, offset: 0)).results;
    } catch (err) {
      error = err;
    } finally {
      isLoading = false;
    }
  }

  @observable
  dynamic error;

  @observable
  bool isLoading = false;

  @observable
  List<VideoCreator>? videoCreators;

  @observable
  List<Video>? videos;

  @action
  void refresh() {
    _getAll();
  }
}
