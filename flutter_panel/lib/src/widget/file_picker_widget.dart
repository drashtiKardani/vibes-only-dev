// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_panel/src/enum/file_types.dart';
import 'package:flutter_panel/src/util/large_file_uploader.dart';
import 'package:flutter_panel/generated/l10n.dart';
import 'package:flutter_panel/src/widget/download_button.dart';

class FilePickerWidget extends StatelessWidget {
  final String title;
  final int count;
  final ValueNotifier<List<html.File>>? valueController;
  final Function(List<html.File> files)? onChange;
  final FileTypes types;
  final bool error;
  final String? errorMessage;
  final bool disabled;
  final int? fakeCount;
  final String? url;
  final String? fileName;

  const FilePickerWidget(
      {super.key,
      required this.title,
      this.valueController,
      this.count = 1,
      required this.onChange,
      this.types = FileTypes.file,
      this.error = false,
      this.disabled = false,
      this.errorMessage,
      this.fakeCount,
      this.url,
      this.fileName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      color: Theme.of(context).inputDecorationTheme.fillColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  color:
                      disabled ? Theme.of(context).disabledColor : Theme.of(context).appBarTheme.titleTextStyle!.color,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                children: [
                  if (fakeCount != null)
                    Text(
                      '$fakeCount / $count',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                        color: disabled
                            ? Theme.of(context).disabledColor
                            : Theme.of(context).appBarTheme.titleTextStyle!.color,
                      ),
                    )
                  else if (disabled)
                    Text(
                      '$count / $count',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                        color: disabled
                            ? Theme.of(context).disabledColor
                            : Theme.of(context).appBarTheme.titleTextStyle!.color,
                      ),
                    )
                  else
                    ValueListenableBuilder<List<html.File>>(
                      valueListenable: valueController!,
                      builder: (context, value, child) => Text('${value.length} / $count'),
                    ),
                  const SizedBox(
                    width: 16,
                  ),
                  if (fileName != null) Text(fileName!) else if (url != null) DownloadButton(url: url!),
                ],
              ),
              if (error) ...[
                const SizedBox(
                  height: 8,
                ),
                Text(
                  errorMessage ?? S.of(context).fieldRequired,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
            ],
          ),
          if (!disabled)
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).colorScheme.surface),
                child: const Icon(Icons.add),
              ),
            )
        ],
      ),
    );
  }

  void _pickFile() {
    LargeFileUploader.pick(
        type: types,
        callback: (file) {
          if ((valueController?.value.length ?? 0) < count) {
            valueController?.value.add(file);
            onChange?.call(valueController!.value);
          }
        });
  }
}
