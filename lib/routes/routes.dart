import 'package:ChatFlutter/screens/chats_screen.dart';
import 'package:ChatFlutter/screens/login_screen.dart';
import 'package:ChatFlutter/widgets/full_image_screen.dart';
import 'package:flutter/material.dart';

import '../screens/users_screen.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final argument = settings.arguments as Map;
    switch (settings.name) {
      case LoginScreen.routeName:
        return MaterialPageRoute(builder: (ctx) => LoginScreen());
      case UsersScreen.routeName:
        return MaterialPageRoute(
            builder: (ctx) => UsersScreen(currentUserId: argument['userId']));
      case ChatsScreen.routeName:
        return MaterialPageRoute(
            builder: (ctx) => ChatsScreen(
                  id: argument['id'],
                  name: argument['name'],
                  avatar: argument['avatar'],
                ));
      case FullImageScreen.routeName:
        return MaterialPageRoute(
            builder: (ctx) => FullImageScreen(url: argument['url']));
      default:
        return MaterialPageRoute(
          builder: (ctx) => Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text('Chat Flutter'),
            ),
            body: Center(
              child: Text('Unknown Page'),
            ),
          ),
        );
    }
  }
}
