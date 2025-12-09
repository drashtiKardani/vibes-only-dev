import 'package:flutter/material.dart';

Color cardBackgroundColor(BuildContext context) {
  var theme = Theme.of(context);
  if (theme.brightness == Brightness.light) {
    return const Color(0xfff2f2f2);
  } else {
    return const Color(0xff2a2a2a);
  }
}
