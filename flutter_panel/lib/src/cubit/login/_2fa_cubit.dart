import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_panel/src/data/network/panel_api.dart';
import 'package:harmony_auth/harmony_auth.dart';
import 'package:vibes_common/vibes.dart';
import '_2fa_state.dart';

class TwoFactorAuthenticationCubit extends Cubit<TwoFactorAuthenticationState> {
  TwoFactorAuthenticationCubit(this.api, this.authRepository) : super(const TwoFactorAuthenticationState.initial());

  final VibesPanelApi api;
  final AuthRepository authRepository;

  Future<void> send2FACode(TwoFACode code) async {
    emit(const TwoFactorAuthenticationState.loading());
    var result = await api
        .send2FACode(code)
        .sealed();
    if (result.isSuccessful) {
      authRepository.setToken(
          AuthToken(refresh: result.data.refresh, access: result.data.access));
      emit(const TwoFactorAuthenticationState.success());
    } else {
      emit(TwoFactorAuthenticationState.failure(error: result.error));
    }
  }
}
