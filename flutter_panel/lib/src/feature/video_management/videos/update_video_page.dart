// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_panel/generated/l10n.dart';
import 'package:flutter_panel/src/config/const.dart';
import 'package:flutter_panel/src/cubit/crud/crud_cubit.dart';
import 'package:flutter_panel/src/di/di.dart';
import 'package:flutter_panel/src/enum/file_types.dart';
import 'package:flutter_panel/src/extension/file_extension.dart';
import 'package:flutter_panel/src/feature/util/flag_utility.dart';
import 'package:flutter_panel/src/widget/blur_dialog.dart';
import 'package:flutter_panel/src/widget/crud/crud_scaffold.dart';
import 'package:flutter_panel/src/widget/custom_checkbox.dart';
import 'package:flutter_panel/src/widget/custom_text_field.dart';
import 'package:flutter_panel/src/widget/date_select_widget.dart';
import 'package:flutter_panel/src/widget/file_picker_widget.dart';
import 'package:flutter_panel/src/widget/formdata_components/formdata_dropdown.dart';
import 'package:flutter_panel/src/widget/image_picker_widget.dart';
import 'package:flutter_panel/src/widget/multi_selector_widget.dart';
import 'package:vibes_common/vibes.dart';

import '../../../route/router.gr.dart';
import '../../../widget/formdata_components/formdata_checkbox.dart';
import '../../../widget/formdata_components/formdata_image.dart';

@RoutePage()
class UpdateVideoPage extends StatefulWidget {
  const UpdateVideoPage({super.key, @PathParam('id') required this.id});

  final String id;

  @override
  State<UpdateVideoPage> createState() => _UpdateVideoPageState();
}

class _UpdateVideoPageState extends State<UpdateVideoPage> with FlagUtility {
  late final CrudCubit cubit;
  late final TextEditingController _titleTextEditingController;
  late final TextEditingController _captionTextEditingController;
  late final TextEditingController _transcriptTextEditingController;
  late final ValueNotifier<List<html.File>> _videoNotifier;
  late final ValueNotifier<Uint8List?> _thumbnailNotifier;
  final ValueNotifier<DateTime?> _publishDateNotifier =
      ValueNotifier<DateTime?>(null);
  late final DateTime? _videoPublishDate;

  /// Lets us complete the future later in the [BlocConsumer] (see `build()` method below).
  final Completer<List<VideoCreator>> videoCreatorsCompleter = Completer();
  late final videoCreatorSelector = FormDataDropDown(
    optionsFuture: videoCreatorsCompleter.future,
    label: 'Video Creator',
    displayNameOf: (VideoCreator videoCreator) => videoCreator.name,
  );
  final excludeAndroidCheckmark = FormDataCheckbox(
    label: strings.excludeAndroid,
  );

  final isFavoriteCheckbox = FormDataCheckbox(label: strings.isFavorite);
  final isTrendCheckbox = FormDataCheckbox(label: strings.isTrend);
  final Completer<String?> trendImageCompleter = Completer();
  late final trendImage = FormDataImagePicker(
    label: strings.trendImage,
    initialValueFuture: trendImageCompleter.future
        .then((url) => url == null ? null : Uri.parse(url).asBytes()),
  );

  late final ValueNotifier<List<Map<String, dynamic>>> _relatedChannelNotifier;
  late final ValueNotifier<List<Map<String, dynamic>>> _statusNotifier;
  late final ValueNotifier<bool?> _premiumContentNotifier;
  late final bool? _initialPremiumFlag;
  List<Map<String, dynamic>>? relatedChannels;
  List<Map<String, dynamic>>? _statusList;

  int _videoFileFakeCount = 0;
  String? _videoFileUrl;

  bool _titleError = false, _thumbnailError = false, _videoFileError = false;

  @override
  void initState() {
    cubit = CrudCubit(api: inject(), uploadApi: inject());
    cubit.getVideo(widget.id, Const.unlimitedRequestLimit, 0);
    _titleTextEditingController = TextEditingController();
    _captionTextEditingController = TextEditingController();
    _transcriptTextEditingController = TextEditingController();
    _videoNotifier = ValueNotifier<List<html.File>>([]);
    _thumbnailNotifier = ValueNotifier<Uint8List?>(null);
    _relatedChannelNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
    _statusNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
    _premiumContentNotifier = ValueNotifier<bool?>(null);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CrudCubit, CrudState>(
        bloc: cubit,
        listener: (blocContext, state) {
          state.maybeWhen(
            getVideo: (video, channels, allVideoCreators) async {
              videoCreatorsCompleter.complete(allVideoCreators);
              videoCreatorSelector.lateInitialValue =
                  allVideoCreators.firstWhereOrNull(
                      (videoCreator) => videoCreator.id == video.creatorId);

              isFavoriteCheckbox.lateInitialValue = video.isFavorite ?? false;
              isTrendCheckbox.lateInitialValue = video.isTrend ?? false;
              trendImageCompleter.complete(video.trendImage);

              populateStatus(video.status.toString());
              populateChannels(video, channels);

              _videoPublishDate =
                  _publishDateNotifier.value = video.publishDate;
              _titleTextEditingController.text = video.title;
              _captionTextEditingController.text = video.caption ?? '';
              _transcriptTextEditingController.text = video.transcript ?? '';
              _videoFileUrl = video.file;
              _initialPremiumFlag = _premiumContentNotifier.value = video.paid;
              excludeAndroidCheckmark.lateInitialValue = video.excludeAndroid;

              setState(() {});

              if (video.thumbnail != null) {
                _thumbnailNotifier.value =
                    await Uri.parse(video.thumbnail!).asBytes();
              }

              if (video.file != null) {
                _videoFileFakeCount = 1;
              }

              setState(() {});
            },
            successfulCreate: () {
              Navigator.of(context).pop();
              AutoRouter.of(context).replace(const VideoRoute());
            },
            failure: (e) {
              Navigator.of(context).pop();
            },
            loading: () => showBlurDialog(context, '', 'Wait a moment please',
                cubit: cubit),
            orElse: (crudState) {},
          );
        },
        builder: (context, state) => CrudScaffold(
              isLoading: state.isLoading,
              title: S.of(context).editVideo,
              onResetClickHandler: _resetForm,
              onSubmitClickHandler: _submitForm,
              submitButtonLabel: strings.update,
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
                  fakeCount: _videoFileFakeCount,
                  url: _videoFileUrl,
                  fileName: _videoNotifier.value.isNotEmpty
                      ? _videoNotifier.value.first.name
                      : null,
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
    _publishDateNotifier.value = _videoPublishDate;
    videoCreatorSelector.reset();
    trendImage.reset();
    isTrendCheckbox.reset();
    isFavoriteCheckbox.reset();
    excludeAndroidCheckmark.reset();

    setState(() {
      _thumbnailNotifier.value = null;
      _videoFileFakeCount = 0;
      _statusNotifier.value = [_statusList!.first];
      _premiumContentNotifier.value = _initialPremiumFlag;
    });
  }

  void _submitForm() async {
    if (_validateFields()) {
      cubit.updateVideo(
        widget.id,
        _titleTextEditingController.text,
        _relatedChannelNotifier.value.map((e) => e['value']),
        _thumbnailNotifier.value!,
        _transcriptTextEditingController.text,
        _videoNotifier.value.isNotEmpty ? _videoNotifier.value.first : null,
        _captionTextEditingController.text,
        _statusNotifier.value.first['value'],
        _publishDateNotifier.value,
        _premiumContentNotifier.value,
        videoCreatorSelector.value,
        trendImage.value,
        isTrendCheckbox.value,
        isFavoriteCheckbox.value,
        excludeAndroidCheckmark.value,
      );
    }
  }

  void populateChannels(Video video, List<Channel> channels) {
    relatedChannels = [];
    for (final channel in channels) {
      final map = {"display": channel.title, "value": channel.id.toString()};
      relatedChannels!.add(map);

      for (final videoChannelId in video.channels) {
        if (videoChannelId == channel.id) {
          _relatedChannelNotifier.value.add(map);
        }
      }
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

    if (_videoNotifier.value.isEmpty && _videoFileFakeCount == 0) {
      setState(() {
        _videoFileError = true;
      });
      invalidFields++;
    } else {
      setState(() {
        _videoFileError = false;
      });
    }

    if (invalidFields == 0) {
      return true;
    }

    return false;
  }
}
