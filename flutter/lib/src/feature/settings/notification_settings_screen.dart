import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/gen/assets.gen.dart' as assets;
import 'package:flutter_mobile_app_presentation/preferences.dart';
import 'package:flutter_mobile_app_presentation/in_app_purchase.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:vibes_only/src/service/push_notification/push_notification.dart';
import 'package:vibes_only/src/widget/back_button_app_bar.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: BackButtonAppBar(
        context,
        onPressed: () => Navigator.pop(context),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: assets.Assets.images.background.image(
              filterQuality: FilterQuality.high,
              package: 'flutter_mobile_app_presentation',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
            ).copyWith(top: context.viewPadding.top + kToolbarHeight + 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style: context.textTheme.displaySmall?.copyWith(
                    fontSize: 24,
                    color: context.colorScheme.onSurface.withValues(alpha: 0.8),
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 20),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('General notifications'),
                  titleTextStyle: context.textTheme.titleMedium?.copyWith(
                    fontSize: 18,
                  ),
                  subtitle: Text(
                    'Get real-time updates on app, video, and product.',
                  ),
                  trailing: Switch.adaptive(
                    activeTrackColor: context.colorScheme.onSurface.withValues(
                      alpha: 0.7,
                    ),
                    value: SyncSharedPreferences.enableNotifications.value,
                    onChanged: (value) async {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) {
                          return const AlertDialog(
                            content: SizedBox(
                              height: 200,
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          );
                        },
                      );
                      SyncSharedPreferences.enableNotifications.value = value;
                      PushNotificationService.setupFCM()
                          .then(
                            (_) => PushNotificationService.setupTopics(
                              userHasSubscription:
                                  BlocProvider.of<InAppPurchaseCubit>(
                                    context,
                                  ).state.isActive,
                            ),
                          )
                          .then((_) {
                            Navigator.pop(context);
                            setState(() {});
                          })
                          .catchError((e) {
                            SyncSharedPreferences.enableNotifications.value =
                                !value;
                            Navigator.pop(context);
                            setState(() {});
                            showDialog(
                              context: context,
                              builder: (_) {
                                return AlertDialog(
                                  title: const Text('Error'),
                                  content: SizedBox(
                                    height: 100,
                                    child: SingleChildScrollView(
                                      child: Center(child: Text(e.toString())),
                                    ),
                                  ),
                                );
                              },
                            );
                          });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
