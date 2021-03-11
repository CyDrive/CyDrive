import 'package:flutter/cupertino.dart';

class FolderView extends StatefulWidget {
  @override
  _FolderViewState createState() => _FolderViewState();
}

class _FolderViewState extends State<FolderView> {
  int _times = 0;
  @override
  Widget build(BuildContext context) {
    var res = Text('This is folder view, times=' + _times.toString());
    _times++;
    return res;
  }
}
