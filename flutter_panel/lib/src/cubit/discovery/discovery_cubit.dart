import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_panel/src/data/network/panel_api.dart';
import 'package:vibes_common/vibes.dart';

import 'discovery_state.dart';

class DiscoveryCubit extends Cubit<DiscoveryState> {
  DiscoveryCubit({required this.api}) : super(const DiscoveryState.initial());

  final VibesPanelApi api;

  Future<void> getHome() async {
    emit(const DiscoveryState.loading());
    final result = await api.home("1").sealed();
    if (result.isSuccessful) {
      emit(DiscoveryState.success(homeResult: result.data));
    } else {
      emit(DiscoveryState.failure(error: result.error));
    }
  }
}
