import 'dart:typed_data';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_panel/src/cubit/crud/crud_cubit.dart';
import 'package:flutter_panel/src/di/di.dart';
import 'package:flutter_panel/src/widget/blur_dialog.dart';
import 'package:flutter_panel/src/widget/crud/crud_scaffold.dart';
import 'package:flutter_panel/src/widget/custom_checkbox.dart';
import 'package:flutter_panel/src/widget/custom_text_field.dart';
import 'package:flutter_panel/src/widget/image_picker_widget.dart';

import '../../route/router.gr.dart';

@RoutePage()
class AddDeviceOrCommodityPage extends StatefulWidget {
  const AddDeviceOrCommodityPage({super.key});

  @override
  State<AddDeviceOrCommodityPage> createState() =>
      _AddDeviceOrCommodityPageState();
}

class _AddDeviceOrCommodityPageState extends State<AddDeviceOrCommodityPage> {
  final _orderTextEditingController = TextEditingController();
  final _nameTextEditingController = TextEditingController();
  final _bluetoothNameTextEditingController = TextEditingController();
  final _motor1NameTextEditingController = TextEditingController();
  final _motor2NameTextEditingController = TextEditingController();
  final _shopUrlTextEditingController = TextEditingController();
  final _numberOfMotorsTextEditingController = TextEditingController();
  final _shopImageNotifier = ValueNotifier<Uint8List?>(null);
  final _controllerImageNotifier = ValueNotifier<Uint8List?>(null);
  final _isToyNotifier = ValueNotifier(false);

  bool _orderError = false,
      _nameError = false,
      _numberOfMotorsError = false,
      _shopImageError = false;

  final bool _bluetoothNameError = false,
      _shopUrlError = false,
      _controllerImageError = false;

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
            AutoRouter.of(context).replace(const DevicesAndCommoditiesRoute());
          },
          failure: (e) {
            Navigator.of(context).pop();
          },
        );
      },
      child: CrudScaffold(
        title: strings.addNewDeviceOrCommodity,
        submitButtonLabel: strings.add,
        onResetClickHandler: _resetForm,
        onSubmitClickHandler: _submitForm,
        children: [
          CustomTextField(
            controller: _orderTextEditingController,
            label: strings.order,
            keyboardType: TextInputType.number,
            error: _orderError,
            errorMessage: 'Leave it empty or enter an integer',
          ),
          const SizedBox(
            height: 16,
          ),
          CustomTextField(
            controller: _nameTextEditingController,
            label: strings.name,
            error: _nameError,
          ),
          const SizedBox(
            height: 16,
          ),
          CustomTextField(
            controller: _bluetoothNameTextEditingController,
            label: strings.bluetoothName,
            error: _bluetoothNameError,
          ),
          const SizedBox(
            height: 16,
          ),
          CustomTextField(
            controller: _motor1NameTextEditingController,
            label: strings.motor1Name,
          ),
          const SizedBox(
            height: 16,
          ),
          CustomTextField(
            controller: _motor2NameTextEditingController,
            label: strings.motor2Name,
          ),
          const SizedBox(
            height: 16,
          ),
          CustomTextField(
            controller: _shopUrlTextEditingController,
            label: strings.shopUrl,
            hint: 'https://example.com',
            error: _shopUrlError,
            maxLines: 2,
          ),
          const SizedBox(
            height: 16,
          ),
          CustomTextField(
            controller: _numberOfMotorsTextEditingController,
            label: strings.numberOfMotors,
            keyboardType: TextInputType.number,
            error: _numberOfMotorsError,
            errorMessage: 'Leave it empty or enter either 1 or 2',
          ),
          const SizedBox(
            height: 16,
          ),
          ImagePickerWidget(
            title: strings.shopPicture,
            valueController: _shopImageNotifier,
            error: _shopImageError,
            withCircleUi: true,
            onChange: (image) {
              setState(() {
                _shopImageNotifier.value = image;
              });
            },
          ),
          const SizedBox(
            height: 16,
          ),
          ImagePickerWidget(
            title: strings.controllerPicture,
            valueController: _controllerImageNotifier,
            error: _controllerImageError,
            withCircleUi: true,
            onChange: (image) {
              setState(() {
                _controllerImageNotifier.value = image;
              });
            },
          ),
          const SizedBox(
            height: 16,
          ),
          CustomCheckbox(
            value: _isToyNotifier.value,
            title: strings.isToy,
            onChanged: (value) => setState(() {
              _isToyNotifier.value = value ?? false;
            }),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    _orderTextEditingController.clear();
    _nameTextEditingController.clear();
    _bluetoothNameTextEditingController.clear();
    _motor1NameTextEditingController.clear();
    _motor2NameTextEditingController.clear();
    _shopUrlTextEditingController.clear();
    _numberOfMotorsTextEditingController.clear();
    _shopImageNotifier.value = null;
    _controllerImageNotifier.value = null;
    _isToyNotifier.value = false;
  }

  void _submitForm() async {
    if (_validateFields()) {
      cubit.addCommodity(
        order: int.tryParse(_orderTextEditingController.text),
        name: _nameTextEditingController.text,
        bluetoothName: _bluetoothNameTextEditingController.text,
        motor1Name: _motor1NameTextEditingController.text,
        motor2Name: _motor2NameTextEditingController.text,
        shopUrl: _shopUrlTextEditingController.text,
        numberOfMotors: int.tryParse(_numberOfMotorsTextEditingController.text),
        shopImage: _shopImageNotifier.value!,
        controllerImage: _controllerImageNotifier.value,
        isToy: _isToyNotifier.value,
      );
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

    if (_orderTextEditingController.text.isNotEmpty &&
        int.tryParse(_orderTextEditingController.text) == null) {
      setState(() {
        _orderError = true;
      });
      invalidFields++;
    } else {
      setState(() {
        _orderError = false;
      });
    }

    if (_numberOfMotorsTextEditingController.text.isNotEmpty &&
        (int.tryParse(_numberOfMotorsTextEditingController.text) == null ||
            int.parse(_numberOfMotorsTextEditingController.text) < 1 ||
            int.parse(_numberOfMotorsTextEditingController.text) > 2)) {
      setState(() {
        _numberOfMotorsError = true;
      });
      invalidFields++;
    } else {
      setState(() {
        _numberOfMotorsError = false;
      });
    }

    if (_shopImageNotifier.value == null) {
      setState(() {
        _shopImageError = true;
      });
      invalidFields++;
    } else {
      setState(() {
        _shopImageError = false;
      });
    }

    if (invalidFields == 0) {
      return true;
    }

    return false;
  }
}
