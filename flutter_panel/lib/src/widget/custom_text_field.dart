import 'package:flutter/material.dart';
import 'package:flutter_panel/generated/l10n.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String? hint;
  final String? errorMessage;
  final int maxLines;
  final bool error;
  final bool readOnly;
  final TextInputType? keyboardType;

  const CustomTextField({
    super.key,
    required this.controller,
    this.label,
    this.error = false,
    this.errorMessage,
    this.hint,
    this.readOnly = false,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).inputDecorationTheme.fillColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white24),
            ),
            maxLines: maxLines,
            readOnly: readOnly,
            keyboardType: keyboardType,
          ),
          if (error) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                errorMessage ?? S.of(context).fieldRequired,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
            const SizedBox(height: 8)
          ]
        ],
      ),
    );
  }
}
