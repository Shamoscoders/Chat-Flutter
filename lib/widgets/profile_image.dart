import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../constant/style.dart';

class ProfileImage extends StatelessWidget {
  const ProfileImage({
    Key key,
    @required this.imageUrl,
    this.imageSize = 35.0,
  }) : super(key: key);

  final String imageUrl;
  final double imageSize;

  @override
  Widget build(BuildContext context) {
    return imageUrl != null
        ? Material(
            child: CachedNetworkImage(
              placeholder: (context, url) => Container(
                child: CircularProgressIndicator(
                  strokeWidth: 1.0,
                  valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                ),
                width: imageSize,
                height: imageSize,
                padding: EdgeInsets.all(10.0),
              ),
              imageUrl: imageUrl,
              width: imageSize,
              height: imageSize,
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(18.0),
            ),
            clipBehavior: Clip.hardEdge,
          )
        : Icon(
            Icons.account_circle,
            size: 50.0,
            color: greyColor,
          );
  }
}
