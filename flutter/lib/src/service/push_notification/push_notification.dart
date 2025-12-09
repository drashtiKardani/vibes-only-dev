import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_mobile_app_presentation/api.dart';
import 'package:flutter_mobile_app_presentation/preferences.dart';
import 'package:vibes_common/vibes.dart';
import 'package:vibes_only/src/di/di.dart';
import 'package:vibes_only/src/service/logger.dart';

class PushNotificationService {
  static Future<void> setupFCM() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        Logger.push.i('User granted permission');
        String? token = await FirebaseMessaging.instance.getToken();
        Logger.push.i('FCM token: $token');
        FirebaseMessaging.instance.onTokenRefresh.listen(_sendTokenToServer);
        if (token != null) {
          return _sendTokenToServer(token);
        } else {
          final error = StateError('FCM token is null');
          FirebaseCrashlytics.instance.recordError(error, null);
          return Future.error(error);
        }
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        Logger.push.w('User granted provisional permission');
      } else {
        Logger.push.w('User declined or has not accepted permission');
      }
    } catch (e) {
      Logger.push.e(e.toString());
    }
  }

  static Future<void> _sendTokenToServer(String token) async {
    String platform = Platform.isIOS
        ? 'ios'
        : Platform.isAndroid
            ? 'android'
            : 'web';
    try {
      return inject<VibeApiNew>().registerToken(
        Device(
          registrationId: token,
          type: platform,
          active: SyncSharedPreferences.enableNotifications.value,
        ),
      );
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(e, null);
      return Future.error(e);
    }
  }

  static Future<void> setupTopics({required bool userHasSubscription}) async {
    if (SyncSharedPreferences.enableNotifications.value == false) {
      await _topics(unsubscribeFrom: [
        PushMessageAudience.free,
        PushMessageAudience.paid
      ]);
    } else {
      if (userHasSubscription) {
        await _topics(
            subscribeTo: [PushMessageAudience.paid],
            unsubscribeFrom: [PushMessageAudience.free]);
      } else {
        await _topics(
            subscribeTo: [PushMessageAudience.free],
            unsubscribeFrom: [PushMessageAudience.paid]);
      }
    }
  }

  static Future<void> _topics(
      {List<PushMessageAudience>? subscribeTo,
      List<PushMessageAudience>? unsubscribeFrom}) async {
    subscribeTo?.forEach((topic) async {
      await FirebaseMessaging.instance.subscribeToTopic(topic.name);
      Logger.push.i('+ Subscribed to topic $topic');
    });

    unsubscribeFrom?.forEach((topic) async {
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic.name);
      Logger.push.i('- Unsubscribed from topic $topic');
    });
  }
}
