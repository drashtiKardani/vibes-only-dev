import 'package:flutter/material.dart';
import 'package:flutter_mobile_app_presentation/src/data/network/vibe_api_new.dart';
import 'package:flutter_mobile_app_presentation/src/theme/theme.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

import 'flavor_config.dart';

class ServerSwapper {
  /// list of all selectable servers that are shown in the "change server dialog".
  static Map<String, String> selectableServers = {
    Flavor.productionFlavor.name: Flavor.productionFlavor.baseUrl,
    Flavor.stagingFlavor.name: Flavor.stagingFlavor.baseUrl,
    'Development': 'https://vo-feat.6thsolution.tech/api/v1/',
  };

  static final ServerSwapper _instance = ServerSwapper._();
  ServerSwapper._();

  final ValueNotifier<String> _currentBaseUrl = ValueNotifier<String>(
    Flavor.instance.baseUrl,
  );

  static ValueNotifier<String> get notifier => _instance._currentBaseUrl;
  static String get currentBaseUrl => _instance._currentBaseUrl.value;

  static void swapTo(String baseUrl) {
    GetIt.I.unregister<VibeApiNew>();
    GetIt.I.registerSingleton(VibeApiNew(GetIt.I.get<Dio>(), baseUrl: baseUrl));
    _instance._currentBaseUrl.value = baseUrl;
  }
}

class ServerSelectorRadioListTile extends RadioListTile<String> {
  ServerSelectorRadioListTile({
    super.key,
    required String title,
    required String baseUrl,
    required Function()? onSelectAlsoDo,
  }) : super(
         value: baseUrl,
         groupValue: ServerSwapper.currentBaseUrl,
         onChanged: (String? value) {
           if (value != null) {
             ServerSwapper.swapTo(value);
           }
           onSelectAlsoDo?.call();
         },
         title: Text('$title server'),
         activeColor: AppColors.vibesPink,
       );
}
