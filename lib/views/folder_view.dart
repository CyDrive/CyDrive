import 'dart:html';
import 'dart:math';

import 'package:flutter/cupertino.dart';

class FolderView extends StatefulWidget {
  @override
  _FolderViewState createState() => _FolderViewState();
}

class _FolderViewState extends State<FolderView> {
  int _times = Random().nextInt(100);
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Text('This is folder view, times=' + _times.toString()),
    );
  }
}
