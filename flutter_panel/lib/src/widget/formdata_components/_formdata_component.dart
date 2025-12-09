import 'package:flutter/widgets.dart';

/// A Class that unites a [widget] with a [value],
/// supposing that this [value], will be a part of an http.post/patch request.
abstract class FormDataComponent<T> {
  final String label;
  final T? initialValue;

  final bool Function(T)? validatingFunction;

  FormDataComponent({required this.label, this.initialValue, this.validatingFunction});

  bool error = false;

  T get value;

  Widget get widget;

  void reset();

  bool get isValid => validatingFunction?.call(value) ?? true;
}
