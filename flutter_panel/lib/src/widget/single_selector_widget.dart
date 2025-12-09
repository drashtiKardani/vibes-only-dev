import 'package:flutter/material.dart';

class SingleSelectorWidget<T> extends StatelessWidget {
  const SingleSelectorWidget({super.key, required this.options, required this.selected, required this.displayNameOf});

  final List<T> options;
  final ValueNotifier<T?> selected;
  final String Function(T value) displayNameOf;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: selected,
      builder: (context, T? value, _) {
        return DropdownButton<T>(
          value: value,
          items: [
            for (T option in options)
              DropdownMenuItem(
                value: option,
                child: Text(displayNameOf(option)),
              ),
          ],
          onChanged: (value) {
            if (value != null) {
              selected.value = value;
            }
          },
        );
      },
    );
  }
}
