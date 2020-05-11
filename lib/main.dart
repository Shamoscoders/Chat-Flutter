import 'dart:async';
import 'dart:convert' show json;

import 'package:ChatFlutter/constant/style.dart';
import 'package:ChatFlutter/users.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import "package:http/http.dart" as http;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

void main() {
  runApp(
    MaterialApp(
      title: 'Google Sign In',
      home: SignInDemo(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class SignInDemo extends StatefulWidget {
  @override
  State createState() => SignInDemoState();
}

class SignInDemoState extends State<SignInDemo> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  SharedPreferences prefs;

  bool isLoading = false;
  bool isLoggedIn = false;
  FirebaseUser currentUser;

  @override
  void initState() {
    super.initState();
    _isSignedIn();
  }

  void _isSignedIn() async {
    _setLoading(true);
    prefs = await SharedPreferences.getInstance();
    isLoggedIn = await googleSignIn.isSignedIn();
    if (isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UsersScreen(
            currentUserId: prefs.getString('id'),
          ),
        ),
      );
    }
    _setLoading(false);
  }

  void _setLoading(bool isLoading) {
    this.setState(() => isLoading = true);
  }

  Future<Null> _handleSignIn() async {
    prefs = await SharedPreferences.getInstance();
    _setLoading(true);
    await _handleFirebaseSignIn()
        .then((firebaseUser) async {
          if (firebaseUser != null) {
            final QuerySnapshot result = await Firestore.instance
                .collection('users')
                .where('id', isEqualTo: firebaseUser.uid)
                .getDocuments(); // check existing user in firestore
            final List<DocumentSnapshot> documents = result.documents;
            if (documents.length == 0) {
              Firestore.instance
                  .collection('users')
                  .document(firebaseUser.uid)
                  .setData({
                'nickname': firebaseUser.displayName,
                'photoUrl': firebaseUser.photoUrl,
                'id': firebaseUser.uid,
                'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
                'chattingWith': null
              });
              currentUser = firebaseUser;
              await prefs.setString('id', currentUser.uid);
              await prefs.setString('nickname', currentUser.displayName);
              await prefs.setString('photoUrl', currentUser.photoUrl);
            } else {
              await prefs.setString('id', documents[0]['id']);
              await prefs.setString('nickname', documents[0]['nickname']);
              await prefs.setString('photoUrl', documents[0]['photoUrl']);
              await prefs.setString('aboutMe', documents[0]['aboutMe']);
            }
            Fluttertoast.showToast(msg: 'Sign in Success');
            _setLoading(false);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      UsersScreen(currentUserId: firebaseUser.uid)),
            );
          } else {
            Fluttertoast.showToast(msg: "Sign in fail");
            _setLoading(false);
          }
        })
        .catchError((err) => print('Error : $err'))
        .whenComplete(() => _setLoading(false));
  }

  Future<FirebaseUser> _handleFirebaseSignIn() async {
    GoogleSignInAccount googleUser = await googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final FirebaseUser user =
        (await firebaseAuth.signInWithCredential(credential)).user;
    print("signed in " + user.displayName);
    return user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Flutter Chat',
            style: TextStyle(color: whiteColor, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: <Widget>[
            Center(
              child: FlatButton(
                  onPressed: _handleSignIn,
                  child: Text(
                    'SIGN IN WITH GOOGLE',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  color: Color(0xffdd4b39),
                  highlightColor: Color(0xffff7f7f),
                  splashColor: Colors.transparent,
                  textColor: Colors.white,
                  padding: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0)),
            ),

            // Loading
            Positioned(
              child: isLoading
                  ? Container(
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                        ),
                      ),
                      color: Colors.white.withOpacity(0.8),
                    )
                  : Container(),
            ),
          ],
        ));
  }
}
