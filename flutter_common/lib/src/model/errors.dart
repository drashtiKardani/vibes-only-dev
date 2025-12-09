import 'package:sealed_annotations/sealed_annotations.dart';

import 'models.dart';

part 'errors.sealed.dart';

@Sealed()
abstract class _VibeError {
  void network(NetworkError error);
}
