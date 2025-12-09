import 'package:vibes_common/vibes.dart';

extension MathSymbol on Constraint {
  String get mathSymbol {
    switch (this) {
      case Constraint.moreThan:
        return '>';
      case Constraint.equals:
        return '=';
      case Constraint.lessThan:
        return '<';
    }
  }
}
