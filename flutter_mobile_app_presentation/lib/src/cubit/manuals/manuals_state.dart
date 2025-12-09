import 'package:sealed_annotations/sealed_annotations.dart';
import 'package:vibes_common/vibes.dart';

part 'manuals_state.sealed.dart';

@Sealed()
abstract class _ManualsState {
  void initial();

  void loading();

  void success(List<Manual> manuals);

  void failure(@WithType('VibeError') error);

  void detailRetrieved(ManualDetails details);
}
