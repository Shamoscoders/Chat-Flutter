import 'package:ChatFlutter/constant/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:photo_view/photo_view.dart';

class FullImageScreen extends StatefulWidget {
  static const routeName = 'fullimage';

  final String url;

  FullImageScreen({Key key, @required this.url}) : super(key: key);

  @override
  State createState() => new FullImageScreenState(url: url);
}

class FullImageScreenState extends State<FullImageScreen> {
  final String url;

  FullImageScreenState({Key key, @required this.url});

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(
          children: <Widget>[
            PhotoView(
              imageProvider: NetworkImage(url),
            ),
            Positioned(top: 0, left: 0, child: _buildAppBar()),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 20,
        ),
        IconButton(
          icon: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Icon(Icons.arrow_back),
          ),
          onPressed: () => Navigator.pop(context),
        )
      ],
    );
  }
}
