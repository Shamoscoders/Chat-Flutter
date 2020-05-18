
import 'dart:convert';

class Payload {
  Notification notification;
  DataNotif data;

  Payload({this.notification, this.data});

  Payload.fromJson(Map<String, dynamic> json) {
    notification = json['notification'] != null
        ? new Notification.fromJson(json['notification'])
        : null;
    data = json['data'] != null ? new DataNotif.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.notification != null) {
      data['notification'] = this.notification.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    return data;
  }
}

class Notification {
  String title;
  String body;

  Notification({this.title, this.body});

  Notification.fromJson(Map<String, dynamic> json) {
    title = json['title'] ?? '';
    body = json['body'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['body'] = this.body;
    return data;
  }
}

class DataNotif {
  String avatar;
  String status;
  String id;
  String name;
  String clickAction;
  DataNotif body;

  DataNotif({this.avatar, this.status, this.id, this.name, this.clickAction});

  DataNotif.fromJson(Map<String, dynamic> jsonString) {
    avatar = jsonString['avatar'] ?? '';
    status = jsonString['status'].toString() ?? '';
    id = jsonString['id'].toString() ?? '';
    name = jsonString['name'] ?? '';
    clickAction = jsonString['click_action'] ?? '';
    final _body = jsonString['body'] ?? null;
    if (_body != null) {
      body = DataNotif.fromJson(json.decode(jsonString['body']));
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['avatar'] = this.avatar;
    data['status'] = this.status;
    data['id'] = this.id;
    data['name'] = this.name;
    data['click_action'] = this.clickAction;
    return data;
  }
}