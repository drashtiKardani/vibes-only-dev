import 'package:flutter/widgets.dart';
import 'package:flutter_panel/src/widget/formdata_components/_formdata_component.dart';

import '../custom_text_field.dart';

class FormDataTextField extends FormDataComponent<String> {
  final TextInputType? keyboardType;
  final String? errorMessage;

  FormDataTextField(
      {required super.label, this.keyboardType, this.errorMessage, super.validatingFunction, super.initialValue});

  late final _controller = TextEditingController(text: initialValue);

  @override
  Widget get widget {
    return CustomTextField(
      controller: _controller,
      label: label,
      keyboardType: TextInputType.number,
      error: error,
      errorMessage: errorMessage,
    );
  }

  @override
  void reset() {
    _controller.text = _lateInitialValue ?? initialValue ?? "";
  }

  @override
  String get value => _controller.text;

  String? _lateInitialValue;

  set lateInitialValue(String text) {
    _lateInitialValue = text;
    _controller.text = text;
  }
}
