import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_panel/src/enum/file_types.dart';
import 'package:flutter_panel/src/util/large_file_uploader.dart';
import 'package:flutter_panel/src/widget/crop_dialog.dart';
import 'package:flutter_panel/src/extension/file_extension.dart';
import 'package:flutter_panel/generated/l10n.dart';

class ImagePickerWidget extends StatelessWidget {
  final String title;
  final ValueNotifier<Uint8List?> valueController;
  final Function(Uint8List? image) onChange;
  final bool error;
  final String? errorMessage;
  final bool withCircleUi;
  final double? aspectRatio;

  const ImagePickerWidget(
      {super.key,
      required this.title,
      required this.valueController,
      required this.onChange,
      this.error = false,
      this.errorMessage,
      this.withCircleUi = false,
      this.aspectRatio});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      color: Theme.of(context).inputDecorationTheme.fillColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 12,
              color: Theme.of(context).appBarTheme.titleTextStyle!.color,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          ValueListenableBuilder<Uint8List?>(
            valueListenable: valueController,
            builder: (context, value, child) {
              return value != null
                  ? SizedBox(
                      width: 150,
                      height: 150,
                      child: Stack(
                        children: [
                          Image.memory(
                            value,
                            fit: BoxFit.cover,
                            width: 150,
                            height: 150,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Align(
                              alignment: Alignment.topRight,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    child: Container(
                                      width: 25,
                                      height: 25,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle, color: Theme.of(context).colorScheme.surface),
                                      child: Icon(
                                        Icons.crop,
                                        color: Theme.of(context).appBarTheme.titleTextStyle!.color!,
                                        size: 20,
                                      ),
                                    ),
                                    onTap: () => _cropImage(context),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  GestureDetector(
                                    onTap: _clearChoice,
                                    child: Container(
                                      width: 25,
                                      height: 25,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle, color: Theme.of(context).colorScheme.surface),
                                      child: Icon(
                                        Icons.clear,
                                        color: Theme.of(context).appBarTheme.titleTextStyle!.color!,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  : GestureDetector(
                      onTap: _pickFile,
                      child: Container(
                        width: 150,
                        height: 150,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: Theme.of(context).primaryColor.withAlpha(50)),
                        child: Icon(
                          Icons.camera_enhance,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    );
            },
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
    );
  }

  void _pickFile() {
    LargeFileUploader.pick(
        type: FileTypes.image,
        callback: (file) async {
          final imageBytes = await file.asBytes();

          valueController.value = imageBytes;
          onChange.call(imageBytes);
        });
  }

  void _clearChoice() {
    onChange.call(null);
  }

  Future _cropImage(BuildContext context) async {
    final croppedImage = await showDialog(
      context: context,
      builder: (context) => CropDialog(
        imageData: valueController.value!,
        withCircleUi: withCircleUi,
        aspectRatio: aspectRatio,
      ),
    ) as Uint8List?;

    if (croppedImage != null) {
      valueController.value = croppedImage;
    }
  }
}
