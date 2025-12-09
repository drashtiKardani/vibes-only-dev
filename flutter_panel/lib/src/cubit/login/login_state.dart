import 'package:sealed_annotations/sealed_annotations.dart';
import 'package:vibes_common/vibes.dart';

part 'login_state.sealed.dart';

@Sealed()
abstract class _LoginState {
  void initial();

  void loading();

  void success();

  void failure(@WithType('VibeError') error);
}
