import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/src/data/network/vibe_api_new.dart';
import 'package:get_it/get_it.dart';
import 'package:sealed_annotations/sealed_annotations.dart';
import 'package:vibes_common/vibes.dart';

part 'channel_videos_cubit.sealed.dart';

class ChannelVideosCubit extends Cubit<ChannelVideosState> {
  ChannelVideosCubit(this.channelId)
    : super(const ChannelVideosState.initial());

  final String channelId;

  Future<void> getChannelVideos() async {
    emit(const ChannelVideosState.loading());
    final result = await GetIt.I
        .get<VibeApiNew>()
        .getVideos(channelId: channelId, limit: 10000000, offset: 0)
        .sealed();
    if (result.isSuccessful) {
      var videos = result.data.results;
      emit(ChannelVideosState.videos(videos: videos));
    } else {
      emit(ChannelVideosState.failure(error: result.error));
    }
  }
}

@Sealed()
abstract class _ChannelVideosState {
  void initial();

  void loading();

  void videos(List<Video> videos);

  void failure(@WithType('VibeError') error);
}
