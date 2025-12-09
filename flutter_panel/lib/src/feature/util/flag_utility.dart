import 'package:flutter/foundation.dart';

mixin FlagUtility {
  Map<dynamic, bool> calcFlagUpdateMap(
      List<Map<String, dynamic>> flags, ValueNotifier<List<Map<String, dynamic>>> flagsNotifier) {
    final flagUpdates = {for (var flag in flags) flag['value']: false};
    flagUpdates.addAll({for (var flag in flagsNotifier.value) flag['value']: true});
    return flagUpdates;
  }
}
