import 'package:ChatFlutter/blocs/users_bloc.dart';
import 'package:ChatFlutter/constant/style.dart';
import 'package:ChatFlutter/data/user.dart';
import 'package:ChatFlutter/models/choice.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../constant/style.dart';
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
      top: false,
      bottom: false,
      child: Scaffold(
        backgroundColor: magentaColor,
        body: WillPopScope(
          onWillPop: () => onBackPress(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              _buildAppBar(),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(color: whiteColor),
                  child: _buildBody(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return FutureBuilder<String>(
        future: User.getPhoto(),
        initialData: '',
        builder: (context, snapshot) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Material(
                          child: CachedNetworkImage(
                            placeholder: (context, url) => Container(
                              child: CircularProgressIndicator(
                                strokeWidth: 1.0,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(themeColor),
                              ),
                              width: 50.0,
                              height: 50.0,
                              padding: EdgeInsets.all(10.0),
                            ),
                            imageUrl: snapshot.data,
                            width: 50.0,
                            height: 50.0,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(25.0),
                          ),
                          clipBehavior: Clip.hardEdge,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        FutureBuilder<String>(
                            initialData: '',
                            future: User.getNickName(),
                            builder: (context, snapshot) {
                              return Text(
                                snapshot.data,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18.0),
                              );
                            })
                      ],
                    ),
                    _buildMore()
                  ],
                ),
                SizedBox(
                  height: 10.0,
                ),
                Text(
                  'Contacts',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
          );
        });
  }

  Widget _buildMore() {
    return PopupMenuButton<Choice>(
      icon: Icon(Icons.more_vert, color: Colors.white,),
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
    );
  }

  Widget _buildBody() {
    return Stack(
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
        child: InkWell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.only(left: 20.0, right: 10.0, top: 20.0),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '${document['nickname']}',
                              style: TextStyle(
                                  color: magentaColor, fontSize: 16.0),
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            Text(
                              '${document['aboutMe'] ?? 'Not available'}',
                              style:
                                  TextStyle(color: greyColor, fontSize: 12.0),
                            ),
                          ],
                        ),
                        margin: EdgeInsets.only(left: 20.0),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                width: double.infinity,
                height: 0.3,
                color: greyColor,
              )
            ],
          ),
          onTap: () => Navigator.pushNamed(context, ChatsScreen.routeName,
              arguments: ChatsScreen.argument(
                  id: document.documentID,
                  name: document['nickname'],
                  avatar: document['photoUrl'])),
        ),
      );
    }
  }

  Future<bool> onBackPress() {
    return Future<bool>.value(true);
  }
}
