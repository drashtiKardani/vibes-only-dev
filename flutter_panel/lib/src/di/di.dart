import 'package:dio/dio.dart';
import 'package:flutter_mobile_app_presentation/api.dart' as mobile_app;
import 'package:flutter_panel/generated/l10n.dart';
import 'package:flutter_panel/src/data/network/panel_api.dart';
import 'package:flutter_panel/src/data/network/panel_upload_api.dart';
import 'package:get_it/get_it.dart';
import 'package:harmony_auth/harmony_auth.dart';
import 'package:harmony_log/harmony_log.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

var getIt = GetIt.I;

Future setupDependencyInjection(String baseUrl) async {
  _registerDio(baseUrl);
  _registerI10n();
}

void _registerDio(String baseUrl) {
  var dio = Dio();
  dio.options.baseUrl = baseUrl;

  dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
      maxWidth: 90));
  // harmony auth setup
  AuthConfig.log = _buildLog();
  final storage = const AuthStorage().streaming().locked();
  final rest = AuthRest(
    dio: dio,
    refreshUrl: '${baseUrl}hippo_shield/main/refresh/',
    checker: const AuthChecker(),
  );
  final repository = AuthRepository(
    storage: storage,
    rest: rest,
  ).debounce(const Duration(seconds: 10)).locked();

  final matcher = const AuthMatcher.all() -
      AuthMatcher.url("${baseUrl}hippo_shield/email_password_authentication/login/") -
      AuthMatcher.url("${baseUrl}hippo_shield/2fa/login/");
  const checker = AuthChecker();
  const manipulator = AuthManipulator();
  final interceptor = AuthInterceptor(
    dio: dio,
    matcher: matcher,
    checker: checker,
    manipulator: manipulator,
    repository: repository,
  );

  dio.interceptors.add(interceptor);

  getIt.registerSingleton(dio);
  getIt.registerLazySingleton(() => repository);

  getIt.registerLazySingleton(() => VibesPanelApi(inject(), baseUrl: baseUrl));
  getIt.registerLazySingleton(() => VibesPanelUploadApi(inject()));

  // Injecting a separate http client to be used in app simulator
  final simDio = Dio();
  simDio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  getIt.registerLazySingleton(() => mobile_app.VibeApiNew(simDio, baseUrl: baseUrl));
}

void _registerI10n() {
  GetIt.I.registerLazySingleton(() => S());
}

Log _buildLog() => Log(
      id: LogId.counter(),
      child: const LogOutput.redirectOnDebug(
        child: LogOutput.plain(
          format: LogPlainFormat.simple(),
          child: LogPlainOutput.console(),
        ),
      ),
    );

S get strings => inject<S>();

T inject<T extends Object>() {
  return getIt.get<T>();
}

Future<T> injectAsync<T extends Object>() {
  return getIt.getAsync<T>();
}
