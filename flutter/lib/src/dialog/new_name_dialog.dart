import 'package:flutter/material.dart';
import 'package:flutter_mobile_app_presentation/dialogs.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:gap/gap.dart';

/// Returns the text inside text field when "Done" is pressed.
Future<String?> showNewNameBottomSheet(BuildContext context,
    {String? oldName}) {
  final TextEditingController controller = TextEditingController(text: oldName);
  controller.selection =
      TextSelection(baseOffset: 0, extentOffset: controller.value.text.length);

  return showBlurredBackgroundBottomSheet(
    context: context,
    builder: (context) {
      return Column(
        children: [
          Text(
            'Give your vibe a name',
            style: context.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const Gap(40),
          TextField(
            autocorrect: false,
            autofocus: false,
            controller: controller,
            cursorColor: context.colorScheme.onSurface,
            decoration: InputDecoration(
              hintText: 'Enter player name',
              hintStyle: TextStyle(
                color: context.colorScheme.onSurface.withValues(alpha: 0.2),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white10),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white10),
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
            ),
            onSubmitted: (text) {
              Navigator.pop(context, text);
            },
          ),
          const Gap(60),
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
                  onPressed: () {
                    Navigator.pop(context, controller.text);
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(context.mediaQuery.size.width, 48),
                  ),
                  child: Text('Done'),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}
