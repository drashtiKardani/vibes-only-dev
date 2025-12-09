import 'package:flutter/material.dart';
import 'package:flutter_panel/src/config/const.dart';
import 'package:timezone/browser.dart' as tz;

class TimeSelectWidget extends StatelessWidget {
  final String title;
  final ValueNotifier<TimeOfDay?> selectedTimeNotifier;

  const TimeSelectWidget({
    super.key,
    required this.title,
    required this.selectedTimeNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final nowInNY = tz.TZDateTime.now(Const.tzNewYork);

    return GestureDetector(
      onTap: () => showTimePicker(
        context: context,
        initialTime: selectedTimeNotifier.value ?? TimeOfDay.fromDateTime(nowInNY),
      ).then(
        (value) {
          if (value != null) selectedTimeNotifier.value = value;
        },
      ),
      child: Container(
        width: double.maxFinite,
        color: Theme.of(context).inputDecorationTheme.fillColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: Theme.of(context).appBarTheme.titleTextStyle!.color,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            ValueListenableBuilder(
              valueListenable: selectedTimeNotifier,
              builder: (context, TimeOfDay? value, child) {
                return Chip(
                  backgroundColor: Theme.of(context).primaryColor,
                  label: Text(
                    value == null ? "Not selected" : value.format(context),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
            const SizedBox(
              height: 8,
            ),
          ],
        ),
      ),
    );
  }
}
