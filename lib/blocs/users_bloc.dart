import 'dart:async';

import 'package:ChatFlutter/repositories/firebase_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsersBloc {
  final _firebaseRepository = FirebaseRepository();

  Stream<QuerySnapshot> get usersStream =>
      Firestore.instance.collection('users').snapshots();


  Future<void> signOut() async {
    try {
      await _firebaseRepository.signOut();
    } catch (er) {
      throw er;
    }
  }

  
}
