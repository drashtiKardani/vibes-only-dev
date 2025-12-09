// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_panel/generated/l10n.dart';
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
import 'package:flutter_panel/src/widget/image_picker_widget.dart';
import 'package:flutter_panel/src/widget/multi_selector_widget.dart';
import 'package:flutter_panel/src/widget/rich_text_field.dart';
import 'package:vibes_common/vibes.dart';

import '../../../route/router.gr.dart';
import 'story_flags.dart';

@RoutePage()
class UpdateStoryPage extends StatefulWidget {
  const UpdateStoryPage({super.key, @PathParam('id') required this.id});

  final String id;

  @override
  State<UpdateStoryPage> createState() => _UpdateStoryPageState();
}

class _UpdateStoryPageState extends State<UpdateStoryPage> with FlagUtility {
  late final CrudCubit cubit;
  late final TextEditingController _titleTextEditingController;
  late final TextEditingController _shortDescriptionTextEditingController;
  late final TextEditingController _bodyTextEditingController;
  late final TextEditingController _transcriptTextEditingController;

  late final ValueNotifier<List<html.File>> _audioNotifier;
  final _coverPhotoNotifier = ValueNotifier<Uint8List?>(null);
  final _showcaseSmallNotifier = ValueNotifier<Uint8List?>(null);
  final _showcaseMediumNotifier = ValueNotifier<Uint8List?>(null);
  final _showcaseTallNotifier = ValueNotifier<Uint8List?>(null);
  final _showcaseExtendedNotifier = ValueNotifier<Uint8List?>(null);
  final _featuredImageNotifier = ValueNotifier<Uint8List?>(null);
  final _androidImageNotifier = ValueNotifier<Uint8List?>(null);
  final ValueNotifier<DateTime?> _publishDateNotifier = ValueNotifier<DateTime?>(null);
  late final DateTime? _storyPublishDate;

  late final ValueNotifier<List<Map<String, dynamic>>> _relatedCategoriesNotifier;
  late final ValueNotifier<List<Map<String, dynamic>>> _relatedCharactersNotifier;
  late final ValueNotifier<List<Map<String, dynamic>>> _flagsNotifier;
  late final ValueNotifier<List<Map<String, dynamic>>> _statusNotifier;
  late final ValueNotifier<bool?> _premiumContentNotifier;
  late final bool? _initialPremiumFlag;
  List<Map<String, dynamic>>? _relatedCategories;
  List<Map<String, dynamic>>? _relatedCharacters;
  List<Map<String, dynamic>>? _statusList;

  int _audioFileFakeCount = 0;
  String? _audioFileUrl;

  bool _titleError = false,
      _shortDescriptionError = false,
      _bodyError = false,
      _coverPhotoError = false,
      _relatedCategoriesError = false;

  // we use the following hash codes to compare and send only the modified images to the server.
  late final int initialCoverPhotoHash;
  late final int initialShowcaseSmallHash;
  late final int initialShowcaseMediumHash;
  late final int initialShowcaseTallHash;
  late final int initialShowcaseExtendedHash;
  late final int initialFeaturedImageHash;
  late final int initialAndroidImageHash;

  @override
  void initState() {
    cubit = CrudCubit(api: inject(), uploadApi: inject());
    cubit.getStory(widget.id);

    _titleTextEditingController = TextEditingController();
    _shortDescriptionTextEditingController = TextEditingController();
    _bodyTextEditingController = TextEditingController();
    _transcriptTextEditingController = TextEditingController();
    _audioNotifier = ValueNotifier<List<html.File>>([]);
    _relatedCategoriesNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
    _relatedCharactersNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
    _flagsNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
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
            getStory: (story, characters, categories) async {
              populateCategories(story, categories);
              populateCharacters(story, characters);
              populateFlags(story);
              populateStatus(story.status ?? 'approved');
              _storyPublishDate = _publishDateNotifier.value = story.publishDate;
              _titleTextEditingController.text = story.title;
              _shortDescriptionTextEditingController.text = story.shortDescription ?? '';
              _bodyTextEditingController.text = story.description;
              _transcriptTextEditingController.text = story.transcript ?? '';
              _audioFileUrl = story.audio;
              _initialPremiumFlag = _premiumContentNotifier.value = story.paid;

              setState(() {});

              if (story.imageCover != null) {
                _coverPhotoNotifier.value = await Uri.parse(story.imageCover!).asBytes();
              }

              if (story.imageShowcaseSmall != null) {
                _showcaseSmallNotifier.value = await Uri.parse(story.imageShowcaseSmall!).asBytes();
              }

              if (story.imageShowcaseMedium != null) {
                _showcaseMediumNotifier.value = await Uri.parse(story.imageShowcaseMedium!).asBytes();
              }
              if (story.imageShowcaseTall != null) {
                _showcaseTallNotifier.value = await Uri.parse(story.imageShowcaseTall!).asBytes();
              }

              if (story.imageShowcaseExtended != null) {
                _showcaseExtendedNotifier.value = await Uri.parse(story.imageShowcaseExtended!).asBytes();
              }
              if (story.imageFull != null) {
                _featuredImageNotifier.value = await Uri.parse(story.imageFull!).asBytes();
              }
              if (story.androidImage != null) {
                _androidImageNotifier.value = await Uri.parse(story.androidImage!).asBytes();
              }

              initialCoverPhotoHash = _coverPhotoNotifier.value.hashCode;
              initialShowcaseSmallHash = _showcaseSmallNotifier.value.hashCode;
              initialShowcaseMediumHash = _showcaseMediumNotifier.value.hashCode;
              initialShowcaseTallHash = _showcaseTallNotifier.value.hashCode;
              initialShowcaseExtendedHash = _showcaseExtendedNotifier.value.hashCode;
              initialFeaturedImageHash = _featuredImageNotifier.value.hashCode;
              initialAndroidImageHash = _androidImageNotifier.value.hashCode;

              if (story.audio != null) {
                _audioFileFakeCount = 1;
              }

              setState(() {});
            },
            successfulCreate: () {
              Navigator.of(context).pop();
              AutoRouter.of(context).replace(const StoriesRoute());
            },
            failure: (e) {
              Navigator.of(context).pop();
            },
            loading: () => showBlurDialog(context, '', 'Wait a moment please', cubit: cubit),
            orElse: (crudState) {},
          );
        },
        builder: (context, state) => CrudScaffold(
              isLoading: state.isLoading,
              title: S.of(context).editStory,
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
                CustomTextField(
                  controller: _shortDescriptionTextEditingController,
                  hint: S.of(context).shortDescription,
                  error: _shortDescriptionError,
                  maxLines: 5,
                ),
                const SizedBox(
                  height: 16,
                ),
                RichTextField(
                  initialText: _bodyTextEditingController.text,
                  hint: strings.body,
                  error: _bodyError,
                  maxLines: 10,
                  onChange: (text) => _bodyTextEditingController.text = text ?? '',
                ),
                const SizedBox(
                  height: 16,
                ),
                FilePickerWidget(
                  title: strings.audio,
                  types: FileTypes.audio,
                  valueController: _audioNotifier,
                  fakeCount: _audioFileFakeCount,
                  fileName: _audioNotifier.value.isNotEmpty ? _audioNotifier.value.first.name : null,
                  url: _audioFileUrl,
                  onChange: (files) {
                    setState(() {
                      _audioNotifier.value = files;
                    });
                  },
                ),
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
                ImagePickerWidget(
                  title: S.of(context).coverPhoto,
                  valueController: _coverPhotoNotifier,
                  error: _coverPhotoError,
                  onChange: _placeImages,
                  aspectRatio: 37 / 25,
                ),
                const SizedBox(
                  height: 16,
                ),
                ImagePickerWidget(
                  title: S.of(context).showcaseSmall,
                  valueController: _showcaseSmallNotifier,
                  aspectRatio: 1,
                  onChange: (image) {
                    setState(() {
                      _showcaseSmallNotifier.value = image;
                    });
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                ImagePickerWidget(
                  title: S.of(context).showcaseMedium,
                  valueController: _showcaseMediumNotifier,
                  aspectRatio: 1,
                  onChange: (image) {
                    setState(() {
                      _showcaseMediumNotifier.value = image;
                    });
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                ImagePickerWidget(
                  title: S.of(context).showcaseTall,
                  valueController: _showcaseTallNotifier,
                  aspectRatio: 18 / 22,
                  onChange: (image) {
                    setState(() {
                      _showcaseTallNotifier.value = image;
                    });
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                ImagePickerWidget(
                  title: S.of(context).showcaseExtended,
                  valueController: _showcaseExtendedNotifier,
                  aspectRatio: 30 / 14,
                  onChange: (image) {
                    setState(() {
                      _showcaseExtendedNotifier.value = image;
                    });
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                ImagePickerWidget(
                  title: S.of(context).featuredStaffPicked,
                  valueController: _featuredImageNotifier,
                  aspectRatio: 30 / 38,
                  onChange: (image) {
                    setState(() {
                      _featuredImageNotifier.value = image;
                    });
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                ImagePickerWidget(
                  title: S.of(context).androidImage,
                  valueController: _androidImageNotifier,
                  aspectRatio: 37 / 25, // same as the coverPhoto's
                  onChange: (image) {
                    setState(() {
                      _androidImageNotifier.value = image;
                    });
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                MultiSelectorWidget(
                  title: S.of(context).relatedCharacters,
                  data: _relatedCharacters,
                  isMultipleSelection: true,
                  isLoading: _relatedCharacters == null,
                  selected: _relatedCharactersNotifier.value,
                  onChange: (selected) => setState(() {
                    _relatedCharactersNotifier.value = selected;
                  }),
                ),
                const SizedBox(
                  height: 16,
                ),
                MultiSelectorWidget(
                  title: S.of(context).relatedCategories,
                  data: _relatedCategories,
                  isMultipleSelection: true,
                  isLoading: _relatedCategories == null,
                  selected: _relatedCategoriesNotifier.value,
                  error: _relatedCategoriesError,
                  onChange: (selected) => setState(() {
                    _relatedCategoriesNotifier.value = selected;
                  }),
                ),
                const SizedBox(
                  height: 16,
                ),
                MultiSelectorWidget(
                  title: strings.flags,
                  data: StoryFlags.all,
                  isMultipleSelection: true,
                  isLoading: false,
                  selected: _flagsNotifier.value,
                  error: false,
                  onChange: (selected) => setState(() {
                    _flagsNotifier.value = selected;
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

  void _resetForm() {
    _titleTextEditingController.clear();
    _shortDescriptionTextEditingController.clear();
    _bodyTextEditingController.clear();
    _publishDateNotifier.value = _storyPublishDate;

    setState(() {
      _audioFileFakeCount = 0;
      _audioNotifier.value.clear();
      _coverPhotoNotifier.value = null;
      _showcaseSmallNotifier.value = null;
      _showcaseMediumNotifier.value = null;
      _showcaseTallNotifier.value = null;
      _showcaseExtendedNotifier.value = null;
      _featuredImageNotifier.value = null;
      _androidImageNotifier.value = null;
      _relatedCharactersNotifier.value.clear();
      _relatedCategoriesNotifier.value.clear();
      _flagsNotifier.value.clear();
      _statusNotifier.value = [_statusList!.first];
      _premiumContentNotifier.value = _initialPremiumFlag;
    });
  }

  void _submitForm() async {
    if (_validateFields()) {
      final characters = <String>[];
      final categories = <String>[];

      for (final item in _relatedCategoriesNotifier.value) {
        categories.add(item['value']);
      }

      for (final item in _relatedCharactersNotifier.value) {
        characters.add(item['value']);
      }

      final flagUpdates = calcFlagUpdateMap(StoryFlags.all, _flagsNotifier);

      cubit.updateStory(
        widget.id,
        _titleTextEditingController.text,
        _shortDescriptionTextEditingController.text,
        _bodyTextEditingController.text,
        modifiedCoverPhoto(),
        modifiedShowcaseSmall(),
        modifiedShowcaseMedium(),
        modifiedShowcaseTall(),
        modifiedShowcaseExtended(),
        modifiedFeaturedImage(),
        categories,
        characters,
        flagUpdates,
        _statusNotifier.value.first['value'],
        _audioNotifier.value.isNotEmpty ? _audioNotifier.value.first : null,
        _publishDateNotifier.value,
        _premiumContentNotifier.value,
        _transcriptTextEditingController.text,
        androidImage: modifiedAndroidImage(),
      );
    }
  }

  Uint8List? modifiedAndroidImage() =>
      _androidImageNotifier.value.hashCode == initialAndroidImageHash ? null : _androidImageNotifier.value;

  Uint8List? modifiedFeaturedImage() =>
      _featuredImageNotifier.value.hashCode == initialFeaturedImageHash ? null : _featuredImageNotifier.value;

  Uint8List? modifiedShowcaseExtended() =>
      _showcaseExtendedNotifier.value.hashCode == initialShowcaseExtendedHash ? null : _showcaseExtendedNotifier.value;

  Uint8List? modifiedShowcaseTall() =>
      _showcaseTallNotifier.value.hashCode == initialShowcaseTallHash ? null : _showcaseTallNotifier.value;

  Uint8List? modifiedShowcaseMedium() =>
      _showcaseMediumNotifier.value.hashCode == initialShowcaseMediumHash ? null : _showcaseMediumNotifier.value;

  Uint8List? modifiedShowcaseSmall() =>
      _showcaseSmallNotifier.value.hashCode == initialShowcaseSmallHash ? null : _showcaseSmallNotifier.value;

  Uint8List? modifiedCoverPhoto() =>
      _coverPhotoNotifier.value.hashCode == initialCoverPhotoHash ? null : _coverPhotoNotifier.value!;

  void populateCategories(Story story, List<Category> categories) {
    _relatedCategories = [];
    for (var category in categories) {
      final map = {"display": category.title, "value": category.id.toString()};
      _relatedCategories!.add(map);

      for (final selectedCategory in story.categories) {
        if (selectedCategory.id == category.id) {
          _relatedCategoriesNotifier.value.add(map);
        }
      }
    }
  }

  void populateCharacters(Story story, List<Character> characters) {
    _relatedCharacters = [];
    for (var character in characters) {
      final map = {
        "display": '${character.firstName ?? ''} ${character.lastName ?? ''}',
        "value": character.id.toString()
      };
      _relatedCharacters!.add(map);

      for (final selectedCharacter in story.characters) {
        if (selectedCharacter.id == character.id) {
          _relatedCharactersNotifier.value.add(map);
        }
      }
    }
  }

  void populateFlags(Story story) {
    if (story.neW ?? false) _flagsNotifier.value.add(StoryFlags.hotAndNew);
    // if (story.featured ?? false) _flagsNotifier.value.add(StoryFlags.featured);
    if (story.trending ?? false) _flagsNotifier.value.add(StoryFlags.trending);
    if (story.top_10 ?? false) _flagsNotifier.value.add(StoryFlags.top10);
    if (story.staffPick ?? false) _flagsNotifier.value.add(StoryFlags.staffPick);
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

  void _placeImages(Uint8List? image) {
    setState(() {
      _coverPhotoNotifier.value = image;
      _showcaseSmallNotifier.value ??= image;
      _showcaseMediumNotifier.value ??= image;
      _showcaseTallNotifier.value ??= image;
      _showcaseExtendedNotifier.value ??= image;
      _featuredImageNotifier.value ??= image;
    });
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

    if (_shortDescriptionTextEditingController.text.isEmpty) {
      setState(() {
        _shortDescriptionError = true;
      });
      invalidFields++;
    } else {
      setState(() {
        _shortDescriptionError = false;
      });
    }

    if (_bodyTextEditingController.text.isEmpty) {
      setState(() {
        _bodyError = true;
      });
      invalidFields++;
    } else {
      setState(() {
        _bodyError = false;
      });
    }

    if (_coverPhotoNotifier.value == null) {
      setState(() {
        _coverPhotoError = true;
      });
      invalidFields++;
    } else {
      setState(() {
        _coverPhotoError = false;
      });
    }

    if (_relatedCategoriesNotifier.value.isEmpty) {
      setState(() {
        _relatedCategoriesError = true;
      });
      invalidFields++;
    } else {
      setState(() {
        _relatedCategoriesError = false;
      });
    }

    if (invalidFields == 0) {
      return true;
    }

    return false;
  }
}
