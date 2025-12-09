import 'dart:typed_data';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_panel/src/cubit/crud/crud_cubit.dart';
import 'package:flutter_panel/src/di/di.dart';
import 'package:flutter_panel/src/extension/file_extension.dart';
import 'package:flutter_panel/src/widget/blur_dialog.dart';
import 'package:flutter_panel/src/widget/crud/crud_scaffold.dart';
import 'package:flutter_panel/src/widget/custom_text_field.dart';
import 'package:flutter_panel/src/widget/date_select_widget.dart';
import 'package:flutter_panel/src/widget/image_picker_widget.dart';
import 'package:vibes_common/vibes.dart';

import '../../../route/router.gr.dart';

@RoutePage()
class UpdateChannelPage extends StatefulWidget {
  const UpdateChannelPage({super.key, @PathParam('id') required this.id});

  final String id;

  @override
  State<UpdateChannelPage> createState() => _UpdateChannelPageState();
}

class _UpdateChannelPageState extends State<UpdateChannelPage> {
  late final CrudCubit cubit;
  late final TextEditingController _titleTextEditingController;
  late final TextEditingController _descriptionTextEditingController;
  late final ValueNotifier<Uint8List?> _imageNotifier;
  final ValueNotifier<DateTime?> _publishDateNotifier = ValueNotifier<DateTime?>(null);
  late final DateTime? _channelPublishDate;

  Channel? channel;

  bool _titleError = false, _descriptionError = false, _imageError = false;

  @override
  void initState() {
    cubit = CrudCubit(api: inject(), uploadApi: inject());
    cubit.getChannel(widget.id);

    _titleTextEditingController = TextEditingController();
    _descriptionTextEditingController = TextEditingController();
    _imageNotifier = ValueNotifier<Uint8List?>(null);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CrudCubit, CrudState>(
        bloc: cubit,
        listener: (blocContext, state) {
          state.maybeWhen(
            getChannel: (channel) async {
              _titleTextEditingController.text = channel.title;
              _descriptionTextEditingController.text = channel.description ?? '';
              _channelPublishDate = _publishDateNotifier.value = channel.publishDate;
              if (channel.image != null) {
                _imageNotifier.value = await Uri.parse(channel.image!).asBytes();
              }
              setState(() {});
            },
            successfulCreate: () {
              Navigator.of(context).pop();
              AutoRouter.of(context).replace(const ChannelRoute());
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
              title: strings.editChannel,
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
                CustomTextField(
                  controller: _descriptionTextEditingController,
                  label: strings.description,
                  error: _descriptionError,
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
                DateSelectWidget(
                  title: strings.publishDate,
                  selectedDateNotifier: _publishDateNotifier,
                ),
                const SizedBox(
                  height: 16,
                ),
              ],
            ));
  }

  void _resetForm() {
    _titleTextEditingController.clear();
    _descriptionTextEditingController.clear();
    _publishDateNotifier.value = _channelPublishDate;
    setState(() {
      _imageNotifier.value = null;
    });
  }

  void _submitForm() async {
    if (_validateFields()) {
      cubit.updateChannel(
        widget.id,
        _titleTextEditingController.text,
        _descriptionTextEditingController.text,
        _imageNotifier.value!,
        _publishDateNotifier.value
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

    if (_descriptionTextEditingController.text.isEmpty) {
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
