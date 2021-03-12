import 'package:cydrive/views/file_view.dart';
import 'package:flutter/material.dart';

class FolderView extends StatefulWidget {
  @override
  _FolderViewState createState() => _FolderViewState();
}

class _FolderViewState extends State<FolderView> {
  List<FileView> fileInfoList = [];

  @override
  Widget build(BuildContext context) {
    for (var i = 0; i < 100; i++) {
      fileInfoList.add(FileView());
    }
    return Container(
        alignment: Alignment.center,
        child: ListView(
          children: fileInfoList,
        ));
  }
}
