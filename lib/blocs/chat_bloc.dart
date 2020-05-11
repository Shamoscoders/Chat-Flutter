import 'dart:async';
import 'dart:io';

import 'package:ChatFlutter/data/user.dart';
import 'package:ChatFlutter/repositories/firebase_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../constant/data.dart';

class ChatBloc {
  final _firebaseRepository = FirebaseRepository();

  String _contactId;
  String _userId;
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
        .limit(20)
        .snapshots();
  }

  ChatBloc({@required String id}) {
    _contactId = id;
    _fireStoreInit();
  }

  void _fireStoreInit() {
    User.getId().then((id) {
      _userId = id;
      groupChatId = id.hashCode <= _contactId.hashCode
          ? '$id-$_contactId'
          : '$_contactId-$id';
      setGroupChat(groupChatId);
      Firestore.instance
          .collection('users')
          .document(id)
          .updateData({'chattingWith': _contactId});
    });
  }

  Future<void> sendMessage(
      {@required String content, @required int type}) async {
    try {
      _firebaseRepository.sendMessage(
          userId: _userId,
          contactId: _contactId,
          groupChatId: groupChatId,
          content: content,
          type: type);
    } catch (er) {
      throw er;
    }
  }

  Future<void> uploadImage({@required File file}) async {
    try {
      _firebaseRepository.uploadImage(
          imageFile: file,
          userId: _userId,
          contactId: _contactId,
          groupChatId: groupChatId);
    } catch (er) {
      throw er;
    }
  }

  dispose() {
    _groupChatController.close();
  }
}
