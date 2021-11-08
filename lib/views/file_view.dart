import 'dart:math';

import 'package:cydrive/models/file.dart';
import 'package:cydrive_sdk/models/file_info.pb.dart';
import 'package:flutter/material.dart';

class FileView extends StatefulWidget {
  @override
  _FileViewState createState() => _FileViewState();
}

class _FileViewState extends State<FileView> {
  FileInfo fileInfo = FileInfo();

  @override
  Widget build(BuildContext context) {
    fileInfo.filePath = Random().nextInt(100).toString();
    return Row(
      children: [
        Spacer(
          flex: 1,
        ),
        Icon(
          Icons.file_copy_sharp,
          size: 80,
        ),
        Text(
          fileInfo.filePath,
          textScaleFactor: 2.5,
        ),
        Spacer(
          flex: 10,
        )
      ],
    );
  }
}
