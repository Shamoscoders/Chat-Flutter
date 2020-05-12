import 'package:ChatFlutter/repositories/firebase_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginBloc {
  final _firebaseRepository = FirebaseRepository();

  Future<bool> isSignIn() async => _firebaseRepository.chekGooglogged();

  Future<FirebaseUser> handleSignIn() async {
    try {
      final firebaseUser = await _firebaseRepository.firebaseSignIn();
      return firebaseUser;
    } catch (er) {
      throw er;
    }
  }
}
