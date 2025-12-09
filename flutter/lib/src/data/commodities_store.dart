import 'package:collection/collection.dart';
import 'package:flutter_mobile_app_presentation/api.dart';
import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:vibes_common/vibes.dart';

part 'commodities_store.g.dart';

// ignore: library_private_types_in_public_api
class CommoditiesStore = _CommoditiesStore with _$CommoditiesStore;

abstract class _CommoditiesStore with Store {
  _CommoditiesStore() {
    GetIt.I<VibeApiNew>().getAllCommodities().then((commodities) {
      this.commodities = commodities;
    }).catchError((err) {
      print(err);
      error = err;
    });
  }

  @observable
  List<Commodity>? commodities;

  @observable
  dynamic error;
}

extension Toy on CommoditiesStore {
  List<Commodity> get knownToys =>
      commodities?.where((c) => c.isToy).toList() ?? [];

  /// Finds the [Commodity] with provided name, or null if nothings matches.
  /// If provided name is null, returns null immediately.
  Commodity? toyWithName(String? bluetoothName) {
    if (bluetoothName == null) return null;
    return knownToys.firstWhereOrNull((c) => c.bluetoothName == bluetoothName);
  }

  bool toyHasTwoMotors(String? bluetoothName) {
    return toyWithName(bluetoothName)?.numberOfMotors == 2;
  }

  bool toyHasThreeMotors(String? bluetoothName) {
    return toyWithName(bluetoothName)?.numberOfMotors == 3;
  }
}
