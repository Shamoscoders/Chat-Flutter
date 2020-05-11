import 'package:ChatFlutter/blocs/users_bloc.dart';
import 'package:ChatFlutter/constant/style.dart';
import 'package:ChatFlutter/models/choice.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'chats_screen.dart';

class UsersScreen extends StatefulWidget {
  static const routeName = 'users';
  static arguments({@required String id}) => {'userId': id};

  final String currentUserId;

  UsersScreen({@required this.currentUserId});

  @override
  UsersScreenState createState() =>
      UsersScreenState(currentUserId: currentUserId);
}

class UsersScreenState extends State<UsersScreen> {
  bool isLoading = false;
  final String currentUserId;

  UsersBloc _usersBloc;

  UsersScreenState({@required this.currentUserId});

  @override
  void initState() {
    _usersBloc = UsersBloc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: _buildAppBar(),
        body: WillPopScope(
          onWillPop: () => onBackPress(),
          child: Stack(
            children: <Widget>[
              // List
              Container(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _usersBloc.usersStream,
                  builder: (context, snapshot) {
                    print(
                        "Result : ${snapshot.hasData} - ${snapshot.data.documents.length}");
                    if (!snapshot.hasData) {
                      return _buildLoading();
                    } else {
                      return ListView.builder(
                        padding: EdgeInsets.all(10.0),
                        itemBuilder: (context, index) =>
                            buildItem(context, snapshot.data.documents[index]),
                        itemCount: snapshot.data.documents.length,
                      );
                    }
                  },
                ),
              ),

              // Loading
              Positioned(
                child: isLoading
                    ? Container(
                        child: _buildLoading(),
                        color: Colors.white.withOpacity(0.8),
                      )
                    : Container(),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      title: Text(
        'MAIN',
        style: TextStyle(color: whiteColor, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      actions: <Widget>[
        PopupMenuButton<Choice>(
          onSelected: (c) {},
          itemBuilder: (BuildContext context) {
            return Choice.getMenu().map((Choice choice) {
              return PopupMenuItem<Choice>(
                  value: choice,
                  child: Row(
                    children: <Widget>[
                      Icon(
                        choice.icon,
                        color: primaryColor,
                      ),
                      Container(
                        width: 10.0,
                      ),
                      Text(
                        choice.title,
                        style: TextStyle(color: primaryColor),
                      ),
                    ],
                  ));
            }).toList();
          },
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return Center(
      child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(themeColor)),
    );
  }

  Widget buildItem(BuildContext context, DocumentSnapshot document) {
    if (document['id'] == currentUserId) {
      return Container();
    } else {
      return Container(
        child: FlatButton(
          child: Row(
            children: <Widget>[
              Material(
                child: document['photoUrl'] != null
                    ? CachedNetworkImage(
                        placeholder: (context, url) => Container(
                          child: CircularProgressIndicator(
                            strokeWidth: 1.0,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(themeColor),
                          ),
                          width: 50.0,
                          height: 50.0,
                          padding: EdgeInsets.all(15.0),
                        ),
                        imageUrl: document['photoUrl'],
                        width: 50.0,
                        height: 50.0,
                        fit: BoxFit.cover,
                      )
                    : Icon(
                        Icons.account_circle,
                        size: 50.0,
                        color: greyColor,
                      ),
                borderRadius: BorderRadius.all(Radius.circular(25.0)),
                clipBehavior: Clip.hardEdge,
              ),
              Flexible(
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Text(
                          'Nickname: ${document['nickname']}',
                          style: TextStyle(color: primaryColor),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                      ),
                      Container(
                        child: Text(
                          'About me: ${document['aboutMe'] ?? 'Not available'}',
                          style: TextStyle(color: primaryColor),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                      )
                    ],
                  ),
                  margin: EdgeInsets.only(left: 20.0),
                ),
              ),
            ],
          ),
          onPressed: () => Navigator.pushNamed(context, ChatsScreen.routeName,
              arguments: ChatsScreen.argument(
                  id: document.documentID, avatar: document['photoUrl'])),
          color: greyColor2,
          padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
        margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
      );
    }
  }

  Future<bool> onBackPress() {
    return Future<bool>.value(true);
  }
}
