import 'dart:async';
import 'dart:io';

import 'package:ChatFlutter/models/notif.dart';
import 'package:ChatFlutter/repositories/firebase_repository.dart';
import 'package:ChatFlutter/repositories/notification_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsersBloc {
  final _firebaseRepository = FirebaseRepository();
  final _notifRepository = NotificationRepository();

  Stream<QuerySnapshot> get usersStream =>
      Firestore.instance.collection('users').snapshots();

  Future<void> signOut() async {
    try {
      await _firebaseRepository.signOut();
    } catch (er) {
      throw er;
    }
  }

  Future<void> registerNotification(Function(Notif) result) async {
    _notifRepository.registerNotification((notif) {
      result(notif);
    });
  }

  void configLocalNotification(Function(String) onSelected) {
    _notifRepository.configLocalNotification(onSelected);
  }

  Future<void> showNotification(message) async {
    Platform.isAndroid
        ? _notifRepository.showNotification(message['notification'])
        : _notifRepository.showNotification(message['aps']['alert']);
  }
}
