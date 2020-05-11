import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;

  static List<Choice> getMenu() {
    return <Choice>[
      const Choice(title: 'Settings', icon: Icons.settings),
      const Choice(title: 'Log out', icon: Icons.exit_to_app),
    ];
  }
}
