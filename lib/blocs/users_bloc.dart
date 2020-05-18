import 'dart:async';
import 'dart:io';
import 'package:ChatFlutter/models/notif.dart';
import 'package:ChatFlutter/repositories/firebase_repository.dart';
import 'package:ChatFlutter/repositories/notification_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class UsersBloc {
  final _firebaseRepository = FirebaseRepository();
  NotificationRepository _notifRepository;


  Stream<QuerySnapshot> get usersStream =>
      Firestore.instance.collection('users').snapshots();

  void setNotifRepository(NotificationRepository repository) {
    _notifRepository = repository;
  }

  Future<void> signOut() async {
    try {
      await _notifRepository.subAndUnSubscribeNotif(false);
      await _firebaseRepository.signOut();
    } catch (er) {
      print('Error : $er');
      throw er;
    }
  }

  Future<void> registerNotification(Function(Notif) result) async {
    _notifRepository.registerNotification((notif) => result(notif));
  }

  void configLocalNotification(Function(String) onSelected) {
    _notifRepository.configLocalNotification(onSelected);
  }

  Future<void> showNotification(Map<String, dynamic> message) async {
    Platform.isAndroid
        ? _notifRepository.showNotification(
            message: message['notification'], data: message)
        : _notifRepository.showNotification(
            message: message['aps']['alert'], data: message);
  }

}
