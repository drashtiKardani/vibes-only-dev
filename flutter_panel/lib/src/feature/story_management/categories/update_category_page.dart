import 'dart:async';
import 'dart:typed_data';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_panel/src/cubit/crud/crud_cubit.dart';
import 'package:flutter_panel/src/di/di.dart';
import 'package:flutter_panel/src/extension/file_extension.dart';
import 'package:flutter_panel/src/widget/blur_dialog.dart';
import 'package:flutter_panel/src/widget/crud/crud_scaffold.dart';
import 'package:flutter_panel/src/widget/custom_checkbox.dart';
import 'package:flutter_panel/src/widget/custom_text_field.dart';
import 'package:flutter_panel/src/widget/date_select_widget.dart';
import 'package:flutter_panel/src/widget/image_picker_widget.dart';
import 'package:flutter_panel/src/widget/multi_selector_widget.dart';
import 'package:vibes_common/vibes.dart';

import '../../../route/router.gr.dart';
import '../../../widget/formdata_components/formdata_image.dart';

@RoutePage()
class UpdateCategoryPage extends StatefulWidget {
  const UpdateCategoryPage({super.key, @PathParam('id') required this.id});

  final String id;

  @override
  State<UpdateCategoryPage> createState() => _UpdateCategoryPageState();
}

class _UpdateCategoryPageState extends State<UpdateCategoryPage> {
  late final CrudCubit cubit;
  late final TextEditingController _titleTextEditingController;
  late final ValueNotifier<bool?> _tileModeNotifier;
  late final ValueNotifier<Uint8List?> _imageNotifier;
  late final ValueNotifier<List<Map<String, dynamic>>> _statusNotifier;
  final ValueNotifier<DateTime?> _publishDateNotifier = ValueNotifier<DateTime?>(null);
  late final DateTime? _categoryPublishDate;
  List<Map<String, dynamic>>? _statusList;

  final Completer<String?> androidImageCompleter = Completer();
  late final androidImage = FormDataImagePicker(
    label: strings.androidImage,
    initialValueFuture: androidImageCompleter.future.then((url) => url == null ? null : Uri.parse(url).asBytes()),
  );

  Category? category;

  bool _titleError = false, _imageError = false;

  @override
  void initState() {
    cubit = CrudCubit(api: inject(), uploadApi: inject());
    cubit.getCategory(widget.id);

    _titleTextEditingController = TextEditingController();
    _tileModeNotifier = ValueNotifier<bool?>(null);
    _imageNotifier = ValueNotifier<Uint8List?>(null);
    _statusNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CrudCubit, CrudState>(
        bloc: cubit,
        listener: (blocContext, state) {
          state.maybeWhen(
            getCategory: (category) async {
              populateStatus(category.status ?? 'approved');
              _titleTextEditingController.text = category.title;
              _tileModeNotifier.value = category.tileView;
              _categoryPublishDate = _publishDateNotifier.value = category.publishDate;
              if (category.image != null) {
                _imageNotifier.value = await Uri.parse(category.image!).asBytes();
              }
              androidImageCompleter.complete(category.androidImage);
              setState(() {});
            },
            successfulCreate: () {
              Navigator.of(context).pop();
              AutoRouter.of(context).replace(const CategoriesRoute());
            },
            failure: (e) {
              Navigator.of(context).pop();
            },
            loading: () => showBlurDialog(context, '', 'Wait a moment please'),
            orElse: (crudState) {},
          );
        },
        builder: (context, state) => CrudScaffold(
              isLoading: state.isLoading,
              title: strings.editCategory,
              onResetClickHandler: _resetForm,
              onSubmitClickHandler: _submitForm,
              submitButtonLabel: strings.update,
              children: [
                CustomTextField(
                  controller: _titleTextEditingController,
                  label: strings.title,
                  error: _titleError,
                ),
                const SizedBox(
                  height: 16,
                ),
                CustomCheckbox(
                  value: _tileModeNotifier.value ?? false,
                  title: strings.tileMode,
                  onChanged: (value) => setState(() {
                    _tileModeNotifier.value = value;
                  }),
                ),
                const SizedBox(
                  height: 16,
                ),
                ImagePickerWidget(
                  title: strings.image,
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
                DateSelectWidget(
                  title: strings.publishDate,
                  selectedDateNotifier: _publishDateNotifier,
                ),
                const SizedBox(
                  height: 16,
                ),
                MultiSelectorWidget(
                  title: strings.status,
                  data: _statusList,
                  isLoading: _statusList == null,
                  selected: _statusNotifier.value,
                  onChange: (selected) => setState(() {
                    if (selected.isNotEmpty) _statusNotifier.value = selected;
                  }),
                )
              ],
            ));
  }

  void populateStatus(String status) {
    _statusList = [
      {"display": strings.simulator, "value": 'approved'},
      {"display": strings.production, "value": 'published'},
    ];
    _statusNotifier.value = [_statusList!.first];
    // ignore: no_leading_underscores_for_local_identifiers
    for (var _status in _statusList!) {
      if (_status['value'] == status) {
        _statusNotifier.value = [_status];
      }
    }
  }

  void _resetForm() {
    _titleTextEditingController.clear();
    _publishDateNotifier.value = _categoryPublishDate;
    androidImage.reset();
    setState(() {
      _imageNotifier.value = null;
      _statusNotifier.value = [_statusList!.first];
    });
  }

  void _submitForm() async {
    if (_validateFields()) {
      cubit.updateCategory(
        widget.id,
        _titleTextEditingController.text,
        _tileModeNotifier.value ?? false,
        _imageNotifier.value!,
        _statusNotifier.value.first['value'],
        _publishDateNotifier.value,
        androidImage.value,
      );
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
