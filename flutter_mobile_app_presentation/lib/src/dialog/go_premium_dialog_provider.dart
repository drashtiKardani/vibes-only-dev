import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobile_app_presentation/dialogs.dart';
import 'package:flutter_mobile_app_presentation/gen/assets.gen.dart';
import 'package:flutter_mobile_app_presentation/generated/l10n.dart';
import 'package:flutter_mobile_app_presentation/src/service/analytics.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:url_launcher/url_launcher.dart';

enum PremiumType { content, feature }

class GoPremiumDialogProvider {
  final void Function(BuildContext context) onSubscribeButtonTapped;

  GoPremiumDialogProvider({required this.onSubscribeButtonTapped});

  bool _goPremiumDialogIsShowing = false;

  void display(BuildContext context, {PremiumType type = PremiumType.content}) {
    if (_goPremiumDialogIsShowing) return;

    final Map<PremiumType, String> typeDescriptionMap = {
      PremiumType.content: S.of(context).content,
      PremiumType.feature: S.of(context).feature,
    };

    Analytics.logEvent(name: 'popUp', context: context);

    _goPremiumDialogIsShowing = true;

    showBlurredBackgroundBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: context.colorScheme.onSurface.withValues(alpha: 0.1),
              ),
              child: Assets.svgs.iconPrimium.svg(
                height: 60,
                width: 60,
                package: 'flutter_mobile_app_presentation',
              ),
            ),
            const SizedBox(height: 20),
            Text(
              S.of(context).premiumDialogTitle,
              style: context.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              S.of(context).premiumDialogBody(typeDescriptionMap[type]!),
              textAlign: TextAlign.center,
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              spacing: 10,
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      fixedSize: Size(context.mediaQuery.size.width, 48),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final email =
                          FirebaseAuth.instance.currentUser?.email ?? '';
                      final userId =
                          FirebaseAuth.instance.currentUser?.uid ?? '';
                      final Uri shopUri = Uri.parse(
                        'https://subscription.vibesonly.com/?email=$email&user_id=$userId',
                      );

                      final result = await launchUrl(
                        shopUri,
                        mode: LaunchMode.externalApplication,
                      );
                      if (result) {
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size(context.mediaQuery.size.width, 48),
                    ),
                    child: Text(S.of(context).subscribe),
                  ),
                ),
                // Expanded(
                //   child: ElevatedButton(
                //     onPressed: () => onSubscribeButtonTapped(context),
                //     style: ElevatedButton.styleFrom(
                //       fixedSize: Size(context.mediaQuery.size.width, 48),
                //     ),
                //     child: Text(S.of(context).subscribe),
                //   ),
                // ),
              ],
            ),
          ],
        );
      },
    ).then((_) => _goPremiumDialogIsShowing = false);
  }
}
