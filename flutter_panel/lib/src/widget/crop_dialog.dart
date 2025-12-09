import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_panel/generated/l10n.dart';
import 'package:flutter_panel/src/util/crop_tool/crop_controller.dart';
import 'package:flutter_panel/src/util/crop_tool/crop_image.dart';

class CropDialog extends StatefulWidget {
  final Uint8List imageData;
  final bool withCircleUi;
  final double? aspectRatio;
  const CropDialog(
      {super.key,
      required this.imageData,
      this.withCircleUi = false,
      this.aspectRatio});

  @override
  State<CropDialog> createState() => _CropDialogState();
}

class _CropDialogState extends State<CropDialog> {
  late final _cropController = CropController(aspectRatio: widget.withCircleUi ? 1.0 : widget.aspectRatio);
  late var _image = Image.memory(widget.imageData);

  /// Contains the bitmap data of cropped image,
  /// Or null if no crop has been done yet.
  ui.Image? _bitmap;
  ui.Image? _initialBitmap;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.55,
        width: MediaQuery.of(context).size.width * 0.5,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: GestureDetector(
                child: Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.surface),
                  child: Icon(
                    Icons.clear,
                    color: Theme.of(context).appBarTheme.titleTextStyle!.color!,
                  ),
                ),
                onTap: () => AutoRouter.of(context).maybePop(),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Flexible(
              child: CropImage(
                image: _image,
                controller: _cropController,
                minimumImageSize: 1,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: () async {
                      _initialBitmap ??= _cropController.image;
                      _bitmap = await _cropController.croppedBitmap();
                      _cropController.image = _bitmap!;
                      _image = Image(
                        image: UiImageProvider(_bitmap!),
                        fit: BoxFit.contain,
                      );
                      _cropController.crop = const Rect.fromLTWH(0, 0, 1, 1);
                      setState(() {});
                    },
                    child: Text(S.of(context).crop),
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: () => setState(() {
                      _image = Image.memory(widget.imageData);
                      if (_initialBitmap != null) _cropController.image = _initialBitmap!;
                      _bitmap = null;
                      _cropController.crop = const Rect.fromLTWH(0, 0, 1, 1);
                    }),
                    child: Text(S.of(context).reset),
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: () => _saveImage(context),
                    child: Text(S.of(context).save),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> _saveImage(BuildContext context) async {
    AutoRouter.of(context).maybePop(
        (await _bitmap?.toByteData(format: ui.ImageByteFormat.png))
            ?.buffer
            .asUint8List());
  }
}
