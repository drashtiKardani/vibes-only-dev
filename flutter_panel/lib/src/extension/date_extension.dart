import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateExtension on DateTime {
  String get firstThreeLetterOfMonthName => DateFormat('MMM').format(this);
  String get dayOfWeek => DateFormat('EEEE').format(this);
  String get hour24minute => DateFormat('Hm').format(this);
}

extension TimeExtension on String {
  String get hoursAndMinutesIn12hFormat {
    final timeOfDay = TimeOfDay(hour: int.parse(split(':')[0]), minute: int.parse(split(':')[1]));

    return '${timeOfDay.hourOfPeriod.toString().hourOrMinuteWithLeading0}:${timeOfDay.minute.toString().hourOrMinuteWithLeading0} ${(timeOfDay.period == DayPeriod.am) ? 'am' : 'pm'}';
  }

  String get hourOrMinuteWithLeading0 => padLeft(2, '0');
}
