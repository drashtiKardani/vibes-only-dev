import 'package:flutter/widgets.dart';
import 'package:flutter_panel/src/widget/formdata_components/_formdata_component.dart';

import '../custom_checkbox.dart';

class FormDataCheckbox extends FormDataComponent<bool> {
  FormDataCheckbox({required super.label, super.validatingFunction, super.initialValue});

  late final _isSelectedNotifier = ValueNotifier(initialValue ?? false);

  @override
  Widget get widget {
    return ValueListenableBuilder(
        valueListenable: _isSelectedNotifier,
        builder: (context, bool value, _) {
          return CustomCheckbox(
            value: value,
            title: label,
            onChanged: (value) => _isSelectedNotifier.value = value ?? false,
          );
        });
  }

  @override
  void reset() {
    _isSelectedNotifier.value = _lateInitialValue ?? initialValue ?? false;
  }

  @override
  bool get value => _isSelectedNotifier.value;

  bool? _lateInitialValue;

  set lateInitialValue(bool? isChecked) {
    _lateInitialValue = isChecked;
    if (isChecked != null) {
      _isSelectedNotifier.value = isChecked;
    }
  }
}
