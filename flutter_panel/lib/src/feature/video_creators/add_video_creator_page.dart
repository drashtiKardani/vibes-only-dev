import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart' hide EditableText;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_panel/src/cubit/crud/crud_cubit.dart';
import 'package:flutter_panel/src/di/di.dart';
import 'package:flutter_panel/src/widget/blur_dialog.dart';
import 'package:flutter_panel/src/widget/crud/crud_scaffold.dart';
import 'package:flutter_panel/src/widget/formdata_components/__group_actions.dart';
import 'package:flutter_panel/src/widget/formdata_components/_formdata_component.dart';
import 'package:flutter_panel/src/widget/formdata_components/formdata_checkbox.dart';
import 'package:flutter_panel/src/widget/formdata_components/formdata_image.dart';
import 'package:flutter_panel/src/widget/formdata_components/formdata_text.dart';
import 'package:vibes_common/vibes.dart';

import '../../route/router.gr.dart';

@RoutePage()
class AddVideoCreatorPage extends StatefulWidget {
  const AddVideoCreatorPage({super.key});

  @override
  State<AddVideoCreatorPage> createState() => _AddVideoCreatorPageState();
}

class _AddVideoCreatorPageState extends State<AddVideoCreatorPage> {
  final editableName = FormDataTextField(
    label: strings.name,
    validatingFunction: (name) => name.isNotEmpty,
  );
  late final editablePhoto = FormDataImagePicker(
    label: strings.photo,
    validatingFunction: (photo) => photo != null,
    withCircleFrame: true,
  );
  final editableOrder = FormDataTextField(
    label: strings.order,
    keyboardType: TextInputType.number,
    errorMessage: 'Leave it empty or enter an integer',
    validatingFunction: (order) => order.isEmpty || int.tryParse(order) != null,
  );
  final editableBio = FormDataTextField(
    label: strings.bio,
  );
  late final editableIsStaffChoice = FormDataCheckbox(
    label: strings.isStaffChoice,
  );

  late final formComponents = <FormDataComponent>[
    editableName,
    editablePhoto,
    editableOrder,
    editableBio,
    editableIsStaffChoice,
  ];

  late final CrudCubit cubit;

  @override
  void initState() {
    super.initState();
    cubit = CrudCubit(api: inject(), uploadApi: inject());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CrudCubit, CrudState>(
      bloc: cubit,
      listener: (BuildContext context, state) {
        state.whenOrNull(
          loading: () => showBlurDialog(context, '', 'Wait a moment please'),
          successfulCreate: () {
            Navigator.of(context).pop();
            AutoRouter.of(context).replace(const VideoCreatorsRoute());
          },
          failure: (e) {
            Navigator.of(context).pop();
          },
        );
      },
      child: CrudScaffold(
        title: strings.addNewVideoCreator,
        submitButtonLabel: strings.add,
        onResetClickHandler: _resetForm,
        onSubmitClickHandler: _submitForm,
        children: formComponents.placeInCrudScaffold(),
      ),
    );
  }

  void _resetForm() {
    formComponents.reset();
  }

  void _submitForm() async {
    if (_validateFields()) {
      final videoCreator = UpdatingVideoCreator()
        ..name = editableName.value
        ..photo = editablePhoto.value
        ..order = int.tryParse(editableOrder.value)
        ..bio = editableBio.value
        ..isStaffChoice = editableIsStaffChoice.value;

      cubit.addVideoCreator(videoCreator);
    }
  }

  bool _validateFields() {
    final valid = formComponents.validate();
    setState(() {});
    return valid;
  }
}
