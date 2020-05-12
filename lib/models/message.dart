
import 'dart:io';

class Message {
  String idTo;
  String idFrom;
  int type;
  String content;
  String timestamp;
  File file;
  bool isOffline = true;

  Message({this.idTo, this.idFrom, this.type, this.content, this.timestamp, this.file});

  Message.fromJson(Map<String, dynamic> json) {
    idTo = json['idTo'];
    idFrom = json['idFrom'];
    type = json['type'];
    content = json['content'];
    timestamp = json['timestamp'];
    isOffline = false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['idTo'] = this.idTo;
    data['idFrom'] = this.idFrom;
    data['type'] = this.type;
    data['content'] = this.content;
    data['timestamp'] = this.timestamp;
    return data;
  }
}