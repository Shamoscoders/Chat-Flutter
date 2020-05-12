import 'dart:io';

import 'package:ChatFlutter/widgets/full_image_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../constant/style.dart';

class ChatImage extends StatelessWidget {
  final String imageUrl;
  final bool isOffline;
  final File file;

  const ChatImage(
      {Key key,
      @required this.context,
      @required this.imageUrl,
      @required this.isOffline,
      this.file})
      : super(key: key);

  final BuildContext context;
  final imageSize = 200.0;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Material(
        child: file != null
            ? Container(
                height: imageSize,
                width: imageSize,
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: Image.file(
                        file,
                        width: imageSize,
                        height: imageSize,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: isOffline
                          ? Icon(
                              Icons.check,
                              color: magentaColor,
                              size: 15,
                            )
                          : Container(),
                    )
                  ],
                ),
              )
            : CachedNetworkImage(
                placeholder: (context, url) => Container(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                  ),
                  width: imageSize,
                  height:imageSize,
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
                    'assets/image_not_found.png',
                    width: imageSize,
                    height: imageSize,
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(8.0),
                  ),
                  clipBehavior: Clip.hardEdge,
                ),
                imageUrl: imageUrl,
                width: imageSize,
                height: imageSize,
                fit: BoxFit.cover,
              ),
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        clipBehavior: Clip.hardEdge,
      ),
      onPressed: () => Navigator.pushNamed(context, FullImageScreen.routeName,
          arguments: {'url': imageUrl}),
      padding: EdgeInsets.all(0),
    );
  }
}
