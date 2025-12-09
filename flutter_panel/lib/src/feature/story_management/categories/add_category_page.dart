import 'dart:typed_data';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_panel/generated/l10n.dart';
import 'package:flutter_panel/src/cubit/crud/crud_cubit.dart';
import 'package:flutter_panel/src/di/di.dart';
import 'package:flutter_panel/src/widget/blur_dialog.dart';
import 'package:flutter_panel/src/widget/crud/crud_scaffold.dart';
import 'package:flutter_panel/src/widget/custom_checkbox.dart';
import 'package:flutter_panel/src/widget/custom_text_field.dart';
import 'package:flutter_panel/src/widget/image_picker_widget.dart';

import '../../../route/router.gr.dart';
import '../../../widget/formdata_components/formdata_image.dart';

@RoutePage()
class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({super.key});

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  late final CrudCubit cubit;

  late final TextEditingController _nameTextEditingController;

  late final ValueNotifier<bool?> _tileModeNotifier;

  late final ValueNotifier<Uint8List?> _imageNotifier;

  final androidImage = FormDataImagePicker(
    label: strings.androidImage,
  );

  bool _nameError = false, _imageError = false;

  @override
  void initState() {
    cubit = CrudCubit(api: inject(), uploadApi: inject());

    _nameTextEditingController = TextEditingController();
    _tileModeNotifier = ValueNotifier<bool?>(null);
    _imageNotifier = ValueNotifier<Uint8List?>(null);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CrudCubit, CrudState>(
        bloc: cubit,
        listener: (blocContext, state) {
          state.whenOrNull(
            failure: (e) {
              Navigator.of(context).pop();
            },
            successfulCreate: () {
              Navigator.of(context).pop();
              AutoRouter.of(context).replace(const CategoriesRoute());
            },
            loading: () => showBlurDialog(context, '', 'Wait a moment please'),
          );
        },
        child: CrudScaffold(
          title: S.of(context).addNewCategory,
          onResetClickHandler: _resetForm,
          onSubmitClickHandler: _submitForm,
          children: [
            CustomTextField(
              controller: _nameTextEditingController,
              label: S.of(context).name,
              error: _nameError,
            ),
            const SizedBox(
              height: 16,
            ),
            CustomCheckbox(
              value: _tileModeNotifier.value ?? false,
              title: S.of(context).tileMode,
              onChanged: (value) => setState(() {
                _tileModeNotifier.value = value;
              }),
            ),
            const SizedBox(
              height: 16,
            ),
            ImagePickerWidget(
              title: S.of(context).image,
              valueController: _imageNotifier,
              error: _imageError,
              aspectRatio: 3 / 2,
              onChange: (image) {
                setState(() {
                  _imageNotifier.value = image;
                });
              },
            ),
            const SizedBox(
              height: 16,
            ),
            androidImage.widget,
            const SizedBox(
              height: 16,
            ),
          ],
        ));
  }

  void _resetForm() {
    _nameTextEditingController.clear();
    androidImage.reset();
    setState(() {
      _imageNotifier.value = null;
      _tileModeNotifier.value = false;
    });
  }

  void _submitForm() async {
    if (_validateFields()) {
      cubit.addCategory(
          _nameTextEditingController.text, _tileModeNotifier.value ?? false, _imageNotifier.value!, androidImage.value);
    }
  }

  bool _validateFields() {
    var invalidFields = 0;

    if (_nameTextEditingController.text.isEmpty) {
      setState(() {
        _nameError = true;
      });
      invalidFields++;
    } else {
      setState(() {
        _nameError = false;
      });
    }

    if (_imageNotifier.value == null) {
      setState(() {
        _imageError = true;
      });
      invalidFields++;
    } else {
      setState(() {
        _imageError = false;
      });
    }

    if (invalidFields == 0) {
      return true;
    }

    return false;
  }
}
