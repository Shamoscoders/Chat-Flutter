import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class UsersBloc {
  Stream<QuerySnapshot> get usersStream =>
      Firestore.instance.collection('users').snapshots();
}
