import 'package:flutter/material.dart';

extension ListWidgetEx on List<Widget> {
  List<Widget> separateBuilder(Widget Function() builder) {
    return length <= 1
        ? this
        : sublist(1).fold([first], (r, element) => [...r, builder(), element]);
  }
}
