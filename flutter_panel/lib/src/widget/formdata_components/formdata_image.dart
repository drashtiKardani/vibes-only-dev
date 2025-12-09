import 'package:flutter/widgets.dart';
import 'package:flutter_panel/src/widget/formdata_components/_formdata_component.dart';
import 'package:vibes_common/vibes.dart';

import '../image_picker_widget.dart';

class FormDataImagePicker extends FormDataComponent<UploadingPhoto?> {
  FormDataImagePicker(
      {required super.label, this.withCircleFrame = false, super.validatingFunction, this.initialValueFuture}) {
    initialValueFuture?.then((value) => _imageNotifier.value = _initialValue = value);
  }

  final bool withCircleFrame;

  /// A more useful alternative to [initialValue],
  /// which is masked here by [_initialValue], and will have the value of this future.
  final Future<UploadingPhoto?>? initialValueFuture;
  UploadingPhoto? _initialValue;

  @override
  UploadingPhoto? get initialValue => _initialValue;

  late final _imageNotifier = ValueNotifier<UploadingPhoto?>(initialValue);

  @override
  Widget get widget {
    return ImagePickerWidget(
      title: label,
      valueController: _imageNotifier,
      error: error,
      withCircleUi: withCircleFrame,
      onChange: (image) {
        _imageNotifier.value = image;
      },
    );
  }

  @override
  void reset() {
    _imageNotifier.value = initialValue;
  }

  @override
  UploadingPhoto? get value => _imageNotifier.value;
}
