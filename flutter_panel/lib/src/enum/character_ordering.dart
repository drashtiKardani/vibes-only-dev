import 'package:flutter_panel/src/di/di.dart';

enum CharacterOrdering { customOrder, nameASC, nameDESC }

extension OrderingExtension on CharacterOrdering {
  String? get value {
    switch (this) {
      case CharacterOrdering.customOrder:
        return null;
      case CharacterOrdering.nameASC:
        return 'first_name';
      case CharacterOrdering.nameDESC:
        return '-first_name';
    }
  }

  String get name {
    switch (this) {
      case CharacterOrdering.customOrder:
        return strings.customOrder;
      case CharacterOrdering.nameASC:
        return strings.a2z;
      case CharacterOrdering.nameDESC:
        return strings.z2a;
    }
  }
}
