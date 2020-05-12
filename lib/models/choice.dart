import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

enum MenuType {
  Setting,
  SignOut
}

class Choice {
  const Choice({this.id, this.title, this.icon});

  final MenuType id;
  final String title;
  final IconData icon;

  static List<Choice> getMenu() {
    return <Choice>[
      const Choice(id: MenuType.Setting, title: 'Settings', icon: Icons.settings),
      const Choice(id: MenuType.SignOut, title: 'Log out', icon: Icons.exit_to_app),
    ];
  }
}
