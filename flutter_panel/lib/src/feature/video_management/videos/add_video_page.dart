// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_panel/generated/l10n.dart';
import 'package:flutter_panel/src/config/const.dart';
import 'package:flutter_panel/src/cubit/crud/crud_cubit.dart';
import 'package:flutter_panel/src/data/network/panel_api.dart';
import 'package:flutter_panel/src/di/di.dart';
import 'package:flutter_panel/src/enum/file_types.dart';
import 'package:flutter_panel/src/widget/blur_dialog.dart';
import 'package:flutter_panel/src/widget/crud/crud_scaffold.dart';
import 'package:flutter_panel/src/widget/custom_checkbox.dart';
import 'package:flutter_panel/src/widget/custom_text_field.dart';
import 'package:flutter_panel/src/widget/file_picker_widget.dart';
import 'package:flutter_panel/src/widget/formdata_components/formdata_dropdown.dart';
import 'package:flutter_panel/src/widget/image_picker_widget.dart';
import 'package:flutter_panel/src/widget/multi_selector_widget.dart';
import 'package:get_it/get_it.dart';
import 'package:vibes_common/vibes.dart';

import '../../../route/router.gr.dart';
import '../../../widget/formdata_components/formdata_checkbox.dart';
import '../../../widget/formdata_components/formdata_image.dart';

@RoutePage()
class AddVideoPage extends StatefulWidget {
  const AddVideoPage({super.key});

  @override
  State<AddVideoPage> createState() => _AddVideoPageState();
}

class _AddVideoPageState extends State<AddVideoPage> {
  late final CrudCubit cubit;
  late final TextEditingController _titleTextEditingController;
  late final TextEditingController _captionTextEditingController;
  late final TextEditingController _transcriptTextEditingController;
  late final ValueNotifier<List<html.File>> _videoNotifier;
  late final ValueNotifier<Uint8List?> _thumbnailNotifier;
  late final ValueNotifier<List<Map<String, dynamic>>> _relatedChannelNotifier;
  List<Map<String, dynamic>>? relatedChannels;
  late final ValueNotifier<bool?> _premiumContentNotifier;
  final videoCreatorSelector = FormDataDropDown(
    optionsFuture: GetIt.I<VibesPanelApi>().getAllVideoCreators(),
    label: 'Video Creator',
    displayNameOf: (VideoCreator videoCreator) => videoCreator.name,
  );
  final excludeAndroidCheckmark = FormDataCheckbox(
    label: strings.excludeAndroid,
  );

  final isFavoriteCheckbox = FormDataCheckbox(label: strings.isFavorite);
  final isTrendCheckbox = FormDataCheckbox(label: strings.isTrend);
  late final trendImage = FormDataImagePicker(
    label: strings.trendImage,
  );

  bool _titleError = false, _videoFileError = false, _thumbnailError = false, _relatedChannelMissingError = false;

  @override
  void initState() {
    cubit = CrudCubit(api: inject(), uploadApi: inject());
    cubit.getAllChannels(Const.unlimitedRequestLimit, 0);

    _titleTextEditingController = TextEditingController();
    _captionTextEditingController = TextEditingController();
    _transcriptTextEditingController = TextEditingController();
    _videoNotifier = ValueNotifier<List<html.File>>([]);
    _thumbnailNotifier = ValueNotifier<Uint8List?>(null);
    _relatedChannelNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
    _premiumContentNotifier = ValueNotifier<bool?>(null);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CrudCubit, CrudState>(
        bloc: cubit,
        listener: (blocContext, state) {
          state.maybeWhen(
            getAllChannels: (result) {
              setState(() {
                relatedChannels = [];
                for (var video in result.results) {
                  relatedChannels!.add({"display": video.title, "value": video.id.toString()});
                }
              });
            },
            successfulCreate: () {
              Navigator.of(context).pop();
              AutoRouter.of(context).replace(const VideoRoute());
            },
            failure: (e) {
              Navigator.of(context).pop();
            },
            loading: () => showBlurDialog(context, '', 'Wait a moment please', cubit: cubit),
            orElse: (crudState) {},
          );
        },
        child: CrudScaffold(
          title: S.of(context).addNewVideo,
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
            FilePickerWidget(
              title: S.of(context).videoFile,
              valueController: _videoNotifier,
              types: FileTypes.video,
              error: _videoFileError,
              onChange: (files) {
                setState(() {
                  _videoNotifier.value = files;
                });
              },
            ),
            const SizedBox(
              height: 16,
            ),
            videoCreatorSelector.widget,
            const SizedBox(
              height: 16,
            ),
            CustomTextField(
              controller: _transcriptTextEditingController,
              hint: S.of(context).transcript,
              maxLines: 10,
            ),
            const SizedBox(
              height: 16,
            ),
            CustomTextField(
              hint: strings.caption,
              controller: _captionTextEditingController,
              maxLines: 6,
            ),
            const SizedBox(
              height: 16,
            ),
            ImagePickerWidget(
              title: S.of(context).thumbnail,
              valueController: _thumbnailNotifier,
              error: _thumbnailError,
              aspectRatio: 10 / 13,
              onChange: (image) {
                setState(() {
                  _thumbnailNotifier.value = image;
                });
              },
            ),
            const SizedBox(height: 16),
            trendImage.widget,
            const SizedBox(height: 16),
            isTrendCheckbox.widget,
            const SizedBox(height: 16),
            isFavoriteCheckbox.widget,
            const SizedBox(height: 16),
            MultiSelectorWidget(
              title: S.of(context).relatedChannels,
              data: relatedChannels,
              isLoading: relatedChannels == null,
              selected: _relatedChannelNotifier.value,
              error: _relatedChannelMissingError,
              isMultipleSelection: true,
              onChange: (selected) => setState(() {
                _relatedChannelNotifier.value = selected;
              }),
            ),
            const SizedBox(
              height: 16,
            ),
            CustomCheckbox(
              value: _premiumContentNotifier.value ?? false,
              title: S.of(context).premiumContent,
              onChanged: (value) => setState(() {
                _premiumContentNotifier.value = value;
              }),
            ),
            const SizedBox(
              height: 16,
            ),
            excludeAndroidCheckmark.widget,
          ],
        ));
  }

  void _resetForm() {
    _titleTextEditingController.clear();
    videoCreatorSelector.reset();
    trendImage.reset();
    isTrendCheckbox.reset();
    isFavoriteCheckbox.reset();
    excludeAndroidCheckmark.reset();

    setState(() {
      _videoNotifier.value.clear();
      _thumbnailNotifier.value = null;
      _premiumContentNotifier.value = null;
    });
  }

  void _submitForm() async {
    if (_validateFields()) {
      cubit.addVideo(
        _titleTextEditingController.text,
        _thumbnailNotifier.value!,
        _videoNotifier.value.first,
        _relatedChannelNotifier.value.map((e) => e['value']),
        _captionTextEditingController.text,
        _transcriptTextEditingController.text,
        _premiumContentNotifier.value,
        videoCreatorSelector.value,
        trendImage.value,
        isTrendCheckbox.value,
        isFavoriteCheckbox.value,
        excludeAndroidCheckmark.value,
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

    if (_thumbnailNotifier.value == null) {
      setState(() {
        _thumbnailError = true;
      });
      invalidFields++;
    } else {
      setState(() {
        _thumbnailError = false;
      });
    }

    if (_videoNotifier.value.isEmpty) {
      setState(() {
        _videoFileError = true;
      });
      invalidFields++;
    } else {
      setState(() {
        _videoFileError = false;
      });
    }

    if (_relatedChannelNotifier.value.isEmpty) {
      setState(() {
        _relatedChannelMissingError = true;
      });
      invalidFields++;
    } else {
      setState(() {
        _relatedChannelMissingError = false;
      });
    }

    if (invalidFields == 0) {
      return true;
    }

    return false;
  }
}
