import 'dart:typed_data';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_panel/generated/l10n.dart';
import 'package:flutter_panel/src/cubit/crud/crud_cubit.dart';
import 'package:flutter_panel/src/di/di.dart';
import 'package:flutter_panel/src/widget/crud/crud_scaffold.dart';
import 'package:flutter_panel/src/widget/custom_text_field.dart';
import 'package:flutter_panel/src/widget/blur_dialog.dart';
import 'package:flutter_panel/src/widget/image_picker_widget.dart';

import '../../../route/router.gr.dart';

@RoutePage()
class AddChannelPage extends StatefulWidget {
  const AddChannelPage({super.key});

  @override
  State<AddChannelPage> createState() => _AddChannelPageState();
}

class _AddChannelPageState extends State<AddChannelPage> {
  late final CrudCubit cubit;
  late final TextEditingController _titleTextEditingController;
  late final TextEditingController _descTextEditingController;
  late final ValueNotifier<Uint8List?> _imageNotifier;

  bool _titleError = false, _descriptionError = false, _imageError = false;

  @override
  void initState() {
    super.initState();
    cubit = CrudCubit(api: inject(), uploadApi: inject());

    _titleTextEditingController = TextEditingController();
    _descTextEditingController = TextEditingController();
    _imageNotifier = ValueNotifier<Uint8List?>(null);
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
              AutoRouter.of(context).replace(const ChannelRoute());
            },
            loading: () => showBlurDialog(context, '', 'Wait a moment please'),
          );
        },
        child: CrudScaffold(
          title: S.of(context).addNewChannel,
          onResetClickHandler: _resetForm,
          onSubmitClickHandler: _submitForm,
          children: [
            CustomTextField(
              controller: _titleTextEditingController,
              label: S.of(context).title,
              error: _titleError,
            ),
            const SizedBox(
              height: 16,
            ),
            CustomTextField(
              controller: _descTextEditingController,
              hint: S.of(context).description,
              error: _descriptionError,
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
          ],
        ));
  }

  void _resetForm() {
    _titleTextEditingController.clear();
    _descTextEditingController.clear();
    setState(() {
      _imageNotifier.value = null;
    });
  }

  void _submitForm() async {
    if (_validateFields()) {
      cubit.addChannel(_titleTextEditingController.text, _descTextEditingController.text, _imageNotifier.value!);
    }
  }

  bool _validateFields() {
    var invalidFields = 0;

    if (_titleTextEditingController.text.isEmpty) {
      setState(() {
        _titleError = true;
      });
      invalidFields++;
    } else {
      setState(() {
        _titleError = false;
      });
    }

    if (_descTextEditingController.text.isEmpty) {
      setState(() {
        _descriptionError = true;
      });
      invalidFields++;
    } else {
      setState(() {
        _descriptionError = false;
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
