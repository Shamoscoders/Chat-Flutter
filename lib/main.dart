import 'package:ChatFlutter/routes/routes.dart';
import 'package:ChatFlutter/screens/login_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Chat Flutter',
      initialRoute: LoginScreen.routeName,
      onGenerateRoute: Routes.generateRoute,
      debugShowCheckedModeBanner: false,
    ),
  );
}
