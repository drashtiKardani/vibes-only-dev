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
import 'package:flutter_panel/src/widget/blur_dialog.dart';
import 'package:flutter_panel/src/widget/crud/crud_scaffold.dart';
import 'package:flutter_panel/src/widget/custom_checkbox.dart';
import 'package:flutter_panel/src/widget/custom_text_field.dart';
import 'package:flutter_panel/src/widget/file_picker_widget.dart';
import 'package:flutter_panel/src/widget/image_picker_widget.dart';
import 'package:flutter_panel/src/widget/multi_selector_widget.dart';
import 'package:flutter_panel/src/widget/rich_text_field.dart';

import '../../../route/router.gr.dart';
import 'story_flags.dart';

@RoutePage()
class AddStoryPage extends StatefulWidget {
  const AddStoryPage({super.key});

  @override
  State<AddStoryPage> createState() => _AddStoryPageState();
}

class _AddStoryPageState extends State<AddStoryPage> {
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

  late final ValueNotifier<List<Map<String, dynamic>>> _relatedCategoriesNotifier;
  late final ValueNotifier<List<Map<String, dynamic>>> _relatedCharactersNotifier;
  late final ValueNotifier<List<Map<String, dynamic>>> _flagsNotifier;
  late final ValueNotifier<bool?> _premiumContentNotifier;

  late CrudCubit cubit;
  List<Map<String, dynamic>>? _relatedCharacters;
  List<Map<String, dynamic>>? _relatedCategories;

  bool _titleError = false,
      _shortDescriptionError = false,
      _bodyError = false,
      _coverPhotoError = false,
      _relatedCategoriesError = false;

  @override
  void initState() {
    super.initState();
    cubit = CrudCubit(api: inject(), uploadApi: inject());
    cubit.getAddStoryFormData();

    _titleTextEditingController = TextEditingController();
    _shortDescriptionTextEditingController = TextEditingController();
    _bodyTextEditingController = TextEditingController();
    _transcriptTextEditingController = TextEditingController();
    _audioNotifier = ValueNotifier<List<html.File>>([]);
    _relatedCategoriesNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
    _relatedCharactersNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
    _flagsNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
    _premiumContentNotifier = ValueNotifier<bool?>(null);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CrudCubit, CrudState>(
        bloc: cubit,
        listener: (context, state) {
          state.maybeWhen(
            getAddStoryFormData: (characters, categories) {
              _relatedCharacters = [];
              for (var character in characters.results) {
                _relatedCharacters!.add({
                  "display": '${character.firstName ?? ''} ${character.lastName ?? ''}',
                  "value": character.id.toString()
                });
              }

              _relatedCategories = [];
              for (var category in categories.results) {
                _relatedCategories!.add({"display": category.title, "value": category.id.toString()});
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
            loading: () => showBlurDialog(context, '', 'Wait a moment please'),
            orElse: (crudState) {},
          );
        },
        child: CrudScaffold(
          title: strings.addNewStory,
          onResetClickHandler: _resetForm,
          onSubmitClickHandler: _submitForm,
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
              controller: _shortDescriptionTextEditingController,
              hint: strings.shortDescription,
              error: _shortDescriptionError,
              maxLines: 5,
            ),
            const SizedBox(
              height: 16,
            ),
            RichTextField(
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
              title: strings.coverPhoto,
              valueController: _coverPhotoNotifier,
              error: _coverPhotoError,
              onChange: _placeImages,
              aspectRatio: 37 / 25,
            ),
            const SizedBox(
              height: 16,
            ),
            ImagePickerWidget(
              title: strings.showcaseSmall,
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
              title: strings.showcaseMedium,
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
              title: strings.showcaseTall,
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
              title: strings.showcaseExtended,
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
              title: strings.featuredStaffPicked,
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
              title: strings.androidImage,
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
              title: strings.relatedCharacters,
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
              title: strings.relatedCategories,
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
          ],
        ));
  }

  void _resetForm() {
    _titleTextEditingController.clear();
    _shortDescriptionTextEditingController.clear();
    _bodyTextEditingController.clear();

    setState(() {
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
      _premiumContentNotifier.value = null;
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

      cubit.addStory(
        _titleTextEditingController.text,
        _shortDescriptionTextEditingController.text,
        _bodyTextEditingController.text,
        _audioNotifier.value.isNotEmpty ? _audioNotifier.value.first : null,
        _coverPhotoNotifier.value!,
        _showcaseSmallNotifier.value,
        _showcaseMediumNotifier.value,
        _showcaseTallNotifier.value,
        _showcaseExtendedNotifier.value,
        _featuredImageNotifier.value,
        categories,
        characters,
        _flagsNotifier.value.map((e) => e['value']),
        _premiumContentNotifier.value,
        _transcriptTextEditingController.text,
        androidImage: _androidImageNotifier.value,
      );
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
