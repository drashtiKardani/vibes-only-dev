import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateSelectWidget extends StatelessWidget {
  final String title;
  final ValueNotifier<DateTime?> selectedDateNotifier;
  final DateTime initialDate;

  DateSelectWidget({
    super.key,
    required this.title,
    required this.selectedDateNotifier,
    DateTime? initialDate,
  })  : initialDate = initialDate ?? DateTime.now();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showDatePicker(
        context: context,
        initialDate: selectedDateNotifier.value ?? initialDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2040),
      ).then(
        (value) {
          if (value != null) selectedDateNotifier.value = value;
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
              valueListenable: selectedDateNotifier,
              builder: (context, DateTime? value, child) {
                return Chip(
                  backgroundColor: Theme.of(context).primaryColor,
                  label: Text(
                    value == null ? "Not selected" : DateFormat('yyyy-MM-dd').format(value),
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
