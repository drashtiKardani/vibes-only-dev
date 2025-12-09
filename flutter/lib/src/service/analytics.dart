import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_mobile_app_presentation/services.dart';
import 'package:get_it/get_it.dart';

class Analytics {
  static void logEvent({required BuildContext context, required String name, Map<String, Object>? parameters}) {
    GetIt.I<AnalyticsService>().logEvent(context: context, name: name, parameters: parameters);
  }
}

class AnalyticsWithFirebase extends AnalyticsService {
  @override
  void logEvent({required BuildContext context, required String name, Map<String, Object>? parameters}) {
    FirebaseAnalytics.instance.logEvent(name: name, parameters: parameters);
  }
}
