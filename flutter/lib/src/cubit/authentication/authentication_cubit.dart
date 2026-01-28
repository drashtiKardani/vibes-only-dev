import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/flutter_mobile_app_presentation.dart';
import 'package:get_it/get_it.dart';
import 'package:vibes_only/src/cubit/authentication/authentication_state.dart';
import 'package:vibes_only/src/cubit/authentication/sign_in_with_apple_helper.dart';
import 'package:vibes_only/src/cubit/authentication/sign_in_with_google_helper.dart';

enum SignInMethod { apple, google }

class AuthenticationCubit extends Cubit<AuthenticationState> {
  AuthenticationCubit() : super(const AuthenticationState.inProgress()) {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user == null) {
        emit(const AuthenticationState.signedOut());
      } else {
        print("Signed in user: ${user.email}, uid: ${user.uid}");
        GetIt.I<VibeApiNew>()
            .socialLogin({
              "firebase_uid": user.uid,
              "email": user.email,
              "display_name": user.displayName,
            })
            .then((value) {
              print("response ==> $value");
              emit(AuthenticationState.signedIn(user: user));
            })
            .catchError((e) {
              print("Error ==> ${e.toString()}");
            });
      }
    });
  }

  void signInWith(SignInMethod method) {
    switch (method) {
      case SignInMethod.apple:
        signInWithApple();

        break;
      case SignInMethod.google:
        signInWithGoogle();
        break;
    }
  }

  Future<void> signInAnonymously() async {
    await FirebaseAuth.instance.signInAnonymously();
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> deleteAccount() async {
    if (FirebaseAuth.instance.currentUser == null) {
      print('User is not logged in.');
      return;
    }
    try {
      await FirebaseAuth.instance.currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        print(
          'The user must reauthenticate '
          'before this operation can be executed.',
        );
        final providerId =
            FirebaseAuth.instance.currentUser!.providerData[0].providerId;
        switch (providerId) {
          case 'google.com':
            reAuthenticateWithGoogle().then(
              (value) => FirebaseAuth.instance.currentUser!.delete(),
            );
            break;
          case 'apple.com':
            reAuthenticateWithApple().then(
              (value) => FirebaseAuth.instance.currentUser!.delete(),
            );
            break;
          default:
            print(
              'Provider ID ($providerId) did not match neither of '
              'google.com or apple.com. '
              'Cannot find a method to re-authenticate the user. '
              'The user cannot be deleted!',
            );
        }
      }
    }
  }
}
