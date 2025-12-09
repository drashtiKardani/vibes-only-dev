import 'package:flutter/material.dart';
import 'package:flutter_mobile_app_presentation/dialogs.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibes_common/vibes.dart';

void showPromotionDialog(BuildContext context, {required String title, required String body, required String code}) {
  showBlurredBackdropDialog(
    context: context,
    title: Center(
      child: Column(
        children: [
          FlickerText(
            text: title,
            color: AppColors.vibesPink,
            fontSize: 18,
            fontWeight: FontWeight.w300,
          ),
        ],
      ),
    ),
    children: [
      const SizedBox(height: 10),
      Text(
        body,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 30),
      ElevatedButton(
        onPressed: () async {
          final url = Uri.tryParse(code);
          print(url);
          if (url != null) {
            launchUrl(url);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.vibesPink,
          minimumSize: const Size.fromHeight(45),
        ),
        child: const Text(
          'View Offer',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        ),
      ),
    ],
  );
}
