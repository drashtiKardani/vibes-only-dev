import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_panel/generated/l10n.dart';
import 'package:flutter_panel/src/config/const.dart';
import 'package:flutter_panel/src/cubit/crud/crud_cubit.dart';
import 'package:flutter_panel/src/di/di.dart';
import 'package:flutter_panel/src/widget/blur_dialog.dart';
import 'package:flutter_panel/src/widget/crud/crud_scaffold.dart';
import 'package:flutter_panel/src/widget/custom_text_field.dart';
import 'package:string_validator/string_validator.dart';

import '../../route/router.gr.dart';

@RoutePage()
class AddStaffPage extends StatefulWidget {
  const AddStaffPage({super.key});

  @override
  State<AddStaffPage> createState() => _AddStaffPageState();
}

class _AddStaffPageState extends State<AddStaffPage> {
  late final CrudCubit cubit;
  late final TextEditingController _firstNameTextEditingController;
  late final TextEditingController _lastNameTextEditingController;
  late final TextEditingController _emailTextEditingController;
  late final TextEditingController _passwordTextEditingController;
  late final TextEditingController _phoneNumberTextEditingController;

  bool _firstNameError = false,
      _lastNameError = false,
      _emailError = false,
      _phoneNumberError = false,
      _passwordError = false;

  @override
  void initState() {
    cubit = CrudCubit(api: inject(), uploadApi: inject());
    cubit.getAllChannels(Const.unlimitedRequestLimit, 0);

    _firstNameTextEditingController = TextEditingController();
    _lastNameTextEditingController = TextEditingController();
    _emailTextEditingController = TextEditingController();
    _passwordTextEditingController = TextEditingController();
    _phoneNumberTextEditingController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CrudCubit, CrudState>(
        bloc: cubit,
        listener: (blocContext, state) {
          state.maybeWhen(
            successfulCreate: () {
              Navigator.of(context).pop();
              AutoRouter.of(context).replace(const StaffRoute());
            },
            failure: (e) {
              Navigator.of(context).pop();
            },
            loading: () => showBlurDialog(context, '', 'Wait a moment please'),
            orElse: (crudState) {},
          );
        },
        child: CrudScaffold(
          title: S.of(context).addNewStaff,
          onResetClickHandler: _resetForm,
          onSubmitClickHandler: _submitForm,
          children: [
            CustomTextField(
              controller: _firstNameTextEditingController,
              label: S.of(context).firstName,
              error: _firstNameError,
            ),
            const SizedBox(
              height: 16,
            ),
            CustomTextField(
              controller: _lastNameTextEditingController,
              label: S.of(context).lastName,
              error: _lastNameError,
            ),
            const SizedBox(
              height: 16,
            ),
            CustomTextField(
              controller: _emailTextEditingController,
              label: S.of(context).email,
              error: _emailError,
            ),
            const SizedBox(
              height: 16,
            ),
            CustomTextField(
              controller: _phoneNumberTextEditingController,
              label: S.of(context).phoneNumber,
              error: _phoneNumberError,
            ),
            const SizedBox(
              height: 16,
            ),
            CustomTextField(
              controller: _passwordTextEditingController,
              label: S.of(context).password,
              error: _passwordError,
            ),
            const SizedBox(
              height: 16,
            ),
          ],
        ));
  }

  void _resetForm() {
    _firstNameTextEditingController.clear();
    _lastNameTextEditingController.clear();
    _emailTextEditingController.clear();
    _passwordTextEditingController.clear();
    _phoneNumberTextEditingController.clear();
  }

  void _submitForm() async {
    if (_validateFields()) {
      cubit.addStaff(
          _firstNameTextEditingController.text,
          _lastNameTextEditingController.text,
          _emailTextEditingController.text,
          _passwordTextEditingController.text,
          _phoneNumberTextEditingController.text);
    }
  }

  bool _validateFields() {
    var invalidFields = 0;

    if (_firstNameTextEditingController.text.isEmpty) {
      setState(() {
        _firstNameError = true;
      });
      invalidFields++;
    } else {
      setState(() {
        _firstNameError = false;
      });
    }
    if (_lastNameTextEditingController.text.isEmpty) {
      setState(() {
        _lastNameError = true;
      });
      invalidFields++;
    } else {
      setState(() {
        _lastNameError = false;
      });
    }
    if (_emailTextEditingController.text.isEmpty) {
      if (isEmail(_emailTextEditingController.text.trim())) {
        setState(() {
          _emailError = true;
        });
        invalidFields++;
      }
    } else {
      setState(() {
        _emailError = false;
      });
    }
    if (_passwordTextEditingController.text.isEmpty) {
      setState(() {
        _passwordError = true;
      });
      invalidFields++;
    } else {
      setState(() {
        _passwordError = false;
      });
    }
    if (_phoneNumberTextEditingController.text.isEmpty) {
      if (isNumeric(_phoneNumberTextEditingController.text.trim())) {
        setState(() {
          _phoneNumberError = true;
        });
        invalidFields++;
      }
    } else {
      setState(() {
        _phoneNumberError = false;
      });
    }

    if (invalidFields == 0) {
      return true;
    }

    return false;
  }
}
