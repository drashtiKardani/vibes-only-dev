import 'package:flutter/widgets.dart';
import 'package:flutter_panel/src/widget/formdata_components/_formdata_component.dart';

extension GroupActions on List<FormDataComponent> {
  List<Widget> placeInCrudScaffold() {
    final widgets = <Widget>[];
    for (int i = 0; i < length; i++) {
      widgets.add(this[i].widget);
      if (i < length - 1) {
        // Add space after every component, except the last one.
        widgets.add(const SizedBox(height: 16));
      }
    }
    return widgets;
  }

  void reset() {
    for (final component in this) {
      component.reset();
    }
  }

  bool validate() {
    var invalidFields = 0;
    for (final component in this) {
      if (component.isValid) {
        component.error = false;
      } else {
        component.error = true;
        invalidFields++;
      }
    }
    return invalidFields == 0;
  }
}
