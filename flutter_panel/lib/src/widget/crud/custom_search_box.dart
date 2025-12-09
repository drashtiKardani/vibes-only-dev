import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

class CustomSearchBox extends StatelessWidget {
  final ValueChanged<String>? onChanged;

  const CustomSearchBox({super.key, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 350,
      child: TextField(
        decoration: const InputDecoration(
          prefixIcon: Icon(IconlyLight.search),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
