import 'package:flutter/material.dart';

class CustomCrudTableItem extends StatelessWidget {
  final List<Widget> fields;

  const CustomCrudTableItem({super.key, required this.fields});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [for (final field in fields) Expanded(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: field,
      ))],
    );
  }
}
