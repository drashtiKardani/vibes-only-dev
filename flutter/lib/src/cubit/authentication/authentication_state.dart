import 'package:firebase_auth/firebase_auth.dart';
import 'package:sealed_annotations/sealed_annotations.dart';

part 'authentication_state.sealed.dart';

@Sealed()
abstract class _AuthenticationState {
  void signedOut();

  void inProgress();

  void signedIn(User user);

  void failure(@WithType('VibeError') error);
}
