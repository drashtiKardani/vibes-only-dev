import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/src/data/network/vibe_api_new.dart';
import 'package:get_it/get_it.dart';
import 'package:vibes_common/vibes.dart';

import 'discovery_state.dart';

class DiscoveryCubit extends Cubit<DiscoveryState> {
  DiscoveryCubit() : super(const DiscoveryState.initial());

  Future<void> getHome() async {
    emit(const DiscoveryState.loading());
    final result = await GetIt.I.get<VibeApiNew>().home().sealed();
    if (result.isSuccessful) {
      emit(DiscoveryState.success(homeResult: result.data));
    } else {
      emit(DiscoveryState.failure(error: result.error));
    }
  }
}
