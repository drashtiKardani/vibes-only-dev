import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_panel/src/widget/formdata_components/__group_actions.dart';
import 'package:vibes_common/vibes.dart';

import '../../cubit/crud/crud_cubit.dart';
import '../../di/di.dart';
import '../../widget/blur_dialog.dart';
import '../../widget/crud/crud_scaffold.dart';
import '../../widget/formdata_components/_formdata_component.dart';
import '../../widget/formdata_components/formdata_text.dart';

@RoutePage()
class MiscellaneousPage extends StatefulWidget {
  const MiscellaneousPage({super.key});

  @override
  State<MiscellaneousPage> createState() => _MiscellaneousPageState();
}

class _MiscellaneousPageState extends State<MiscellaneousPage> {
  late final CrudCubit cubit;

  final appleHelpUrl = FormDataTextField(
    label: strings.appleHelpUrl,
    validatingFunction: (name) => name.isNotEmpty,
  );

  final androidHelpUrl = FormDataTextField(
    label: strings.androidHelpUrl,
    validatingFunction: (name) => name.isNotEmpty,
  );

  late final formComponents = <FormDataComponent>[
    appleHelpUrl,
    androidHelpUrl,
  ];

  @override
  void initState() {
    super.initState();
    cubit = CrudCubit(api: inject(), uploadApi: inject());
    cubit.getSettings();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CrudCubit, CrudState>(
      bloc: cubit,
      listener: (context, state) => state.whenOrNull(
        loading: () => showBlurDialog(context, '', 'Wait a moment please'),
        successfulCreate: () {
          Navigator.pop(context);
          return showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: const Text('Settings Update.'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
              ],
            ),
          );
        },
        getSettings: (data) {
          appleHelpUrl.lateInitialValue = data.appleHelpUrl;
          androidHelpUrl.lateInitialValue = data.androidHelpUrl;
          return null;
        },
      ),
      child: CrudScaffold(
        showBackButton: false,
        title: strings.miscellaneous,
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
      final settings = HelpUrls(
        appleHelpUrl: appleHelpUrl.value,
        androidHelpUrl: androidHelpUrl.value,
      );
      cubit.updateSettings(settings);
    }
  }

  bool _validateFields() {
    final valid = formComponents.validate();
    setState(() {});
    return valid;
  }
}
