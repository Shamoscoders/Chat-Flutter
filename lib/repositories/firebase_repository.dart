import 'dart:io';

import 'package:ChatFlutter/data/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../constant/data.dart';

class FirebaseRepository {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<bool> chekGooglogged() async => _googleSignIn.isSignedIn();

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      await _googleSignIn.disconnect();
      await _googleSignIn.signOut();
    } on PlatformException catch (err) {
      print('Error Platform : $err');
      throw err;
    } catch (err) {
      print('Error : $err');
      throw err;
    }
  }

  Future<FirebaseUser> firebaseSignIn() async {
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final FirebaseUser firebaseUser =
        (await _firebaseAuth.signInWithCredential(credential)).user;
    if (firebaseUser != null) {
      final documents = await userFireStore(firebaseUser.uid);
      if (documents.length == 0) {
        saveUserFireStore(firebaseUser);
        User.saveUser(
            id: firebaseUser.uid,
            nickname: firebaseUser.displayName,
            photoUrl: firebaseUser.photoUrl);
      } else {
        User.saveUser(
            id: documents[0]['id'],
            nickname: documents[0]['nickname'],
            photoUrl: documents[0]['photoUrl'],
            aboutMe: documents[0]['aboutMe']);
      }
    } else {
      throw 'Sign Fail';
    }
    return firebaseUser;
  }

  Future<List<DocumentSnapshot>> userFireStore(String userId) async {
    final QuerySnapshot result = await Firestore.instance
        .collection('users')
        .where('id', isEqualTo: userId)
        .getDocuments();
    return result.documents;
  }

  Future<void> saveUserFireStore(FirebaseUser firebaseUser) async {
    Firestore.instance.collection('users').document(firebaseUser.uid).setData({
      'nickname': firebaseUser.displayName,
      'photoUrl': firebaseUser.photoUrl,
      'id': firebaseUser.uid,
      'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
      'chattingWith': null
    });
  }

  Future<void> sendMessage(
      {@required String userId,
      @required String contactId,
      @required String groupChatId,
      @required String content,
      @required int type}) async {
    var documentReference = Firestore.instance
        .collection(CHAT_COLLECTIONS)
        .document(groupChatId)
        .collection(groupChatId)
        .document(DateTime.now().millisecondsSinceEpoch.toString());

    Firestore.instance.runTransaction((transaction) async {
      try {
        transaction.set(
          documentReference,
          {
            'idFrom': userId,
            'idTo': contactId,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
            'type': type
          },
        );
      } catch (er) {
        throw er;
      }
    });
  }

  Future<void> uploadImage(
      {@required String userId,
      @required String contactId,
      @required String groupChatId,
      @required File imageFile}) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(imageFile);
    try {
      final storageTaskSnapshot = await uploadTask.onComplete;
      final fileUrl = await storageTaskSnapshot.ref.getDownloadURL();
      sendMessage(
          userId: userId,
          contactId: contactId,
          groupChatId: groupChatId,
          content: fileUrl,
          type: 1);
    } catch (er) {
      throw er;
    }
  }
}
