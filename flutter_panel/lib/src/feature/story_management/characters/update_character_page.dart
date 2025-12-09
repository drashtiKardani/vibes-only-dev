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
import 'package:flutter_panel/src/widget/image_picker_widget.dart';
import 'package:flutter_panel/src/widget/multi_selector_widget.dart';
import 'package:vibes_common/vibes.dart';

import '../../../route/router.gr.dart';

@RoutePage()
class UpdateCharacterPage extends StatefulWidget {
  const UpdateCharacterPage({super.key, @PathParam('id') required this.id});

  final String id;

  @override
  State<UpdateCharacterPage> createState() => _UpdateCharacterPageState();
}

class _UpdateCharacterPageState extends State<UpdateCharacterPage> {
  late final CrudCubit cubit;
  late final _orderTextEditingController = TextEditingController();
  late final TextEditingController _titleTextEditingController;
  late final TextEditingController _bioTextEditingController;
  late final ValueNotifier<Uint8List?> _imageNotifier;
  late final ValueNotifier<bool?> _showOnHomepageNotifier;
  late final ValueNotifier<List<Map<String, dynamic>>> _statusNotifier;
  List<Map<String, dynamic>>? _statusList;

  Character? character;

  bool _titleError = false, _bioError = false, _imageError = false, _orderError = false;

  @override
  void initState() {
    cubit = CrudCubit(api: inject(), uploadApi: inject());
    cubit.getCharacter(widget.id);

    _titleTextEditingController = TextEditingController();
    _bioTextEditingController = TextEditingController();
    _imageNotifier = ValueNotifier<Uint8List?>(null);
    _showOnHomepageNotifier = ValueNotifier(false);
    _statusNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CrudCubit, CrudState>(
        bloc: cubit,
        listener: (blocContext, state) {
          state.maybeWhen(
            getCharacter: (character) async {
              populateStatus(character.status ?? 'approved');
              _orderTextEditingController.text = character.order.toString();
              _titleTextEditingController.text = '${character.firstName ?? ''} ${character.lastName ?? ''}';
              _bioTextEditingController.text = character.bio;
              _showOnHomepageNotifier.value = character.showOnHomepage;
              _imageNotifier.value = await Uri.parse(character.profileImage).asBytes();
              setState(() {});
            },
            successfulCreate: () {
              Navigator.of(context).pop();
              AutoRouter.of(context).replace(const CharactersRoute());
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
              title: strings.editCharacter,
              onResetClickHandler: _resetForm,
              onSubmitClickHandler: _submitForm,
              submitButtonLabel: strings.update,
              children: [
                CustomTextField(
                  controller: _orderTextEditingController,
                  label: strings.order,
                  error: _orderError,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(
                  height: 16,
                ),
                CustomTextField(
                  controller: _titleTextEditingController,
                  label: strings.title,
                  error: _titleError,
                ),
                const SizedBox(
                  height: 16,
                ),
                CustomTextField(
                  controller: _bioTextEditingController,
                  label: strings.bio,
                  error: _bioError,
                  maxLines: 6,
                ),
                const SizedBox(
                  height: 16,
                ),
                ImagePickerWidget(
                  title: strings.image,
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
                  value: _showOnHomepageNotifier.value ?? false,
                  title: strings.showOnHomepage,
                  onChanged: (value) => setState(() {
                    _showOnHomepageNotifier.value = value ?? false;
                  }),
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
    setState(() {
      _imageNotifier.value = null;
      _showOnHomepageNotifier.value = false;
      _statusNotifier.value = [_statusList!.first];
    });
  }

  void _submitForm() async {
    if (_validateFields()) {
      cubit.updateCharacter(
        widget.id,
        _titleTextEditingController.text,
        _bioTextEditingController.text,
        _imageNotifier.value!,
        _showOnHomepageNotifier.value ?? false,
        _statusNotifier.value.first['value'],
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
