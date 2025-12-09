import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_panel/src/data/network/panel_api.dart';
import 'package:get_it/get_it.dart';
import 'package:harmony_auth/harmony_auth.dart';
import 'login_state.dart';
import 'package:vibes_common/vibes.dart';
import 'package:dio/dio.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this.api, this.authRepository) : super(const LoginState.initial());

  final VibesPanelApi api;
  final AuthRepository authRepository;

  Future<void> login(String email, String password) async {
    emit(const LoginState.loading());

    SealedResult<LoginResponse, VibeError> result;
    try {
      var response =
          await api.login(LoginByEmail(email: email, password: password));
      result = SealedResult.success(response);
    } on DioException catch (e) {
      var error = VibeError.network(
        error: NetworkError(
            message: e.response?.data["detail"],
            code: e.response?.statusCode ?? 0),
      );
      result = SealedResult.error(error);
    } catch (e) {
      if (kDebugMode) {
        print('$e');
      }
      var error = VibeError.network(error: NetworkError(message: '', code: 0));
      result = SealedResult.error(error);
    }

    if (result.isSuccessful) {
      authRepository.setToken(AuthToken(
        refresh: result.data.data.refresh,
        access: result.data.data.access,
      ));
      emit(const LoginState.success());
    } else {
      emit(LoginState.failure(error: result.error));
    }
  }

  Future<void> logout() async {
    emit(const LoginState.initial());
    await GetIt.I<AuthRepository>().removeToken();
  }
}
