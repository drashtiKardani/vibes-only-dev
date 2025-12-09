import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';

class Analytics {
  static void logEvent({required BuildContext context, required String name, Map<String, Object>? parameters}) {
    GetIt.I<AnalyticsService>().logEvent(context: context, name: name, parameters: parameters);
  }
}

abstract class AnalyticsService {
  void logEvent({required BuildContext context, required String name, Map<String, Object>? parameters});
}

class AnalyticsMock extends AnalyticsService {
  @override
  void logEvent({required BuildContext context, required String name, Map<String, Object?>? parameters}) {
    // Do nothing
    debugPrint('AnalyticsMock ~> name:$name - parameters:$parameters');
  }
}
