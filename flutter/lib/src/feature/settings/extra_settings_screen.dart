import 'package:flutter/material.dart';
import 'package:flutter_mobile_app_presentation/preferences.dart';

/// Normally hidden from the end-user, but useful for the developer
class ExtraSettingsScreen extends StatefulWidget {
  const ExtraSettingsScreen({super.key});

  @override
  State createState() => _ExtraSettingsScreenState();
}

class _ExtraSettingsScreenState extends State<ExtraSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Extra Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w300,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
        child: Column(
          children: [
            _CheckboxSetting(
              preference: SyncSharedPreferences.doNotAskToConnectToy,
              label: 'Do not Show "Connect your vibe" dialog',
              setState: setState,
            ),
            const SizedBox(height: 20),
            _CheckboxSetting(
              preference: SyncSharedPreferences.userSkippedInitialIAP,
              label: 'Automatically skip the initial "Subscription Purchasing" screen',
              setState: setState,
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckboxSetting extends Row {
  _CheckboxSetting({
    required Preference preference,
    required String label,
    required void Function(VoidCallback fn) setState,
  }) : super(
          children: [
            Checkbox(
              value: preference.value,
              onChanged: (newValue) {
                setState(() {
                  preference.value = newValue!;
                });
              },
            ),
            const SizedBox(width: 5),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
          ],
        );
}
