import 'package:flutter/material.dart';
import 'package:flutter_panel/src/widget/formdata_components/_formdata_component.dart';
import 'package:flutter_panel/src/widget/single_selector_widget.dart';

class FormDataDropDown<T> extends FormDataComponent<T?> {
  FormDataDropDown(
      {required this.optionsFuture, required this.displayNameOf, required super.label, super.initialValue});

  late final ValueNotifier<T?> _selected = ValueNotifier(initialValue);

  final Future<List<T>> optionsFuture;

  final String Function(T value) displayNameOf;

  @override
  void reset() {
    _selected.value = _lateInitialValue ?? initialValue;
  }

  @override
  get value => _selected.value;

  T? _lateInitialValue;

  set lateInitialValue(T? t) {
    _lateInitialValue = t;
    _selected.value = t;
  }

  @override
  Widget get widget => FutureBuilder<List<T>>(
        future: optionsFuture,
        builder: (context, snapshot) {
          return Container(
            color: Theme.of(context).inputDecorationTheme.fillColor,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: snapshot.hasData
                ? Row(
                    children: [
                      Text(label),
                      const SizedBox(width: 8),
                      SingleSelectorWidget(options: snapshot.data!, selected: _selected, displayNameOf: displayNameOf),
                    ],
                  )
                : const Center(child: CircularProgressIndicator()),
          );
        },
      );
}
