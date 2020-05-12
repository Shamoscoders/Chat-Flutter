import 'dart:ui';

import 'package:ChatFlutter/blocs/login_bloc.dart';
import 'package:ChatFlutter/data/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
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
  bool _isLoading = false;
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
    this.setState(() => _isLoading = isLoading);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;
    final height = screenSize.height;
    return Scaffold(
      backgroundColor: greyColor4,
      body: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: height / 3,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [magentaColor, blueColor],
                    begin: FractionalOffset.topLeft,
                    end: FractionalOffset.bottomRight,
                    stops: [0.0, 1.0],
                    tileMode: TileMode.clamp),
              ),
              child: Center(
                child: Text(
                  'Chat Flutter',
                  style: TextStyle(
                      color: whiteColor,
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Positioned(
            top: height / 3 - 30,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.center,
              child: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: whiteColor),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    'assets/logo.png',
                    fit: BoxFit.cover,
                    height: 50,
                    width: 50,
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _buildSpace(100.0),
                  _buildTitle(width),
                  _buildSpace(50.0),
                  _buildButton(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSpace(double space) {
    return SizedBox(
      height: space,
    );
  }

  Widget _buildTitle(double width) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          color: magentaColor,
          height: 0.5,
          width: width / 4,
        ),
        Text(
          'Sign In',
          style: TextStyle(color: magentaColor, fontSize: 14.0),
        ),
        Container(
          color: magentaColor,
          height: 0.5,
          width: width / 4,
        ),
      ],
    );
  }

  Widget _buildButton() {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: () => _isLoading ? null : _handleSignIn(),
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: _isLoading ? greyColor3 : Colors.white,
          borderRadius: BorderRadius.circular(25.0),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned(
              left: 25,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  'assets/google.png',
                  height: 30,
                  width: 30,
                ),
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: 
                _isLoading ? CupertinoActivityIndicator()
                : Text(
                  'Google',
                  style: TextStyle(color: greyColor, fontSize: 16.0),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          ],
        ),
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
            Navigator.pushReplacementNamed(context, UsersScreen.routeName,
                arguments: UsersScreen.arguments(id: firebaseUser.uid));
          }
        })
        .catchError((er) => Fluttertoast.showToast(msg: er.toString()))
        .whenComplete(() => _setLoading(false));
  }
}
