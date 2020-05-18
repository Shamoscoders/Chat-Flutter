import 'package:ChatFlutter/providers/global_provider.dart';
import 'package:ChatFlutter/routes/routes.dart';
import 'package:ChatFlutter/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(App());

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: independentProviders,
      child: MaterialApp(
        title: 'Chat Flutter',
        initialRoute: LoginScreen.routeName,
        onGenerateRoute: Routes.generateRoute,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
