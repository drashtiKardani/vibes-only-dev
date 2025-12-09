import 'package:flutter/material.dart';
import 'package:flutter_mobile_app_presentation/dialogs.dart';
import 'package:flutter_mobile_app_presentation/preferences.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:vibes_only/src/feature/toy/toy_search_dialog.dart';
import 'package:vibes_only/src/widget/vibes_elevated_button.dart';

class EnabledConnectToyDialogProvider extends ConnectToyDialogProvider {
  @override
  Future display(BuildContext context) =>
      showConnectToyDialog(context: context);
}

Future showConnectToyDialog({required BuildContext context}) async {
  return showBlurredBackgroundBottomSheet(
    context: context,
    builder: (context) {
      return Column(
        spacing: 30,
        children: [
          Text(
            'Connect Your Vibe',
            style: context.textTheme.displaySmall?.copyWith(
              fontSize: 24,
              letterSpacing: 0.5,
            ),
          ),
          StatefulBuilder(
            builder: (context, setState) {
              return Row(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: SyncSharedPreferences.doNotAskToConnectToy.value,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3),
                    ),
                    onChanged: (value) {
                      setState(() {
                        SyncSharedPreferences.doNotAskToConnectToy.value =
                            value ?? false;
                      });
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        SyncSharedPreferences.doNotAskToConnectToy.value =
                            !SyncSharedPreferences.doNotAskToConnectToy.value;
                      });
                    },
                    child: Text(
                      'Don\'t show this again.',
                      style: context.textTheme.titleLarge,
                    ),
                  ),
                ],
              );
            },
          ),
          Row(
            spacing: 14,
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    fixedSize: Size(context.mediaQuery.size.width, 48),
                  ),
                  child: const Text('Dismiss'),
                ),
              ),
              Expanded(
                child: VibesElevatedButton(
                  text: 'Connect',
                  onPressed: () {
                    Navigator.pop(context);
                    showToySearchDialog(context);
                  },
                ),
              ),
            ],
          )
        ],
      );
    },
  );
}
