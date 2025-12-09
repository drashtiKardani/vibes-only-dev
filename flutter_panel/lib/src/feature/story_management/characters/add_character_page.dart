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

@RoutePage()
class AddCharacterPage extends StatefulWidget {
  const AddCharacterPage({super.key});

  @override
  State<AddCharacterPage> createState() => _AddCharacterPageState();
}

class _AddCharacterPageState extends State<AddCharacterPage> {
  late final CrudCubit cubit;

  late final _orderTextEditingController = TextEditingController();
  late final TextEditingController _nameTextEditingController;

  late final TextEditingController _bioTextEditingController;

  late final ValueNotifier<Uint8List?> _imageNotifier;

  late final ValueNotifier<bool> _showOnHomepageNotifier;

  bool _nameError = false, _bioError = false, _imageError = false, _orderError = false;

  @override
  void initState() {
    cubit = CrudCubit(api: inject(), uploadApi: inject());

    _nameTextEditingController = TextEditingController();
    _bioTextEditingController = TextEditingController();
    _imageNotifier = ValueNotifier<Uint8List?>(null);
    _showOnHomepageNotifier = ValueNotifier(false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CrudCubit, CrudState>(
        bloc: cubit,
        listener: (blocContext, state) {
          state.maybeWhen(
            failure: (e) {
              Navigator.of(context).pop();
            },
            successfulCreate: () {
              Navigator.of(context).pop();
              AutoRouter.of(context).replace(const CharactersRoute());
            },
            loading: () => showBlurDialog(context, '', 'Wait a moment please'),
            orElse: (crudState) {},
          );
        },
        child: CrudScaffold(
          title: S.of(context).addNewCharacter,
          onResetClickHandler: _resetForm,
          onSubmitClickHandler: _submitForm,
          children: [
            CustomTextField(
              controller: _orderTextEditingController,
              label: S.of(context).order,
              error: _orderError,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(
              height: 16,
            ),
            CustomTextField(
              controller: _nameTextEditingController,
              label: S.of(context).name,
              error: _nameError,
            ),
            const SizedBox(
              height: 16,
            ),
            CustomTextField(
              controller: _bioTextEditingController,
              hint: S.of(context).bio,
              error: _bioError,
              maxLines: 6,
            ),
            const SizedBox(
              height: 16,
            ),
            ImagePickerWidget(
              title: S.of(context).image,
              valueController: _imageNotifier,
              error: _imageError,
              withCircleUi: true,
              onChange: (image) {
                setState(() {
                  _imageNotifier.value = image;
                });
              },
            ),
            const SizedBox(
              height: 16,
            ),
            CustomCheckbox(
              value: _showOnHomepageNotifier.value,
              title: strings.showOnHomepage,
              onChanged: (value) => setState(() {
                _showOnHomepageNotifier.value = value ?? false;
              }),
            ),
          ],
        ));
  }

  void _resetForm() {
    _orderTextEditingController.clear();
    _nameTextEditingController.clear();
    _bioTextEditingController.clear();
    setState(() {
      _imageNotifier.value = null;
      _showOnHomepageNotifier.value = false;
    });
  }

  void _submitForm() async {
    if (_validateFields()) {
      cubit.addCharacter(
        _nameTextEditingController.text,
        _bioTextEditingController.text,
        _imageNotifier.value!,
        _showOnHomepageNotifier.value,
        _orderTextEditingController.text,
      );
    }
  }

  bool _validateFields() {
    var invalidFields = 0;

    if (_orderTextEditingController.text.isEmpty) {
      setState(() {
        _orderError = true;
      });
      invalidFields++;
    } else {
      setState(() {
        _orderError = false;
      });
    }

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

    if (_bioTextEditingController.text.isEmpty) {
      setState(() {
        _bioError = true;
      });
      invalidFields++;
    } else {
      setState(() {
        _bioError = false;
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
