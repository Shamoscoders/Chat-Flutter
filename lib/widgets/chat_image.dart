
import 'package:ChatFlutter/widgets/full_image_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../constant/style.dart';

class ChatImage extends StatelessWidget {

  final String imageUrl;

  const ChatImage({
    Key key,
    @required this.context, @required this.imageUrl
  }) : super(key: key);

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
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
          imageUrl: imageUrl,
          width: 200.0,
          height: 200.0,
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        clipBehavior: Clip.hardEdge,
      ),
      onPressed: () => Navigator.pushNamed(
          context, FullImageScreen.routeName,
          arguments: {'url': imageUrl}),
      padding: EdgeInsets.all(0),
    );
  }
}