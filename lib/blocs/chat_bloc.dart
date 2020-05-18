import 'dart:async';
import 'dart:io';

import 'package:ChatFlutter/data/user.dart';
import 'package:ChatFlutter/repositories/firebase_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../constant/data.dart';

class ChatBloc {
  final _firebaseRepository = FirebaseRepository();

  String contactId;
  String userId;
  String groupChatId = '';

  StreamController _groupChatController = StreamController<String>.broadcast();

  Stream<String> get groupChatStream => _groupChatController.stream;
  Function(String) get setGroupChat => _groupChatController.add;

  Stream<QuerySnapshot> chatsStream(String groubId) {
    return Firestore.instance
        .collection(CHAT_COLLECTIONS)
        .document(groubId)
        .collection(groubId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  String get currentTime => DateTime.now().millisecondsSinceEpoch.toString();

  ChatBloc({@required String id}) {
    contactId = id;
    _fireStoreInit();
  }

  void _fireStoreInit() {
    User.getId().then((id) {
      userId = id;
      groupChatId = id.hashCode <= contactId.hashCode
          ? '$id-$contactId'
          : '$contactId-$id';
      setGroupChat(groupChatId);
      Firestore.instance
          .collection('users')
          .document(id)
          .updateData({'chattingWith': contactId});
    });
  }

  Future<void> sendMessage(
      {@required String content,
      @required int type,
      @required timeStamp,
      String name,
      String avatar}) async {
    try {
      _firebaseRepository.sendMessage(
          userId: userId,
          contactId: contactId,
          groupChatId: groupChatId,
          content: content,
          timeStamp: timeStamp,
          type: type,
          name: name,
          avatar: avatar);
    } catch (er) {
      throw er;
    }
  }

  Future<void> uploadImage(
      {@required File file,
      @required String timeStamp,
      String name,
      String avatar}) async {
    try {
      _firebaseRepository.uploadImage(
          imageFile: file,
          userId: userId,
          contactId: contactId,
          groupChatId: groupChatId,
          timeStamp: timeStamp,
          name: name,
          avatar: avatar);
    } catch (er) {
      throw er;
    }
  }

  dispose() {
    _groupChatController.close();
  }
}
