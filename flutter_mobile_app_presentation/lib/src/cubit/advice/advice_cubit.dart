import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/src/data/network/vibe_api_new.dart';
import 'package:get_it/get_it.dart';
import 'package:vibes_common/vibes.dart';

import 'advice_state.dart';

class AdviceCubit extends Cubit<AdviceState> {
  AdviceCubit() : super(const AdviceState.initial());

  Future<void> getVideos(String channelId) async {
    emit(const AdviceState.loading());
    final result = await GetIt.I.get<VibeApiNew>().getVideos(channelId: channelId, limit: 100, offset: 0).sealed();
    if (result.isSuccessful) {
      emit(AdviceState.success(videoResult: result.data));
    } else {
      emit(AdviceState.failure(error: result.error));
    }
  }

  Future<void> getVideoDetail(String videoId) async {
    emit(const AdviceState.loading());
    final result = await GetIt.I.get<VibeApiNew>().getVideoDetail(videoId).sealed();
    if (result.isSuccessful) {
      final allVideosWrapper = AllVideo(count: 1, results: [result.data]);
      emit(AdviceState.success(videoResult: allVideosWrapper));
    } else {
      emit(AdviceState.failure(error: result.error));
    }
  }
}
