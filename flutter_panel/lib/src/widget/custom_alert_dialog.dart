import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final String? title;
  final String message;
  final String? positiveButtonLabel;
  final String? negativeButtonLabel;
  final VoidCallback onPositiveButtonClick;

  const CustomAlertDialog(
      {super.key,
      this.title,
      required this.message,
      this.positiveButtonLabel,
      this.negativeButtonLabel,
      required this.onPositiveButtonClick});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        height: 150,
        width: MediaQuery.of(context).size.width * 0.3,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(
                title!,
                style: const TextStyle(fontSize: 22),
              ),
              const SizedBox(
                height: 16,
              ),
            ],
            Text(
              message,
              style: TextStyle(fontSize: 16, color: Theme.of(context).appBarTheme.titleTextStyle!.color!.withAlpha(150)),
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    onPressed: onPositiveButtonClick,
                    child: Text(
                      positiveButtonLabel ?? 'Ok',
                      style: const TextStyle(fontSize: 16),
                    )),
                const SizedBox(
                  width: 8,
                ),
                TextButton(
                    onPressed: () => AutoRouter.of(context).maybePop(),
                    child: Text(
                      negativeButtonLabel ?? 'Cancel',
                      style: const TextStyle(fontSize: 16),
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }
}
