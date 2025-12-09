import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/flutter_mobile_app_presentation.dart';
import 'package:get_it/get_it.dart';
import 'package:vibes_common/vibes.dart';
import 'package:flutter_mobile_app_presentation/src/cubit/manuals/manuals_state.dart';

class ManualsCubit extends Cubit<ManualsState> {
  ManualsCubit() : super(ManualsState.initial());

  Future<void> getManuals() async {
    emit(const ManualsState.loading());
    final SealedResult<AllManuals, VibeError> result =
        await GetIt.I.get<VibeApiNew>().getAllManuals().sealed();
    if (result.isSuccessful) {
      emit(ManualsState.success(manuals: result.data.data));
    } else {
      emit(ManualsState.failure(error: result.error));
    }
  }

  Future<void> getManualDetails(int id) async {
    emit(const ManualsState.loading());
    final SealedResult<ManualDetails, VibeError> result =
        await GetIt.I.get<VibeApiNew>().getManualDetails(id).sealed();
    if (result.isSuccessful) {
      emit(ManualsState.detailRetrieved(details: result.data));
    } else {
      emit(ManualsState.failure(error: result.error));
    }
  }
}
