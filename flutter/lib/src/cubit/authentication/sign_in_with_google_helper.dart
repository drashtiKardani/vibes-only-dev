import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<OAuthCredential> getCredentialFromGoogle() async {
  // Trigger the authentication flow
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  // Obtain the auth details from the request
  final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );

  return credential;
}

Future<UserCredential> signInWithGoogle() async {
  // Once signed in, return the UserCredential
  return await FirebaseAuth.instance
      .signInWithCredential(await getCredentialFromGoogle());
}

Future reAuthenticateWithGoogle() async {
  FirebaseAuth.instance.currentUser!
      .reauthenticateWithCredential(await getCredentialFromGoogle());
}
