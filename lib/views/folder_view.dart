import 'dart:math';

import 'package:cydrive/models/file.dart';
import 'package:flutter/material.dart';

class FolderView extends StatefulWidget {
  final List<FileInfo> fileInfoList;

  FolderView(this.fileInfoList);

  @override
  _FolderViewState createState() => _FolderViewState();
}

class _FolderViewState extends State<FolderView> {

  @override
  Widget build(BuildContext context) {
    // for (var i = 0; i < 100; i++) {
    //   widget.fileInfoList.add(FileInfo());
    //   widget.fileInfoList.last.size = Random().nextInt(1 << 30);
    //   widget.fileInfoList.last.filename = 'file_' + i.toString();
    // }

    return ListView.builder(
      itemBuilder: _buildFileItem,
      itemCount: widget.fileInfoList.length,
    );
  }

  Widget _buildFileItem(BuildContext context, int index) {
    return ListTile(
      leading: Icon(Icons.file_copy_sharp),
      title: Text(widget.fileInfoList[index].filename),
      trailing: _buildSizeText(widget.fileInfoList[index].size),
    );
  }

  Widget _buildSizeText(int size) {
    const units = ["B", "KiB", "MiB", "GiB"];
    int unitIndex = 0;
    while (unitIndex + 1 < units.length && size >= 1024) {
      size >>= 10;
      unitIndex++;
    }

    return Text(size.toString() + ' ' + units[unitIndex]);
  }
}
