import 'package:sealed_annotations/sealed_annotations.dart';
import 'package:vibes_common/vibes.dart';

part 'advice_state.sealed.dart';

@Sealed()
abstract class _AdviceState {
  void initial();

  void loading();

  void success(AllVideo videoResult);

  void failure(@WithType('VibeError') error);
}
