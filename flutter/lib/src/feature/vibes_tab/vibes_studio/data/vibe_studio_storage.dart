import 'dart:convert';

import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibes_only/src/feature/vibes_tab/vibes_studio/data/new_vibe_store.dart';

part 'vibe_studio_storage.g.dart';

// ignore: library_private_types_in_public_api
class VibeStudioStorage = _VibeStudioStorage with _$VibeStudioStorage;

/// Holds every created [NewVibeStore].
/// abstract class _NewVibeStore with Store {
abstract class _VibeStudioStorage with Store {
  static const _storageAccessKey = '_|-|_vibe_studio_store_|-|_';

  _VibeStudioStorage() {
    SharedPreferences.getInstance().then((prefs) {
      _listOfVibes = ObservableList.of(
        prefs.getStringList(_storageAccessKey)?.map((e) => NewVibeStore.fromJson(jsonDecode(e))).toList() ?? [],
      );
    });
  }

  @observable
  ObservableList<NewVibeStore>? _listOfVibes;

  @computed
  ObservableList<NewVibeStore>? get listOfVibes => _listOfVibes == null ? null : ObservableList.of(_listOfVibes!);

  @action
  void addNewOrModifyExisting(NewVibeStore vibe) {
    if (_listOfVibes != null) {
      final existingIndex = _listOfVibes!.indexOf(vibe);
      if (existingIndex == -1) {
        _listOfVibes!.add(vibe);
      } else {
        _listOfVibes![existingIndex] = vibe;
      }
      _saveToDisk();
    }
  }

  @action
  void delete(NewVibeStore vibe) {
    if (_listOfVibes != null) {
      _listOfVibes!.remove(vibe);
      _saveToDisk();
    }
  }

  void _saveToDisk() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setStringList(_storageAccessKey, _listOfVibes!.map((e) => jsonEncode(e)).toList());
    });
  }
}
