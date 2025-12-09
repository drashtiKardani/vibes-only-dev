import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/src/data/network/vibe_api_new.dart';
import 'package:get_it/get_it.dart';
import 'package:vibes_common/vibes.dart';
import 'package:sealed_annotations/sealed_annotations.dart';

part 'video_cubit.sealed.dart';

class VideoCubit extends Cubit<VideoState> {
  VideoCubit() : super(const VideoState.initial());

  Future<void> getChannelVideos() async {
    emit(const VideoState.loading());
    final result = await GetIt.I.get<VibeApiNew>().getChannels(10000000, 0).sealed();
    if (result.isSuccessful) {
      var channels = result.data.results;
      var sections = <Section>[];

      for (Channel channel in channels) {
        var section = Section(
          id: channel.id,
          isVisible: true,
          title: channel.title,
          contentType: "video",
          style: Style.showcaseMedium,
          containingStories: [],
          characters: [],
          categories: [],
          videos: channel.videoList,
        );
        sections.add(section);
      }
      emit(VideoState.channels(channels: channels));
    } else {
      emit(VideoState.failure(error: result.error));
    }
  }
}

@Sealed()
abstract class _VideoState {
  void initial();

  void loading();

  void channels(List<Channel> channels);

  void failure(@WithType('VibeError') error);
}
