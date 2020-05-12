import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  static const String ID = 'id';
  static const String NICKNAME = 'nickname';
  static const String PHOTO = 'photoUrl';
  static const String ABOUT = 'aboutMe';

  static Future<void> saveUser(
      {@required String id,
      @required String nickname,
      @required String photoUrl,
      String aboutMe}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(ID, id);
    await prefs.setString(NICKNAME, nickname);
    await prefs.setString(PHOTO, photoUrl);
    if (aboutMe != null) await prefs.setString(ABOUT, aboutMe);
  }

  static Future<String> getId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(ID);
  }

  static Future<String> getNickName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(NICKNAME);
  }

  static Future<String> getPhoto() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(PHOTO);
  }

  static Future<String> getAboutMe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(ABOUT);
  }

  static Future<void> clear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

}
