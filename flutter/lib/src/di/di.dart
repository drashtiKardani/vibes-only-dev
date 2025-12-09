import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobile_app_presentation/api.dart';
import 'package:flutter_mobile_app_presentation/data_stores.dart';
import 'package:flutter_mobile_app_presentation/dialogs.dart';
import 'package:flutter_mobile_app_presentation/flavors.dart';
import 'package:flutter_mobile_app_presentation/services.dart';
import 'package:flutter_mobile_app_presentation/toy.dart';
import 'package:get_it/get_it.dart';
import 'package:vibes_only/src/data/commodities_store.dart';
import 'package:vibes_only/src/feature/story_player/components/toy_control_buttons.dart';
import 'package:vibes_only/src/feature/toy/remote_lover/service/service.dart';
import 'package:vibes_only/src/service/analytics.dart';

import '../feature/iap/iap_screen.dart';
import '../feature/story_player/dialogs.dart';

var getIt = GetIt.I;

Future setupDependencyInjection() async {
  _registerDio();
  getIt.registerSingleton<RemoteLoverService>(RemoteLoverService());
  getIt.registerSingleton(CommoditiesStore());
  getIt.registerSingleton(GoPremiumDialogProvider(onSubscribeButtonTapped: (context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const InAppPurchaseScreen(comingFromMainScreen: true)),
    );
  }));
  getIt.registerSingleton<AnalyticsService>(AnalyticsWithFirebase());
  getIt.registerSingleton<ToyControlButtonsProvider>(EnabledToyControlInStoryPlayer());
  getIt.registerSingleton<ConnectToyDialogProvider>(EnabledConnectToyDialogProvider());
  getIt.registerSingleton(HelpUrlsStore());
}

void _registerDio() {
  getIt.registerLazySingleton<Dio>(() {
    var dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (Platform.isAndroid) {
          options.headers['platform'] = 'android';
        } else if (Platform.isIOS) {
          options.headers['platform'] = 'ios';
        }
        return handler.next(options); //continue
      },
    ));
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      options.path += "?state=published";
      return handler.next(options);
    }));
    dio.interceptors.add(LogInterceptor(
        request: false, requestHeader: false, requestBody: false, responseHeader: false, responseBody: false));
    return dio;
  });
  getIt.registerLazySingleton(() => VibeApiNew(inject(), baseUrl: Flavor.instance.baseUrl));
}

T inject<T extends Object>() {
  return getIt.get<T>();
}

Future<T> injectAsync<T extends Object>() {
  return getIt.getAsync<T>();
}
