import 'package:ChatFlutter/blocs/login_bloc.dart';
import 'package:ChatFlutter/data/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../constant/style.dart';
import '../screens/users_screen.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = 'login';

  @override
  State createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;
  bool isLoggedIn = false;
  FirebaseUser currentUser;
  LoginBloc _loginBloc;

  @override
  void initState() {
    _loginBloc = LoginBloc();
    super.initState();
    _isSignedIn();
  }

  void _isSignedIn() async {
    _setLoading(true);
    _loginBloc.isSignIn().then((value) async {
      final userId = await User.getId();
      print("UserId : $userId");
      Navigator.pushNamed(context, UsersScreen.routeName,
          arguments: UsersScreen.arguments(id: userId));
    }).whenComplete(() => _setLoading(false));
  }

  void _setLoading(bool isLoading) {
    this.setState(() => isLoading = true);
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
      ),
    );
  }

  void _handleSignIn() {
    _setLoading(true);
    _loginBloc
        .handleSignIn()
        .then((firebaseUser) {
          if (firebaseUser != null) {
            Fluttertoast.showToast(msg: 'SignIn Success');
            Navigator.pushNamed(context, UsersScreen.routeName,
                arguments: UsersScreen.arguments(id: firebaseUser.uid));
          }
        })
        .catchError((er) => Fluttertoast.showToast(msg: er.toString()))
        .whenComplete(() => _setLoading(false));
  }
}
