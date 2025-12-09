import 'package:flutter_panel/src/di/di.dart';

enum CategoryOrdering { titleASC, titleDESC }

extension OrderingExtension on CategoryOrdering {
  String get value {
    switch (this) {
      case CategoryOrdering.titleASC:
        return 'title';
      case CategoryOrdering.titleDESC:
        return '-title';
    }
  }

  String get name {
    switch (this) {
      case CategoryOrdering.titleASC:
        return strings.a2z;
      case CategoryOrdering.titleDESC:
        return strings.z2a;
    }
  }
}
