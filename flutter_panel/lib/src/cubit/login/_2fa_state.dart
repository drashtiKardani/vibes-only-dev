import 'package:sealed_annotations/sealed_annotations.dart';
import 'package:vibes_common/vibes.dart';

part '_2fa_state.sealed.dart';

@Sealed()
abstract class _TwoFactorAuthenticationState {
  void initial();

  void loading();

  void success();

  void failure(@WithType('VibeError') error);
}
