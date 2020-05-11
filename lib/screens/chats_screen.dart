import 'dart:io';

import 'package:ChatFlutter/blocs/chat_bloc.dart';
import 'package:ChatFlutter/constant/style.dart';
import 'package:ChatFlutter/data/user.dart';
import 'package:ChatFlutter/widgets/full_image_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ChatsScreen extends StatefulWidget {
  static const routeName = 'chat';
  static argument({@required String id, @required String avatar}) =>
      {'id': id, 'avatar': avatar};

  final String id;
  final String avatar;

  ChatsScreen({Key key, @required this.id, @required this.avatar});

  @override
  _ChatsScreenState createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  String _userId;
  List<DocumentSnapshot> listMessages = [];

  ChatBloc _chatBloc;

  File imageFile;
  bool isLoading;
  bool isShowSticker;
  String imageUrl;

  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();
  final FocusNode focusNode = new FocusNode();

  @override
  void initState() {
    _chatBloc = ChatBloc(id: widget.id);
    super.initState();
    User.getId().then((value) => _userId = value);
    isLoading = false;
    isShowSticker = false;
    imageUrl = '';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBodyChat(),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      title: Text(
        'Chat',
        style: TextStyle(color: whiteColor, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
    );
  }

  Widget _buildBodyChat() {
    return WillPopScope(
      onWillPop: () => onBackPress(),
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[_buildListMessage(), _buildInput()],
          ),
          // (isShowSticker ? buildSticker() : Container()),
          _buildLoading()
        ],
      ),
    );
  }

  Widget _buildListMessage() {
    return StreamBuilder<String>(
        stream: _chatBloc.groupChatStream,
        builder: (context, snapshot) {
          return Flexible(
            child: (!snapshot.hasData && snapshot.data == '')
                ? Center(
                    child: Container(
                      child: Text('Empty'),
                    ),
                  )
                : StreamBuilder<QuerySnapshot>(
                    stream: _chatBloc.chatsStream(snapshot.data),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        listMessages = snapshot.data.documents;
                        return ListView.builder(
                            padding: EdgeInsets.all(10.0),
                            itemCount: listMessages.length,
                            reverse: true,
                            controller: listScrollController,
                            itemBuilder: (context, index) =>
                                _buildItem(index, listMessages[index]));
                      } else {
                        return _buildProgressIndicator();
                      }
                    },
                  ),
          );
        });
  }

  Widget _buildInput() {
    return Container(
      width: double.infinity,
      height: 50.0,
      decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: greyColor2, width: 0.5),
          ),
          color: Colors.white),
      child: Row(
        children: <Widget>[
          // Button send image
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(Icons.image),
                onPressed: () => pickImage(),
                color: primaryColor,
              ),
            ),
            color: Colors.white,
          ),
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(Icons.face),
                onPressed: () => pickSticker(),
                color: primaryColor,
              ),
            ),
            color: Colors.white,
          ),

          // Edit text
          Flexible(
            child: Container(
              child: TextField(
                style: TextStyle(color: primaryColor, fontSize: 15.0),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: greyColor),
                ),
                focusNode: focusNode,
              ),
            ),
          ),

          // Button send message
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 8.0),
              child: new IconButton(
                icon: new Icon(Icons.send),
                onPressed: () => _onSendMessage(textEditingController.text, 0),
                color: primaryColor,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Future pickImage() async {
    ImagePicker.pickImage(source: ImageSource.gallery).then((value) {
      if (value != null) {
        setState(() {
          imageFile = value;
          isLoading = true;
        });
        uploadFile();
      }
    });
  }

  void pickSticker() {
    // Hide keyboard when sticker appear
    focusNode.unfocus();
    setState(() => isShowSticker = !isShowSticker);
  }

  void uploadFile() {
    _chatBloc
        .uploadImage(file: imageFile)
        .then((value) {})
        .catchError((err) => Fluttertoast.showToast(msg: 'Error : $err'))
        .whenComplete(() => setState(() => isLoading = false));
  }

  void _onSendMessage(String content, int type) {
    // type: 0 = text, 1 = image, 2 = sticker
    if (content.trim() != '') {
      textEditingController.clear();
      try {
        _chatBloc.sendMessage(content: content, type: type);
      } catch (err) {
        Fluttertoast.showToast(msg: err.toString());
      }
      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(msg: 'Nothing to send');
    }
  }

  Widget _buildItem(int index, DocumentSnapshot document) {
    if (document['idFrom'] == _userId) {
      return _buildMyMessage(index, document);
    } else {
      return _buildFriendsMessage(index, document);
    }
  }

  Widget _buildMyMessage(int index, DocumentSnapshot document) {
    return Row(
      children: <Widget>[
        document['type'] == 0
            // Text
            ? Container(
                child: Text(
                  document['content'],
                  style: TextStyle(color: primaryColor),
                ),
                padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                width: 200.0,
                decoration: BoxDecoration(
                    color: greyColor2,
                    borderRadius: BorderRadius.circular(8.0)),
                margin: EdgeInsets.only(
                    bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                    right: 10.0),
              )
            : document['type'] == 1
                // Image
                ? Container(
                    child: FlatButton(
                      child: Material(
                        child: CachedNetworkImage(
                          placeholder: (context, url) => Container(
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(themeColor),
                            ),
                            width: 200.0,
                            height: 200.0,
                            padding: EdgeInsets.all(70.0),
                            decoration: BoxDecoration(
                              color: greyColor2,
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Material(
                            child: Image.asset(
                              'images/img_not_available.jpeg',
                              width: 200.0,
                              height: 200.0,
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(8.0),
                            ),
                            clipBehavior: Clip.hardEdge,
                          ),
                          imageUrl: document['content'],
                          width: 200.0,
                          height: 200.0,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        clipBehavior: Clip.hardEdge,
                      ),
                      onPressed: () => Navigator.pushNamed(
                          context, FullImageScreen.routeName,
                          arguments: {'url': document['content']}),
                      padding: EdgeInsets.all(0),
                    ),
                    margin: EdgeInsets.only(
                        bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                        right: 10.0),
                  )
                // Sticker
                : Container(
                    child: new Image.asset(
                      'images/${document['content']}.gif',
                      width: 100.0,
                      height: 100.0,
                      fit: BoxFit.cover,
                    ),
                    margin: EdgeInsets.only(
                        bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                        right: 10.0),
                  ),
      ],
      mainAxisAlignment: MainAxisAlignment.end,
    );
  }

  Widget _buildFriendsMessage(int index, DocumentSnapshot document) {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              isLastMessageLeft(index)
                  ? Material(
                      child: CachedNetworkImage(
                        placeholder: (context, url) => Container(
                          child: CircularProgressIndicator(
                            strokeWidth: 1.0,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(themeColor),
                          ),
                          width: 35.0,
                          height: 35.0,
                          padding: EdgeInsets.all(10.0),
                        ),
                        imageUrl: widget.avatar,
                        width: 35.0,
                        height: 35.0,
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(18.0),
                      ),
                      clipBehavior: Clip.hardEdge,
                    )
                  : Container(width: 35.0),
              document['type'] == 0
                  ? Container(
                      child: Text(
                        document['content'],
                        style: TextStyle(color: Colors.white),
                      ),
                      padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                      width: 200.0,
                      decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(8.0)),
                      margin: EdgeInsets.only(left: 10.0),
                    )
                  : document['type'] == 1
                      ? Container(
                          child: FlatButton(
                            child: Material(
                              child: CachedNetworkImage(
                                placeholder: (context, url) => Container(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        themeColor),
                                  ),
                                  width: 200.0,
                                  height: 200.0,
                                  padding: EdgeInsets.all(70.0),
                                  decoration: BoxDecoration(
                                    color: greyColor2,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Material(
                                  child: Image.asset(
                                    'images/img_not_available.jpeg',
                                    width: 200.0,
                                    height: 200.0,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                ),
                                imageUrl: document['content'],
                                width: 200.0,
                                height: 200.0,
                                fit: BoxFit.cover,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                              clipBehavior: Clip.hardEdge,
                            ),
                            onPressed: () => Navigator.pushNamed(
                                context, FullImageScreen.routeName,
                                arguments: {'url': document['content']}),
                            padding: EdgeInsets.all(0),
                          ),
                          margin: EdgeInsets.only(left: 10.0),
                        )
                      : Container(
                          child: new Image.asset(
                            'images/${document['content']}.gif',
                            width: 100.0,
                            height: 100.0,
                            fit: BoxFit.cover,
                          ),
                          margin: EdgeInsets.only(
                              bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                              right: 10.0),
                        ),
            ],
          ),

          // Time
          isLastMessageLeft(index)
              ? Container(
                  child: Text(
                    DateFormat('dd MMM kk:mm').format(
                        DateTime.fromMillisecondsSinceEpoch(
                            int.parse(document['timestamp']))),
                    style: TextStyle(
                        color: greyColor,
                        fontSize: 12.0,
                        fontStyle: FontStyle.italic),
                  ),
                  margin: EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
                )
              : Container()
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
      margin: EdgeInsets.only(bottom: 10.0),
    );
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessages != null &&
            listMessages[index - 1]['idFrom'] != _userId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessages != null &&
            listMessages[index - 1]['idFrom'] == _userId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Widget _buildLoading() {
    return Positioned(
      child: isLoading
          ? Container(
              child: Container(
                child: _buildProgressIndicator(),
                color: Colors.white.withOpacity(0.8),
              ),
            )
          : Container(),
    );
  }

  Widget _buildProgressIndicator() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(themeColor),
      ),
    );
  }

  Future<bool> onBackPress() {
    return Future<bool>.value(true);
  }
}
