import 'dart:convert';
import 'dart:io';

import 'package:ChatFlutter/constant/env.dart';
import 'package:ChatFlutter/data/user.dart';
import 'package:ChatFlutter/models/notif.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class NotificationRepository {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<void> registerNotification(Function(Notif) result) async {
    if (Platform.isIOS) {
      firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: false),
      );
    }
    User.getId().then((value) {
      print('id : $value');
      firebaseMessaging.subscribeToTopic(value);
    });
    firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
      print('onConfig: $message');
      result(Notif(NotifTrigger.forground, message));
      return;
    }, onResume: (Map<String, dynamic> message) {
      print('onResume: $message');
      result(Notif(NotifTrigger.background, message));
      return;
    }, onLaunch: (Map<String, dynamic> message) {
      print('onLaunch: $message');
      result(Notif(NotifTrigger.background, message));
      return;
    });
  }

  Future<void> configLocalNotification(
      Function(String) selectNotification) async {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('mipmap/ic_launcher');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
  }

  Future<void> showNotification(message) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'com.bcr.ChatFlutter',
      'Flutter chat demo',
      'your channel description',
      playSound: true,
      enableVibration: true,
      importance: Importance.Max,
      priority: Priority.High,
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(0, message['title'].toString(),
        message['body'].toString(), platformChannelSpecifics,
        payload: json.encode(message));
  }

  Future<void> sendPushNotif(
      {@required String target,
      String title = 'Message',
      String message = 'notification'}) async {
    print('Target : $target');
    try {
      final response = await http.post(
        ENDPOINT_FCM_SEND,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$SERVER_TOKEN_FIREBASE',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{'body': message, 'title': title},
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            'to': '/topics/$target',
          },
        ),
      );
      print(
          'Success : ${json.encode(response.body)} - StatusCode = ${response.statusCode}');
    } catch (err) {
      print('error : $err');
      throw err;
    }
  }
}
