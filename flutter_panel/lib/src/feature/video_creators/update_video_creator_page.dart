import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_panel/src/cubit/crud/crud_cubit.dart';
import 'package:flutter_panel/src/di/di.dart';
import 'package:flutter_panel/src/extension/file_extension.dart';
import 'package:flutter_panel/src/widget/blur_dialog.dart';
import 'package:flutter_panel/src/widget/crud/crud_scaffold.dart';
import 'package:flutter_panel/src/widget/formdata_components/__group_actions.dart';
import 'package:vibes_common/vibes.dart';

import '../../route/router.gr.dart';
import '../../widget/formdata_components/_formdata_component.dart';
import '../../widget/formdata_components/formdata_checkbox.dart';
import '../../widget/formdata_components/formdata_image.dart';
import '../../widget/formdata_components/formdata_text.dart';

@RoutePage()
class UpdateVideoCreatorPage extends StatefulWidget {
  final VideoCreator videoCreator;

  const UpdateVideoCreatorPage({super.key, required this.videoCreator});

  @override
  State<UpdateVideoCreatorPage> createState() => _UpdateVideoCreatorPageState();
}

class _UpdateVideoCreatorPageState extends State<UpdateVideoCreatorPage> {
  late final editableName = FormDataTextField(
    label: strings.name,
    initialValue: widget.videoCreator.name,
    validatingFunction: (name) => name.isNotEmpty,
  );
  late final editablePhoto = FormDataImagePicker(
    label: strings.photo,
    initialValueFuture: Uri.parse(widget.videoCreator.photo).asBytes(),
    validatingFunction: (photo) => photo != null,
    withCircleFrame: true,
  );
  late final editableOrder = FormDataTextField(
    label: strings.order,
    initialValue: widget.videoCreator.order.toString(),
    keyboardType: TextInputType.number,
    errorMessage: 'Leave it empty or enter an integer',
    validatingFunction: (order) => order.isEmpty || int.tryParse(order) != null,
  );
  late final editableBio = FormDataTextField(
    label: strings.bio,
    initialValue: widget.videoCreator.bio,
  );
  late final editableIsStaffChoice = FormDataCheckbox(
    label: strings.isStaffChoice,
    initialValue: widget.videoCreator.isStaffChoice,
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
        title: strings.updateVideoCreator,
        submitButtonLabel: strings.update,
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
        ..photo =
            (editablePhoto.value != editablePhoto.initialValue ? editablePhoto.value : null) // prevent re-uploading
        ..order = int.tryParse(editableOrder.value)
        ..bio = editableBio.value
        ..isStaffChoice = editableIsStaffChoice.value;

      cubit.updateVideoCreator(widget.videoCreator.id, videoCreator);
    }
  }

  bool _validateFields() {
    final valid = formComponents.validate();
    setState(() {});
    return valid;
  }
}
